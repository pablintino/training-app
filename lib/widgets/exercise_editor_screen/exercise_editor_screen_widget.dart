import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/models/exercises_models.dart';
import 'package:training_app/utils/form_utils.dart';
import 'package:training_app/widgets/exercise_editor_screen/bloc/exercise_manipulation_bloc.dart';
import 'package:training_app/widgets/exercise_screen/bloc/exercise_list_bloc.dart';

class ExerciseEditorScreenWidget extends StatefulWidget {
  final ExerciseListBloc _exerciseListBloc;
  final Exercise? initialExercise;

  ExerciseEditorScreenWidget(this._exerciseListBloc, {this.initialExercise});

  @override
  _ExerciseEditorScreenWidgetState createState() =>
      _ExerciseEditorScreenWidgetState(_exerciseListBloc, initialExercise);
}

class _ExerciseEditorScreenWidgetState
    extends State<ExerciseEditorScreenWidget> {
  final ExerciseManipulationBloc _exerciseManipulationBloc;

  _ExerciseEditorScreenWidgetState(
      ExerciseListBloc exerciseListBloc, Exercise? initialExercise)
      : _exerciseManipulationBloc = ExerciseManipulationBloc(exerciseListBloc) {
    if (initialExercise != null) {
      _exerciseManipulationBloc.add(InitializeUpdateEvent(initialExercise));
    }
  }

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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
            } else if (state is OnGoingExerciseManipulationState) {
              if (!state.exerciseName.dirty) {
                _nameController.text = state.exerciseName.value ?? '';
              }
              if (!state.exerciseDescription.dirty) {
                _descriptionController.text =
                    state.exerciseDescription.value ?? '';
              }
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

  String? _getNameValidationError(ExerciseManipulationState state) {
    ValidationError? validationError =
        state is OnGoingExerciseManipulationState && state.exerciseName.dirty
            ? state.exerciseName.status
            : null;
    return validationError == null
        ? null
        : (validationError == ValidationError.empty
            ? 'Exercise name cannot be empty'
            : 'Exercise name already exists');
  }

  Widget _buildNameTextField(ExerciseManipulationState state) {
    return TextFormField(
      controller: _nameController,
      onChanged: (value) =>
          _exerciseManipulationBloc.add(NameInputUpdateEvent(value)),
      focusNode: _nameFocusNode,
      onFieldSubmitted: (_) =>
          FocusScope.of(context).requestFocus(_descriptionFocusNode),
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          hintText: 'Name',
          labelText: 'Exercise name',
          errorText: _getNameValidationError(state)),
    );
  }

  String? _getDescriptionValidationError(ExerciseManipulationState state) {
    ValidationError? validationError =
        state is OnGoingExerciseManipulationState &&
                state.exerciseDescription.dirty
            ? state.exerciseDescription.status
            : null;
    return validationError != null && validationError == ValidationError.empty
        ? 'Exercise description cannot be empty'
        : null;
  }

  Widget _buildDescriptionTextField(ExerciseManipulationState state) {
    return TextFormField(
      controller: _descriptionController,
      onChanged: (value) =>
          _exerciseManipulationBloc.add(DescriptionInputUpdateEvent(value)),
      onFieldSubmitted: (String value) {
        _exerciseManipulationBloc.add(SubmitExerciseEvent());
      },
      maxLines: null,
      focusNode: _descriptionFocusNode,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          hintText: 'Description',
          labelText: 'Exercise description',
          errorText: _getDescriptionValidationError(state)),
    );
  }

  @override
  void dispose() {
    _exerciseManipulationBloc.close();
    super.dispose();
  }
}
