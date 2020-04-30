import 'package:flutter/material.dart';
import '../database_helpers.dart';
import 'package:lottie/lottie.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map> entriesOverview;
  bool showEntryDetails = false;
  bool showTestCard = false;
  double _height = 0;

  @override
  void initState() {
    read();
    super.initState();
  }

  // read on datebase
  // read() async {
  //   DatabaseHelper helper = DatabaseHelper.instance;
  //   int rowId = 1;
  //   Entry entry = await helper.queryWord(rowId);
  //   if (entry == null) {
  //     print('read row $rowId: empty');
  //   } else {
  //     print('read row $rowId: ${entry.id} ${entry.date}');
  //   }
  // }

  // read on datebase
  void read() async {
    DatabaseHelper helper = DatabaseHelper.instance;

    List<Map> entries = await helper.queryAllRows();
    setState(() {
      entriesOverview = entries;
    });
  }

  // delete all entries
  void delete() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    helper.deleteAll();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        // appBar:
        // new AppBar(title: Text("home")),
        body: Stack(
          children: <Widget>[
            // test card
            testCard(),

            // header + body (listview)
            Column(
              children: <Widget>[
                Header(),
                overviewCard(),
                ListView(shrinkWrap: true, children: <Widget>[
                  entriesOverview == null || showTestCard == true
                      ? Text("")
                      : buildEntryList(),
                ]),
              ],
            )
          ],
        ),
        floatingActionButton: showTestCard == false
            ? new FloatingActionButton(
                backgroundColor: Color.fromRGBO(74, 0, 224, 60),
                //  Color.fromRGBO(142, 45, 226, 30),
                //       Color.fromRGBO(74, 0, 224, 60)
                onPressed: pushAddDailyScreen,
                tooltip: 'Add task',
                child: new Icon(Icons.add))
            : Text("")

        //     Container(
        //       child: Stack(
        //         children: <Widget>[
        //           Positioned.fill(
        //             child:
        //                 Align(alignment: Alignment.centerRight, child: Text("lul")),
        //           ),
        //         ],
        //       ),
        //     ),

        );
  }

  Widget Header() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 25, top: 60),
              child: Text('Überblick',
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.w300)),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: new Container(
                  margin: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.topRight,
                        colors: [
                          Color.fromRGBO(255, 65, 108, 30),
                          Color.fromRGBO(255, 75, 43, 70)
                        ]),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[500],
                        blurRadius: 20.0,
                        spreadRadius: 1.0,
                        offset: Offset(
                          4.0,
                          4.0,
                        ),
                      ),
                    ],
                    borderRadius: BorderRadius.all(
                        Radius.circular(12.5) //         <--- border radius here
                        ),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _height = 400;
                        showTestCard = !showTestCard;
                      });
                      print("open test card");
                    },
                    child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Testergebnis eintragen",
                                style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300)),
                            Lottie.asset(
                              'assets/test.json',
                              width: 75,
                              height: 75,
                            )
                          ],
                        )),
                  )),
            ),
          ],
        ),
      ],
    );
  }

  Widget testCard() {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: AnimatedContainer(
          child: GestureDetector(
            onHorizontalDragStart: (DragStartDetails details) {
              print("start");
              print(details);
            },
            onHorizontalDragUpdate: (DragUpdateDetails details) {
              print("update");
              print(details);
              setState(() {
                _height = details.delta.dy;
              });
            },
            onHorizontalDragEnd: (DragEndDetails details) {
              setState(() {
                showTestCard = false;
              });
            },
          ),
          duration: Duration(seconds: 1),
          height: _height,
          curve: Curves.fastOutSlowIn,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[400],
                  blurRadius: 20.0, // has the effect of softening the shadow
                  spreadRadius: 3.0, // has the effect of extending the shadow
                  offset: Offset(
                    0, // horizontal, move right 10
                    0, // vertical, move down 10
                  ),
                )
              ],
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        ));
  }

  Widget overviewCard() {
    int personsTotal = 0;
    int locationsTotal = 0;

    if (entriesOverview != null) {
      for (int i = 0; i < entriesOverview.length; i++) {
        personsTotal += entriesOverview[i]['persons'].split(" , ").length;
        locationsTotal += entriesOverview[i]['locations'].split(" , ").length;
      }
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: new Container(
              margin: const EdgeInsets.only(left: 20.0, right: 20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.topRight,
                    colors: [
                      Color.fromRGBO(142, 45, 226, 30),
                      Color.fromRGBO(74, 0, 224, 60)
                    ]),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[500],
                    blurRadius: 20.0,
                    spreadRadius: 1.0,
                    offset: Offset(
                      4.0,
                      4.0,
                    ),
                  ),
                ],
                borderRadius: BorderRadius.all(
                    Radius.circular(12.5) //         <--- border radius here
                    ),
              ),
              child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(Icons.people_outline,
                              color: Colors.white, size: 40),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(personsTotal.toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w300)),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Icon(Icons.location_on,
                              color: Colors.white, size: 40),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(locationsTotal.toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w300)),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Icon(Icons.tram, color: Colors.white, size: 40),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(locationsTotal.toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w300)),
                          ),
                        ],
                      ),
                    ],
                  ))),
        ),
      ],
    );
  }

  Widget buildEntryList() {
    return new ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index < entriesOverview.length) {
          return buildEntry(entriesOverview[index], index);
        }
      },
    );
  }

  // Build a single location item
  Widget buildEntry(Map entry, int index) {
    String persons = entry['persons'];
    var numberPersons = persons.split(" , ").length.toString();
    // print(numberPersons);

    String locations = entry['locations'];
    var numberLocations = locations.split(" , ").length.toString();

    String opnv = entry['opnv'];
    // print(opnv);

    return Stack(
      children: <Widget>[
        new Card(
          margin: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
          child: InkWell(
            onTap: () {
              setState(() {
                showEntryDetails = !showEntryDetails;
              });
            },
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Icon(Icons.date_range),
                          ),
                          Text(entry['date'].toString()),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 7.0),
                            child: Icon(Icons.people),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Text(numberPersons),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 7.0),
                            child: Icon(Icons.location_city),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Text(numberLocations),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 7.0),
                            child: Icon(Icons.tram),
                          ),
                          opnv == false
                              ? Icon(Icons.remove_circle)
                              : Icon(Icons.done)
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        // open details for a specific entry
        // showEntryDetails == true ? openCard(entry) : Text("salli"),
      ],
    );
  }

  Widget openCard() {
    print('open card');
    // print("personen " + entry['date'].toString());

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      top: 0,
      child: Container(
        color: Colors.pink,
        height: 275.0,
        child: Column(
          children: <Widget>[
            // Text(entry['date']),
            // Text("persons"),
            // Text(entry['persons']),
            // Text("locations"),
            // Text(entry['locations']),
          ],
        ),
      ),
    );
  }

  void pushAddDailyScreen() {
    // Navigator.pushNamed(context, '/addEntry', arguments: {'geoData': geoData});
    // print(geoData);

    Navigator.pushNamed(context, '/addEntry');
  }

  Widget homeTab() {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 50.0),
          child: new Text("test",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 35,
                  fontWeight: FontWeight.w200)),
        ),
        // Positioned(child: new Container(height: 100, width: 100, color: Colors.red,)),

        new Container(
            margin: const EdgeInsets.only(top: 30.0),
            height: 150,
            width: 200,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 20.0, // has the effect of softening the shadow
                  spreadRadius: 3.0, // has the effect of extending the shadow
                  offset: Offset(
                    0, // horizontal, move right 10
                    0, // vertical, move down 10
                  ),
                )
              ],
              color: Colors.white,
              borderRadius: BorderRadius.all(
                  Radius.circular(12.5) //         <--- border radius here
                  ),
            ),
            child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: new Container(
                  width: 30,
                  height: 75,
                  color: Colors.indigo,
                ))),

        RaisedButton(
          child: Text(
            "Get location",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          color: Colors.indigo,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          onPressed: read,
        ),

        Column(
          children: <Widget>[
            // entriesOverview == null ? Text("scheiseee") : Text(entriesOverview[0]['persons'])

            //  userLocation == null
            //       ? CircularProgressIndicator()
            //       : Text("Location:" +
            //           userLocation.latitude.toString() +
            //           " " +
            //           userLocation.longitude.toString()),

            RaisedButton(
              child: Text(
                "delete all items",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              color: Colors.indigo,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              onPressed: delete,
            ),
          ],
        )

        // FlatButton(child: Text("Get location"), onPressed: () => lol()),+
      ],
    );
  }
}
