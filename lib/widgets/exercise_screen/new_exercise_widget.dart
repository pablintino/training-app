import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/models/exercises_models.dart';
import 'package:training_app/widgets/exercise_screen/bloc/exercise_list_bloc.dart';

class NewExerciseScreenWidget extends StatefulWidget {
  final ExerciseListBloc exerciseListBloc;

  NewExerciseScreenWidget(this.exerciseListBloc);

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

  _submitForm() {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      final Exercise exercise = Exercise(
          name: _nameController.text, description: _descriptionController.text);
      widget.exerciseListBloc.add(CreateExerciseEvent(exercise));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Registration sent')));
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
          actions: [
            TextButton(
              onPressed: () {
                final Exercise exercise = Exercise(
                    name: _nameController.text,
                    description: _descriptionController.text);

                widget.exerciseListBloc.add(CreateExerciseEvent(exercise));
              },
              child: new Icon(
                Icons.save,
                color: Colors.white,
              ),
            )
          ],
        ),
        body: BlocListener<ExerciseListBloc, ExerciseListState>(
          bloc: widget.exerciseListBloc,
          listener: (ctx, state) {
            if (state is ExerciseCreationSuccessState) {
              Navigator.of(context).pop();
            } else if (state is ExerciseCreationErrorState) {
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

  Form _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          _buildFormTextField('Name', 'Exercise name', _nameFocusNode,
              _nameController, (_) => _nextFocus(_descriptionFocusNode)),
          _buildFormTextField(
              'Description',
              'Exercise description',
              _descriptionFocusNode,
              _descriptionController,
              (_) => _submitForm()),
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
