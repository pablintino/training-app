import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:training_app/widgets/time_picker.dart';

class WorkoutItemEditorWidget extends StatelessWidget {
  final List<int> _items = List<int>.generate(25, (int index) => index);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: ListView(children: [
          _buildTextFormField('Name', 'Item name'),
          _buildTextFormField('Modality', 'Item modality'),
          _buildTextFormFieldNumeric('Rounds', 'Total number of rounds'),
          _buildTimeSelectionField(context, 'Timecap'),
          _buildTimeSelectionField(context, 'Rest time'),
          _buildTimeSelectionField(context, 'Work time'),
          ..._buildSectionDivider(context, 'Sets'),
          _buildList(context)
        ],),
      ),
    );
  }

  TextFormField _buildTextFormField(String label, String hint) {
    return TextFormField(
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          hintText: hint,
          labelText: label,
        ));
  }

  TextFormField _buildTextFormFieldNumeric(String label, String hint) {
    return TextFormField(
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: hint,
          labelText: label,
        ));
  }

  List<Widget> _buildSectionDivider(BuildContext context, String tittle) {
    return [
      Container(
        alignment: AlignmentDirectional.topStart,
        padding: EdgeInsets.only(top: 25),
        child: Text(
          tittle,
          style: TextStyle(fontSize: 18.0),
          textAlign: TextAlign.left,
        ),
      ),
      Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width - 50,
            child: Divider(
              thickness: 1,
              color: Colors.blue.withOpacity(0.5),
            ),
          ),
          Expanded(child: Container())
        ],
      )
    ];
  }

  TextFormField _buildTimeSelectionField(BuildContext context, String label) {
    return TextFormField(
      decoration: InputDecoration(
          labelText: label,
          suffixIcon: IconButton(
              icon: Icon(Icons.timer),
              onPressed: () async {
                DateTime? test = await showCustomHourPicker(context,
                    title: 'Pick ${label.toLowerCase()}');
                print(test);
              })),

      // Note: This 2 props makes this seem disabled
      enableInteractiveSelection: false,
      // will disable paste operation
      focusNode: new AlwaysDisabledFocusNode(),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }
  Widget _buildList(BuildContext buildContext) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      onReorder: (int oldIndex, int newIndex) {

      },
      scrollDirection: Axis.vertical,
      //shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          key: Key('$index'),
          padding: EdgeInsets.symmetric(vertical: 0),
          child: Card(
            //shape: RoundedRectangleBorder(
            //  borderRadius: BorderRadius.circular(5),
            //side: BorderSide(
            //color: Colors.black,
            //),
            //),
            elevation: 2,
            //shadowColor: Colors.red,
            child: ListTile(
              //leading: const Icon(Icons.flight_land),
              title: Text(
                'Day $index',
                style: TextStyle(
                  fontSize: 15,
                  //COLOR DEL TEXTO TITULO
                  //color: Colors.blueAccent,
                ),
              ),
              //subtitle: Text(
              //  'Sub Title',
              //),
              trailing: const Icon(Icons.drag_indicator),
            ),
          ),
        );
      },
      itemCount: 25,
    );
  }


}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
