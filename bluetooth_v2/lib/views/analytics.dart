import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 'https://covid19.mathdro.id/api'
Future<Map> fetchData() async {
  final response =
      await http.get('https://covid19.mathdro.id/api/countries/germany');

  if (response.statusCode == 200) {
    // print(json.decode(response.body));
    return json.decode(response.body);

    // return Album.fromJson(json.decode(response.body));
  } else {
    throw Exception('fetch is failed');
  }
}

// class Album {
//   final int userId;
//   final int id;
//   final String title;

//   Album({this.userId, this.id, this.title});

//   factory Album.fromJson(Map<String, dynamic> json) {
//     return Album(
//       userId: json['userId'],
//       id: json['id'],
//       title: json['title'],
//     );
//   }
// }

class Analytics extends StatefulWidget {
  @override
  _AnalyticsState createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  Future<Map> currentData;

  int confirmed;
  int recovered;
  int deaths;

  // functions

  @override
  void initState() {
    waitForData();

    super.initState();
  }

  waitForData() async {
    var data = await fetchData();
    setState(() {
      confirmed = data['confirmed']['value'];
      recovered = data['recovered']['value'];
      deaths = data['deaths']['value'];
      print(confirmed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // body: Header()
        body: Center(
      child: 
       confirmed != null ?  Text(
        confirmed.toString()
      ) :  Text("scheise")
      // child: FutureBuilder<Album>(
      //   future: futureAlbum,
      //   builder: (context, snapshot) {
      //     if (snapshot.hasData) {
      //       return Text(snapshot.data.title);
      //     } else if (snapshot.hasError) {
      //       return Text("${snapshot.error}");
      //     }

      //     // By default, show a loading spinner.
      //     return CircularProgressIndicator();
      //   },
      // ),
    ));
  }

  // widgets

  Widget Header() {
    return Text("Analytics");
  }
}
