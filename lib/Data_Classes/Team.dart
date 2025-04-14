import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled1/Team_Display_Page_Package/TeamDisplayPage.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/globals.dart';

import 'Player.dart';

class Team {

  late List<Player> _players;
  List<String>  last5Results=["W","D","L","W","D"];


  // Constructor with optional values
  Team(this.name,this._matches, this._wins, this._losses, this._draws,this._group,this._foundationYear,this._titles,this._coach,[List<Player>? players] ) {
    _players = players ?? []; // Initialize players list if null
  }
  int? _foundationYear;
  String name;
  String _coach;
  int _matches, _wins, _losses, _draws, _titles;
  final int _group;
  bool _isFavourite=false;
  static int n=0;

  final Image _image1=Image.asset('fotos/csdfootball.png');
  final Image _image2=Image.asset('fotos/teamlogo.png');
  // Getters
  int get matches => _matches;
  int get wins => _wins;
  int get losses => _losses;
  int get draws => _draws;
  int get group => _group;
  List<Player> get players => _players;
  int get totalPoints=> (3*_wins+_draws);
  int get totalGames=> ( _wins + _draws + _losses );
  bool get isFavourite => _isFavourite;
  int? get foundationYear=> _foundationYear;
  int get titles=>_titles;

  List<Player> get getPlayers => _players;

  String get coach => _coach;

  Image get image {
    if (n%2==0) {
      n++;
      return _image1;
    } else {
      n++;
      return _image2;
    }

  }

  // Method to add a player
  Future<void> addPlayer(Player player) async {
   if (globalUser.controlTheseTeams(name,null)) {
      _players.add(player);

      await FirebaseFirestore.instance
          .collection('teams')
          .doc(player.teamName)
          .set({
        'Players': player.toMap(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> deletePlayer(Player player) async {
    if (globalUser.controlTheseTeams(name,null)){
      _players.remove(player);

      await FirebaseFirestore.instance
          .collection('teams') // π.χ. "teams"
          .doc(name)
          .update({
        'Players.${player.name}${player.number}': FieldValue.delete(),
      });
    }
  }

  Future<void> increaseWins() async {
    _wins++;
    await FirebaseFirestore.instance
        .collection('teams')
        .doc(name)
        .set({
      'Wins': FieldValue.increment(1)
    }, SetOptions(merge: true));

    updateHistory("W");
  }

  Future<void> increaseLoses() async {
    _losses++;
    await FirebaseFirestore.instance
        .collection('teams')
        .doc(name)
        .set({
      'Loses': FieldValue.increment(1)
    }, SetOptions(merge: true));

    updateHistory("L");
  }
  Future<void> increaseDraws() async {
    _draws++;
    await FirebaseFirestore.instance
        .collection('teams')
        .doc(name)
        .set({
      'Draws': FieldValue.increment(1)
    }, SetOptions(merge: true));

    updateHistory("D");
  }
  Future<void> reduceWins() async {
    _wins--;
    await FirebaseFirestore.instance
        .collection('teams')
        .doc(name)
        .set({
      'Wins': FieldValue.increment(-1)
    }, SetOptions(merge: true));
    shiftRightAndClearLast();
  }

  Future<void> reduceLoses() async {
    _losses--;
    await FirebaseFirestore.instance
        .collection('teams')
        .doc(name)
        .set({
      'Loses': FieldValue.increment(-1)
    }, SetOptions(merge: true));
    shiftRightAndClearLast();
  }
  Future<void> reduceDraws() async {
    _draws--;
    await FirebaseFirestore.instance
        .collection('teams')
        .doc(name)
        .set({
      'Draws': FieldValue.increment(-1)
    }, SetOptions(merge: true));
    shiftRightAndClearLast();
  }
  bool changeFavourite(){
    _isFavourite=!_isFavourite;
    return _isFavourite;
  }


//αναβάθμιση 5 τελευταίων αποτελεσματων
  Future<void> updateHistory(String newResult) async {
    final validResults = ['W', 'D', 'L'];
    if (!validResults.contains(newResult)) {
      throw Exception("Invalid result: must be W, D, or L");
    }

    final userRef = FirebaseFirestore.instance.collection('teams').doc(name);
    final snapshot = await userRef.get();

    if (!snapshot.exists) return;

    List<dynamic> history = snapshot.data()?['LastFive'] ?? [];

    history.removeWhere((item) => item == "");
    // Βεβαιώνεσαι ότι ο πίνακας έχει 6 θέσεις
    while (history.length < 6) {
      history.insert(0, "");  // Βάζει το "" στην αρχή της λίστας
    }

    // Διαγραφή του πρώτου (παλιότερου) αν έχει 6 στοιχεία
    if (history.length >= 6) {
      history.removeAt(0);
    }

    // Προσθήκη του νέου στο τέλος
    history.add(newResult);

    // Ενημέρωση Firestore
    await userRef.update({'LastFive': history});
  }

  Future<void> shiftRightAndClearLast() async {
    final userRef = FirebaseFirestore.instance.collection('teams').doc(name);
    final snapshot = await userRef.get();

    if (!snapshot.exists) return;

    List<dynamic> history = snapshot.data()?['LastFive'] ?? [];

    // Βεβαιώνεσαι ότι ο πίνακας έχει 6 θέσεις
    while (history.length < 6) {
      history.insert(0, "");  // Βάζει το "" στην αρχή της λίστας
    }

    // Κάνουμε shift προς τα δεξιά από το τέλος μέχρι τη θέση 1
    for (int i = history.length - 1; i > 0; i--) {
      history[i] = history[i - 1];
    }

    // Καθαρίζουμε τη θέση 0
    history[0] = "";

    await userRef.update({'LastFive': history});
  }


  void setCoachName(String name){
    _coach=name;
  }
  void setFoundationYear(int year){
    _foundationYear=year;
  }




}
