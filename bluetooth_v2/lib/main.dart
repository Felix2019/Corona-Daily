import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:background_fetch/background_fetch.dart';
import 'dart:async';

import './views/home.dart';
import './views/analytics.dart';
import './views/addDaily.dart';
import './components/geo.dart';

List<Place> geoData = [];

void backgroundFetchHeadlessTask(String taskId) async {
  print("headless task startet");
  print('[BackgroundFetch] Headless event received.');
  //  geostream
  print(geoData);
  BackgroundFetch.finish(taskId);
}

void main() {
  runApp(MaterialApp(
    title: 'Named Routes Demo',
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => Main(),
      '/addEntry': (context) => Daily(places: geoData),
    },
  ));

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class Main extends StatefulWidget {
  Main({Key key, this.title}) : super(key: key);
  final String title;

  @override
  MainState createState() => MainState();
}

class MainState extends State<Main> {
  int _status = 0;
  List<DateTime> _events = [];

  var geolocator = Geolocator();
  Position position;
  String currentPlace;

  int selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 15,
            stopOnTerminate: false,
            enableHeadless: true,
            requiredNetworkType: NetworkType.NONE), (String taskId) async {
      // This is the fetch-event callback.
      print("[BackgroundFetch] Event received $taskId");
      // setState(() {
      //   _events.insert(0, new DateTime.now());
      //   print("finisch eeey");
      //   print(_events[0]);
      // });
      geoStream();
      print(geoData);
      BackgroundFetch.finish(taskId);
    }).then((int status) {
      print("nice fetch");
      print('[BackgroundFetch] configure success: $status');
      setState(() {
        _status = status;
      });
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
      setState(() {
        _status = e;
      });
    });

    // Optionally query the current BackgroundFetch status.
    int status = await BackgroundFetch.status;
    setState(() {
      _status = status;
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  static List<Widget> _widgetOptions = <Widget>[
    Home(),
    Analytics(),
    Text(
      'Index 1: daily',
      style: optionStyle,
    ),
    Text(
      'Index 2: Umgebung',
      style: optionStyle,
    ),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Future sleep1() {
    return new Future.delayed(const Duration(seconds: 3), () => "1");
  }

  geoStream() {
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 200);

    geolocator
        .getPositionStream(locationOptions)
        .listen((Position newposition) {
      if (newposition != null) {
        // function for geocoding to name
        Future wait() async {
          String placeName =
              await getPlaceTitle(newposition.latitude, newposition.longitude);

          var newPlace = new Place(placeName, newposition.latitude, newposition.longitude);

          setState(() {
            geoData.add(newPlace);
          });
        }

        wait();
      } else {
        print("geo error");
      }
    });
  }

  Future<String> getPlaceTitle(lat, long) async {
    List<Placemark> placemark =
        await Geolocator().placemarkFromCoordinates(lat, long);

    return placemark[0].name;
  }

  @override
  void initState() {
    initPlatformState();
    // geoStream();
    super.initState();
  }

  // static main page
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.content_paste),
            title: Text('daily'),
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.map),
          //   title: Text('Umgebung'),
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.poll),
            title: Text('Analytics'),
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Color.fromRGBO(74, 0, 224, 60),
        onTap: onItemTapped,
      ),
    );
  }

  Future<void> getLocation() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.location);
    print(permission);

    if (permission == PermissionStatus.denied) {
      await PermissionHandler()
          .requestPermissions([PermissionGroup.locationAlways]);
    }

    GeolocationStatus geolocationStatus =
        await geolocator.checkGeolocationPermissionStatus();

    switch (geolocationStatus) {
      case GeolocationStatus.denied:
        print('denied');
        break;
      case GeolocationStatus.disabled:
        print('disabled');
        break;
      case GeolocationStatus.restricted:
        print('restricted');
        break;
      case GeolocationStatus.unknown:
        print('unknown');
        break;
      case GeolocationStatus.granted:
        print('Access granted');
    }
  }
} // class homepage

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import 'package:background_fetch/background_fetch.dart';

// /// This "Headless Task" is run when app is terminated.
// void backgroundFetchHeadlessTask(String taskId) async {
//   print('[BackgroundFetch] Headless event received.');
//   BackgroundFetch.finish(taskId);
// }

// void main() {
//   // Enable integration testing with the Flutter Driver extension.
//   // See https://flutter.io/testing/ for more info.
//   runApp(new MyApp());

//   // Register to receive BackgroundFetch events after app is terminated.
//   // Requires {stopOnTerminate: false, enableHeadless: true}
//   BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => new _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   bool _enabled = true;
//   int _status = 0;
//   List<DateTime> _events = [];

//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//   }

//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initPlatformState() async {
//     // Configure BackgroundFetch.
//     BackgroundFetch.configure(BackgroundFetchConfig(
//         minimumFetchInterval: 15,
//         stopOnTerminate: false,
//         enableHeadless: false,
//         requiresBatteryNotLow: false,
//         requiresCharging: false,
//         requiresStorageNotLow: false,
//         requiresDeviceIdle: false,
//         requiredNetworkType: NetworkType.NONE
//     ), (String taskId) async {
//       // This is the fetch-event callback.
//       print("[BackgroundFetch] Event received $taskId");
//       setState(() {
//         _events.insert(0, new DateTime.now());
//       });
//       // IMPORTANT:  You must signal completion of your task or the OS can punish your app
//       // for taking too long in the background.
//       BackgroundFetch.finish(taskId);
//     }).then((int status) {
//       print('[BackgroundFetch] configure success: $status');
//       setState(() {
//         _status = status;
//       });
//     }).catchError((e) {
//       print('[BackgroundFetch] configure ERROR: $e');
//       setState(() {
//         _status = e;
//       });
//     });

//     // Optionally query the current BackgroundFetch status.
//     int status = await BackgroundFetch.status;
//     setState(() {
//       _status = status;
//     });

//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;
//   }

//   void _onClickEnable(enabled) {
//     setState(() {
//       _enabled = enabled;
//     });
//     if (enabled) {
//       BackgroundFetch.start().then((int status) {
//         print('[BackgroundFetch] start success: $status');
//       }).catchError((e) {
//         print('[BackgroundFetch] start FAILURE: $e');
//       });
//     } else {
//       BackgroundFetch.stop().then((int status) {
//         print('[BackgroundFetch] stop success: $status');
//       });
//     }
//   }

//   void _onClickStatus() async {
//     int status = await BackgroundFetch.status;
//     print('[BackgroundFetch] status: $status');
//     setState(() {
//       _status = status;
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return new MaterialApp(
//       home: new Scaffold(
//         appBar: new AppBar(
//           title: const Text('BackgroundFetch Example', style: TextStyle(color: Colors.black)),
//           backgroundColor: Colors.amberAccent,
//           brightness: Brightness.light,
//           actions: <Widget>[
//             Switch(value: _enabled, onChanged: _onClickEnable),
//           ]
//         ),
//         body: Container(
//           color: Colors.black,
//           child: new ListView.builder(
//               itemCount: _events.length,
//               itemBuilder: (BuildContext context, int index) {
//                 DateTime timestamp = _events[index];
//                 return InputDecorator(
//                     decoration: InputDecoration(
//                         contentPadding: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 0.0),
//                         labelStyle: TextStyle(color: Colors.amberAccent, fontSize: 20.0),
//                         labelText: "[background fetch event]"
//                     ),
//                     child: new Text(timestamp.toString(), style: TextStyle(color: Colors.white, fontSize: 16.0))
//                 );
//               }
//           ),
//         ),
//         bottomNavigationBar: BottomAppBar(
//           child: Row(
//             children: <Widget>[
//               RaisedButton(onPressed: _onClickStatus, child: Text('Status')),
//               Container(child: Text("$_status"), margin: EdgeInsets.only(left: 20.0))
//             ]
//           )
//         ),
//       ),
//     );
//   }

// }
