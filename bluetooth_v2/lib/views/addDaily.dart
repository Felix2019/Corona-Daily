import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';


import '../components/geolocation.dart';
import '../components/geo.dart';

import '../database_helpers.dart';

class Daily extends StatefulWidget {
  List<Place> places;
  Daily({Key key, @required this.places}) : super(key: key);

  @override
  AddEntry createState() => AddEntry(places);
}

class AddEntry extends State<Daily> {
  List<Place> places;
  AddEntry(this.places);

  String currentDate;
  List<String> persons = [];
  List<String> locations = [];
  String opnv = "false";
  bool opnvCheckbox = false;

  @override
  void initState() {
    for (var i = 0; i < places.length; i++) {
      setState(() {
        locations.add(places[i].title);
        print(locations);
      });
    }

    getDate();
    super.initState();
  }

  // get current date
  void getDate() {
    setState(() {
      DateTime date = DateTime.now();
      currentDate = DateFormat('dd.M.yyyy').format(date);
    });
  }

  void addPerson(value) {
    setState(() {
      if (value != null) {
        setState(() {
          persons.add(value);
          print("persons: " + persons.toString());
        });
      }
    });
  }

  void addLocation(value) {
    setState(() {
      if (value != null) {
        setState(() {
          locations.add(value);
          print("manuelle orte: " + locations.toString());
          print("call function add location " + locations.length.toString());
        });
      }
    });
  }

  void removePerson(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text('"${persons[index]}" entfernen?'),
              actions: <Widget>[
                new FlatButton(
                    child: new Text('Zurück'),
                    onPressed: () => Navigator.of(context).pop()),
                new FlatButton(
                    child: new Text('Entfernen'),
                    onPressed: () {
                      setState(() {
                        persons.removeAt(index);
                      });

                      Navigator.of(context).pop();
                    })
              ]);
        });
  }

  void removeLocation(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text('"${locations[index]}" entfernen?'),
              actions: <Widget>[
                new FlatButton(
                    child: new Text('Zurück'),
                    onPressed: () => Navigator.of(context).pop()),
                new FlatButton(
                    child: new Text('Entfernen'),
                    onPressed: () {
                      setState(() {
                        locations.removeAt(index);
                      });
                      Navigator.of(context).pop();
                    })
              ]);
        });
  }

  Widget buildPersonsList() {
    return new ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index < persons.length) {
          return buildPersonItem(persons[index], index);
        }
      },
    );
  }

  // Build a single person item
  Widget buildPersonItem(String person, int index) {
    // return new ListTile(title: new Text(person));
    return new Card(
      margin: const EdgeInsets.all(15.0),
      child: ListTile(
        leading: Icon(Icons.person),
        title: Text(persons[index]),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline),
          tooltip: 'Person entfernen',
          onPressed: () => removePerson(index),
        ),
      ),
    );
  }

  Widget buildLocationsList() {
    return new ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index < locations.length) {
          return buildLocationItem(locations[index], index);
        }
      },
    );
  }

  // Build a single location item
  Widget buildLocationItem(String location, int index) {
    return new Card(
      margin: const EdgeInsets.all(15.0),
      child: ListTile(
        leading: Icon(Icons.location_on),
        title: Text(locations[index]),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline),
          tooltip: 'Person entfernen',
          onPressed: () => removeLocation(index),
        ),
      ),
    );
  }

  checkBoxControl(bool value) {
    setState(() {
      opnvCheckbox = value;
      if (opnvCheckbox == true) {
        opnv = "genutzt";
      } else {
        opnv = "nicht genutzt";
      }
    });
  }

  // save daily entry in database
  save() async {
    String numberPersons = persons[0].toString();
    for (int i = 1; i < persons.length; i++) {
      numberPersons += " , " + persons[i].toString();
    }
    print(numberPersons);

    String numberLocations = locations[0].toString();
    for (int i = 1; i < locations.length; i++) {
      numberLocations = " , " + locations[i].toString();
    }
    print(numberLocations);

    Entry entry = new Entry();
    entry.date = currentDate;
    entry.persons = numberPersons;
    entry.locations = numberLocations;
    entry.opnv = opnv;

    DatabaseHelper helper = DatabaseHelper.instance;
    int id = await helper.insert(entry);
    print('inserted row: $id');
    print(entry.date +
        ", " +
        entry.persons +
        ", " +
        entry.locations +
        ", " +
        entry.opnv);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // geoTracking = ModalRoute.of(context).settings.arguments;
    // print(geoTracking['geoData'][0].title);

    return new Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: new Text("Eintrag anlegen"),
        backgroundColor: Colors.indigo,
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 30),
                    child: Text('Heute, $currentDate',
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                            fontWeight: FontWeight.w300)),
                  ),
                  // Icon(Icons.poll)
                ],
              ),

              Card(
                margin: const EdgeInsets.all(15.0),
                child: ExpansionTile(
                  leading: Icon(Icons.person_add),
                  title: Text('Kontaktverfolgung'),
                  trailing: Icon(Icons.arrow_drop_down),
                  children: <Widget>[
                    Container(
                      width: 300,
                      margin: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: new TextField(
                        onSubmitted: (val) {
                          addPerson(val);
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Personen hinzufügen',
                        ),
                      ),
                    ),
                    buildPersonsList()
                  ],
                ),
              ),

              // FlatButton(
              //     child: Text("Get location"),
              //     onPressed: () {
              //       print("sal");
              //     }),

              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 30),
                    child: Text('Orte',
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                            fontWeight: FontWeight.w300)),
                  ),
                  // Icon(Icons.poll)
                ],
              ),

              Container(
                  margin: const EdgeInsets.all(15.0),
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius:
                            20.0, // has the effect of softening the shadow
                        spreadRadius:
                            3.0, // has the effect of extending the shadow
                        offset: Offset(
                          0, // horizontal, move right 10
                          0, // vertical, move down 10
                        ),
                      )
                    ],
                    borderRadius: BorderRadius.all(
                        Radius.circular(12.5) //         <--- border radius here
                        ),
                  ),
                  child: Flex(
                    direction: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Unterwegs mit ÖPNV?",
                          style: TextStyle(color: Colors.white, fontSize: 17),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Checkbox(
                            value: opnvCheckbox,
                            onChanged: checkBoxControl,
                            activeColor: Colors.white10,
                            hoverColor: Colors.redAccent,
                          )),
                    ],
                  )),

              Card(
                margin: const EdgeInsets.all(15.0),
                child: ExpansionTile(
                  leading: Icon(Icons.location_on),
                  title: Text('Besuchte Orte'),
                  // subtitle: Text('Kontaktverfolgung'),
                  trailing: Icon(Icons.arrow_drop_down),
                  children: <Widget>[
                    Container(
                      width: 300,
                      margin: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: new TextField(
                        onSubmitted: (val) {
                          addLocation(val);
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Orte hinzufügen',
                        ),
                      ),
                    ),
                    buildLocationsList()
                  ],
                ),
              ),

              // daily total statistics
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                        margin: const EdgeInsets.all(15.0),
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.topRight,
                              colors: [Colors.indigo, Colors.indigo[400]]),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[600],
                              blurRadius:
                                  20.0, // has the effect of softening the shadow
                              spreadRadius:
                                  1.0, // has the effect of extending the shadow
                              offset: Offset(
                                4.0, // horizontal, move right 10
                                4.0, // vertical, move down 10
                              ),
                            ),
                            // BoxShadow(
                            //   color: Colors.white,
                            //   blurRadius: 20.0,
                            //   spreadRadius: 1.0,
                            //   offset: Offset(
                            //     -4.0,
                            //     -4.0,
                            //   ),
                            // )
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(
                                  12.5) //         <--- border radius here
                              ),
                        ),
                        // row with 3 child container
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                children: <Widget>[
                                  // heading
                                  Text(
                                    "Tagesübersicht",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                //  number of people you met today
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        blurRadius:
                                            20.0, // has the effect of softening the shadow
                                        spreadRadius:
                                            3.0, // has the effect of extending the shadow
                                        offset: Offset(
                                          0, // horizontal, move right 10
                                          0, // vertical, move down 10
                                        ),
                                      )
                                    ],
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            12.5) //         <--- border radius here
                                        ),
                                  ),
                                  // margin: EdgeInsets.all(25.0),
                                  child: Column(children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Icon(Icons.people_outline,
                                              color: Colors.indigo, size: 40),
                                          Text(persons.length.toString(),
                                              style: TextStyle(
                                                  color: Colors.indigo,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w300)),
                                        ],
                                      ),
                                    ),
                                  ]),
                                ),

                                //  number of locations you visited today
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        blurRadius:
                                            20.0, // has the effect of softening the shadow
                                        spreadRadius:
                                            3.0, // has the effect of extending the shadow
                                        offset: Offset(
                                          0, // horizontal, move right 10
                                          0, // vertical, move down 10
                                        ),
                                      )
                                    ],
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            12.5) //         <--- border radius here
                                        ),
                                  ),
                                  // margin: EdgeInsets.all(25.0),
                                  child: Column(children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Icon(Icons.location_on,
                                              color: Colors.indigo, size: 40),
                                          Text(locations.length.toString(),
                                              style: TextStyle(
                                                  color: Colors.indigo,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w300)),
                                        ],
                                      ),
                                    ),
                                  ]),
                                ),

                                //  show whether user has used öpnv
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        blurRadius:
                                            20.0, // has the effect of softening the shadow
                                        spreadRadius:
                                            3.0, // has the effect of extending the shadow
                                        offset: Offset(
                                          0, // horizontal, move right 10
                                          0, // vertical, move down 10
                                        ),
                                      )
                                    ],
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            12.5) //         <--- border radius here
                                        ),
                                  ),
                                  // margin: EdgeInsets.all(25.0),
                                  child: Column(children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Icon(Icons.tram,
                                              color: Colors.indigo, size: 40),
                                          Text(opnv.toString(),
                                              style: TextStyle(
                                                  color: Colors.indigo,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w300)),
                                        ],
                                      ),
                                    ),
                                  ]),
                                ),
                              ],
                            ),
                          ],
                        )

                        // child: Padding(
                        //     padding: const EdgeInsets.all(30.0),
                        //     child: new Container(
                        //       width: 30,
                        //       height: 75,
                        //       color: Colors.indigo,
                        //     )
                        //     )
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
          backgroundColor: Colors.indigo,
          onPressed: save,
          tooltip: 'Save Entry',
          child: new Icon(Icons.save)),
    );
  }
}
