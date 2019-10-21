import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Races> fetchRaces() async {
  final response =
  await http.get('https://jsonplaceholder.typicode.com/posts/1');

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    return Races.fromJson(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

/*class Race {
  final int userId;
  final int id;
  final String title;
  final String body;

  Race({this.userId, this.id, this.title, this.body});

  factory Race.fromJson(Map<String, dynamic> json) {
    return Race(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
} */

class Races {
  List<Competitions> competitions;

  Races({this.competitions});

  Races.fromJson(Map<String, dynamic> json) {
    if (json['competitions'] != null) {
      competitions = new List<Competitions>();
      json['competitions'].forEach((v) {
        competitions.add(new Competitions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.competitions != null) {
      data['competitions'] = this.competitions.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Competitions {
  int id;
  String name;
  String organizer;
  String date;
  int timediff;
  int multidaystage;
  int multidayfirstday;

  Competitions(
      {this.id,
        this.name,
        this.organizer,
        this.date,
        this.timediff,
        this.multidaystage,
        this.multidayfirstday});

  Competitions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    organizer = json['organizer'];
    date = json['date'];
    timediff = json['timediff'];
    multidaystage = json['multidaystage'];
    multidayfirstday = json['multidayfirstday'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['organizer'] = this.organizer;
    data['date'] = this.date;
    data['timediff'] = this.timediff;
    data['multidaystage'] = this.multidaystage;
    data['multidayfirstday'] = this.multidayfirstday;
    return data;
  }
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Races> races;

  @override
  void initState() {
    super.initState();
    races = fetchRaces();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder<Races>(
            future: races,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(/*snapshot.data.competitions*/'Test');
                // TODO print competition
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}