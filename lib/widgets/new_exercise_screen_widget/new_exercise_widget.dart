import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/models/exercises_models.dart';
import 'package:training_app/widgets/new_exercise_screen_widget/bloc/exercise_create_bloc.dart';

class NewExerciseScreenWidget extends StatefulWidget {
  @override
  _NewExerciseScreenWidgetState createState() =>
      _NewExerciseScreenWidgetState();
}

class _NewExerciseScreenWidgetState extends State<NewExerciseScreenWidget> {
  final _formKey = GlobalKey<FormState>();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ExerciseCreateBloc _exerciseCreateBloc = ExerciseCreateBloc();

  _submitForm() {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      final Exercise exercise = Exercise(
          name: _nameController.text, description: _descriptionController.text);

      print(exercise.toString());

      // If the form passes validation, display a Snackbar.
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Registration sent')));
      //_formKey.currentState.save();
      //_formKey.currentState.reset();
      //_nextFocus(_nameFocusNode);
    }
  }

  String? _validateInput(String? value) {
    if (value != null && value.trim().isEmpty) {
      return 'Field required';
    }
    return null;
  }

  _nextFocus(FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New exercise'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: BlocConsumer<ExerciseCreateBloc, ExerciseCreateState>(
              bloc: _exerciseCreateBloc,
              listener: (ctx, state) => {},
              builder: (ctx, state) => _buildForm(ctx),
            )),
      ),
    );
  }

  Form _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildFormTextField('Name', 'Exercise name', _nameFocusNode,
              _nameController, (_) => _nextFocus(_descriptionFocusNode)),
          _buildFormTextField(
              'Description',
              'Exercise description',
              _descriptionFocusNode,
              _descriptionController,
              (_) => _submitForm()),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 16,
                  ),
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Add'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  TextFormField _buildFormTextField(
      String name,
      String label,
      FocusNode focusNode,
      TextEditingController controller,
      ValueChanged<String> onSubmit) {
    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      validator: _validateInput,
      onFieldSubmitted: onSubmit,
      decoration: InputDecoration(
        hintText: name,
        labelText: label,
      ),
    );
  }
}
