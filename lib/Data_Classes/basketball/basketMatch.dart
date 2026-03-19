import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../../globals.dart';
import '../../globals.dart' as global;
import 'basketPlayer.dart';
import 'basketTeam.dart';

class BasketMatch extends ChangeNotifier {
  final basketTeam _homeTeam, _awayTeam;

  late int startTimeInSeconds;

  bool _hasMatchStarted = false;
  bool _hasMatchFinished = false;

  bool _hasPeriodEnded = false;


  int _currentPeriod = 0;
 // List<PeriodScore> periods = [];

  int _homeScore = 0, _awayScore = 0;

  Map<int, Map<String, int>> _periodScores = {};  //1: home:20, away:17

  final Map<String, Map<String, int>> _playerPoints = { //ποντοι καθε παιχτη ματς ανα ομαδα
    'home': {},
    'away': {}
  };




  final int _day, _month, _year, _time;
  final bool _isGroupPhase;
  final int _game;

  late int hour = _time ~/ 100;
  late int minute = _time % 100;

  StreamSubscription<DocumentSnapshot>? _matchSubscription;
  ValueNotifier<bool> notify = ValueNotifier<bool>(false);

  BasketMatch(
    this._homeTeam,
    this._awayTeam,

    this._homeScore,
    this._awayScore,
    this._periodScores,

    this._isGroupPhase,
    this._game,

    this._time,
    this._day,
    this._month,
    this._year,

    this._hasMatchStarted,
    this._hasMatchFinished,
    this._currentPeriod
    //this.periods
  ) {

    _startListeningForUpdates();

  }

  //  Getters
  basketTeam get homeTeam => _homeTeam;
  basketTeam get awayTeam => _awayTeam;

  bool get hasMatchStarted  => _hasMatchStarted;
  bool get hasMatchFinished => _hasMatchFinished;
  bool get isPeriodEnded => _hasPeriodEnded;

  bool get isHalftime => _hasPeriodEnded && _currentPeriod == 2;

  int get time => _time;
  int get day => _day;
  int get month => _month;
  int get year => _year;

  int get currentPeriod => _currentPeriod;

  int get homeScore => _homeScore;
  int get awayScore => _awayScore;
  Map<int, Map<String, int>> get periodScores => _periodScores;
  Map<String, Map<String, int>> get playerPoints => _playerPoints;

  String get dateString {
    return "${_day.toString().padLeft(2, '0')}.${_month.toString().padLeft(2, '0')}.${(_year % 100).toString().padLeft(2, '0')}";
  }

  String get matchDocId => "${homeTeam.nameEnglish}$_day$_month$_year$_game${awayTeam.nameEnglish}";




  // Δημιουργία DateTime
  late DateTime matchDateTime = DateTime(_year, _month, _day, hour, minute);


  int get homeFirstHalfScore {
    int q1 = _periodScores[1]?['home'] ?? 0;
    int q2 = _periodScores[2]?['home'] ?? 0;
    return q1 + q2;
  }

  int get awayFirstHalfScore {
    int q1 = _periodScores[1]?['away'] ?? 0;
    int q2 = _periodScores[2]?['away'] ?? 0;
    return q1 + q2;
  }

  // Υπολογισμός Σκορ Β' Ημιχρόνου (Q3 + Q4)
  int get homeSecondHalfScore {
    int q3 = _periodScores[3]?['home'] ?? 0;
    int q4 = _periodScores[4]?['home'] ?? 0;
    return q3 + q4;
  }

  int get awaySecondHalfScore {
    int q3 = _periodScores[3]?['away'] ?? 0;
    int q4 = _periodScores[4]?['away'] ?? 0;
    return q3 + q4;
  }


  String matchweekInfo() {
    String info;
    if (_isGroupPhase) {
      greek ? info = "Φάση ομίλων" : info = "Group Stage";
    } else {
      if (_game == 2) {
        greek ? info = 'Τελικός' : info = 'Final';
      } else if (_game == 4) {
        info = greek ? 'Ημιτελικός' : 'SemiFinal';
      } else {
        greek
            ? info = "Φάση των $_game: Νοκ Άουτ"
            : info = "Stage $_game: Round of 16";
      }
    }
    return info;
  }

  String get timeString {
    int hour = _time ~/ 100;
    int min = _time % 100;
    return "${hour.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}";
  }

  //------------------------------------
 // Συναρτησεις για ροη


  void startMatch() {
    _hasMatchStarted = true;
    _currentPeriod = 1;
    _hasPeriodEnded = false;
    _updateBase({
      'HasMatchStarted': true,
      'CurrentPeriod': 1,
      'IsPeriodEnded': false,
      'HomeScore': 0,
      'AwayScore': 0
    });
    notifyListeners();
  }

  void cancelStartMatch() {
    if (!_hasMatchStarted) return;

    _hasMatchStarted = false;
    _currentPeriod = 0;
    _hasPeriodEnded = false;

    _updateBase({
      'HasMatchStarted': false,
      'CurrentPeriod': 0,
      'IsPeriodEnded': false,
    });
    notifyListeners();
  }

  void finishCurrentPeriod() {
    if (!_hasMatchStarted || _hasMatchFinished || _hasPeriodEnded) return;

    _hasPeriodEnded = true;

    // Ελέγχουμε αν είναι το τέλος του αγώνα (4η περίοδος ή παράταση ΚΑΙ δεν έχουμε ισοπαλία)
    if (_currentPeriod >= 4 && _homeScore != _awayScore) {
      finishMatch();
    } else {
      _updateBase({'IsPeriodEnded': true});
      notifyListeners();
    }
  }

  void cancelFinishCurrentPeriod() {
    if (!_hasPeriodEnded && !_hasMatchFinished) return;

    _hasPeriodEnded = false;

    // Αν η λήξη της περιόδου είχε προκαλέσει και λήξη του ματς, το παίρνουμε πίσω!
    if (_hasMatchFinished) {
      _hasMatchFinished = false;
      _updateBase({
        'HasMatchFinished': false,
        'IsPeriodEnded': false
      });
    } else {
      _updateBase({'IsPeriodEnded': false});
    }
    notifyListeners();
  }

  // Καλείται όταν ξεκινάει το επόμενο δεκάλεπτο
  void startNextPeriod() {
    if (!_hasMatchStarted || _hasMatchFinished || !_hasPeriodEnded) return;

    _hasPeriodEnded = false;
    _currentPeriod++;

    _updateBase({
      'CurrentPeriod': _currentPeriod,
      'IsPeriodEnded': false
    });
    notifyListeners();
  }

  void cancelStartNextPeriod() {
    if (_hasPeriodEnded || _currentPeriod <= 1 || _hasMatchFinished) return;

    _hasPeriodEnded = true; // Ξαναγυρνάμε σε κατάσταση διαλείμματος
    _currentPeriod--;       // Γυρνάμε την περίοδο ένα νούμερο πίσω

    _updateBase({
      'CurrentPeriod': _currentPeriod,
      'IsPeriodEnded': true
    });
    notifyListeners();
  }

  void finishMatch() {
    _hasMatchFinished = true;
    _hasPeriodEnded = true;
    _updateBase({
      'HasMatchFinished': true,
      'IsPeriodEnded': true
    });
    // Εδώ  μελλοντικά η λογική για update βαθμολογίας
    notifyListeners();
  }

  void cancelFinishMatch() {
    if (!_hasMatchFinished) return;



    _hasMatchFinished = false;
    _hasPeriodEnded = false;

    _updateBase({
      'HasMatchFinished': false,
      'IsPeriodEnded': false
    });

    // Εδώ, αν λογική που ενημερώνει τη βαθμολογία στη λήξη,
    // θα πρέπει να αφαιρεθούν οι πόντοι βαθμολογίας.

    notifyListeners();
  }



  //--------------
  //συναρτησεις για σκορ


  Future<void> teamScored(bool isHomeTeam, int points, BasketPlayer? player) async {
    if (!_hasMatchStarted || _hasMatchFinished) return;

    // Εδώ θα μαζέψουμε όλες τις αλλαγές για να κάνουμε ΜΟΝΟ ΕΝΑ write στο Firebase!
    Map<String, dynamic> updatesMap = {};

    // Αρχικοποίηση τοπικού Map αν δεν υπάρχει για το τρέχον δεκάλεπτο
    if (!_periodScores.containsKey(_currentPeriod)) {
      _periodScores[_currentPeriod] = {'home': 0, 'away': 0};
    }

    if (isHomeTeam) {
      _homeScore += points;
      _periodScores[_currentPeriod]!['home'] = (_periodScores[_currentPeriod]!['home'] ?? 0) + points;

      updatesMap['HomeScore'] = FieldValue.increment(points);
      updatesMap['PeriodScores.$_currentPeriod.home'] = FieldValue.increment(points);
    } else {
      _awayScore += points;
      _periodScores[_currentPeriod]!['away'] = (_periodScores[_currentPeriod]!['away'] ?? 0) + points;

      updatesMap['AwayScore'] = FieldValue.increment(points);
      updatesMap['PeriodScores.$_currentPeriod.away'] = FieldValue.increment(points);
    }

    // --- ΚΑΤΑΓΡΑΦΗ ΠΟΝΤΩΝ ΠΑΙΚΤΗ ---
    if (player != null) {
      String playerKey = "${player.name}${player.surname}${player.number}";
      String teamKey = isHomeTeam ? 'home' : 'away'; // Βρίσκουμε σε ποια ομάδα ανήκει

      // 1. Τοπική ανανέωση πόντων
      _playerPoints[teamKey]![playerKey] = (_playerPoints[teamKey]![playerKey] ?? 0) + points;

      // 2. Προσθήκη στο Map για το Firebase
      updatesMap['PlayerPoints.$teamKey.$playerKey'] = FieldValue.increment(points);

      // 3. Ενημέρωση των συνολικών πόντων του παίκτη
      await player.scoredPoints(points);
    }

    // Στέλνουμε ΌΛΑ τα δεδομένα μαζί με μία μόνο κλήση!
    await _updateBase(updatesMap);

    notifyListeners();
  }

 //αφαιρεση ποντων για λαθος
  Future<void> cancelPoints(bool isHomeTeam, int points, BasketPlayer? player) async {
    if (!_hasMatchStarted || _hasMatchFinished) return;

    // Αν προσπαθήσει να αφαιρέσει πόντους ενώ το σκορ είναι 0, σταματάμε.
    if (isHomeTeam && _homeScore - points < 0) return;
    if (!isHomeTeam && _awayScore - points < 0) return;

    Map<String, dynamic> updatesMap = {};

    if (isHomeTeam) {
      _homeScore -= points;
      // Βεβαιωνόμαστε ότι δεν θα πάει κάτω από το μηδέν και το σκορ περιόδου
      int newPeriodScore = (_periodScores[_currentPeriod]?['home'] ?? 0) - points;
      _periodScores[_currentPeriod]!['home'] = newPeriodScore < 0 ? 0 : newPeriodScore;

      updatesMap['HomeScore'] = FieldValue.increment(-points);
      updatesMap['PeriodScores.$_currentPeriod.home'] = FieldValue.increment(-points);
    } else {
      _awayScore -= points;
      int newPeriodScore = (_periodScores[_currentPeriod]?['away'] ?? 0) - points;
      _periodScores[_currentPeriod]!['away'] = newPeriodScore < 0 ? 0 : newPeriodScore;

      updatesMap['AwayScore'] = FieldValue.increment(-points);
      updatesMap['PeriodScores.$_currentPeriod.away'] = FieldValue.increment(-points);
    }

    // --- ΑΦΑΙΡΕΣΗ ΠΟΝΤΩΝ ΠΑΙΚΤΗ ---
    if (player != null) {
      String playerKey = "${player.name}${player.surname}${player.number}";
      String teamKey = isHomeTeam ? 'home' : 'away';

      int currentPlayerPoints = _playerPoints[teamKey]![playerKey] ?? 0;
      int newPlayerPoints = currentPlayerPoints - points;
      _playerPoints[teamKey]![playerKey] = newPlayerPoints < 0 ? 0 : newPlayerPoints;

      updatesMap['PlayerPoints.$teamKey.$playerKey'] = FieldValue.increment(-points);

      // Ενημέρωση των συνολικών πόντων του παίκτη (πρέπει να φτιάξεις/έχεις μια συνάρτηση στο BasketPlayer που αφαιρεί)
      // π.χ. await player.removedPoints(points);
      // Αν δεν έχεις τέτοια συνάρτηση, μπορείς να καλέσεις την scoredPoints με αρνητικό νούμερο:
      await player.scoredPoints(-points);
    }

    await _updateBase(updatesMap);

    notifyListeners();
  }




  // --- ΕΠΙΚΟΙΝΩΝΙΑ ΜΕ FIREBASE ---

  Future<void> _updateBase(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection('year')
        .doc(global.thisYearNow.toString())
        .collection("basket_matches")
        .doc(matchDocId)
        .set(data, SetOptions(merge: true));
  }

  void _startListeningForUpdates() {
    _matchSubscription = FirebaseFirestore.instance
        .collection('year')
        .doc(global.thisYearNow.toString())
        .collection("basket_matches")
        .doc(matchDocId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      bool changed = false;

      // Έλεγχος βασικών μεταβλητών
      if (_homeScore != (data['HomeScore'] ?? _homeScore)) {
        _homeScore = data['HomeScore'] ?? 0;
        changed = true;
      }
      if (_awayScore != (data['AwayScore'] ?? _awayScore)) {
        _awayScore = data['AwayScore'] ?? 0;
        changed = true;
      }
      if (_currentPeriod != (data['CurrentPeriod'] ?? _currentPeriod)) {
        _currentPeriod = data['CurrentPeriod'] ?? 0;
        changed = true;
      }
      if (_hasMatchFinished != (data['HasMatchFinished'] ?? _hasMatchFinished)) {
        _hasMatchFinished = data['HasMatchFinished'] ?? false;
        changed = true;
      }

      if (_hasPeriodEnded != (data['IsPeriodEnded'] ?? false)) {
        _hasPeriodEnded = data['IsPeriodEnded'] ?? false;
        changed = true;
      }

      // Έλεγχος Map δεκαλέπτων
      if (data.containsKey('PeriodScores')) {
        // ΠΡΟΣΟΧΗ: Το Firebase διαβάζει τα keys ως String!
        Map<String, dynamic> fetchedPeriods = data['PeriodScores'];

        fetchedPeriods.forEach((key, value) {
          int periodKey = int.parse(key); // Το μετατρέπουμε σε int για το δικό μας Map

          if (!_periodScores.containsKey(periodKey)) {
            _periodScores[periodKey] = {'home': 0, 'away': 0};
          }

          if (_periodScores[periodKey]!['home'] != (value['home'] ?? 0) ||
              _periodScores[periodKey]!['away'] != (value['away'] ?? 0)) {

            _periodScores[periodKey]!['home'] = value['home'] ?? 0;
            _periodScores[periodKey]!['away'] = value['away'] ?? 0;
            changed = true;
          }
        });
      }

      if (data.containsKey('PlayerPoints')) {
        Map<String, dynamic> fetchedPlayerPoints = data['PlayerPoints'];

        for (var teamKey in ['home', 'away']) {
          if (fetchedPlayerPoints.containsKey(teamKey)) {
            Map<String, dynamic> teamPoints = fetchedPlayerPoints[teamKey];

            teamPoints.forEach((playerKey, value) {
              int pointsValue = value as int;
              if (_playerPoints[teamKey]![playerKey] != pointsValue) {
                _playerPoints[teamKey]![playerKey] = pointsValue;
                changed = true;
              }
            });
          }
        }
      }

      if (changed) notifyListeners();

      if (_hasMatchFinished) {
        stopListening();
      }
    });
  }

  void stopListening() {
    _matchSubscription?.cancel();
    _matchSubscription = null;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }




}


//καποτε οι περιοδοι ηταν σε αλλη κλαση
//class PeriodScore {
//  int team1Score;
//  int team2Score;
//  bool finished;
//  int period;
//
//  PeriodScore({
//    this.team1Score = 0,
//    this.team2Score = 0,
//    this.finished = false,
//    this.period = 0,
//  });
//
//  void updateScore(int team1ScoreP, int team2ScoreP) {
//    int s1 = team1ScoreP;
//    int s2 = team2ScoreP;
//
//
//      team1Score = s1;
//      team2Score = s2;
//      finished = true;
//
//    }
//
//}
