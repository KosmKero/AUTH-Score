import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:untitled1/Team_Display_Page_Package/TeamDisplayPage.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/globals.dart';

import 'basketPlayer.dart';

class basketTeam {
  late List<BasketPlayer> _players;
  List<String> last5Results = ["W", "W", "L", "W", "W"];

  late final Image _image;
  // Constructor with optional values
  basketTeam(
      this.name,
      this._nameEnglish,
      this._matches,
      this._wins,
      this._losses,
      this._group,
      this._foundationYear,
      this._titles,
      this._coach,
      this._position,
      this._initials,
      this.secondCoachName,
      this.coachName,
      [List<BasketPlayer>? players]) {
    _players = players ?? []; // Initialize players list if null

    loadTeamImage();
  }

  final String _initials, coachName,secondCoachName;
  int? _foundationYear;
  final String name, _nameEnglish;
  String _coach;
  int _matches, _wins, _losses, _titles, _position;
  int _pointsFor = 0, _pointsAgainst = 0;
  final int _group;
  bool _isFavourite = false;
  static int n = 0;

  // Getters
  int get matches => _matches;
  int get wins => _wins;
  int get losses => _losses;
  int get group => _group;
  int get pointsFor => _pointsFor;
  int get pointsAgainst => _pointsAgainst;
  int get pointsDifference => _pointsFor - _pointsAgainst;

  List<BasketPlayer> get players => _players;
  int get totalPoints => (2 * _wins + _losses);
  int get totalGames => (_wins + _losses);
  bool get isFavourite => _isFavourite;
  int? get foundationYear => _foundationYear;
  int get titles => _titles;
  int get position => _position;
  String get initials => _initials;
  String get nameEnglish => _nameEnglish;
  List<BasketPlayer> get getPlayers => _players;

  String get coach => _coach;

  Image get image {
    return _image;
  }

  DocumentReference<Map<String, dynamic>> get teamDoc =>
      FirebaseFirestore.instance
          .collection('basket')
          .doc(thisYearNow.toString())
          .collection('teams')
          .doc(name);

  // Method to add a player
  Future<void> addPlayer(BasketPlayer player) async {
    if (globalUser.controlTheseTeams(name, null)) {
      _players.add(player);

      await teamDoc.set({
        'Players': player.toMap(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> deletePlayer(BasketPlayer player) async {
    if (globalUser.controlTheseTeams(name, null)) {
      _players.remove(player);

      await teamDoc.update({
        'Players.${player.name}${player.number}': FieldValue.delete(),
      });
    }
  }

  Future<void> updatePlayer(
      BasketPlayer oldPlayer, BasketPlayer newPlayer) async {
    if (!globalUser.controlTheseTeams(name, null)) return;
    final oldKey = '${oldPlayer.name}${oldPlayer.number}';
    final newKey = '${newPlayer.name}${newPlayer.number}';

    if (oldKey != newKey) {
      // Μετακίνησε/μετονόμασε τον παίχτη: διαγραφή παλιού κλειδιού + προσθήκη νέου
      await teamDoc.update({
        'Players.${oldPlayer.name}${oldPlayer.number}': FieldValue.delete(),
      });

      await teamDoc.set({
        'Players': newPlayer.toMap(),
      }, SetOptions(merge: true));
    } else {
      await teamDoc.set({
        'Players': newPlayer.toMap(),
      }, SetOptions(merge: true));
    }

    // Ενημέρωσε και την τοπική λίστα
    _players.remove(oldPlayer);
    _players.add(newPlayer);
  }

  Future<void> increaseWins(bool isGroupPhase) async {
    if (isGroupPhase) {
      _wins++;
      await teamDoc.set(
          {'Wins': FieldValue.increment(1), 'Matches': FieldValue.increment(1)},
          SetOptions(merge: true));
    }
    updateHistory("W");
  }

  Future<void> increaseLoses(bool isGroupPhase) async {
    if (isGroupPhase) {
      _losses++;
      await teamDoc.set({
        'Loses': FieldValue.increment(1),
        'Matches': FieldValue.increment(1)
      }, SetOptions(merge: true));
    }
    updateHistory("L");
  }

  Future<void> reduceWins(bool isGroupPhase) async {
    if (isGroupPhase) {
      _wins--;
      await teamDoc.set({
        'Wins': FieldValue.increment(-1),
        'Matches': FieldValue.increment(-1)
      }, SetOptions(merge: true));
    }
    shiftRightAndClearLast();
  }

  Future<void> reduceLoses(bool isGroupPhase) async {
    if (isGroupPhase) {
      _losses--;
      await teamDoc.set({
        'Loses': FieldValue.increment(-1),
        'Matches': FieldValue.increment(-1)
      }, SetOptions(merge: true));
    }
    shiftRightAndClearLast();
  }

  bool changeFavourite() {
    _isFavourite = !_isFavourite;
    return _isFavourite;
  }

//αναβάθμιση 5 τελευταίων αποτελεσματων
  Future<void> updateHistory(String newResult) async {
    final validResults = ['W', 'L'];
    if (!validResults.contains(newResult)) {
      throw Exception("Invalid result: must be W, or L");
    }

    final userRef = teamDoc;
    final snapshot = await userRef.get();

    if (!snapshot.exists) return;

    List<dynamic> history = snapshot.data()?['LastFive'] ?? [];

    // Αφαίρεσε όλα τα κενά entries (αν υπάρχουν)
    history.removeWhere((item) => item == "");

    // Αν έχει ήδη 5 αποτελέσματα, αφαίρεσε το πιο παλιό (πρώτο)
    if (history.length >= 6) {
      history.removeAt(0);
    }

    // Πρόσθεσε το νέο στο τέλος
    history.add(newResult);

    // Ενημέρωσε τη βάση
    await userRef.update({'LastFive': history});
  }

  Future<void> shiftRightAndClearLast() async {
    final userRef = teamDoc;
    final snapshot = await userRef.get();

    if (!snapshot.exists) return;

    List<dynamic> history = snapshot.data()?['LastFive'] ?? [];

    // Βεβαιώνεσαι ότι ο πίνακας έχει 6 θέσεις
    while (history.length < 6) {
      history.insert(0, ""); // Βάζει το "" στην αρχή της λίστας
    }

    // Κάνουμε shift προς τα δεξιά από το τέλος μέχρι τη θέση 1
    for (int i = history.length - 1; i > 0; i--) {
      history[i] = history[i - 1];
    }

    // Καθαρίζουμε τη θέση 0
    history[0] = "";

    await userRef.update({'LastFive': history});
  }

  void setCoachName(String name) {
    _coach = name;
  }

  void setFoundationYear(int year) {
    _foundationYear = year;
  }

  void setPosition(int pos) {
    _position = pos;
  }

  Future<void> loadTeamImage() async {
   //try {
   //  // Προσπάθεια να φορτωθεί το αρχείο
   //  await rootBundle.load('logos/$nameEnglish.png');
   //  _image = Image.asset('logos/$nameEnglish.png');
   //} catch (e) {
      // Αν δεν υπάρχει, χρησιμοποίησε fallback
      _image = Image.asset('fotos/default_team_logo.png');
   // }
  }

  Future<void> increasePointsFor(int points) async {
    _pointsFor=_pointsFor+points;
    await teamDoc
        .set({'pointsFor': _pointsFor}, SetOptions(merge: true));
  }

  Future<void> decreasePointsFor(int points) async {
    if (_pointsFor > 0) {
      _pointsFor=_pointsFor-points;
      await teamDoc.set(
          {'pointsFor': FieldValue.increment(-1)}, SetOptions(merge: true));
    }
  }

  Future<void> increasePointsAgainst(int points) async {
    _pointsAgainst=_pointsAgainst+points;
    await teamDoc.set(
        {'pointsAgainst': FieldValue.increment(1)}, SetOptions(merge: true));
  }

  Future<void> decreasePointsAgainst(int points) async {
    if (_pointsAgainst > 0) {
      _pointsAgainst=_pointsAgainst-points;
      await teamDoc.set(
          {'pointsAgainst': FieldValue.increment(-1)}, SetOptions(merge: true));
    }
  }

  Future<void> increaseMatches() async {
    _matches++;
    await teamDoc
        .set({'Matches': FieldValue.increment(1)}, SetOptions(merge: true));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is basketTeam && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
