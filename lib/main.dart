import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

Future<Runners> fetchRunners(int id, String classname) async {
  final response = await http.get(
      'https://liveresultat.orientering.se/api.php?comp=$id&method=getclassresults&class=$classname');

  if (response.statusCode == 200) {
    return Runners.fromJson(json.decode(response.body));
  } else {
    Fluttertoast.showToast(msg: 'Network error', gravity: ToastGravity.BOTTOM);
    throw Exception('Network error');
  }
}

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

class Runners {
  String status;
  String className;
  List<Results> results;
  String hash;

  Runners({this.status, this.className, this.results, this.hash});

  Runners.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    className = json['className'];
    if (json['results'] != null) {
      results = new List<Results>();
      json['results'].forEach((v) {
        results.add(new Results.fromJson(v));
      });
    }
    hash = json['hash'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['className'] = this.className;
    if (this.results != null) {
      data['results'] = this.results.map((v) => v.toJson()).toList();
    }
    data['hash'] = this.hash;
    return data;
  }
}

class Results {
  String place;
  String name;
  String club;
  String result;
  int status;
  String timeplus;
  int progress;
  int start;

  Results(
      {this.place,
      this.name,
      this.club,
      this.result,
      this.status,
      this.timeplus,
      this.progress,
      this.start});

  Results.fromJson(Map<String, dynamic> json) {
    place = json['place'];
    name = json['name'];
    club = json['club'];
    result = json['result'];
    status = json['status'];
    timeplus = json['timeplus'];
    progress = json['progress'];
    start = json['start'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['place'] = this.place;
    data['name'] = this.name;
    data['club'] = this.club;
    data['result'] = this.result;
    data['status'] = this.status;
    data['timeplus'] = this.timeplus;
    data['progress'] = this.progress;
    data['start'] = this.start;
    return data;
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

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Everysplitgood',
      home: Home(),
    );
  }
}

int _selectedIndex = 1;

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    var races = fetchRaces();
    final today = /*DateFormat('yyyy/MM/dd').format(DateTime.now());*/ DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return Scaffold(
      appBar: AppBar(title: Text('Home Screen')),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            title: Text('Starred'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            title: Text('Schedule'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).accentColor,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      /*drawer: Drawer(child: ListView(
        children: <Widget>[
          ListTile(
            title: Text("Races"),
            trailing: Icon(Icons.arrow_forward),
          ),
          ListTile(
            title: Text("Settings"),
            trailing: Icon(Icons.arrow_forward),
          ),
        ],
      ),),*/
      body: FutureBuilder<Races>(
        future: races,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scrollbar(
                child: ListTileTheme(
              child: ListView.separated(
                itemCount: snapshot.data.competitions.length,
                itemBuilder: (context, index) {
                  var raceday = DateTime(
                      int.parse(snapshot.data.competitions[index].date
                          .substring(0, 4)),
                      int.parse(snapshot.data.competitions[index].date
                          .substring(5, 7)),
                      int.parse(snapshot.data.competitions[index].date
                          .substring(8, 10)));
                  if (!raceday.isAefore(today)) {
                    return ListTile(
                      /*leading: today == raceday
                            ? Icon(Icons.assistant_photo)
                            : null,*/
                      title: Text(snapshot.data.competitions[index].name),
                      subtitle:
                          snapshot.data.competitions[index].organizer != ""
                              ? Text(DateFormat('yyyy/MM/dd').format(raceday) +
                                  ' · ' +
                                  snapshot.data.competitions[index].organizer)
                              : Text(DateFormat('yyyy/MM/dd').format(raceday)),
                      trailing: Icon(Icons.keyboard_arrow_right),
                      selected: today.compareTo(raceday) == 0,
                      onTap: () {
                        _navigateToRaceScreen(
                            context,
                            snapshot.data.competitions[index].id,
                            snapshot.data.competitions[index].name);
                      },
                    );
                  } else {
                    return Text('TODO how do I now show this????');
                  }
                },
                separatorBuilder: (context, index) {
                  return Divider();
                },
              ),
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
                      if (snapshot.data.classes[index].className != "") {
                        return ListTile(
                          title: Text(snapshot.data.classes[index].className),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () {
                            _navigateToRunnerScreen(context, id,
                                snapshot.data.classes[index].className, name);
                          },
                        );
                      } else {
                        return Text('TODO how do I now show this????');
                      }
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
    var runners = fetchRunners(id, classname);
    return Scaffold(
        appBar: AppBar(title: Text(classname + ' · ' + name)),
        body: FutureBuilder<Runners>(
            future: runners,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.results.length < 1) {
                  return Center(
                    child: Text('No runners yet'),
                  );
                } else {
                  return Scrollbar(
                      child: ListView.separated(
                        itemCount: snapshot.data.results.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading:  Text((index + 1).toString()),
                            title: Text(snapshot.data.results[index].name),
                            subtitle: snapshot.data.results[index].club != "" ? Text(snapshot.data.results[index].club) : null,
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
}