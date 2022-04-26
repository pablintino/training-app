// Taken from the deprecated https://github.com/dart-archive/isolate

import 'dart:async';

import 'dart:isolate';

/// Creates a [Future], and a [SendPort] that can be used to complete that
/// future.
///
/// Calls [action] with the response `SendPort`, then waits for someone
/// to send a value on that port
/// The returned `Future` is completed with the value sent on the port.
///
/// If [action] throws, which it shouldn't,
/// the returned future is completed with that error.
/// Any return value of `action` is ignored, and if it is asynchronous,
/// it should handle its own errors.
///
/// If [timeout] is supplied, it is used as a limit on how
/// long it can take before the message is received. If a
/// message isn't received in time, the [timeoutValue] used
/// as the returned future's value instead.
/// If the result type, [R], does not allow `null`, and [timeout] is provided,
/// then [timeoutValue] must also be non-`null`.
/// Use [singleResponseFutureWithTimeout] instead of providing
/// the optional parameters to this function. It prevents getting run-time
/// errors from providing a [timeout] and no [timeoutValue] with a non-nullable
/// result type.
///
/// If you need a timeout on the operation, it's recommended to specify
/// a timeout using [singleResponseFutureWithTimeout],
/// and not use [Future.timeout] on the returned `Future`.
/// The `Future` method won't be able to close the underlying [ReceivePort],
/// and will keep waiting for the first response anyway.
Future<R> singleResponseFuture<R>(
  void Function(SendPort responsePort) action, {
  @Deprecated("Use singleResponseFutureWithTimeout instead") Duration? timeout,
  @Deprecated("Use singleResponseFutureWithTimeout instead") R? timeoutValue,
}) {
  if (timeout == null) {
    return _singleResponseFuture<R>(action);
  }
  if (timeoutValue is! R) {
    throw ArgumentError.value(
        null, "timeoutValue", "The result type is non-null");
  }
  return singleResponseFutureWithTimeout(action, timeout, timeoutValue);
}

/// Same as [singleResponseFuture], but with required [timeoutValue],
/// this allows us not to require a nullable return value
Future<R> singleResponseFutureWithTimeout<R>(
    void Function(SendPort responsePort) action,
    Duration timeout,
    R timeoutValue) {
  var completer = Completer<R>.sync();
  var responsePort = RawReceivePort();
  var timer = Timer(timeout, () {
    responsePort.close();
    completer.complete(timeoutValue);
  });
  var zone = Zone.current;
  responsePort.handler = (response) {
    responsePort.close();
    timer.cancel();
    zone.run(() {
      _castComplete<R>(completer, response);
    });
  };
  try {
    action(responsePort.sendPort);
  } catch (error, stack) {
    responsePort.close();
    timer.cancel();
    // Delay completion because completer is sync.
    scheduleMicrotask(() {
      completer.completeError(error, stack);
    });
  }
  return completer.future;
}

/// Helper function for [singleResponseFuture].
///
/// Use this as the implementation of [singleResponseFuture]
/// when removing the deprecated parameters.
Future<R> _singleResponseFuture<R>(
    void Function(SendPort responsePort) action) {
  var completer = Completer<R>.sync();
  var responsePort = RawReceivePort();
  var zone = Zone.current;
  responsePort.handler = (response) {
    responsePort.close();
    zone.run(() {
      _castComplete<R>(completer, response);
    });
  };
  try {
    action(responsePort.sendPort);
  } catch (error, stack) {
    responsePort.close();
    // Delay completion because completer is sync.
    scheduleMicrotask(() {
      completer.completeError(error, stack);
    });
  }
  return completer.future;
}

// Helper function that casts an object to a type and completes a
// corresponding completer, or completes with the error if the cast fails.
void _castComplete<R>(Completer<R> completer, Object value) {
  try {
    completer.complete(value as R);
  } catch (error, stack) {
    completer.completeError(error, stack);
  }
}
