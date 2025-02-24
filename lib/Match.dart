
import 'Team.dart';

class Match {
  //με το _ γινεται private

  late bool _hasMatchStarted;
  late int _scoreHome, _scoreAway, _day, _month, _year, _time;
  late Team _homeTeam,_awayTeam;

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
    _hasMatchStarted = hasMatchStarted;
    _scoreAway = 0;
    _scoreHome = 0;
    _time = time;
    _day = day;
    _month = month;
    _year = year;
  }
  Team get homeTeam => _homeTeam;
  Team get awayTeam => _awayTeam;
  bool get hasMatchStarted => _hasMatchStarted;
  int get scoreHome => _scoreHome;
  int get scoreAway => _scoreAway;
  int get time => _time;
  int get day => _day;
  int get month => _month;
  int get year => _year;
  String get timeString=> "${(time/100).toInt()}:${time%100}";


  void setScoreHome(int score){
    _scoreHome=score;
  }
  void setScoreAway(int score){
    _scoreAway=score;
  }
}