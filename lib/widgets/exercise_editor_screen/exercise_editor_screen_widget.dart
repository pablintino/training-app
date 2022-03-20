import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/widgets/exercise_editor_screen/bloc/exercise_manipulation_bloc.dart';
import 'package:training_app/widgets/exercise_editor_screen/bloc/state_form_models.dart';
import 'package:training_app/widgets/exercise_screen/bloc/exercise_list_bloc.dart';

class ExerciseEditorScreenWidget extends StatefulWidget {
  final ExerciseListBloc _exerciseListBloc;

  ExerciseEditorScreenWidget(this._exerciseListBloc);

  @override
  _ExerciseEditorScreenWidgetState createState() =>
      _ExerciseEditorScreenWidgetState(_exerciseListBloc);
}

class _ExerciseEditorScreenWidgetState
    extends State<ExerciseEditorScreenWidget> {
  final ExerciseManipulationBloc _exerciseManipulationBloc;

  _ExerciseEditorScreenWidgetState(ExerciseListBloc exerciseListBloc)
      : _exerciseManipulationBloc = ExerciseManipulationBloc(exerciseListBloc);

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('New exercise'),
          actions: [
            TextButton(
              onPressed: () =>
                  _exerciseManipulationBloc.add(SubmitExerciseEvent()),
              child: new Icon(
                Icons.save,
                color: Colors.white,
              ),
            )
          ],
        ),
        body: BlocListener<ExerciseManipulationBloc, ExerciseManipulationState>(
          bloc: _exerciseManipulationBloc,
          listener: (ctx, state) {
            if (state is ExerciseManipulationFinishedState) {
              Navigator.of(context).pop();
            } else if (state is ExerciseManipulationErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.error),
                duration: Duration(seconds: 2),
              ));
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: _buildForm(context),
            ),
          ),
        ));
  }

  Widget _buildForm(BuildContext context) {
    return BlocBuilder<ExerciseManipulationBloc, ExerciseManipulationState>(
        bloc: _exerciseManipulationBloc,
        builder: (ctx, state) => Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  _buildNameTextField(state),
                  _buildDescriptionTextField(state),
                ],
              ),
            ));
  }

  Widget _buildNameTextField(ExerciseManipulationState state) {
    ExerciseNameInputError? validationError =
        state is OnGoingExerciseManipulationState &&
                state.exerciseNameField.dirty
            ? state.exerciseNameField.status
            : null;
    final String? errorText = validationError == null
        ? null
        : (validationError == ExerciseNameInputError.empty
            ? 'Exercise name cannot be empty'
            : 'Exercise name already exists');
    return TextFormField(
      onChanged: (value) =>
          _exerciseManipulationBloc.add(NameInputUpdateEvent(value)),
      focusNode: _nameFocusNode,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          hintText: 'Name', labelText: 'Exercise name', errorText: errorText),
    );
  }

  Widget _buildDescriptionTextField(ExerciseManipulationState state) {
    ExerciseDescriptionInputError? validationError =
        state is OnGoingExerciseManipulationState &&
                state.exerciseDescriptionField.dirty
            ? state.exerciseDescriptionField.status
            : null;
    final String? errorText = validationError != null &&
            validationError == ExerciseDescriptionInputError.empty
        ? 'Exercise description cannot be empty'
        : null;
    return TextFormField(
      onChanged: (value) =>
          _exerciseManipulationBloc.add(DescriptionInputUpdateEvent(value)),
      focusNode: _descriptionFocusNode,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          hintText: 'Description',
          labelText: 'Exercise description',
          errorText: errorText),
    );
  }

  @override
  void dispose() {
    _exerciseManipulationBloc.close();
    super.dispose();
  }
}
