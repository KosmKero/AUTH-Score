import 'package:flutter/cupertino.dart';
import 'package:untitled1/API/Match_Handle.dart';
import 'package:untitled1/API/top_players_handle.dart';
import 'package:untitled1/Data_Classes/Player.dart';

import 'Team.dart';

class Match extends ChangeNotifier{
  //με το _ γινεται private

  bool _hasMatchStarted=false;
  bool _hasMatchFinished=false,_hasSecondHalfStarted=false,_hasFirstHalfFinished=false,_isHalfTime=false;
  late int _scoreHome, _scoreAway, _day, _month, _year, _time;
  late Team _homeTeam,_awayTeam;
  late int _startTimeInSeconds;
  late bool _isGroupPhase; //μεταβλητη που δειχνει αν ειμαστε στη φαση των ομιλων ή στα νοκ αουτς (true->όμιλοι,false->νοκ αουτς)
  late int _game;  //αν ειμαστε σε ομιλους δειχνει την αγωνιστικη, αλλιως δειχνει τη φαση των νοκα ουτς (16 , 8 ,4 η τελικός)

  final Map<int,List<Goal>> _goalsList={0:[],1:[]};
  Match(
      {required Team homeTeam,
        required Team awayTeam,
        required bool hasMatchStarted,
        required int time,
        required int day,
        required int month,
        required year,required isGroupPhase,required game}) {
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

    _isGroupPhase=isGroupPhase;
    _game=game;
  }
  Team get homeTeam => _homeTeam;
  Team get awayTeam => _awayTeam;
  bool get hasMatchStarted => _hasMatchStarted;
  bool get hasFirstHalfFinished=> _hasFirstHalfFinished;
  bool get hasMatchFinished=> _hasMatchFinished;
  bool get hasSecondHalfStarted=> _hasSecondHalfStarted;
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


  bool isHalfTime(){
    if (hasFirstHalfFinished && !hasSecondHalfStarted){
      _isHalfTime=true;
      return true;
    }
    return false;
  }

  Map<int,List<Goal>> get goalsList => _goalsList;

  String get timeString {
    int hour = time ~/ 100;
    int min = time % 100;
    return "${hour.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}";
  }

  String get dateString{
     return "${_day.toString().padLeft(2, '0')}.${_month.toString().padLeft(2, '0')}.${_year.toString().padLeft(4, '0')}";
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
    _hasSecondHalfStarted=true;
    notifyListeners();
  }
  void firstHalfFinished(){
    _hasFirstHalfFinished=true;
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
    (!_hasSecondHalfStarted)? half=0:half=1;

    _scoreHome++;
    _goalsList[half]?.add(Goal(name, _scoreHome, _scoreAway, DateTime.now().millisecondsSinceEpoch~/ 1000-startTimeInSeconds  , null, true,homeTeam)); //θελει διορθωση
    notifyListeners();


  }
  void awayScored(String name){
    int half;
    (!_hasSecondHalfStarted)? half=0:half=1;

    _scoreAway++;
    _goalsList[half]?.add(Goal(name, _scoreHome, _scoreAway, DateTime.now().millisecondsSinceEpoch~/ 1000-startTimeInSeconds  , null, false,awayTeam));
     notifyListeners();
  }

  void matchProgressed(){
    if (_hasSecondHalfStarted){
      matchFinished();
    }
    else if (_hasFirstHalfFinished){
      _hasSecondHalfStarted=true;
    }
    else if (_hasMatchStarted){
      _hasFirstHalfFinished=true;
    }

  }

  String matchweekInfo(){
    String info;
    _isGroupPhase? info="Φάση ομίλων: Αγωνιστική $_game": info="Φάση των $_game: Νοκ Άουτ";
    return info;

  }




}


class Goal extends ChangeNotifier{
  Goal(this._scorerName, this._homeScore, this._awayScore, this._minute, this._assistName, this._isHomeTeam,Team team){
    for (Player player in team.players){
      if ("${player.name.substring(0,1)}. ${player.surname}"==scorerName){
        player.scoredGoal();
      }
    }
    TopPlayersHandle().playerScored(scorerName);
  }

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
