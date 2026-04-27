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

  // Μεταβλητές για Staff και Αρχηγούς
  String? homeCaptain;
  String? awayCaptain;
  String? homeCoach;
  String? awayCoach;
  String? homeAssistant;
  String? awayAssistant;
  String? homeKitman;
  String? awayKitman;

  late bool penaltyOver;

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

  // λιστες για τις συνθεσεις
  List<String> homeSquad = [];
  List<String> homeStarters = [];
  List<String> awaySquad = [];
  List<String> awayStarters = [];
  List<String> homeSubsIn = [];   //όσοι μπήκαν
  List<String> awaySubsIn = [];   //όσοι μπήκαν
  List<String> homeSubsOut = []; //Όσοι βγήκαν
  List<String> awaySubsOut = []; //Όσοι βγήκαν

  late int hour = _time ~/ 100;

  late int minute = time % 100;

  // Δημιουργία DateTime
  late DateTime matchDateTime = DateTime(year, month, day, hour, minute);


  String? pdfReportUrl;

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
      required slot,

      required this.homeSquad,
      required this.homeStarters,
      required this.awaySquad,
      required this.awayStarters,
      required this.homeSubsIn,
      required this.awaySubsIn,
      required this.homeSubsOut,
      required this.awaySubsOut,
      required this.temporaryNumbers,
      required this.homeCaptain,
      required this.awayCaptain,
      required this.homeCoach,
      required this.awayCoach,
      required this.homeAssistant,
      required this.awayAssistant,
      required this.homeKitman,
      required this.awayKitman,
      // required this.selectedFormationHome,
      // required this.selectedFormationAway,
      // required Map<String,int> playersI11Home,
      // required Map<String,int> playersI11Away,
      // required Map<String,bool> selectedHome,
      // required Map<String,bool> selectedAway
      })
  {
    _homeTeam = homeTeam;
    _awayTeam = awayTeam;
    _hasMatchStarted = hasMatchStarted;
    _hasMatchFinished = hasMatchFinished;
    _hasSecondHalfStarted = hasSecondHalfStarted;
    _hasFirstHalfFinished = hasFirstHalfFinished;
    penaltyShootout = PenaltyShootout(penalties);

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

    penaltyOver=isShootoutOver;
    _slot = slot;


    _notify = ValueNotifier<bool>((globalUser.matchKeys[matchKey] ??
        (globalUser.favoriteList.contains(homeTeam.name) ||
            globalUser.favoriteList.contains(awayTeam.name))));

    startListeningForUpdates();
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

  DateTime get matchDateTime2 {
    return DateTime.utc(_year, _month, _day, hour, minute).subtract(const Duration(hours: 3));
  }

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

  // 1. Το Map που αποθηκεύει προσωρινά τα νούμερα {ΌνομαΠαίκτη: ΝέοΝούμερο}
  Map<String, int> temporaryNumbers = {};

  // 2. Συνάρτηση για να αποθηκεύει το νέο νούμερο
  Future<void> updateTemporaryNumber(String playerName, int newNumber) async {
    temporaryNumbers[playerName] = newNumber;
    notifyListeners(); // Ενημερώνει το UI

    await FirebaseFirestore.instance
        .collection("year")
        .doc(thisYearNow.toString()) // Ή thisYearNow.toString() ανάλογα πώς το έχεις στο αρχείο
        .collection("matches")
        .doc(matchKey) // Το ID του αγώνα
        .set({
      'temporaryNumbers': temporaryNumbers,
    }, SetOptions(merge: true)); // Το merge: true απλά προσθέτει το πεδίο χωρίς να σβήσει τα υπόλοιπα!
  }

  // 3. Συνάρτηση που επιστρέφει το σωστό νούμερο (το προσωρινό ή το κανονικό)
  int getDisplayNumber(Player player) {
    return temporaryNumbers[player.name] ?? player.number;
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

  Future<void> matchStarted() async {
    _scoreHome = 0;
    _scoreAway = 0;
    _startTimeInSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _hasMatchStarted = true;
    await matchStartedBase(true);
    notifyListeners();
  }

  Future<void> secondHalfStarted() async {
    _hasSecondHalfStarted = true;
    await secondHalfStartedBase(true);
    notifyListeners();
  }

  Future<void> firstHalfFinished() async {
    _hasFirstHalfFinished = true;
    await firstHalfFinishedBase(true);
  }

  //ετοιμο
  Future<void> homeScored(String name, bool hasName, {int? minute}) async {
    if (hasMatchStarted &&
        (globalUser.controlTheseTeamsFootball(homeTeam.name, awayTeam.name) || globalUser.isUpperAdmin)) {

      int half;
      (!isExtraTimeTime)
          ? (!_hasSecondHalfStarted) ? half = 0 : half = 1
          : (!_hasFirstHalfExtraTimeFinished) ? half = 2 : half = 3;

      Goal goal = Goal(
          scorerName: name,
          homeScore: homeScore,
          awayScore: awayScore,
          minute: minute ?? DateTime.now().millisecondsSinceEpoch ~/ 1000 - startTimeInSeconds,
          isHomeTeam: true,
          team: homeTeam,
          half: half);

      _matchFacts[half] ??= [];
      _matchFacts[half]!.add(goal);

      if (hasName) {
        for (Player player in homeTeam.players) {
          if ("${player.name.substring(0, 1)}. ${player.surname}" == name) {
            await TopPlayersHandle().playerScored(player);
            break;
          }
        }
      }
      await syncFactsWithFirestore();
    }
  }

  //ετοιμο
  Future<void> awayScored(String name, bool hasName, {int? minute}) async {
    if (hasMatchStarted &&
        (globalUser.controlTheseTeamsFootball(homeTeam.name, awayTeam.name) || globalUser.isUpperAdmin)) {

      int half;
      (!isExtraTimeTime)
          ? ((!_hasSecondHalfStarted) ? half = 0 : half = 1)
          : ((!_hasFirstHalfExtraTimeFinished) ? half = 2 : half = 3);

      Goal goal = Goal(
          scorerName: name,
          homeScore: homeScore,
          awayScore: awayScore,
          minute: minute ?? DateTime.now().millisecondsSinceEpoch ~/ 1000 - startTimeInSeconds,
          isHomeTeam: false,
          team: awayTeam,
          half: half);

      _matchFacts[half] ??= [];
      _matchFacts[half]!.add(goal);

      if (hasName) {
        for (Player player in awayTeam.players) {
          if ("${player.name.substring(0, 1)}. ${player.surname}" == name) {
            await TopPlayersHandle().playerScored(player);
            break;
          }
        }
      }
      await syncFactsWithFirestore();
    }
  }


  bool get hasMatchEndedFinal{
    return (((_hasMatchFinished && !isExtraTimeTime) || (hasExtraTimeFinished && !isPenaltyTime)) || isShootoutOver );
  }

  //etoimo
  Future<void> matchProgressed() async {
    if (isExtraTimeTime) {
      if (_hasSecondHalfExtraTimeStarted) {
        _hasExtraTimeFinished = true;
        await progressS('hasExtraTimeFinished', true);
        if (!isPenaltyTime) {
          await MatchHandle().matchFinished(this);
        }
        notifyListeners();
      } else if (_hasFirstHalfExtraTimeFinished) {
        _hasSecondHalfExtraTimeStarted = true;
        await progressS('hasSecondHalfExtraTimeStarted', true);
        _startTimeInSeconds =
            DateTime.now().millisecondsSinceEpoch ~/ 1000 - 105 * 60;
        await updateTime(_startTimeInSeconds);
        notifyListeners();
      } else if (_hasExtraTimeStarted) {
        _hasFirstHalfExtraTimeFinished = true;
        await progressS('hasFirstHalfExtraTimeFinished', true);

        notifyListeners();
      } else if (_hasMatchFinished) {
        _hasExtraTimeStarted = true;
        await progressS('hasExtraTimeStarted', true);
        _startTimeInSeconds =
            DateTime.now().millisecondsSinceEpoch ~/ 1000 - 90 * 60;
        await updateTime(_startTimeInSeconds);
        notifyListeners();
      }
      return;
    }
    if (_hasSecondHalfStarted) {
      _hasMatchFinished = true;
      await matchFinishedBase(true,);

      if (!isExtraTimeTime) {
        await MatchHandle().matchFinished(this);
      }
      await updateStandings(true);
      notifyListeners();
    } else if (_hasFirstHalfFinished) {
      _hasSecondHalfStarted = true;
      _startTimeInSeconds =
          DateTime.now().millisecondsSinceEpoch ~/ 1000 - 45 * 60;
      await secondHalfStartedBase(true);
    } else if (_hasMatchStarted) {
      _hasFirstHalfFinished = true;
      await firstHalfFinishedBase(true);
    }
  }

  Future<void> noMatch30(bool isHomeTeam) async {
    int homeGoals = (isHomeTeam) ? 3 : 0;
    int awayGoals = (!isHomeTeam) ? 3 : 0;

    // 1. Ενημερώνουμε τα τοπικά variables αμέσως
    _scoreHome = homeGoals;
    _scoreAway = awayGoals;
    _hasMatchStarted = true;
    _hasMatchFinished = true;
    _startTimeInSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // 2. Ενιαίο Update στο Firebase για το MatchDoc
    await FirebaseFirestore.instance
        .collection('year')
        .doc(global.thisYearNow.toString())
        .collection("matches")
        .doc(matchDocId)
        .update({
      'GoalHome': homeGoals,
      'GoalAway': awayGoals,
      'HasMatchStarted': true,
      'hasMatchFinished': true,
      'hasMatchEndedFinal': true,
      'Type': 'previous',
      'startTimeInSeconds': _startTimeInSeconds,
    });

    // 3. Ενημέρωση Βαθμολογίας
    await updateStandings(true);

    // 4. Ενημέρωση παικτών
    await MatchHandle().matchFinished(this);


    String correctChoice;
    (scoreHome > scoreAway)
        ? correctChoice = "1"
        : (scoreHome == scoreAway)
        ? correctChoice = "X"
        : correctChoice = "2";

    await FirebaseFirestore.instance.collection('votes').doc(matchKey).set({  // ανανεωση του ματς στο στοιχημα
      'hasMatchFinished': true,
      'correctChoice': correctChoice,
      'statsUpdated': false,
      'GoalHome': scoreHome,
      'GoalAway': awayScore
    }, SetOptions(merge: true));

    notifyListeners();
  }


  Future<void> updateStandings(bool progress) async {

      if (progress) {
        await Future.wait([
          homeTeam.applyMatchResult(scoreHome, scoreAway, isGroupPhase),
          awayTeam.applyMatchResult(awayScore, homeScore, isGroupPhase)
        ]);
      } else {

        await Future.wait([
          homeTeam.revertMatchResult(scoreHome, scoreAway, isGroupPhase),
          awayTeam.revertMatchResult(awayScore, homeScore, isGroupPhase)
        ]);
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
  Future<void> matchCancelProgressed() async {
    if (_hasExtraTimeFinished &&
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) - startTimeInSeconds <
            3 * 3600) {
      if (!isPenaltyTime) {
        await MatchHandle().matchNotFinished(this);
      }
      _hasExtraTimeFinished = false;
      await progressS('hasExtraTimeFinished', false);
      notifyListeners();
      return;
    } else if (isExtraTimeTime) {
      if (_hasSecondHalfExtraTimeStarted) {
        _hasSecondHalfExtraTimeStarted = false;
        await progressS('hasSecondHalfExtraTimeStarted', false);
        notifyListeners();
      } else if (_hasFirstHalfExtraTimeFinished) {
        _hasFirstHalfExtraTimeFinished = false;
        await progressS('hasFirstHalfExtraTimeFinished', false);
        notifyListeners();
      } else if (_hasExtraTimeStarted) {
        _hasExtraTimeStarted = false;
        await progressS('hasExtraTimeStarted', false);
        notifyListeners();
      } else {
        _hasMatchFinished = false;
        await matchFinishedBase(false);
        await updateStandings(false); // Εδώ το είχες βάλει σωστά!

        notifyListeners();
      }
      return;
    }

    if (_hasMatchFinished &&
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) - startTimeInSeconds <
            3 * 3600) {
      if (!isExtraTimeTime) {
        await MatchHandle().matchNotFinished(this);
      }
      await updateStandings(false); // Εδώ το είχες βάλει σωστά!

      _hasMatchFinished = false;
      await matchFinishedBase(false);
      notifyListeners();
    } else if (_hasSecondHalfStarted) {
      _hasSecondHalfStarted = false;
      await secondHalfStartedBase(false);
    } else if (_hasFirstHalfFinished) {
      _hasFirstHalfFinished = false;
      await firstHalfFinishedBase(false);
    } else if (_hasMatchStarted) {
      _hasMatchStarted = false;
      await matchStartedBase(false);
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
      bool isHomeTeam,{bool isSecondYellow = false, String? reason}) async {
    if ((!hasMatchFinished || (isExtraTimeTime && !_hasExtraTimeFinished)) &&
        (globalUser.controlTheseTeamsFootball(homeTeam.name, awayTeam.name) || globalUser.isUpperAdmin)) {

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
          name: name,
          team: team,
          isYellow: isYellow,
          isSecondYellow: isSecondYellow,
          reason: reason,
          minute: minute ??
              (DateTime.now().millisecondsSinceEpoch ~/ 1000) -
                  startTimeInSeconds,
          isHomeTeam: isHomeTeam,
          half: half);

      _matchFacts[half] ??= [];
      _matchFacts[half]!.add(card);

      await syncFactsWithFirestore();
    }
  }

  //ετοιμο
  Future<void> cancelGoal(Goal goal1) async {
    if ((globalUser.controlTheseTeamsFootball(homeTeam.name, awayTeam.name) || globalUser.isUpperAdmin)) {

      if (_matchFacts.containsKey(goal1.half)) {

        // 1. Το διαγράφουμε από την τοπική λίστα
        _matchFacts[goal1.half]!.removeWhere((goal) => goal is Goal && goal == goal1);

        // 2. Το αφαιρούμε από τα στατιστικά του παίκτη (TopPlayers)
        for (Player player in goal1.team.players) {
          if ("${player.name[0]}. ${player.surname}" == goal1.name) {
            await TopPlayersHandle().goalCancelled(player);
            break;
          }
        }

        await syncFactsWithFirestore();
      }
    }
  }

  Future<void> editGoal(Goal oldGoal, Goal newGoal) async {
    if (startTimeInSeconds > DateTime.now().millisecondsSinceEpoch ~/ 1000 - 10800 &&
        (globalUser.controlTheseTeamsFootball(homeTeam.name, awayTeam.name) || globalUser.isUpperAdmin)) {

      if (_matchFacts.containsKey(oldGoal.half)) {

        // 1. Αφαιρούμε το Γκολ από τον παλιό παίκτη (TopPlayers)
        for (Player player in oldGoal.team.players) {
          if ("${player.name[0]}. ${player.surname}" == oldGoal.name) {
            await TopPlayersHandle().goalCancelled(player);
            break;
          }
        }

        // 2. Βάζουμε το Γκολ στον νέο παίκτη
        if (newGoal.name != 'Άλλος') {
          final teamPlayers = newGoal.isHomeTeam ? homeTeam.players : awayTeam.players;
          for (Player player in teamPlayers) {
            if ("${player.name[0]}. ${player.surname}" == newGoal.name) {
              await TopPlayersHandle().playerScored(player);
              break;
            }
          }
        }

        // 3. Αλλαγή στην τοπική λίστα (Διαγραφή παλιού - Προσθήκη νέου)
        _matchFacts[oldGoal.half]!.removeWhere((goal) => goal is Goal && goal == oldGoal);
        _matchFacts[newGoal.half] ??= [];
        _matchFacts[newGoal.half]!.add(newGoal);

        await syncFactsWithFirestore();
      }
    }
  }

  Future<void> editCard(CardP oldCard, CardP newCard) async {
    if (startTimeInSeconds > DateTime.now().millisecondsSinceEpoch ~/ 1000 - 10800 &&
        (globalUser.controlTheseTeamsFootball(homeTeam.name, awayTeam.name) || globalUser.isUpperAdmin)) {

      if (_matchFacts.containsKey(oldCard.half)) {

        // 1. Αφαίρεση κάρτας από τον παλιό παίκτη
        for (Player player in oldCard.team.players) {
          if ("${player.name.substring(0, 1)}. ${player.surname}" == oldCard.name) {
            oldCard.isYellow ? await player.cancelYellowCard() : await player.cancelRedCard();
            break;
          }
        }

        // 2. Χρέωση κάρτας στον νέο παίκτη
        for (Player player in newCard.team.players) {
          if ("${player.name.substring(0, 1)}. ${player.surname}" == newCard.name) {
            newCard.isYellow ? await player.gotYellowCard() : await player.gotRedCard();
            break;
          }
        }

        // 3. Αλλαγή στην τοπική λίστα
        _matchFacts[oldCard.half]!.removeWhere((card) => card is CardP && card == oldCard);
        _matchFacts[newCard.half] ??= [];
        _matchFacts[newCard.half]!.add(newCard);

        await syncFactsWithFirestore();
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
      timestamp: DateTime.now().toIso8601String(),
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
//ετοιμο
  Future<void> cancelCard(CardP card1) async {
    if ((!hasMatchFinished || (isExtraTimeTime && !hasExtraTimeFinished)) &&
        (globalUser.controlTheseTeamsFootball(homeTeam.name, awayTeam.name) || globalUser.isUpperAdmin)) {

      if (_matchFacts.containsKey(card1.half)) {

        // 1. Τη βγάζουμε από την τοπική λίστα
        _matchFacts[card1.half]!.removeWhere((card) => card is CardP && card == card1);

        // 2. Ενημερώνουμε τα στατιστικά του παίκτη
        for (Player player in card1.team.players) {
          if ("${player.name.substring(0, 1)}. ${player.surname}" == card1.name) {
            card1.isYellow ? await player.cancelYellowCard() : await player.cancelRedCard();
            break;
          }
        }

        await syncFactsWithFirestore();
      }
    }
  }


  // ΠΡΟΣΘΗΚΗ: Δέχεται πλέον και τα καθαρά ονόματα (nameOut, nameIn)
  Future<void> performSubstitution(String keyOut, String keyIn, String nameOut, String nameIn, bool isHome) async {
    // 1. Υπολογίζουμε Ημίχρονο & Λεπτό
    int half;
    (!isExtraTimeTime)
        ? (!_hasSecondHalfStarted ? half = 0 : half = 1)
        : (!_hasFirstHalfExtraTimeFinished ? half = 2 : half = 3);

    int currentMinute = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - startTimeInSeconds;

    // 2. Δημιουργούμε το MatchFact της Αλλαγής ΜΕ ΤΑ ΟΝΟΜΑΤΑ
    Substitution sub = Substitution(
      playerIn: keyIn,
      playerOut: keyOut,
      playerInName: nameIn,
      playerOutName: nameOut,
      minute: currentMinute,
      isHomeTeam: isHome,
      team: isHome ? homeTeam : awayTeam,
      half: half,
    );

    _matchFacts[half] ??= [];
    _matchFacts[half]!.add(sub);
    await syncFactsWithFirestore();

    // 3. ΑΠΟΘΗΚΕΥΣΗ ΣΤΟ FIREBASE (Atomic Update - Ίδιο με πριν)
    String teamPrefix = isHome ? 'home' : 'away';

    await FirebaseFirestore.instance.collection("year").doc(global.thisYearNow.toString()).collection("matches").doc(matchDocId).update({
      '${teamPrefix}Starters': FieldValue.arrayRemove([keyOut]),
    });

    await FirebaseFirestore.instance.collection("year").doc(global.thisYearNow.toString()).collection("matches").doc(matchDocId).update({
      '${teamPrefix}Starters': FieldValue.arrayUnion([keyIn]),
      '${teamPrefix}SubsIn': FieldValue.arrayUnion([keyIn]),
      '${teamPrefix}SubsOut': FieldValue.arrayUnion([keyOut]),
    });
  }
  Future<void> cancelSubstitution(String playerKey, bool isHome) async {
    // 1. Ψάχνουμε να βρούμε το ζευγάρι της αλλαγής στα facts
    Substitution? targetSub;
    for (int i = 0; i < 4; i++) {
      if (_matchFacts.containsKey(i)) {
        for (var fact in _matchFacts[i]!) {
          if (fact is Substitution && (fact.playerIn == playerKey || fact.playerOut == playerKey)) {
            targetSub = fact;
            break;
          }
        }
      }
      if (targetSub != null) break;
    }

    if (targetSub != null) {
      String keyIn = targetSub.playerIn;
      String keyOut = targetSub.playerOut;

      // 2. Διαγράφουμε την αλλαγή από το Φύλλο Αγώνα (Timeline)
      _matchFacts[targetSub.half]!.remove(targetSub);
      await syncFactsWithFirestore();

      String teamPrefix = isHome ? 'home' : 'away';

      await FirebaseFirestore.instance.collection("year").doc(global.thisYearNow.toString()).collection("matches").doc(matchDocId).update({
        '${teamPrefix}Starters': FieldValue.arrayRemove([keyIn]),
        '${teamPrefix}SubsIn': FieldValue.arrayRemove([keyIn]),
        '${teamPrefix}SubsOut': FieldValue.arrayRemove([keyOut]),
      });

      await FirebaseFirestore.instance.collection("year").doc(global.thisYearNow.toString()).collection("matches").doc(matchDocId).update({
        '${teamPrefix}Starters': FieldValue.arrayUnion([keyOut]),
      });
    }
  }

  void makeAllFalse(int i) {
    for (Player player in (i == 0) ? homeTeam.players : awayTeam.players) {
      playersSelectedHome[player] = false;
      playersSelectedAway[player] = false;
    }
  }

  void startListeningForUpdates() {

    if (_matchSubscription != null) return;

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

      if (data.containsKey('penalties')) {
        final rawPenalties = data['penalties'] as List<dynamic>? ?? [];
        final parsedPenalties = rawPenalties
            .map((p) => PenaltyShoot.fromMap(Map<String, dynamic>.from(p)))
            .toList();

        // Ταξινομούμε βάσει χρόνου
        parsedPenalties.sort((a, b) =>
            (a.timestamp ?? '').compareTo(b.timestamp ?? ''));

        penaltyShootout.penalties = parsedPenalties;
        changed = true;
      }

      homeSquad = List<String>.from(data['homeSquad'] ?? []);
      homeStarters = List<String>.from(data['homeStarters'] ?? []);
      awaySquad = List<String>.from(data['awaySquad'] ?? []);
      awayStarters = List<String>.from(data['awayStarters'] ?? []);
      homeSubsIn = List<String>.from(data['homeSubsIn'] ?? []);
      awaySubsIn = List<String>.from(data['awaySubsIn'] ?? []);
      homeSubsOut = List<String>.from(data['homeSubsOut'] ?? []);
      awaySubsOut = List<String>.from(data['awaySubsOut'] ?? []);


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

  Future<void> saveLineupAndStaff({
    required bool isHomeTeam,
    required List<String> newSquad,
    required List<String> newStarters,
    String? captain,
    String? coach,
    String? assistant,
    String? kitman,
  }) async {

    String teamPrefix = isHomeTeam ? 'home' : 'away';

    // 1. Ενημερώνουμε τις τοπικές μεταβλητές της κλάσης (για να ενημερωθεί το UI ακαριαία)
    if (isHomeTeam) {
      homeSquad = newSquad;
      homeStarters = newStarters;
      homeCaptain = captain;
      homeCoach = coach;
      homeAssistant = assistant;
      homeKitman = kitman;
    } else {
      awaySquad = newSquad;
      awayStarters = newStarters;
      awayCaptain = captain;
      awayCoach = coach;
      awayAssistant = assistant;
      awayKitman = kitman;
    }
    notifyListeners(); // Λέμε στο UI "Ξανασχεδιάσου, έχουμε νέα δεδομένα!"

    // 2. Στέλνουμε τα δεδομένα στο Firebase
    await FirebaseFirestore.instance
        .collection("year")
        .doc(global.thisYearNow.toString())
        .collection("matches")
        .doc(matchDocId)
        .update({
      '${teamPrefix}Squad': newSquad,
      '${teamPrefix}Starters': newStarters,
      '${teamPrefix}Captain': captain,
      '${teamPrefix}Coach': coach,
      '${teamPrefix}Assistant': assistant,
      '${teamPrefix}Kitman': kitman,
    });
  }

  //Ταξινομεί, διορθώνει τα σκορ και σώζει τα πάντα
  Future<void> syncFactsWithFirestore() async {
    int runningHome = 0, runningAway = 0;
    int runningHomeExtra = 0, runningAwayExtra = 0;

    // 1. Διασχίζουμε τα ημίχρονα (0 -> 1 -> 2 -> 3)
    for (int half = 0; half < 4; half++) {
      if (_matchFacts.containsKey(half) && _matchFacts[half]!.isNotEmpty) {

        // 2. Ταξινόμηση βάσει λεπτού
        _matchFacts[half]!.sort((a, b) => a.minute.compareTo(b.minute));

        // 3. Ξαναμοιράζουμε τα σκορ!
        for (MatchFact fact in _matchFacts[half]!) {
          if (fact is Goal) {
            if (half < 2) {
              fact.isHomeTeam ? runningHome++ : runningAway++;
            } else {
              fact.isHomeTeam ? runningHomeExtra++ : runningAwayExtra++;
            }
            // Το σκορ που βλέπει ο χρήστης στην οθόνη (π.χ. 2-1)
            fact.homeScore = runningHome + runningHomeExtra;
            fact.awayScore = runningAway + runningAwayExtra;
          }
        }
      }
    }

    // 4. Ενημερώνουμε τις μεταβλητές του αγώνα!
    _scoreHome = runningHome;
    _scoreAway = runningAway;
    _scoreHomeExtraTime = runningHomeExtra;
    _scoreAwayExtraTime = runningAwayExtra;

    // 5. Ανανεώνουμε το UI ακαριαία!
    notifyListeners();

    // 6. Στέλνουμε ΤΑ ΠΑΝΤΑ στο Firebase με 1 κίνηση!
    try {
      await FirebaseFirestore.instance
          .collection('year')
          .doc(global.thisYearNow.toString())
          .collection("matches")
          .doc(matchDocId)
          .update({
        'facts': MatchFactsStorageHelper().encodeMatchFacts(_matchFacts),
        'GoalHome': _scoreHome,
        'GoalAway': _scoreAway,
        'GoalHomeExtraTime': _scoreHomeExtraTime,
        'GoalAwayExtraTime': _scoreAwayExtraTime,
      });
    } catch (e) {
      print('🔥 Σφάλμα κατά τον μαζικό συγχρονισμό: $e');
    }
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
            return fact.toMap();
          } else if (fact is CardP) {
            return fact.toMap();
          } else if (fact is Substitution) {
            return fact.toMap();
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
        } else if (type == 'sub') {
          return Substitution.fromMap(map, team);
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
