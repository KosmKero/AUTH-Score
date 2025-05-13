import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'Team.dart';

class Player extends ChangeNotifier{
  final String _name, _surname,_teamName,_teamNameEnglish;
  late int _goals, _numOfYellowCards, _numOfRedCards;
  int _position,_number,_age; //αν ειναι 0 ειναι τερματοφυλακας,αν ειναι 1 ειναι αμυντικος, αν ειναι 2 τότε είναι μέσος, αν ειανι 3 ειναι επιθετικος
  //Team _team;

  // Constructor
  Player(this._name, this._surname,this._position, this._goals,this._number,
      this._age,this._teamName,
      this._numOfYellowCards, this._numOfRedCards,this._teamNameEnglish);


  // Getters
  String get name => _name;
  String get surname => _surname;
  int get goals => _goals;
  int get numOfYellowCards => _numOfYellowCards;
  int get numOfRedCards => _numOfRedCards;
  int get position => _position;
  int get age =>_age;
  int get number => _number;
  String get teamName=> _teamName;
  String get teamNameEnglish => _teamNameEnglish;


  Future<void> scoredGoal() async {
    _goals++;

    await FirebaseFirestore.instance
        .collection('teams')
        .doc(teamName)
        .set({
      'Players': toMap(),
    }, SetOptions(merge: true));
  }

  Future<void> goalCancelled() async {
    if (_goals > 0) _goals--;

    await FirebaseFirestore.instance
        .collection('teams')
        .doc(teamName)
        .set({
      'Players': toMap(),
    }, SetOptions(merge: true));
  }

  Future<void> gotYellowCard() async {
    _numOfYellowCards++;

    await FirebaseFirestore.instance
        .collection('teams')
        .doc(teamName)
        .set({
      'Players': toMap(),
    }, SetOptions(merge: true));
  }
  Future<void> gotRedCard() async {
    _numOfRedCards++;

    await FirebaseFirestore.instance
        .collection('teams')
        .doc(teamName)
        .set({
      'Players': toMap(),
    }, SetOptions(merge: true));
  }

  Future<void> cancelYellowCard() async {
    _numOfYellowCards--;

    await FirebaseFirestore.instance
        .collection('teams')
        .doc(teamName)
        .set({
      'Players': toMap(),
    }, SetOptions(merge: true));
  }


  Future<void> cancelRedCard() async {
    _numOfRedCards--;

    await FirebaseFirestore.instance
        .collection('teams')
        .doc(teamName)
        .set({
      'Players': toMap(),
    }, SetOptions(merge: true));
  }

  Map<String,Map<String, dynamic>> toMap() {
    return {
      name+number.toString(): {
        'Name': _name,
        'Surname': _surname,
        'Goals': _goals,
        'numOfYellowCards': _numOfYellowCards,
        'numOfRedCards': _numOfRedCards,
        'Position': _position,
        'Age': _age,
        'Number': _number,
        'TeamName': _teamName,
        'teamNameEnglish':_teamNameEnglish
      }
    };
  }
  Map<String, dynamic> toMap2() {
    return {
        'Name': _name,
        'Surname': _surname,
        'Goals': _goals,
        'numOfYellowCards': _numOfYellowCards,
        'numOfRedCards': _numOfRedCards,
        'Position': _position,
        'Age': _age,
        'Number': _number,
        'TeamName': _teamName,
        'teamNameEnglish':_teamNameEnglish
    };
  }



}