import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

Future<Races> fetchRaces() async {
  final response = await http.get(
      'https://liveresultat.orientering.se/api.php?method=getcompetitions');

  if (response.statusCode == 200) {
    return Races.fromJson(json.decode(response.body));
  } else {
    Fluttertoast.showToast(msg: 'Network error', gravity: ToastGravity.BOTTOM);
    throw Exception('Network error');
  }
}

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

void main() {
  runApp(MaterialApp(
    title: 'Everysplitgood',
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatelessWidget {
  final races = fetchRaces();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Screen')),
      body: FutureBuilder<Races>(
        future: races,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scrollbar(
                child: ListView.separated(
              itemCount: snapshot.data.competitions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data.competitions[index].name),
                  subtitle: snapshot.data.competitions[index].organizer != ""
                      ? Text(snapshot.data.competitions[index].organizer)
                      : null,
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    _navigateToRaceScreen(
                        context, snapshot.data.competitions[index].id);
                  },
                );
              },
              separatorBuilder: (context, index) {
                return Divider();
              },
            ));
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  void _navigateToRaceScreen(BuildContext context, id) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RaceScreen(id: id),
        ));
  }
}

class RaceScreen extends StatelessWidget {
  final int id;
  RaceScreen({Key key, @required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Race screen')),
      body: Center(
        child: RaisedButton(
          child: Text(id.toString()),
          onPressed: () {
            _goBackToHomeScreen(context);
          },
        ),
      ),
    );
  }

  void _goBackToHomeScreen(BuildContext context) {
    Navigator.pop(context);
  }
}
