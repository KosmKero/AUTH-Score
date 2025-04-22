import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:untitled1/API/Match_Handle.dart';
import 'package:untitled1/API/top_players_handle.dart';
import 'package:untitled1/Data_Classes/Player.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';

import '../globals.dart';
import 'Team.dart';
import 'match_facts.dart';

class MatchDetails extends ChangeNotifier {
  //με το _ γινεται private

  ValueNotifier<bool> _notify = ValueNotifier<bool>(false);
  bool _hasMatchStarted = false;
  bool _hasMatchFinished = false,
      _hasSecondHalfStarted = false,
      _hasFirstHalfFinished = false;
  late int _scoreHome, _scoreAway, _day, _month, _year, _time;
  late Team _homeTeam, _awayTeam;
  late int _startTimeInSeconds;
  late bool
      _isGroupPhase; //μεταβλητη που δειχνει αν ειμαστε στη φαση των ομιλων ή στα νοκ αουτς (true->όμιλοι,false->νοκ αουτς)
  late int
      _game; //αν ειμαστε σε ομιλους δειχνει την αγωνιστικη, αλλιως δειχνει τη φαση των νοκα ουτς (16 , 8 ,4 η τελικός)

  late DocumentSnapshot _data;

  String selectedFormationHome = "4-3-3"; // Προεπιλεγμένο σύστημα
  String selectedFormationAway = "4-3-3";
  //final Map<int,List<Goal>> _goalsList={0:[],1:[]};
  //final Map<int, List<CardP>> _cardList = {0:[],1:[]};

  late Map<int, List<MatchFact>> _matchFacts = {0: [], 1: []};
  StreamSubscription<DocumentSnapshot>? _matchSubscription;

  //Μαπ που θα δειχνει ποιοι παιχτες επιλέχθηκαν απο τον αντμιν για την αρχικη ενδεκαδα,
  // για να μη του εμφανιζονται σαν επιλογη στο gui
  Map<Player, bool> playersSelectedHome = {};
  Map<Player, bool> playersSelectedAway = {};

  Map<Player?,int> players11Home = {};
  Map<Player?,int> players11Away = {};


  MatchDetails(
      {required Team homeTeam,
      required Team awayTeam,
      required bool hasMatchStarted,
      required bool hasMatchFinished,
      required bool hasSecondHalfStarted,
      required bool hasFirstHalfFinished,
      required int time,
      required int day,
      required int month,
      required year,
      required isGroupPhase,
      required game,
      required int scoreHome,
      required int scoreAway,
      required int timeStarted,
     // required this.selectedFormationHome,
     // required this.selectedFormationAway,
     // required Map<String,int> playersI11Home,
     // required Map<String,int> playersI11Away,
     // required Map<String,bool> selectedHome,
     // required Map<String,bool> selectedAway
       }) {
    _homeTeam = homeTeam;
    _awayTeam = awayTeam;
    _hasMatchStarted = hasMatchStarted;
    _hasMatchFinished = hasMatchFinished;
    _hasSecondHalfStarted = hasSecondHalfStarted;
    _hasFirstHalfFinished = hasFirstHalfFinished;
    if (hasMatchFinished) {
      _hasSecondHalfStarted = true;
      _hasFirstHalfFinished = true;
      _hasMatchStarted=true;
    }

    _time = time;
    _day = day;
    _month = month;
    _year = year;
    _startTimeInSeconds = timeStarted;
    _scoreHome = scoreHome;
    _scoreAway = scoreAway;

    _isGroupPhase = isGroupPhase;
    _game = game;

    /*for (final entry in selectedHome.entries) {
      final name = entry.key;
      final isSelected = entry.value;

      final player = homeTeam.players.firstWhere(
            (p) => p.name == name,
      );

      playersSelectedHome[player] = isSelected;
    }

    for (final entry in selectedAway.entries) {
      final name = entry.key;
      final isSelected = entry.value;

      final player = awayTeam.players.firstWhere(
            (p) => p.name == name,
      );

      playersSelectedAway[player] = isSelected;
    }

// Θέσεις στην ενδεκάδα
    for (final entry in playersI11Home.entries) {
      final name = entry.key;
      final position = entry.value;

      final player = homeTeam.players.firstWhere(
            (p) => p.name == name,
      );

      players11Home[player] = position;
    }

    for (final entry in playersI11Away.entries) {
      final name = entry.key;
      final position = entry.value;

      final player = awayTeam.players.firstWhere(
            (p) => p.name == name,
      );

      players11Away[player] = position;
    }

     */


    loadMatchFactsFromBase();

    _notify =  ValueNotifier<bool>((globalUser.matchKeys[matchKey] ??
        (globalUser.favoriteList.contains(homeTeam.name) ||
            globalUser.favoriteList.contains(awayTeam.name))));


    _startListeningForUpdates();
  }

  factory MatchDetails.fromFirestore(DocumentSnapshot data) {


    List<List<Player?>> players11 = [[], []];

    return MatchDetails(
      homeTeam: data["Hometeam"] ?? "",
      awayTeam: data["Awayteam"] ?? "",
      hasMatchStarted: data['HasMatchStarted'] ?? false,
      time: data["Time"] ?? 0,
      day: data["Day"] ?? 0,
      month: data["Month"] ?? 0,
      year: data["Year"] ?? 0,
      isGroupPhase: data["IsGroupPhase"] ?? false,
      game: data["Game"] ?? 0,
      scoreHome: data["GoalHome"] ?? -1,
      scoreAway: data["GoalAway"] ?? -1,
      hasMatchFinished: data["hasMatchFinished"],
      hasSecondHalfStarted: data["hasSecondHalfStarted"],
      hasFirstHalfFinished: data["hasFirstHalfFinished"],
      timeStarted: data["TimeStarted"] ?? DateTime.now().millisecondsSinceEpoch,
      //selectedFormationHome: data["selectedFormationHome"] ?? "4-3-3",
      //selectedFormationAway: data["selectedFormationAway"] ?? "4-3-3",
      //playersI11Home: Map<String, int>.from(data["playersI11Home"] ?? {}), //φορτωνουμε μαπ με αρχικη ενδεκαδα (ονομα παιχτη, θεση)
      //playersI11Away: Map<String, int>.from(data["playersI11Away"] ?? {}), //φορτωνουμε μαπ με αρχικη ενδεκαδα (ονομα παιχτη, θεση)
      //selectedHome: Map<String, bool>.from(data["selectedHome"] ?? {}), //φορτωνουμε μαπ με επιλεγμενους παιχτες (ονομα παιχτη, αν ειναι επιλεγμενους)
      //selectedAway: Map<String, bool>.from(data["selectedAway"] ?? {}), //φορτωνουμε μαπ με επιλεγμενους παιχτες (ονομα παιχτη, αν ειναι επιλεγμενους)

    );
  }

  Team get homeTeam => _homeTeam;
  Team get awayTeam => _awayTeam;
  bool get hasMatchStarted => _hasMatchStarted;
  bool get hasFirstHalfFinished => _hasFirstHalfFinished;
  bool get hasMatchFinished => _hasMatchFinished;
  bool get hasSecondHalfStarted => _hasSecondHalfStarted;
  int get scoreHome => _scoreHome;
  int get scoreAway => _scoreAway;
  int get time => _time;
  int get day => _day;
  int get month => _month;
  int get year => _year;
  int get startTimeInSeconds => _startTimeInSeconds;
  bool get isGroupPhase=> _isGroupPhase;
  int get game => _game;
  ValueNotifier<bool> get notify => _notify;

  String get matchKey => '${homeTeam.nameEnglish}$day$month$year$game${awayTeam.nameEnglish}';



  bool isHalfTime() {
    if (hasFirstHalfFinished && !hasSecondHalfStarted) {
      return true;
    }
    return false;
  }

  //Συναρτησεις για αποθηκευση δεδομενων στη βαση
  //progress αν ειναι τρου προχωραει το ματς αλλιως κανει κανσελ
  Future<void> matchStartedBase(bool progress) async {
    await FirebaseFirestore.instance
        .collection('matches')
        .doc(matchDocId)
        .set({
      'HasMatchStarted': progress,
      'TimeStarted': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'GoalAway': 0,
      'GoalHome': 0
    }, SetOptions(merge: true));
  }

  Future<void> firstHalfFinishedBase(bool progress) async {
    await FirebaseFirestore.instance
        .collection('matches')
        .doc(matchDocId)
        .set({
      'hasFirstHalfFinished': progress,
    }, SetOptions(merge: true)); // ώστε να μη διαγράψει άλλα πεδία
  }

  Future<void> secondHalfStartedBase(bool progress) async {
    await FirebaseFirestore.instance
        .collection('matches')
        .doc(matchDocId)
        .set({
      'hasSecondHalfStarted': progress,
      'TimeStarted': DateTime.now().millisecondsSinceEpoch ~/ 1000 - 45 * 60
    }, SetOptions(merge: true)); // ώστε να μη διαγράψει άλλα πεδία
  }

  Future<void> matchFinishedBase(bool progress) async {
    String type = progress ? "previous" : "upcoming";

    await FirebaseFirestore.instance
        .collection('matches')
        .doc(matchDocId)
        .set({'hasMatchFinished': progress, 'Type': type},
            SetOptions(merge: true)); // ώστε να μη διαγράψει άλλα πεδία

    String matchKey = '${homeTeam.name}${awayTeam.name}${dateString}';

    String correctChoice;
    (scoreHome>scoreAway) ? correctChoice="1": (scoreHome==scoreAway)? correctChoice="X": correctChoice="2";

    await FirebaseFirestore.instance
        .collection('votes')
        .doc(matchKey)
        .set({'hasMatchFinished': progress,
              'correctChoice': correctChoice,
              'statsUpdated': false},
        SetOptions(merge: true)); // ώστε να μη διαγράψει άλλα πεδία
  }

  Future<void> homeScoredBase() async {
    await FirebaseFirestore.instance
        .collection('matches')
        .doc(matchDocId)
        .set({
      'GoalHome': FieldValue.increment(1),
    }, SetOptions(merge: true)); // ώστε να μη διαγράψει άλλα πεδία
  }

  Future<void> awayScoredBase() async {
    await FirebaseFirestore.instance
        .collection('matches')
        .doc(matchDocId)
        .set({
      'GoalAway': FieldValue.increment(1),
    }, SetOptions(merge: true)); // ώστε να μη διαγράψει άλλα πεδία
  }

  Future<void> loadMatchFactsFromBase() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('matches')
        .doc(matchDocId)
        .get();

    final data = docSnapshot.data();
    if (data != null && data.containsKey('facts')) {
      _matchFacts = await MatchFactsStorageHelper.decodeMatchFacts(
          Map<String, dynamic>.from(data['facts']));
    }
  }

  //Map<int,List<Goal>> get goalsList => _goalsList;
  Map<int, List<MatchFact>> get matchFact => _matchFacts;

  String get timeString {
    int hour = time ~/ 100;
    int min = time % 100;
    return "${hour.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}";
  }

  String get dateString {
    return "${_day.toString().padLeft(2, '0')}.${_month.toString().padLeft(2, '0')}.${_year.toString().substring(2,4)}";
  }

  Future<void> setScoreHome(int score) async {
    _scoreHome = score;

    await FirebaseFirestore.instance
        .collection('matches')
        .doc(matchDocId)
        .set({
      'GoalHome': score,
    }, SetOptions(merge: true));
  }

  Future<void> setScoreAway(int score) async {
    _scoreAway = score;

    await FirebaseFirestore.instance
        .collection('matches')
        .doc(matchDocId)
        .set({
      'GoalAway': score,
    }, SetOptions(merge: true));
  }

  void matchStarted() {
    _scoreHome = 0;
    _scoreAway = 0;
    _startTimeInSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _hasMatchStarted = true;
    matchStartedBase(true);
    notifyListeners();
  }

  void secondHalfStarted() {
    _hasSecondHalfStarted = true;
    secondHalfStartedBase(true);
    notifyListeners();
  }

  void firstHalfFinished() {
    _hasFirstHalfFinished = true;
    firstHalfFinishedBase(true);
  }

  //ετοιμο
  Future<void> homeScored(String name) async {
    if (hasMatchStarted && globalUser.controlTheseTeams(homeTeam.name, awayTeam.name)) {
      int half;
      (!_hasSecondHalfStarted) ? half = 0 : half = 1;

      _scoreHome++;
      homeScoredBase();

      Goal goal = Goal(
          scorerName: name,
          homeScore: _scoreHome,
          awayScore: _scoreAway,
          minute: DateTime.now().millisecondsSinceEpoch ~/ 1000 -
              startTimeInSeconds,
          isHomeTeam: true,
          team: homeTeam,
          half: half);

      _matchFacts[half]?.add(goal);

      for (Player player in homeTeam.players) {
        if ("${player.name.substring(0, 1)}. ${player.surname}" == name) {
          TopPlayersHandle().playerScored(player);
          break;
        }
      }

      MatchFactsStorageHelper().addMatchFact(
          matchDoc:
              FirebaseFirestore.instance.collection('matches').doc(matchDocId),
          half: half,
          factMap: goal.toMap());

      notifyListeners();
    }
  }

  //ετοιμο
  void awayScored(String name) {
    if (!hasMatchFinished && globalUser.controlTheseTeams(homeTeam.name, awayTeam.name)) {
      int half;
      (!_hasSecondHalfStarted) ? half = 0 : half = 1;

      _scoreAway++;
      awayScoredBase();

      Goal goal = Goal(
          scorerName: name,
          homeScore: _scoreHome,
          awayScore: _scoreAway,
          minute: DateTime.now().millisecondsSinceEpoch ~/ 1000 -
              startTimeInSeconds,
          isHomeTeam: false,
          team: awayTeam,
          half: half);

      _matchFacts[half]?.add(goal);

      for (Player player in awayTeam.players) {
        if ("${player.name.substring(0, 1)}. ${player.surname}" == name) {
          TopPlayersHandle().playerScored(player);
          break;
        }
      }

      MatchFactsStorageHelper().addMatchFact(
          matchDoc:
              FirebaseFirestore.instance.collection('matches').doc(matchDocId),
          half: half,
          factMap: goal.toMap());

      notifyListeners();
    }
  }

  //ετοιμο
  void matchProgressed() {
    if (_hasSecondHalfStarted) {
      if (!_hasMatchFinished) {
        MatchHandle().matchFinished(this);
      }
      _hasMatchFinished = true;
      matchFinishedBase(true);
      updateStandings(true);

      notifyListeners();
    } else if (_hasFirstHalfFinished) {
      _hasSecondHalfStarted = true;
      _startTimeInSeconds =
          DateTime.now().millisecondsSinceEpoch ~/ 1000 - 45 * 60;
      secondHalfStartedBase(true);
    } else if (_hasMatchStarted) {
      _hasFirstHalfFinished = true;
      firstHalfFinishedBase(true);
    }
  }

  void updateStandings(bool progress) {
    if (progress) {
      if (scoreHome == scoreAway) {
        homeTeam.increaseDraws();
        awayTeam.increaseDraws();
      } else if (scoreHome > scoreAway) {
        homeTeam.increaseWins();
        awayTeam.increaseLoses();
      } else {
        homeTeam.increaseLoses();
        awayTeam.increaseWins();
      }
    } else {
      if (scoreHome == scoreAway) {
        homeTeam.reduceDraws();
        awayTeam.reduceDraws();
      } else if (scoreHome > scoreAway) {
        homeTeam.reduceWins();
        awayTeam.reduceLoses();
      } else {
        homeTeam.reduceLoses();
        awayTeam.reduceWins();
      }
    }
    if (isGroupPhase) {
      TeamsHandle().sortTeams(homeTeam.group);
    }
  }

  //ετοιμο
  void matchCancelProgressed() {
    if (_hasMatchFinished &&
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) - startTimeInSeconds <
            3600) {
      if (_hasMatchFinished) {
        MatchHandle().matchNotFinished(this);
        updateStandings(false);
      }
      _hasMatchFinished = false;
      matchFinishedBase(false);
      notifyListeners();
    } else if (_hasSecondHalfStarted) {
      _hasSecondHalfStarted = false;
      secondHalfStartedBase(false);
    } else if (_hasFirstHalfFinished) {
      _hasFirstHalfFinished = false;
      firstHalfFinishedBase(false);
    } else if (_hasMatchStarted) {
      _hasMatchStarted = false;
      matchStartedBase(false);
      notifyListeners();
    }
  }

  String matchweekInfo() {
    String info;
    _isGroupPhase ?greek?info = "Φάση ομίλων":info = "Group Stage"
        :greek? info = "Φάση των $_game: Νοκ Άουτ":info = "Stage $_game: Round of 16";
    return info;
  }

  //ετοιμο
  Future<void> playerGotCard(
      String name, Team team, bool isYellow, int? minute, bool isHomeTeam) async {
    if (!hasMatchFinished && globalUser.controlTheseTeams(homeTeam.name, awayTeam.name)) {

      for (Player player in team.players) {
        if ("${player.name.substring(0, 1)}. ${player.surname}" == name) {
          isYellow ? await player.gotYellowCard() : await player.gotRedCard();
          break;
        }
      }
      int half;
      (!_hasSecondHalfStarted) ? half = 0 : half = 1;

      CardP card = CardP(
          playerName: name,
          team: team,
          isYellow: isYellow,
          minute: minute ??
              (DateTime.now().millisecondsSinceEpoch ~/ 1000) -
                  startTimeInSeconds,
          isHomeTeam: isHomeTeam,
          half: half);

      _matchFacts[half]?.add(card);
      await MatchFactsStorageHelper().addMatchFact(
          matchDoc:
              FirebaseFirestore.instance.collection('matches').doc(matchDocId),
          half: half,
          factMap: card.toMap());
      notifyListeners();
    }
  }

  //ετοιμο
  Future<void> cancelGoal(Goal goal1) async {
    if (!hasMatchFinished && globalUser.controlTheseTeams(homeTeam.name, awayTeam.name)) {
      if (_matchFacts.containsKey(goal1.half)) {
        _matchFacts[goal1.half]!
            .removeWhere((goal) => goal is Goal && goal == goal1);

        goal1.isHomeTeam ? _scoreHome-- : _scoreAway--;
        for (Player player in goal1.team.players) {
          if ("${player.name[0]}. ${player.surname}" == goal1.scorerName) {
            TopPlayersHandle().goalCancelled(player);
            break;
          }
        }

        await MatchFactsStorageHelper().deleteMatchFact(
            matchDoc: FirebaseFirestore.instance
                .collection('matches')
                .doc(matchDocId),
            half: goal1.half,
            factMap: goal1.toMap());

        String type;
        (goal1.isHomeTeam) ? (type = 'GoalHome') : (type = 'GoalAway');
        await FirebaseFirestore.instance
            .collection('matches')
            .doc(matchDocId)
            .set({
          type: FieldValue.increment(-1),
        }, SetOptions(merge: true));

        notifyListeners(); // Ενημέρωση των listeners για την αλλαγή
      }
    }
  }

  //ετοιμο
  void cancelCard(CardP card1) {
    if (!hasMatchFinished && globalUser.controlTheseTeams(homeTeam.name, awayTeam.name)) {
      if (_matchFacts.containsKey(card1.half)) {
        _matchFacts[card1.half]!
            .removeWhere((card) => card is CardP && card == card1);

        for (Player player in card1.team.players) {
          if ("${player.name.substring(0, 1)}. ${player.surname}" ==
              card1.name) {
            card1.isYellow ? player.cancelYellowCard() : player.cancelRedCard();
            break;
          }
        }

        MatchFactsStorageHelper().deleteMatchFact(
            matchDoc: FirebaseFirestore.instance
                .collection('matches')
                .doc(matchDocId),
            half: card1.half,
            factMap: card1.toMap());

        notifyListeners(); // Ενημέρωση των listeners για την αλλαγή
      }
    }
  }

  void makeAllFalse(int i) {
    for (Player player in (i == 0) ? homeTeam.players : awayTeam.players) {
      playersSelectedHome[player] = false;
      playersSelectedAway[player] = false;
    }
  }

  void _startListeningForUpdates() {

    _matchSubscription = FirebaseFirestore.instance
        .collection('matches')
        .doc(matchDocId)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      bool changed = false;

      // Update each field only if it changed
      if (_hasMatchStarted != (data['HasMatchStarted'] ?? false)) {
        _hasMatchStarted = data['HasMatchStarted'] ?? false;
        changed = true;
      }

      if (_hasFirstHalfFinished != (data['hasFirstHalfFinished'] ?? false)) {
        _hasFirstHalfFinished = data['hasFirstHalfFinished'] ?? false;
        changed = true;
      }

      if (_hasSecondHalfStarted != (data['hasSecondHalfStarted'] ?? false)) {
        _hasSecondHalfStarted = data['hasSecondHalfStarted'] ?? false;
        changed = true;
      }

      if (_hasMatchFinished != (data['hasMatchFinished'] ?? false)) {
        _hasMatchFinished = data['hasMatchFinished'] ?? false;
        changed = true;
      }

      if (_scoreHome != (data['GoalHome'] ?? 0)) {
        _scoreHome = data['GoalHome'] ?? 0;
        changed = true;
      }

      if (_scoreAway != (data['GoalAway'] ?? 0)) {
        _scoreAway = data['GoalAway'] ?? 0;
        changed = true;
      }

      if (_startTimeInSeconds != (data['TimeStarted'] ?? 0)) {
        _startTimeInSeconds = data['TimeStarted'] ?? 0;
        changed = true;
        print("$_startTimeInSeconds $changed");
      }

      // Update match facts only if present
      if (data.containsKey('facts')) {
        final factsMap = Map<String, dynamic>.from(data['facts']);
        final decodedFacts =
            await MatchFactsStorageHelper.decodeMatchFacts(factsMap);
        _matchFacts = decodedFacts;
        changed = true;
      }

      if (changed) notifyListeners();
    });
  }

  String get matchDocId {
    return homeTeam.nameEnglish +
        day.toString() +
        month.toString() +
        year.toString() +
        _game.toString() +
        awayTeam.nameEnglish;
  }

  @override
  void dispose() {
    _matchSubscription?.cancel();
    super.dispose();
  }

  void enableNotify(bool notify){
    _notify.value=notify;
  }

}



class MatchFactsStorageHelper {
  // Μετατρέπει το Map<int, List<MatchFact>> σε Map<String, dynamic> για Firestore
  Map<String, dynamic> encodeMatchFacts(Map<int, List<MatchFact>> facts) {
    return facts.map((half, factList) {
      return MapEntry(
        half.toString(),
        factList.map((fact) {
          if (fact is Goal) {
            return fact.toMap(); // Δεν προσθέτουμε το 'type' εδώ
          } else if (fact is CardP) {
            return fact.toMap(); // Δεν προσθέτουμε το 'type' εδώ
          } else {
            throw Exception('Unknown MatchFact type');
          }
        }).toList(),
      );
    });
  }

  //Δουλευει
  // Μετατρέπει τα δεδομένα από Firestore πίσω σε Map<int, List<MatchFact>>
  // Κάνουμε την decodeMatchFacts async
  static Future<Map<int, List<MatchFact>>> decodeMatchFacts(
    Map<String, dynamic> firestoreMap,
  ) async {
    final Map<int, List<MatchFact>> result = {};

    // Για κάθε μισό του παιχνιδιού
    for (var halfKey in firestoreMap.keys) {
      int half = int.parse(halfKey);
      List<dynamic> factList = firestoreMap[halfKey] as List<dynamic>;

      // Χρησιμοποιούμε await για να πάρουμε την ομάδα
      List<MatchFact> matchFacts =
          await Future.wait(factList.map<Future<MatchFact>>((item) async {
        final Map<String, dynamic> map = Map<String, dynamic>.from(item);
        final String type = map['type'];

        // Περιμένουμε την ομάδα πριν προχωρήσουμε με τα υπόλοιπα
        final Team team = await TeamsHandle().getTeam(map['team']) as Team;

        if (type == 'goal') {
          return Goal.fromMap(map, team);
        } else if (type == 'card') {
          return CardP.fromMap(map, team);
        } else {
          throw Exception('Unknown type: $type');
        }
      }));

      // Προσθέτουμε τα γεγονότα για το συγκεκριμένο μισό
      result[half] = matchFacts;

      // Ταξινομούμε ανά λεπτό (αν χρειάζεται)
      result[half]?.sort((a, b) => a.minute.compareTo(b.minute));
    }

    return result;
  }

//Δουλευει
  //προσθηκη ενος γκολ ή κάρτας
  Future<void> addMatchFact({
    required DocumentReference matchDoc,
    required int half,
    required Map<String, dynamic> factMap,
  }) async {
    try {
      await matchDoc.update({
        'facts.$half': FieldValue.arrayUnion([factMap]),
      });
    } catch (e) {
      print('🔥 Error adding match fact: $e');
      // μπορείς να ρίξεις throw αν θες να το χειριστείς από πάνω
      // throw e;
    }
  }

  Future<void> deleteMatchFact({
    required DocumentReference matchDoc,
    required int half,
    required Map<String, dynamic>
        factMap, // Το γεγονός που θέλεις να διαγράψεις
  }) async {
    try {
      // Χρησιμοποιούμε την arrayRemove για να διαγράψουμε το γεγονός από την λίστα
      await matchDoc.update({
        'facts.$half': FieldValue.arrayRemove([factMap]),
      });

      print("🎯 Το γεγονός διαγράφηκε επιτυχώς από τη βάση δεδομένων.");
    } catch (e) {
      print('🔥 Σφάλμα κατά τη διαγραφή του γεγονότος: $e');
    }
  }
}
