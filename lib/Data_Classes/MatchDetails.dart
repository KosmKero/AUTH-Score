import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:untitled1/API/Match_Handle.dart';
import 'package:untitled1/API/top_players_handle.dart';
import 'package:untitled1/Data_Classes/Player.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';

import '../globals.dart';
import '../globals.dart' as global;
import 'Penaltys.dart';
import 'Team.dart';
import 'match_facts.dart';

class MatchDetails extends ChangeNotifier {
  //με το _ γινεται private

  late PenaltyShootout penaltyShootout;

  ValueNotifier<bool> _notify = ValueNotifier<bool>(false);
  bool _hasMatchStarted = false;
  bool _hasMatchFinished = false,
      _hasSecondHalfStarted = false,
      _hasFirstHalfFinished = false;
  late int _scoreHome,
      _scoreAway,
      _day,
      _month,
      _year,
      _time,
      _scoreHomeExtraTime,
      _scoreAwayExtraTime,
      _slot; //δειχνει σε ποιο μπρακετ θα ειναι το ματς
  late Team _homeTeam, _awayTeam;
  late int _startTimeInSeconds;
  late bool
      _isGroupPhase; //μεταβλητη που δειχνει αν ειμαστε στη φαση των ομιλων ή στα νοκ αουτς (true->όμιλοι,false->νοκ αουτς)
  late int
      _game; //αν ειμαστε σε ομιλους δειχνει την αγωνιστικη, αλλιως δειχνει τη φαση των νοκα ουτς (16 , 8 ,4 η τελικός)

  late bool _hasFirstHalfExtraTimeFinished,
      _hasExtraTimeFinished,
      _hasExtraTimeStarted,
      _hasSecondHalfExtraTimeStarted;

  late bool penaltyOver;
  late DocumentSnapshot _data;

  String selectedFormationHome = "4-3-3"; // Προεπιλεγμένο σύστημα
  String selectedFormationAway = "4-3-3";
  //final Map<int,List<Goal>> _goalsList={0:[],1:[]};
  //final Map<int, List<CardP>> _cardList = {0:[],1:[]};

  late Map<int, List<MatchFact>> _matchFacts = {0: [], 1: [], 2: [], 3: []};
  StreamSubscription<DocumentSnapshot>? _matchSubscription;

  //Μαπ που θα δειχνει ποιοι παιχτες επιλέχθηκαν απο τον αντμιν για την αρχικη ενδεκαδα,
  // για να μη του εμφανιζονται σαν επιλογη στο gui
  Map<Player, bool> playersSelectedHome = {};
  Map<Player, bool> playersSelectedAway = {};

  Map<Player?, int> players11Home = {};
  Map<Player?, int> players11Away = {};


  late int hour = _time ~/ 100;

  late int minute = time % 100;

  // Δημιουργία DateTime
  late DateTime matchDateTime = DateTime(year, month, day, hour, minute);


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
      required hasFirstHalfExtraTimeFinished,
      required hasExtraTimeFinished,
      required hasExtraTimeStarted,
      required hasSecondHalfExtraTimeStarted,
      required scoreAwayExtraTime,
      required scoreHomeExtraTime,
      required penalties,
      required slot
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
    penaltyShootout = PenaltyShootout([]);

    _hasFirstHalfExtraTimeFinished = hasFirstHalfExtraTimeFinished;
    _hasExtraTimeFinished = hasExtraTimeFinished;
    _hasExtraTimeStarted = hasExtraTimeStarted;
    _hasSecondHalfExtraTimeStarted = hasSecondHalfExtraTimeStarted;

    _scoreAwayExtraTime = scoreAwayExtraTime;
    _scoreHomeExtraTime = scoreHomeExtraTime;


    if (hasMatchFinished) {
      _hasSecondHalfStarted = true;
      _hasFirstHalfFinished = true;
      _hasMatchStarted = true;
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


    if (_hasExtraTimeFinished) {
      loadPenaltys();
    }
    penaltyOver=isShootoutOver;
    _slot = slot;


    _notify = ValueNotifier<bool>((globalUser.matchKeys[matchKey] ??
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
        timeStarted:
            data["TimeStarted"] ?? DateTime.now().millisecondsSinceEpoch,
        hasFirstHalfExtraTimeFinished:
            data['hasFirstHalfExtraTimeFinished'] ?? false,
        hasExtraTimeFinished: data['hasExtraTimeFinished'] ?? false,
        hasExtraTimeStarted: data['hasExtraTimeStarted'] ?? false,
        hasSecondHalfExtraTimeStarted:
            data['hasSecondHalfExtraTimeStarted'] ?? false,
        scoreAwayExtraTime: data['scoreAwayExtraTime'] ?? 0,
        scoreHomeExtraTime: data['scoreHomeExtraTime'] ?? 0,
        penalties: (data['penalties'] as List<dynamic>? ?? [])
            .map((p) => PenaltyShoot.fromMap(Map<String, dynamic>.from(p)))
            .toList(),
        slot: data["slot"]

        //selectedFormationHome: data["selectedFormationHome"] ?? "4-3-3",
        //selectedFormationAway: data["selectedFormationAway"] ?? "4-3-3",
        //playersI11Home: Map<String, int>.from(data["playersI11Home"] ?? {}), //φορτωνουμε μαπ με αρχικη ενδεκαδα (ονομα παιχτη, θεση)
        //playersI11Away: Map<String, int>.from(data["playersI11Away"] ?? {}), //φορτωνουμε μαπ με αρχικη ενδεκαδα (ονομα παιχτη, θεση)
        //selectedHome: Map<String, bool>.from(data["selectedHome"] ?? {}),    //φορτωνουμε μαπ με επιλεγμενους παιχτες (ονομα παιχτη, αν ειναι επιλεγμενους)
        //selectedAway: Map<String, bool>.from(data["selectedAway"] ?? {}),    //φορτωνουμε μαπ με επιλεγμενους παιχτες (ονομα παιχτη, αν ειναι επιλεγμενους)

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
  bool get isGroupPhase => _isGroupPhase;
  int get game => _game;
  int get slot => _slot;
  ValueNotifier<bool> get notify => _notify;

  String get matchKey =>
      '${homeTeam.nameEnglish}$day$month$year$game${awayTeam.nameEnglish}';

  bool get hasFirstHalfExtraTimeFinished => _hasFirstHalfExtraTimeFinished;
  bool get hasExtraTimeFinished => _hasExtraTimeFinished;
  bool get hasExtraTimeStarted => _hasExtraTimeStarted;
  bool get hasSecondHalfExtraTimeStarted => _hasSecondHalfExtraTimeStarted;

  int get homeScore => _scoreHome + _scoreHomeExtraTime;
  int get awayScore => _scoreAway + _scoreAwayExtraTime;

  int get penaltyScoreHome => penaltyShootout.homeScore;
  int get penaltyScoreAway => penaltyShootout.awayScore;



  bool get isPenaltyTime => _hasExtraTimeFinished && (homeScore == awayScore);




  bool get isShootoutOver {
    final homePenalties =
        penaltyShootout.penalties.where((p) => p.isHomeTeam).toList();
    final awayPenalties =
        penaltyShootout.penalties.where((p) => !p.isHomeTeam).toList();

    final int homeScore = homePenalties.where((p) => p.isScored).length;
    final int awayScore = awayPenalties.where((p) => p.isScored).length;

    final int homeShots = homePenalties.length;
    final int awayShots = awayPenalties.length;


    // 1. Πριν τα 5 πέναλτι, έλεγχος αν υπάρχει μη αναστρέψιμη διαφορά
    if (homeShots < 5 || awayShots < 5) {
      final remainingHome = 5 - homeShots;
      final remainingAway = 5 - awayShots;

      if (homeScore > awayScore + remainingAway) return true;
      if (awayScore > homeScore + remainingHome) return true;

      return false;
    }

    // 2. Αν συμπληρώθηκαν τα 5: αν έχουμε νικητή
    if (homeShots == 5 && awayShots == 5 && homeScore != awayScore) {
      return true;
    }

    // 3. Ξαφνικός θάνατος (sudden death)
    if (homeShots > 5 && awayShots > 5) {
      // πάντα ίσος αριθμός εκτελέσεων για να συνεχιστεί
      if (homeShots == awayShots && homeScore != awayScore) {
        return true;
      }
    }

    return false;
  }

  Future<void> loadPenaltys() async {
    penaltyShootout = await PenaltyShootout.loadFromFirestore(matchKey, _year, _month);
    notifyListeners();
  }

  bool isHalfTime() {
    return (hasFirstHalfFinished && !hasSecondHalfStarted);
  }

  bool isExtraTimeHalf() {
    return (hasFirstHalfExtraTimeFinished && !hasSecondHalfExtraTimeStarted);
  }

  //Συναρτησεις για αποθηκευση δεδομενων στη βαση
  //progress αν ειναι τρου προχωραει το ματς αλλιως κανει κανσελ

  Future<void> progressS(String ofWhat, bool progress) async {
    await FirebaseFirestore.instance.collection('year').doc(global.thisYearNow.toString()).collection("matches").doc(matchDocId).set({
      ofWhat: progress,
    }, SetOptions(merge: true)); // ώστε να μη διαγράψει άλλα πεδία
  }

  Future<void> updateTime(int time1) async {
    await FirebaseFirestore.instance.collection('year').doc(global.thisYearNow.toString()).collection("matches").doc(matchDocId).set(
        {'TimeStarted': time1},
        SetOptions(merge: true)); // ώστε να μη διαγράψει άλλα πεδία
  }

  Future<void> matchStartedBase(bool progress) async {
    await FirebaseFirestore.instance.collection('year').doc(global.thisYearNow.toString()).collection("matches").doc(matchDocId).set({
      'HasMatchStarted': progress,
      'TimeStarted': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'GoalAway': 0,
      'GoalHome': 0
    }, SetOptions(merge: true));
  }

  Future<void> firstHalfFinishedBase(bool progress) async {
    await FirebaseFirestore.instance.collection('year').doc(global.thisYearNow.toString()).collection("matches").doc(matchDocId).set({
      'hasFirstHalfFinished': progress,
    }, SetOptions(merge: true)); // ώστε να μη διαγράψει άλλα πεδία
  }

  Future<void> secondHalfStartedBase(bool progress) async {
    await FirebaseFirestore.instance.collection('year').doc(global.thisYearNow.toString()).collection("matches").doc(matchDocId).set({
      'hasSecondHalfStarted': progress,
      'TimeStarted': DateTime.now().millisecondsSinceEpoch ~/ 1000 - 45 * 60
    }, SetOptions(merge: true)); // ώστε να μη διαγράψει άλλα πεδία
  }

  Future<void> matchFinishedBase(bool progress) async {
    //String type = progress ? "previous" : "upcoming";

    await FirebaseFirestore.instance.collection('year').doc(global.thisYearNow.toString()).collection("matches").doc(matchDocId).set(
        {'hasMatchFinished': progress},
        SetOptions(merge: true)); // ώστε να μη διαγράψει άλλα πεδία // τελειωσε το ματς
    String matchKey =
        '${homeTeam.nameEnglish}${awayTeam.nameEnglish}${dateString}';

    String correctChoice;
    (scoreHome > scoreAway)
        ? correctChoice = "1"
        : (scoreHome == scoreAway)
            ? correctChoice = "X"
            : correctChoice = "2";

    await FirebaseFirestore.instance.collection('votes').doc(matchKey).set({  // ανανεωση του ματς στο στοιχημα
      'hasMatchFinished': progress,
      'correctChoice': correctChoice,
      'statsUpdated': false,
      'GoalHome': scoreHome,
      'GoalAway': awayScore
    }, SetOptions(merge: true)); // ώστε να μη διαγράψει άλλα πεδία
  }

  Future<void> homeScoredBase() async {
    String goal;
    isExtraTimeTime ? goal = 'GoalHomeExtraTime' : goal = 'GoalHome';
    await FirebaseFirestore.instance.collection('year').doc(global.thisYearNow.toString()).collection("matches").doc(matchDocId).set({
      goal: FieldValue.increment(1),
    }, SetOptions(merge: true)); // ώστε να μη διαγράψει άλλα πεδία
  }

  Future<void> awayScoredBase() async {
    String goal;
    isExtraTimeTime ? goal = 'GoalAwayExtraTime' : goal = 'GoalAway';
    await FirebaseFirestore.instance.collection('year').doc(global.thisYearNow.toString()).collection("matches").doc(matchDocId).set({
      goal: FieldValue.increment(1),
    }, SetOptions(merge: true)); // ώστε να μη διαγράψει άλλα πεδία
  }

  Future<void> loadMatchFactsFromBase() async {
    int yuse =year;
    if (month>9 ){
      yuse = year+1;
    }

    final docSnapshot = await FirebaseFirestore.instance
        .collection('year').doc(yuse.toString()).collection("matches")
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
    return "${_day.toString().padLeft(2, '0')}.${_month.toString().padLeft(2, '0')}.${(_year % 100).toString().padLeft(2, '0')}";
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
  void homeScored(String name, bool hasName) {
    if (hasMatchStarted &&
        globalUser.controlTheseTeamsFootball(homeTeam.name, awayTeam.name)) {
      int half;
      (!isExtraTimeTime)
          ? (!_hasSecondHalfStarted)
              ? half = 0
              : half = 1
          : (!_hasFirstHalfExtraTimeFinished)
              ? half = 2
              : half = 3;

      if (isExtraTimeTime) {
        _scoreHomeExtraTime++;
      } else {
        _scoreHome++;
      }

      homeScoredBase();

      Goal goal = Goal(
          scorerName: name,
          homeScore: homeScore,
          awayScore: awayScore,
          minute: DateTime.now().millisecondsSinceEpoch ~/ 1000 -
              startTimeInSeconds,
          isHomeTeam: true,
          team: homeTeam,
          half: half);

      _matchFacts[half]?.add(goal);

      if (hasName) {
        for (Player player in homeTeam.players) {
          if ("${player.name.substring(0, 1)}. ${player.surname}" == name) {
            TopPlayersHandle().playerScored(player);
            break;
          }
        }
      }

      MatchFactsStorageHelper().addMatchFact(
          matchDoc:
              FirebaseFirestore.instance.collection('year').doc(global.thisYearNow.toString()).collection("matches").doc(matchDocId),
          half: half,
          factMap: goal.toMap());

      notifyListeners();
    }
  }

  //ετοιμο
  void awayScored(String name, bool hasName) {
    if (hasMatchStarted &&
        globalUser.controlTheseTeamsFootball(homeTeam.name, awayTeam.name)) {
      int half;
      (!isExtraTimeTime)
          ? ((!_hasSecondHalfStarted) ? half = 0 : half = 1)
          : ((!_hasFirstHalfExtraTimeFinished) ? half = 2 : half = 3);

      if (isExtraTimeTime) {
        _scoreAwayExtraTime++;
        awayScoredBase();
      } else {
        _scoreAway++;
        awayScoredBase();
      }
      Goal goal = Goal(
          scorerName: name,
          homeScore: homeScore,
          awayScore: awayScore,
          minute: DateTime.now().millisecondsSinceEpoch ~/ 1000 -
              startTimeInSeconds,
          isHomeTeam: false,
          team: awayTeam,
          half: half);

      _matchFacts[half]?.add(goal);

      if (hasName) {
        for (Player player in awayTeam.players) {
          if ("${player.name.substring(0, 1)}. ${player.surname}" == name) {
            TopPlayersHandle().playerScored(player);
            break;
          }
        }
      }

      MatchFactsStorageHelper().addMatchFact(
          matchDoc:
              FirebaseFirestore.instance.collection('year').doc(global.thisYearNow.toString()).collection("matches").doc(matchDocId),
          half: half,
          factMap: goal.toMap());

      notifyListeners();
    }
  }


  bool get hasMatchEndedFinal{
    return (((_hasMatchFinished && !isExtraTimeTime) || (hasExtraTimeFinished && !isPenaltyTime)) || isShootoutOver );
  }

  //etoimo
  void matchProgressed() {
    if (isExtraTimeTime) {
      if (_hasSecondHalfExtraTimeStarted) {
        _hasExtraTimeFinished = true;
        progressS('hasExtraTimeFinished', true);
        if (!isPenaltyTime) {
          MatchHandle().matchFinished(this);
        }
        notifyListeners();
      } else if (_hasFirstHalfExtraTimeFinished) {
        _hasSecondHalfExtraTimeStarted = true;
        progressS('hasSecondHalfExtraTimeStarted', true);
        _startTimeInSeconds =
            DateTime.now().millisecondsSinceEpoch ~/ 1000 - 105 * 60;
        updateTime(_startTimeInSeconds);
        notifyListeners();
      } else if (_hasExtraTimeStarted) {
        _hasFirstHalfExtraTimeFinished = true;
        progressS('hasFirstHalfExtraTimeFinished', true);

        notifyListeners();
      } else if (_hasMatchFinished) {
        _hasExtraTimeStarted = true;
        progressS('hasExtraTimeStarted', true);
        _startTimeInSeconds =
            DateTime.now().millisecondsSinceEpoch ~/ 1000 - 90 * 60;
        updateTime(_startTimeInSeconds);
        notifyListeners();
      }
      return;
    }
    if (_hasSecondHalfStarted) {
      _hasMatchFinished = true;
      matchFinishedBase(true,);

      if (!isExtraTimeTime) {
        MatchHandle().matchFinished(this);
      }
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

  Future<void> noMatch30(bool isHomeTeam) async{//κερδισε η γηγπεδουχος 3-0 στα χαρτια;
      int homeGoals = (isHomeTeam) ? 3 : 0;
      int awayGoals = (!isHomeTeam) ? 3 : 0;
      matchStarted();

      // 1. Ενημέρωση του εγγράφου του αγώνα
      await FirebaseFirestore.instance
          .collection('year')
          .doc(global.thisYearNow.toString())
          .collection("matches")
          .doc(matchDocId)
          .update({
        'GoalHome': homeGoals,
        'GoalAway': awayGoals,
        'hasFirstHalfFinished': true,
        'hasSecondHalfStarted': true,
      });

      _hasMatchFinished = true;
      matchFinishedBase(true,);

      await MatchHandle().matchFinished(this);
      updateStandings(true);
      notifyListeners();


  }
  void updateStandings(bool progress) {

      if (progress) {
        if (scoreHome == scoreAway) {
          homeTeam.increaseDraws(isGroupPhase);
          awayTeam.increaseDraws(isGroupPhase);
        } else if (scoreHome > scoreAway) {
          homeTeam.increaseWins(isGroupPhase);
          awayTeam.increaseLoses(isGroupPhase);
        } else {
          homeTeam.increaseLoses(isGroupPhase);
          awayTeam.increaseWins(isGroupPhase);
        }
      } else {
        if (scoreHome == scoreAway) {
          homeTeam.reduceDraws(isGroupPhase);
          awayTeam.reduceDraws(isGroupPhase);
        } else if (scoreHome > scoreAway) {
          homeTeam.reduceWins(isGroupPhase);
          awayTeam.reduceLoses(isGroupPhase);
        } else {
          homeTeam.reduceLoses(isGroupPhase);
          awayTeam.reduceWins(isGroupPhase);
        }
    }
      if (isGroupPhase) {
        TeamsHandle().sortTeams(homeTeam.group);
      }
  }

  bool get isExtraTimeTime {
    return hasMatchFinished && scoreAway == scoreHome && !isGroupPhase;
  }
  //_hasExtraTimeFinished=false;
  //progressS('hasExtraTimeFinished', false);

  //--oxi etoimo
  void matchCancelProgressed() {
    if (_hasExtraTimeFinished &&
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) - startTimeInSeconds <
            3 * 3600) {
      if (!isPenaltyTime) {
        MatchHandle().matchNotFinished(this);
      }
      _hasExtraTimeFinished = false;
      progressS('hasExtraTimeFinished', false);
      notifyListeners();
      return;
    } else if (isExtraTimeTime) {
      if (_hasSecondHalfExtraTimeStarted) {
        _hasSecondHalfExtraTimeStarted = false;
        progressS('hasSecondHalfExtraTimeStarted', false);
        notifyListeners();
      } else if (_hasFirstHalfExtraTimeFinished) {
        _hasFirstHalfExtraTimeFinished = false;
        progressS('hasFirstHalfExtraTimeFinished', false);
        notifyListeners();
      } else if (_hasExtraTimeStarted) {
        _hasExtraTimeStarted = false;
        progressS('hasExtraTimeStarted', false);
        notifyListeners();
      } else {
        _hasMatchFinished = false;
        matchFinishedBase(false);
        updateStandings(false);

        notifyListeners();
      }
      return;
    }

    if (_hasMatchFinished &&
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) - startTimeInSeconds <
            3 * 3600) {
      if (!isExtraTimeTime) {
        MatchHandle().matchNotFinished(this);
      }
      updateStandings(false);

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
    if (_isGroupPhase) {
      greek ? info = "Φάση ομίλων" : info = "Group Stage";
    } else {
      if (_game == 2) {
        greek ? info = 'Τελικός' : info = 'Final';
      }
      else if (_game == 4) {
        info = greek ? 'Ημιτελικός' : 'SemiFinal';
      } else {
        greek
            ? info = "Φάση των $_game: Νοκ Άουτ"
            : info = "Stage $_game: Round of 16";
      }
    }
    return info;
  }

  //ετοιμο
  Future<void> playerGotCard(String name, Team team, bool isYellow, int? minute,
      bool isHomeTeam) async {
    if ((!hasMatchFinished || (isExtraTimeTime && !_hasExtraTimeFinished)) &&
        globalUser.controlTheseTeamsFootball(homeTeam.name, awayTeam.name)) {
      for (Player player in team.players) {
        if ("${player.name.substring(0, 1)}. ${player.surname}" == name) {
          isYellow ? await player.gotYellowCard() : await player.gotRedCard();
          break;
        }
      }
      int half;
      (!isExtraTimeTime)
          ? ((!_hasSecondHalfStarted) ? half = 0 : half = 1)
          : (hasSecondHalfExtraTimeStarted)
              ? half = 3
              : half = 2;

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
              FirebaseFirestore.instance.collection('year').doc(global.thisYearNow.toString()).collection("matches").doc(matchDocId),
          half: half,
          factMap: card.toMap());
      notifyListeners();
    }
  }

  //ετοιμο
  Future<void> cancelGoal(Goal goal1) async {
    if (globalUser.controlTheseTeamsFootball(homeTeam.name, awayTeam.name)) {
      //μικροτερο απο 3 ωρες
      if (_matchFacts.containsKey(goal1.half)) {
        _matchFacts[goal1.half]!
            .removeWhere((goal) => goal is Goal && goal == goal1);

        goal1.half < 2
            ? (goal1.isHomeTeam ? _scoreHome-- : _scoreAway--)
            : (goal1.isHomeTeam
                ? _scoreHomeExtraTime--
                : _scoreAwayExtraTime--);
        for (Player player in goal1.team.players) {
          if ("${player.name[0]}. ${player.surname}" == goal1.scorerName) {
            TopPlayersHandle().goalCancelled(player);
            break;
          }
        }

        await MatchFactsStorageHelper().deleteMatchFact(
            matchDoc: FirebaseFirestore.instance
                .collection('year').doc(global.thisYearNow.toString()).collection("matches")
                .doc(matchDocId),
            half: goal1.half,
            factMap: goal1.toMap());

        String type;
        goal1.half < 2
            ? (goal1.isHomeTeam)
                ? (type = 'GoalHome')
                : (type = 'GoalAway')
            : (goal1.isHomeTeam)
                ? (type = 'GoalHomeExtraTime')
                : (type = 'GoalAwayExtraTime');
        await FirebaseFirestore.instance
            .collection('year').doc(global.thisYearNow.toString()).collection("matches")
            .doc(matchDocId)
            .set({
          type: FieldValue.increment(-1),
        }, SetOptions(merge: true));

        notifyListeners(); // Ενημέρωση των listeners για την αλλαγή
      }
    }
  }

  Future<void> editGoal(Goal oldGoal, Goal newGoal) async {
    if (startTimeInSeconds >
            DateTime.now().millisecondsSinceEpoch ~/ 1000 - 10800 &&
        globalUser.controlTheseTeamsFootball(homeTeam.name, awayTeam.name)) {
      if (_matchFacts.containsKey(oldGoal.half)) {
        cancelGoal(oldGoal);

        if (!newGoal.isHomeTeam) {
          if (isExtraTimeTime) {
            _scoreAwayExtraTime++;
            awayScoredBase();
          } else {
            _scoreAway++;
            awayScoredBase();
          }
        } else {
          if (isExtraTimeTime) {
            _scoreHomeExtraTime++;
            homeScoredBase();
          } else {
            _scoreHome++;
            homeScoredBase();
          }
        }

        _matchFacts[newGoal.half]?.add(newGoal);

        if (newGoal.name != 'Άλλος') {
          final teamPlayers =
          newGoal.isHomeTeam ? homeTeam.players : awayTeam.players;

          for (Player player in teamPlayers) {
            if ("${player.name[0]}. ${player.surname}" == newGoal.name) {
              TopPlayersHandle().playerScored(player);
              break;
            }
          }
        }


        MatchFactsStorageHelper().addMatchFact(
            matchDoc: FirebaseFirestore.instance
                .collection('year').doc(global.thisYearNow.toString()).collection("matches")
                .doc(matchDocId),
            half: newGoal.half,
            factMap: newGoal.toMap());

        notifyListeners();
      }
    }
  }

  Future<void> editCard(CardP oldCard, CardP newCard) async {
    if (startTimeInSeconds >
            DateTime.now().millisecondsSinceEpoch ~/ 1000 - 10800 &&
        globalUser.controlTheseTeamsFootball(homeTeam.name, awayTeam.name)) {
      if (_matchFacts.containsKey(oldCard.half)) {
        // 1. Διαγραφή της παλιάς κάρτας
        _matchFacts[oldCard.half]!
            .removeWhere((card) => card is CardP && card == oldCard);

        // 2. Ενημέρωση του σκορ ή άλλων στατιστικών αν χρειάζεται
        // Εδώ δεν αλλάζει σκορ, αλλά μπορείς να ενημερώσεις άλλες πληροφορίες, αν απαιτείται.

        // 3. Διαγραφή της παλιάς κάρτας από τη βάση δεδομένων
        await MatchFactsStorageHelper().deleteMatchFact(
          matchDoc:
              FirebaseFirestore.instance.collection('year').doc(global.thisYearNow.toString()).collection("matches").doc(matchDocId),
          half: oldCard.half,
          factMap: oldCard.toMap(),
        );

        // 4. Προσθήκη της νέας κάρτας στη βάση δεδομένων
        await MatchFactsStorageHelper().addMatchFact(
          matchDoc:
              FirebaseFirestore.instance.collection('year').doc(global.thisYearNow.toString()).collection("matches").doc(matchDocId),
          half: newCard.half,
          factMap: newCard.toMap(),
        );

        // 5. Ενημέρωση του UI
        notifyListeners();
      }
    }
  }

  Future<void> addPenalty({
    required bool isScored,
    required bool isHomeTeam,
  }) async {
    final penalty = PenaltyShoot(
      isScored: isScored,
      isHomeTeam: isHomeTeam,
    );

    await penaltyShootout.addPenalty(penalty, matchDocId);

    if (isShootoutOver) {
      MatchHandle().matchFinished(this);
      await FirebaseFirestore.instance.collection('year').doc(global.thisYearNow.toString()).collection("matches").doc(matchDocId).set({
        'shootoutOver': true,
      }, SetOptions(merge: true));

    }
    notifyListeners();
  }

  Future<void> cancelPenalty() async {


    await penaltyShootout.removeLastPenalty(matchKey);

    if (!isShootoutOver) {
      MatchHandle().matchNotFinished(this);
      await FirebaseFirestore.instance.collection('year').doc(global.thisYearNow.toString()).collection("matches").doc(matchDocId).set({
        'shootoutOver': false,
      }, SetOptions(merge: true));

    }
    notifyListeners();
  }

//ετοιμο
  void cancelCard(CardP card1) {
    if ((!hasMatchFinished || (isExtraTimeTime && !hasExtraTimeFinished)) &&
        globalUser.controlTheseTeamsFootball(homeTeam.name, awayTeam.name)) {
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
                .collection('year').doc(global.thisYearNow.toString()).collection("matches")
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
        .collection('year').doc(global.thisYearNow.toString()).collection("matches")
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

      if (_hasExtraTimeStarted != (data['hasExtraTimeStarted'] ?? false)) {
        _hasExtraTimeStarted = data['hasExtraTimeStarted'] ?? false;
        changed = true;
      }

      if (_hasFirstHalfExtraTimeFinished != (data['hasFirstHalfExtraTimeFinished'] ?? false)) {
        _hasFirstHalfExtraTimeFinished     = data['hasFirstHalfExtraTimeFinished'] ?? false;
        changed = true;
      }

      if (_hasSecondHalfExtraTimeStarted != (data['hasSecondHalfExtraTimeStarted'] ?? false)) {
        _hasSecondHalfExtraTimeStarted = data['hasSecondHalfExtraTimeStarted'] ?? false;
        changed = true;
      }

      if (_hasExtraTimeFinished != (data['hasExtraTimeFinished'] ?? false)) {
        _hasExtraTimeFinished = data['hasExtraTimeFinished'] ?? false;
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
      }

      if (data.containsKey('shootoutOver') && penaltyOver != (data['shootoutOver'] ?? false)) {
        penaltyOver = data['shootoutOver'] ?? false;
        changed = true;
      }

      // Update match facts only if present
      if (data.containsKey('facts')) {
        final factsMap = Map<String, dynamic>.from(data['facts']);
        final decodedFacts = await MatchFactsStorageHelper.decodeMatchFacts(factsMap);

        if (!mapEquals(_matchFacts, decodedFacts)) {
          _matchFacts = decodedFacts;
          changed = true;
        }
      }


      if (changed) notifyListeners();


      if (hasMatchEndedFinal) {
        stopListening();
      }
    });
  }
  void stopListening() {
    _matchSubscription?.cancel();
    _matchSubscription = null;
  }

  String get matchDocId {
    return homeTeam.nameEnglish +
        _day.toString() +
        _month.toString() +
        _year.toString() +
        _game.toString() +
        awayTeam.nameEnglish;
  }

  @override
  void dispose() {
    _matchSubscription?.cancel();
    super.dispose();
  }

  void enableNotify(bool notify) {
    _notify.value = notify;
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

  //Future<void> addPenalty({
  //  required DocumentReference matchDoc,
  //}) async {
  //   await MatchFactsStorageHelper().addPenalty(
  //     matchDoc:
  //         FirebaseFirestore.instance.collection('matches').doc(matchDocId),
  //     penaltyMap: {
  //       'playerId': player.id,
  //       'isScored': isScored,
  //       'isHomeTeam': isHomeTeam,
  //       'timestamp': Timestamp.now(),
  //     },
  //   );
  // }

  static Future<PenaltyShootout> loadFromFirestore(String matchDocId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('year').doc(thisYearNow.toString()).collection("matches")
        .doc(matchDocId)
        .collection('penalties')
        .orderBy('timestamp')
        .get();

    final penalties = snapshot.docs.map((doc) {
      final data = doc.data();
      return PenaltyShoot(
        isScored: data['isScored'],
        isHomeTeam: data['isHomeTeam'],
      );
    }).toList();

    return PenaltyShootout(penalties);
  }
}
