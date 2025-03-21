
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:untitled1/API/Match_Handle.dart';
import 'package:untitled1/Data_Classes/Player.dart';
import 'package:untitled1/Match_Details_Package/Match_Started_Details_Page.dart';

import 'Team.dart';

class Match extends ChangeNotifier{
  //με το _ γινεται private

  bool _hasMatchStarted=false;
  bool _hasMatchFinished=false,_hasSecondhalfStarted=false;
  late int _scoreHome, _scoreAway, _day, _month, _year, _time;
  late Team _homeTeam,_awayTeam;
  late int _startTimeInSeconds;

  final Map<int,List<Goal>> _goalsList={0:[],1:[]};
  Match(
      {required Team homeTeam,
        required Team awayTeam,
        required bool hasMatchStarted,
        required int time,
        required int day,
        required int month,
        required year}) {
    _homeTeam = homeTeam;
    _awayTeam = awayTeam;
    _hasMatchStarted = false;
    _scoreAway = 0;
    _scoreHome = 0;
    _time = time;
    _day = day;
    _month = month;
    _year = year;
    _startTimeInSeconds= DateTime.now().millisecondsSinceEpoch;
  }
  Team get homeTeam => _homeTeam;
  Team get awayTeam => _awayTeam;
  bool get hasMatchStarted => _hasMatchStarted;
  bool get hasMatchFinished=> _hasMatchFinished;
  bool get hasSecondhalfStarted=> _hasSecondhalfStarted;
  int get scoreHome => _scoreHome;
  int get scoreAway => _scoreAway;
  int get time => _time;
  int get day => _day;
  int get month => _month;
  int get year => _year;
  int get startTimeInSeconds=>_startTimeInSeconds;

  //debug
  String get homeInitials=>"CSD";
  String get awayInitials=>"NMK";


  Map<int,List<Goal>> get goalsList => _goalsList;

  String get timeString {
    int hour = time ~/ 100;
    int min = time % 100;
    return "${hour.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}";
  }



  void setScoreHome(int score){
    _scoreHome=score;
  }
  void setScoreAway(int score){
    _scoreAway=score;
  }
  void matchStarted() {
    _startTimeInSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _hasMatchStarted = true;
    notifyListeners();
  }
  void secondHalfStarted(){
    _hasSecondhalfStarted=true;
    notifyListeners();
  }

  void matchFinished(){
    if (!_hasMatchFinished) {
      MatchHandle().matchFinished(this);
    }
    _hasMatchFinished=true;

    notifyListeners();
  }


  void homeScored(String name){
    int half;
    (!_hasSecondhalfStarted)? half=0:half=1;

    _scoreHome++;
    _goalsList[half]?.add(Goal(name, _scoreHome, _scoreAway, DateTime.now().millisecondsSinceEpoch~/ 1000-startTimeInSeconds  , null, true)); //θελει διορθωση
    notifyListeners();


  }
  void awayScored(String name){
    int half;
    (!_hasSecondhalfStarted)? half=0:half=1;

    _scoreAway++;
    _goalsList[half]?.add(Goal(name, _scoreHome, _scoreAway, DateTime.now().millisecondsSinceEpoch~/ 1000-startTimeInSeconds  , null, false));
     notifyListeners();
  }

}


class Goal {
  Goal(this._scorerName, this._homeScore, this._awayScore, this._minute, this._assistName, this._isHomeTeam);

  final bool _isHomeTeam;
  final int _homeScore, _awayScore, _minute;
  final String _scorerName;
  final String? _assistName;

  int get homeScore => _homeScore;
  int get awayScore => _awayScore;
  int get minute => _minute;
  bool get isHomeTeam=>_isHomeTeam;
  String get scorerName => _scorerName;
  String? get assistName => _assistName;


  String get timeString {
    return ((_minute ~/ 60)+1).toString().padLeft(2, '0');
  }
}
