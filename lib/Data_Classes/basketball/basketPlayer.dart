import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';


class BasketPlayer extends ChangeNotifier{
  final String _name, _surname,_teamName,_teamNameEnglish;
  late int _points;
  int _position,_number; //αν ειναι 0 ειναι τερματοφυλακας,αν ειναι 1 ειναι αμυντικος, αν ειναι 2 τότε είναι μέσος, αν ειανι 3 ειναι επιθετικος

  // Constructor
  BasketPlayer(this._name, this._surname,this._position, this._points,this._number,this._teamName, this._teamNameEnglish);


  // Getters
  String get name => _name;
  String get surname => _surname;
  int get points => _points;

  int get position => _position;

  int get number => _number;
  String get teamName=> _teamName;
  String get teamNameEnglish => _teamNameEnglish;


  Future<void> scoredPoints(int points) async {
    _points=_points+points;

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
        'Points': _points,
        'Position': _position,
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
      'Points': _points,
      'Position': _position,
      'Number': _number,
      'TeamName': _teamName,
      'teamNameEnglish':_teamNameEnglish
    };
  }



}