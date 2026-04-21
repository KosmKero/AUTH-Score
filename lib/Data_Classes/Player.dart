import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart'; // 🌟 ΝΕΟ IMPORT

import '../globals.dart';
import 'Team.dart';

class Player extends ChangeNotifier {
  String? _id;
  final String _name, _surname, _teamName, _teamNameEnglish;
  late int _goals, _numOfYellowCards, _numOfRedCards;
  int _position, _number, _appearances;
  DateTime? _cardExpiryDate;

  Player(this._name, this._surname, this._position, this._goals, this._number,
       this._teamName, this._numOfYellowCards, this._numOfRedCards,
      this._teamNameEnglish, this._cardExpiryDate, this._appearances, [this._id]);

  // Getters
  String? get id => _id;
  String get name => _name;
  String get surname => _surname;
  int get goals => _goals;
  int get numOfYellowCards => _numOfYellowCards;
  int get numOfRedCards => _numOfRedCards;
  int get position => _position;
  int get number => _number;
  int get appearances => _appearances;
  String get teamName => _teamName;
  String get teamNameEnglish => _teamNameEnglish;

  String get uniqueKey {
    if (_id != null && _id!.isNotEmpty) {
      return _id!; // Αν έχει ID (νέος παίκτης), δώσε το ID
    } else {
      return "$_name$_number"; // Αν ΔΕΝ έχει (παλιός παίκτης), δώσε το παλιό κλειδί για να μη σπάσουν τα παλιά ματς!
    }
  }

  bool get hasValidHealthCard {
    if (_cardExpiryDate == null) return false;
    DateTime expirationDate = DateTime(_cardExpiryDate!.year + 1, _cardExpiryDate!.month, _cardExpiryDate!.day);
    return DateTime.now().isBefore(expirationDate);
  }

  DateTime? get cardExpiryDate => _cardExpiryDate;

  Future<void> setCardExpiryDate(DateTime? date) async {
    _cardExpiryDate = date;
    await _updatePlayerInBase();
    notifyListeners();
  }

  Future<void> playerPlayed() async {
    _appearances++;
    await _updatePlayerInBase();
    notifyListeners();
  }

  Future<void> cancelPlayerPlayed() async {
    if (_appearances > 0) _appearances--;
    await _updatePlayerInBase();
    notifyListeners();
  }

  Future<void> scoredGoal() async {
    _goals++;
    await _updatePlayerInBase();
    notifyListeners();
  }

  Future<void> goalCancelled() async {
    if (_goals > 0) _goals--;
    await _updatePlayerInBase();
    notifyListeners();
  }

  Future<void> gotYellowCard() async {
    _numOfYellowCards++;
    await _updatePlayerInBase();
    notifyListeners();
  }

  Future<void> gotRedCard() async {
    _numOfRedCards++;
    await _updatePlayerInBase();
    notifyListeners();
  }

  Future<void> cancelYellowCard() async {
    if (_numOfYellowCards > 0) _numOfYellowCards--;
    await _updatePlayerInBase();
    notifyListeners();
  }

  Future<void> cancelRedCard() async {
    if (_numOfRedCards > 0) _numOfRedCards--;
    await _updatePlayerInBase();
    notifyListeners();
  }

  Future<void> _updatePlayerInBase() async {
    await FirebaseFirestore.instance
        .collection('year').doc(thisYearNow.toString()).collection('teams')
        .doc(teamName)
        .set({
      'Players': toMap(),
    }, SetOptions(merge: true));
  }

  Map<String, Map<String, dynamic>> toMap() {
    return {
      uniqueKey: { // Χρησιμοποιεί το uniqueKey αντί για name+number
        'id': _id, // Σώζει το ID (αν υπάρχει)
        'Name': _name,
        'Surname': _surname,
        'Goals': _goals,
        'numOfYellowCards': _numOfYellowCards,
        'numOfRedCards': _numOfRedCards,
        'Position': _position,
        'Number': _number,
        'TeamName': _teamName,
        'teamNameEnglish': _teamNameEnglish,
        'healthCardExpiry': _cardExpiryDate != null ? Timestamp.fromDate(_cardExpiryDate!) : null,
        'Appearances': _appearances,
      }
    };
  }

  Map<String, dynamic> toMap2() {
    return {
      'id': _id,
      'Name': _name,
      'Surname': _surname,
      'Goals': _goals,
      'numOfYellowCards': _numOfYellowCards,
      'numOfRedCards': _numOfRedCards,
      'Position': _position,
      'Number': _number,
      'TeamName': _teamName,
      'teamNameEnglish': _teamNameEnglish,
      'healthCardExpiry': _cardExpiryDate != null ? Timestamp.fromDate(_cardExpiryDate!) : null,
      'Appearances': _appearances,
    };
  }
}