import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../../globals.dart';

class BasketPlayer extends ChangeNotifier{
  final String _name, _surname, _teamName, _teamNameEnglish, _id; // ΠΡΟΣΤΕΘΗΚΕ ΤΟ _id
  int _points;
  final int _position, _number;

  // Constructor με ID
  BasketPlayer(this._name, this._surname, this._position, this._points, this._number, this._teamName, this._teamNameEnglish, this._id);

  // Getters
  String get name => _name;
  String get surname => _surname;
  int get points => _points;
  int get position => _position;
  int get number => _number;
  String get teamName => _teamName;
  String get teamNameEnglish => _teamNameEnglish;
  String get id => _id; // ΝΕΟ GETTER

  Future<void> scoredPoints(int points) async {
    _points = _points + points;
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

  // ΔΙΟΡΘΩΣΗ: Πλέον το κλειδί στο Firestore θα είναι το ID, όχι το Όνομα+Νούμερο
  Map<String, Map<String, dynamic>> toMap() {
    return {
      _id: {
        'id': _id,
        'Name': _name,
        'Surname': _surname,
        'Points': _points,
        'Position': _position,
        'Number': _number,
        'TeamName': _teamName,
        'teamNameEnglish': _teamNameEnglish
      }
    };
  }

  Map<String, dynamic> toMap2() {
    return {
      'id': _id,
      'Name': _name,
      'Surname': _surname,
      'Points': _points,
      'Position': _position,
      'Number': _number,
      'TeamName': _teamName,
      'teamNameEnglish': _teamNameEnglish
    };
  }
}