import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../../globals.dart';


class BasketPlayer extends ChangeNotifier{
  final String _name, _surname,_teamName,_teamNameEnglish;
  int _points;
  final int _position,_number; //αν ειναι 1 ειναι pg,2 sg,3 sf,4 pf, 5 c

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

    notifyListeners();

    await FirebaseFirestore.instance
        .collection('basket')
        .doc(thisYearNow.toString())
        .collection('teams')
        .doc(teamName)
        .set({
      'Players': toMap(),
    }, SetOptions(merge: true));


  }


  Map<String,Map<String, dynamic>> toMap() {
    return {
      _name+_surname+_number.toString(): { //ισως θελει αλλο key
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