import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'httpclient.dart';
import 'drawer.dart';
import 'sqldb.dart';
import 'dart:async';

class DescProfile {
  DescProfile({
    this.title,
    this.value
  });
  String title;
  var value;
}

enum SingingCharacter { weightlifting, athletics, other }

// SingingCharacter _selectedItem = SingingCharacter.weightlifting;
int _selectedItem = 0;

class MyItem {
  MyItem({ this.isExpanded: false, this.header, this.body });

  bool isExpanded;
  final String header;
  final String body;
}

List<MyItem> _items = <MyItem>[
  new MyItem(header: 'Type Experiance', body: 'body')
];

List<DescProfile> listProfile = <DescProfile>[
  new DescProfile(title: '', value: ''),
  new DescProfile(title: '', value: ''),
  new DescProfile(title: '', value: ''),
  new DescProfile(title: '', value: ''),
  new DescProfile(title: '', value: ''),
  new DescProfile(title: '', value: ''),
  new DescProfile(title: '', value: ''),
];

class Profile extends StatefulWidget {

  @override
  _Profile createState() => new _Profile();
}

class _Profile extends State<Profile> {

  HttpClient httpClient = new HttpClient();
  DescProfile descProfile;
  String authToken = '';
  String authSecret = '';
  String idUser = '';
  String login = '';
  int idtypeexercise = 0;
  double lastWeightKg;
  bool isSave = false;

  @override
  void initState() {
    super.initState();
    getValues().then((value) {
      getDetailProfile();
    });
  }
  
  getDetailProfile() {
    httpClient.getUserByLogin(login).then((user) {
      httpClient.getProfile(authToken, authSecret).then((profile) {
        listProfile.clear();
        setState(() {
          listProfile.add(new DescProfile(
            title: 'Height measure: ',
            value: profile['height_measure']
          ));
          listProfile.add(new DescProfile(
            title: 'Weight measure: ',
            value: profile['weight_measure']
          ));
          listProfile.add(new DescProfile(
            title: 'Last weight kg: ',
            value: double.parse(profile['last_weight_kg'])
          ));
          listProfile.add(new DescProfile(
            title: 'Goal weight kg: ',
            value: double.parse(profile['goal_weight_kg'])
          ));
          listProfile.add(new DescProfile(
            title: 'Height cm: ',
            value: double.parse(profile['height_cm'])
          ));
          listProfile.add(new DescProfile(
            title: 'Calories norm: ',
            value: user[0]['caloriesnorm']
          ));
          listProfile.add(new DescProfile(
            title: 'Reset calories: ',
            value: user[0]['resetcalories']
          ));
        });
        lastWeightKg = double.parse(profile['last_weight_kg']);
        controllerWeight.text = lastWeightKg.toString();
        controllerCaloriesNorm.text = user[0]['caloriesnorm'].toString();
        controllerResetCalories.text = user[0]['resetcalories'].toString();
        print(listProfile);
      });
    });
  }

  Future getValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');
    authSecret = prefs.getString('auth_secret');
    login = prefs.getString('login');
    idUser = prefs.getInt('userid').toString();
    idtypeexercise = prefs.getInt('idtypeexercise');
    setState(() {
      _selectedItem = idtypeexercise - 1;
    });
  }

  _saveValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('idtypeexercise', _selectedItem + 1);
    getDetailProfile();
  }

  TextEditingController controllerWeight = new TextEditingController();
  TextEditingController controllerCaloriesNorm = new TextEditingController();
  TextEditingController controllerResetCalories = new TextEditingController();

  @override
  Widget build(BuildContext context) {

    var listViewProgress = new Container(
      child: new Center(
        child: new SizedBox(
          height: 50.0,
          width: 50.0,
          child: new CircularProgressIndicator(
            value: null,
            strokeWidth: 7.0,
          ),
        ),
      ),
    );

    var listView = new ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        new Container(
          margin: const EdgeInsets.only(left: 10.0),
          child: new ListTile(
            title: new Text(listProfile[0].title + listProfile[0].value.toString()),
          )
        ),
        new Divider(),
        new Container(
          margin: const EdgeInsets.only(left: 10.0),
          child: new ListTile(
            title: new Text(listProfile[1].title + listProfile[1].value.toString()),
          )
        ),
        new Divider(),
        new Container(
          margin: const EdgeInsets.only(left: 10.0),
          child: new ListTile(
            title: new Text(listProfile[2].title + listProfile[2].value.toString()),
            trailing: new Icon(Icons.edit),
            onTap: () {
              showDialog(
                context: context,
                child: new AlertDialog(
                  title: new Text('Editing weight'),
                  content: new Container(
                    child: new Row(
                      children: <Widget>[
                        new IconButton(
                          icon: new Icon(FontAwesomeIcons.minus), 
                          color: Colors.blue,
                          onPressed: () {
                            setState(() {
                              lastWeightKg = lastWeightKg - 0.01;
                              print(lastWeightKg);
                              controllerWeight.text = new NumberFormat("##.##").format(lastWeightKg);
                            });
                          },
                        ),
                        new Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: new TextField(
                            textAlign: TextAlign.center,
                            controller: controllerWeight,
                            keyboardType: TextInputType.number,
                            decoration: new InputDecoration(
                              hintText: 'New your weight',
                            ),
                          ),
                        ),
                        new IconButton(
                          icon: new Icon(FontAwesomeIcons.plus),
                          color: Colors.blue,
                          onPressed: () {
                            setState(() {
                              lastWeightKg = lastWeightKg + 0.01;
                              lastWeightKg.roundToDouble();
                              print(lastWeightKg);
                              controllerWeight.text = new NumberFormat("##.##").format(lastWeightKg);
                            });
                          },
                        ),                            
                      ],
                    ),
                  ),
                  actions: <Widget> [
                    new FlatButton(
                      child: new Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    new FlatButton(
                      child: new Text('OK'),
                      onPressed: () {
                        httpClient.updtaeWeight(authToken, authSecret, controllerWeight.text).then((val) {
                          print(val);
                          Navigator.pop(context);
                          getDetailProfile();
                        });
                      },
                    ),
                  ]
                )
              );
            },
          )
        ),
        new Divider(),
        new Container(
          margin: const EdgeInsets.only(left: 10.0),
          child: new ListTile(
            title: new Text(listProfile[3].title + listProfile[3].value.toString()),
          )
        ),
        new Divider(),
        new Container(
          margin: const EdgeInsets.only(left: 10.0),
          child: new ListTile(
            title: new Text(listProfile[4].title + listProfile[4].value.toString()),
          )
        ),
        new Divider(),
        new Container(
          margin: const EdgeInsets.only(left: 10.0),
          child: new ListTile(
            title: new Text(listProfile[5].title + listProfile[5].value.toString()),
            trailing: new Icon(Icons.edit),
            onTap: () {
              showDialog(
                context: context,
                child: new AlertDialog(
                  title: new Text('Editing calories norm'),
                  content: new Container(
                    child: new Container(
                      child: new TextField(
                        textAlign: TextAlign.center,
                        controller: controllerCaloriesNorm,
                        keyboardType: TextInputType.number,
                        decoration: new InputDecoration(
                          hintText: 'New your calories norm',
                        ),
                      ),
                    ),
                  ),
                  actions: <Widget> [
                    new FlatButton(
                      child: new Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    new FlatButton(
                      child: new Text('OK'),
                      onPressed: () {
                        httpClient.updateCaloriesNorm(controllerCaloriesNorm.text, idUser).then((val) {
                          print(val);
                          Navigator.pop(context);
                          getDetailProfile();
                        });
                      },
                    ),
                  ]
                )
              );
            },
          )
        ),
        new Divider(),
        new Container(
          margin: const EdgeInsets.only(left: 10.0),
          child: new ListTile(
            title: new Text(listProfile[6].title + listProfile[6].value.toString()),
            trailing: new Icon(Icons.edit),
            onTap: () {
              showDialog(
                context: context,
                child: new AlertDialog(
                  title: new Text('Editing reset calories'),
                  content: new Container(
                    child: new Container(
                      child: new TextField(
                        textAlign: TextAlign.center,
                        controller: controllerResetCalories,
                        keyboardType: TextInputType.number,
                        decoration: new InputDecoration(
                          hintText: 'New your reset calories',
                        ),
                      ),
                    ),
                  ),
                  actions: <Widget> [
                    new FlatButton(
                      child: new Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    new FlatButton(
                      child: new Text('OK'),
                      onPressed: () {
                        httpClient.updateResetCalories(controllerResetCalories.text, idUser).then((val) {
                          print(val);
                          Navigator.pop(context);
                          getDetailProfile();
                        });
                      },
                    ),
                  ]
                )
              );
            },
          )
        ),
        new Divider(),
        new ExpansionTile(
          initiallyExpanded: isSave,
          title: const Text('Type exercise'),
          children: <Widget>[
            new RadioListTile<int>(
              title: const Text('Weightlifting'),
              value: 0,
              groupValue: _selectedItem,
              onChanged: (int value) { 
                setState(() {
                  print(value);
                  _selectedItem = value;
                }); 
              },
            ),
            new RadioListTile<int>(
              title: const Text('Athletics'),
              value: 1,
              groupValue: _selectedItem,
              onChanged: (int value) {
                setState(() {
                  print(value);
                  _selectedItem = value;
                });
              },
            ),
            new RadioListTile<int>(
              title: const Text('Other exercises'),
              value: 2,
              groupValue: _selectedItem,
              onChanged: (int value) {
                setState(() {
                  print(value);
                  _selectedItem = value;
                });
              },
            ),
            new Container(
              width: MediaQuery.of(context).size.width,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    child: new FlatButton(
                      child: new Text(
                        'Save',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500
                        )
                      ),
                      onPressed: () {
                        httpClient.updateIdTypeExercise(_selectedItem + 1, idUser).then((val) {
                          setState(() {
                            isSave = false;
                            _selectedItem = val[0]['idtypeexercise'] - 1;
                          });
                          _saveValues();
                        });
                      },
                    ),
                  ),
                ],
              ),
            )
          ]
        ),
      ],
    );

    return new Scaffold(
      drawer: new MyDrawer(),
      appBar: new AppBar(
        backgroundColor: Colors.blue,
        title: new Text('Profile'),
      ),
      body: new Container(
        child: new Center(
          child: (listProfile[0].title != '') ? listView : listViewProgress
        ),
      )
    );
  }
}
