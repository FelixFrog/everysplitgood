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

Future<Class> fetchClass(int id) async {
  final response = await http.get(
      'https://liveresultat.orientering.se/api.php?method=getclasses&comp=$id');

  if (response.statusCode == 200) {
    return Class.fromJson(json.decode(response.body));
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

class Class {
  String status;
  List<Classes> classes;
  String hash;

  Class({this.status, this.classes, this.hash});

  Class.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['classes'] != null) {
      classes = new List<Classes>();
      json['classes'].forEach((v) {
        classes.add(new Classes.fromJson(v));
      });
    }
    hash = json['hash'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.classes != null) {
      data['classes'] = this.classes.map((v) => v.toJson()).toList();
    }
    data['hash'] = this.hash;
    return data;
  }
}

class Classes {
  String className;

  Classes({this.className});

  Classes.fromJson(Map<String, dynamic> json) {
    className = json['className'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['className'] = this.className;
    return data;
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Everysplitgood',
    theme: ThemeData.dark(),
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var races = fetchRaces();
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
                      ? Text(snapshot.data.competitions[index].date
                              .replaceAll(new RegExp(r'-'), '/') +
                          ' · ' +
                          snapshot.data.competitions[index].organizer)
                      : Text(snapshot.data.competitions[index].date),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    _navigateToRaceScreen(
                        context,
                        snapshot.data.competitions[index].id,
                        snapshot.data.competitions[index].name);
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

  void _navigateToRaceScreen(BuildContext context, int id, String name) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RaceScreen(id: id, name: name),
        ));
  }
}

class RaceScreen extends StatelessWidget {
  final int id;
  final String name;
  RaceScreen({Key key, @required this.id, @required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var classes = fetchClass(id);
    return Scaffold(
        appBar: AppBar(title: Text(name)),
        body: FutureBuilder<Class>(
            future: classes,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.classes.length < 1) {
                  return Center(
                    child: Text('No classes defined yet'),
                  );
                } else {
                  return Scrollbar(
                      child: ListView.separated(
                    itemCount: snapshot.data.classes.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(snapshot.data.classes[index].className),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                          _navigateToRunnerScreen(context, id,
                              snapshot.data.classes[index].className, name);
                        },
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                  ));
                }
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }));
  }

  void _navigateToRunnerScreen(
      BuildContext context, int id, String classname, String name) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              RunnerScreen(id: id, classname: classname, name: name),
        ));
  }
}

class RunnerScreen extends StatelessWidget {
  final int id;
  final String name;
  final String classname;
  RunnerScreen(
      {Key key,
      @required this.id,
      @required this.classname,
      @required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(classname)),
        body: Center(
          child: Text('Hi!'),
        ));
  }
}
