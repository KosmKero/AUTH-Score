import 'package:flutter/cupertino.dart';

import '../../globals.dart';
import 'basketTeam.dart';

class basketMatch extends ChangeNotifier {


  late basketTeam homeTeam,awayTeam;

  bool matchStarted = true;
  bool matchFinished = false;


  bool _isGroupPhase=false;
  int _game=0;

  List<PeriodScore> periods = [];

  int homeScore=0,awayScore=0;

  int _day=2, _month=12, _year=2025,_time=0;

  basketMatch() {

    homeTeam= basketTeam("Paok", "sf ", 3,3, 0, 2, 2025 , 0 , " ", 1 , "paok",' asd','c2');
    awayTeam= basketTeam("oly", "fsd",  3,2, 1, 2, 2025 , 0 , " ", 2 , "ol",'da ','dd');


    // Αρχικοποίηση με 4 κανονικές περιόδους
    for (int i = 0; i < 4; i++) {
      periods.add(PeriodScore(period: i));
    }
  }
  String get dateString {
    return "${_day.toString().padLeft(2, '0')}.${_month.toString().padLeft(2, '0')}.${(_year % 100).toString().padLeft(2, '0')}";
  }

  late int hour = _time ~/ 100;

  late int minute = _time % 100;

  // Δημιουργία DateTime
  late DateTime matchDateTime = DateTime(_year, _month, _day, hour, minute);

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

  String get timeString {
    int hour = _time ~/ 100;
    int min =  _time % 100;
    return "${hour.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}";
  }

  int get time => _time;
  int get day => _day;
  int get month => _month;
  int get year => _year;

  void startPeriod({int thisPeriod = 0}) {
    // Προσθήκη περιόδου αν είναι παράταση
    if (periods.isEmpty || periods.last.finished) {
      periods.add(PeriodScore(period: thisPeriod));
      notifyListeners();
    }
    notifyListeners();
  }

  void finishPeriod(int index) {
    if (index < periods.length) {
      periods[index].finished = true;
      notifyListeners();
    }
  }

  void updateScore(int period, int team1Score, int team2Score) {
    int s1= team1Score-homeScore;
    int s2= team2Score-awayScore;
    homeScore=team1Score;
    awayScore=team2Score;

    if (period < periods.length) {
      periods[period].team1Score = s1;
      periods[period].team2Score = s2;
      periods[period].finished=true;
      notifyListeners();
    }
  }
}

class PeriodScore {
  int team1Score;
  int team2Score;
  bool finished;
  int period;

  PeriodScore(
      {
    this.team1Score = 0,
    this.team2Score = 0,
    this.finished = false,
    this.period = 0,
  });
}
