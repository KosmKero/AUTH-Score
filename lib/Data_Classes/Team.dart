import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//mport 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';
import 'package:untitled1/Team_Display_Page_Package/TeamDisplayPage.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/globals.dart';

import 'Player.dart';

class Team {
  late List<Player> _players;
  List<String> last5Results = ["W", "D", "L", "W", "D"];

  late final Image _image;
  // Constructor with optional values
  Team(
      this.name,
      this._nameEnglish,
      this._matches,
      this._wins,
      this._losses,
      this._draws,
      this._group,
      this._foundationYear,
      this._titles,
      this._coach,
      this._position,
      this._initials,
      [List<Player>? players]) {
    _players = players ?? []; // Initialize players list if null

    //loadTeamImage();
  }

  String _initials;
  int? _foundationYear;
  String name, _nameEnglish;
  String _coach;
  int _matches, _wins, _losses, _draws, _titles, _position;
  int _goalsFor = 0, _goalsAgainst = 0;
  final int _group;
  bool _isFavourite = false;
  static int n = 0;

  // Getters
  int get matches => _matches;
  int get wins => _wins;
  int get losses => _losses;
  int get draws => _draws;
  int get group => _group;
  int get goalsFor => _goalsFor;
  int get goalsAgainst => _goalsAgainst;
  int get goalDifference => _goalsFor - _goalsAgainst;

  List<Player> get players => _players;
  int get totalPoints => (3 * _wins + _draws);
  int get totalGames => (_wins + _draws + _losses);
  bool get isFavourite => _isFavourite;
  int? get foundationYear => _foundationYear;
  int get titles => _titles;
  int get position => _position;
  String get initials => _initials;
  String get nameEnglish => _nameEnglish;
  List<Player> get getPlayers => _players;

  String get coach => _coach;

  //Image get image {
  //    return _image;
  //}

  // Method to add a player
  Future<void> addPlayer(Player player) async {
    if (globalUser.controlTheseTeamsFootball(name, null) ||
        globalUser.isUpperAdmin) {
      _players.add(player);

      await FirebaseFirestore.instance
          .collection('year')
          .doc(thisYearNow.toString())
          .collection('teams')
          .doc(player.teamName)
          .set({
        'Players': player.toMap(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> deletePlayer(Player player) async {
    if (globalUser.controlTheseTeamsFootball(name, null) ||
        globalUser.isUpperAdmin) {
      _players.remove(player);

      await FirebaseFirestore.instance
          .collection('year')
          .doc(thisYearNow.toString())
          .collection('teams') // π.χ. "teams"
          .doc(name)
          .update({
        'Players.${player.name}${player.number}': FieldValue.delete(),
      });
    }
  }

  Future<void> updatePlayer(Player oldPlayer, Player newPlayer) async {
    if (!(globalUser.controlTheseTeamsFootball(name, null) ||
        globalUser.isUpperAdmin)) return;
    final oldKey = '${oldPlayer.name}${oldPlayer.number}';
    final newKey = '${newPlayer.name}${newPlayer.number}';

    if (oldKey != newKey) {
      // Μετακίνησε/μετονόμασε τον παίχτη: διαγραφή παλιού κλειδιού + προσθήκη νέου
      await FirebaseFirestore.instance
          .collection('year')
          .doc(thisYearNow.toString())
          .collection('teams') // π.χ. "teams"
          .doc(name)
          .update({
        'Players.${oldPlayer.name}${oldPlayer.number}': FieldValue.delete(),
      });

      await FirebaseFirestore.instance
          .collection('year')
          .doc(thisYearNow.toString())
          .collection('teams')
          .doc(newPlayer.teamName)
          .set({
        'Players': newPlayer.toMap(),
      }, SetOptions(merge: true));
    } else {
      await FirebaseFirestore.instance
          .collection('year')
          .doc(thisYearNow.toString())
          .collection('teams')
          .doc(newPlayer.teamName)
          .set({
        'Players': newPlayer.toMap(),
      }, SetOptions(merge: true));
    }

    // Ενημέρωσε και την τοπική λίστα
    _players.remove(oldPlayer);
    _players.add(newPlayer);
  }

// Ενιαία ενημέρωση στατιστικών ομάδας μετά από αγώνα
  Future<void> applyMatchResult(int scored, int conceded, bool isGroupPhase) async {
    String resultType;
    int winInc = 0, drawInc = 0, lossInc = 0;

    if (scored > conceded) {
      winInc = 1;
      resultType = "W";
    } else if (scored == conceded) {
      drawInc = 1;
      resultType = "D";
    } else {
      lossInc = 1;
      resultType = "L";
    }

    if (isGroupPhase) {
      _wins += winInc;
      _draws += drawInc;
      _losses += lossInc;
      _goalsFor += scored;
      _goalsAgainst += conceded;
      _matches++;

      await FirebaseFirestore.instance
          .collection('year')
          .doc(thisYearNow.toString())
          .collection('teams')
          .doc(name)
          .set({
        'Wins': FieldValue.increment(winInc),
        'Draws': FieldValue.increment(drawInc),
        'Loses': FieldValue.increment(lossInc),
        'Matches': FieldValue.increment(1),
        'goalsFor': FieldValue.increment(scored),
        'goalsAgainst': FieldValue.increment(conceded),
      }, SetOptions(merge: true));
    }

    await updateHistory(resultType);
  }

// Ενιαία ΑΝΑΙΡΕΣΗ στατιστικών ομάδας (όταν ακυρώνεται/γυρνάει πίσω ένα ματς)
  Future<void> revertMatchResult(int scored, int conceded, bool isGroupPhase) async {
    int winDec = 0, drawDec = 0, lossDec = 0;

    if (scored > conceded) {
      winDec = -1;
    } else if (scored == conceded) {
      drawDec = -1;
    } else {
      lossDec = -1;
    }

    if (isGroupPhase) {
      _wins += winDec;
      _draws += drawDec;
      _losses += lossDec;
      _goalsFor -= scored;
      _goalsAgainst -= conceded;
      _matches--;

      await FirebaseFirestore.instance
          .collection('year')
          .doc(thisYearNow.toString())
          .collection('teams')
          .doc(name)
          .set({
        'Wins': FieldValue.increment(winDec),
        'Draws': FieldValue.increment(drawDec),
        'Loses': FieldValue.increment(lossDec),
        'Matches': FieldValue.increment(-1),
        'goalsFor': FieldValue.increment(-scored),
        'goalsAgainst': FieldValue.increment(-conceded),
      }, SetOptions(merge: true));
    }

    await shiftRightAndClearLast();
  }

  bool changeFavourite() {
    _isFavourite = !_isFavourite;
    return _isFavourite;
  }

//αναβάθμιση 5 τελευταίων αποτελεσματων
  Future<void> updateHistory(String newResult) async {
    final validResults = ['W', 'D', 'L'];
    if (!validResults.contains(newResult)) {
      throw Exception("Invalid result: must be W, D, or L");
    }

    final userRef = FirebaseFirestore.instance
        .collection('year')
        .doc(thisYearNow.toString())
        .collection('teams')
        .doc(name);
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
    final userRef = FirebaseFirestore.instance
        .collection('year')
        .doc(thisYearNow.toString())
        .collection('teams')
        .doc(name);

    final snapshot = await userRef.get();
    if (!snapshot.exists) return;

    List<String> history =
        List<String>.from(snapshot.data()?['LastFive'] ?? []);

    // Γεμίζουμε μέχρι 6 θέσεις
    while (history.length < 6) {
      history.add("");
    }

    // Shift: βάζουμε κενό στην αρχή, μετακινούμε όλα, κόβουμε το τελευταίο
    history.insert(0, "");
    if (history.length > 6) {
      history.removeLast();
    }

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

  //Future<void> loadTeamImage() async {
  //  try {
  //    // Προσπάθεια να φορτωθεί το αρχείο
  //    await rootBundle.load('logos/$nameEnglish.png');
  //    _image= Image.asset('logos/$nameEnglish.png');
  //  } catch (e) {
  //    // Αν δεν υπάρχει, χρησιμοποίησε fallback
  //    _image= Image.asset('fotos/default_team_logo.png');
  //  }
  //}

  Widget get image {
    final String v =
        '2'; //FirebaseRemoteConfig.instance.getString('logo_version');
    final String imageUrl =
        "https://firebasestorage.googleapis.com/v0/b/auth-score-742c5.firebasestorage.app/o/logos%2F${nameEnglish.toUpperCase()}.png?alt=media&v=$v";

    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheKey: "${nameEnglish.toUpperCase()}_$v",
      memCacheHeight: 100,
      memCacheWidth: 100,
      placeholder: (context, url) => Image.asset(
        'fotos/default_team_logo.png',
        width: 25,
        height: 25,
      ),
      errorWidget: (context, url, error) => Image.asset(
        'fotos/default_team_logo.png',
        width: 25,
        height: 25,
        fit: BoxFit.contain,
      ),
      width: 25,
      height: 25,
      fit: BoxFit.contain,
      fadeInDuration: const Duration(milliseconds: 20),
    );
  }



  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Team && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  // Μετατρέπει την ομάδα (και τους παίκτες της) σε Map για το Firebase
  Map<String, dynamic> toMap() {
    // 1. Μετατρέπουμε όλους τους παίκτες της ομάδας σε ένα Map
    Map<String, dynamic> playersMap = {};
    for (var player in _players) {
      // Χρησιμοποιούμε το όνομα+νούμερο ως κλειδί, όπως το είχαμε συμφωνήσει!
      playersMap['${player.name}${player.number}'] = player.toMap2();
    }

    // 2. Επιστρέφουμε τα στοιχεία της ομάδας
    return {
      'Name': name,
      'NameEnglish': _nameEnglish,
      'Coach': _coach,
      'Matches': _matches,
      'Wins': _wins,
      'Loses':
          _losses, // Προσοχή στο όνομα (Loses) για να ταιριάζει με τη βάση σου
      'Draws': _draws,
      'Group': _group,
      'Foundation Year': _foundationYear,
      'Titles': _titles,
      'initials': _initials,
      'position': _position,
      'goalsFor': _goalsFor,
      'goalsAgainst': _goalsAgainst,
      'LastFive': last5Results,
      'Players': playersMap, // Το Map των παικτών που φτιάξαμε παραπάνω
    };
  }
}
