import 'package:flutter/material.dart';

class CommonSectionSeparator extends StatelessWidget {
  final String title;

  const CommonSectionSeparator({Key? key, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        alignment: AlignmentDirectional.topStart,
        padding: EdgeInsets.only(top: 25),
        child: Text(
          title,
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
    ]);
  }
}
