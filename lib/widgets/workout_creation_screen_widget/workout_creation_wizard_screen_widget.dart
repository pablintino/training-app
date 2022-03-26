import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:training_app/widgets/two_letters_icon/two_letters_icon.dart';

class TestStepper extends StatelessWidget {
  const TestStepper({Key? key}) : super(key: key);

  static const String _title = 'Workout title';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(_title)),
      body: Widget2(),
    );
  }
}

class Widget2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Widget2State();
}

class _Widget2State extends State<Widget2> with SingleTickerProviderStateMixin {
  TabController? controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: false,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    child: TextFormField(
                      enabled: false,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Workout name',
                      ),
                      initialValue: 'Workout name',
                      style: TextStyle(fontSize: 25.0),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    child: TextFormField(
                      enabled: false,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Workout description',
                      ),
                      initialValue:
                          'Dummy description',
                      style: TextStyle(fontSize: 15.0),
                      maxLines: 3,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize:
                  Size(double.infinity, MediaQuery.of(context).size.height / 6),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Container(
                      alignment: AlignmentDirectional.topStart,
                      child: Text(
                        'Sessions',
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
                  ],
                ),
              ),
            ),
          )
        ];
      },
      body: Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: ListView.builder(
            itemBuilder: (_, idx) => TestCardWidget(idx),
            itemCount: 8,
          )),
    );
  }
}

class TestCardWidget extends StatefulWidget {
  final int itemNumber;

  const TestCardWidget(this.itemNumber, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TestCardState(itemNumber);
}

class _TestCardState extends State<TestCardWidget> {

  final int itemNumber;

  final List<int> _items = List<int>.generate(5, (int index) => index);
  final GlobalKey<ExpansionTileCardState> cardA = new GlobalKey();

  _TestCardState(this.itemNumber);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    );
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ExpansionTileCard(
        key: cardA,
        leading: TwoLettersIcon('$itemNumber'),
        initialElevation: 5.0,
        elevation: 5.0,
        title: Text('Week 1'),
        //subtitle: Text('I expand, too!'),
        children: <Widget>[
          Divider(
            thickness: 1.0,
            height: 1.0,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: _buildList(context),
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceAround,
            buttonHeight: 52.0,
            buttonMinWidth: 90.0,
            children: <Widget>[
              TextButton(
                style: flatButtonStyle,
                onPressed: () {
                  cardA.currentState?.collapse();
                },
                child: Column(
                  children: <Widget>[
                    Icon(Icons.delete, color: Colors.red),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                    ),
                    Text(
                      'Close',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              TextButton(
                style: flatButtonStyle,
                onPressed: () {
                  cardA.currentState?.toggleExpansion();
                },
                child: Column(
                  children: <Widget>[
                    Icon(Icons.add),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                    ),
                    Text('Add'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext buildContext) {
    return ReorderableListView.builder(
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final int item = _items.removeAt(oldIndex);
          _items.insert(newIndex, item);
        });
      },
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
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
      itemCount: 5,
    );
  }
}
