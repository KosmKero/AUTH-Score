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

  //final Map<int,List<Goal>> _goalsList={0:[],1:[]};
  //final Map<int, List<CardP>> _cardList = {0:[],1:[]};

  final Map<int, List<MatchFact>> _matchFacts = {0:[],1:[]};

  //Μαπ που θα δειχνει ποιοι παιχτες επιλέχθηκαν απο τον αντμιν για την αρχικη ενδεκαδα,
  // για να μη ντου εμφανιζονται σαν επιλογη στο gui
    List<Map<Player,bool>> playersSelected=[{},{}];

    List<List<Player?>> players11=[[],[]];

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

    for (Player player in homeTeam.players) {
      playersSelected[0][player]=false;
    }
    for (Player player in awayTeam.players) {
      playersSelected[1][player]=false;
    }
    for (int i=0;i<2;i++){
      for (int j=0;j<11;j++){
        players11[i].add(null);
      }
    }
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

  //Map<int,List<Goal>> get goalsList => _goalsList;
  Map<int,List<MatchFact>> get matchFact => _matchFacts;

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


  void homeScored(String name){
    int half;
    (!_hasSecondHalfStarted)? half=0:half=1;

    _scoreHome++;
    _matchFacts[half]?.add(Goal(scorerName: name, homeScore: _scoreHome, awayScore: _scoreAway, minute: DateTime.now().millisecondsSinceEpoch~/ 1000-startTimeInSeconds, isHomeTeam:  true, team: homeTeam,half: half ));
    notifyListeners();


  }
  void awayScored(String name){
    int half;
    (!_hasSecondHalfStarted)? half=0:half=1;

    _scoreAway++;
    _matchFacts[half]?.add(Goal(scorerName: name, homeScore: _scoreHome, awayScore: _scoreAway, minute: DateTime.now().millisecondsSinceEpoch~/ 1000-startTimeInSeconds, isHomeTeam:  false, team: awayTeam,half: half ));
     notifyListeners();
  }

  void matchProgressed(){
    if (_hasSecondHalfStarted){
      if (!_hasMatchFinished) {
        MatchHandle().matchFinished(this);
      }
      _hasMatchFinished=true;
      notifyListeners();
    }
    else if (_hasFirstHalfFinished){
      _hasSecondHalfStarted=true;
    }
    else if (_hasMatchStarted){
      _hasFirstHalfFinished=true;
    }

  }

  void matchCancelProgressed(){
    if (_hasMatchFinished && (DateTime.now().millisecondsSinceEpoch~/ 1000)-startTimeInSeconds<120){
      if (_hasMatchFinished) {
        MatchHandle().matchNotFinished(this);
      }
      _hasMatchFinished=false;
      notifyListeners();
    }
    else if (_hasSecondHalfStarted){
      _hasSecondHalfStarted=false;
    }
    else if (_hasFirstHalfFinished){
      _hasFirstHalfFinished=false;
    }
    else if (_hasMatchStarted){
      _hasMatchStarted=false;
      notifyListeners();
    }

  }

  String matchweekInfo(){
    String info;
    _isGroupPhase? info="Φάση ομίλων: Αγωνιστική $_game": info="Φάση των $_game: Νοκ Άουτ";
    return info;

  }

  void playerGotCard(String name,Team team,bool isYellow,int? minute,bool isHomeTeam){


    for (Player player in team.players){
      if ("${player.name.substring(0,1)}. ${player.surname}"==name){
        isYellow? player.gotYellowCard() : player.gotRedCard();
        break;
      }
    }
    int half;
    (!_hasSecondHalfStarted) ? half=0 : half=1;
    _matchFacts[half]?.add(CardP(playerName: name, team: team, isYellow: isYellow, minute: minute??  (DateTime.now().millisecondsSinceEpoch~/ 1000)-startTimeInSeconds, isHomeTeam: isHomeTeam,half: half));
    notifyListeners();
  }

  void cancelGoal(Goal goal1) {
    if (_matchFacts.containsKey(goal1.half)) {
        _matchFacts[goal1.half]!.removeWhere((goal) => goal is Goal && goal == goal1);
        goal1.isHomeTeam? _scoreHome-- : _scoreAway--;
        for (Player player in goal1.team.players) {
          if ("${player.name.substring(0, 1)}. ${player.surname}" == goal1.scorerName) {
            player.goalCancelled();
            TopPlayersHandle().goalCancelled(goal1.scorerName);
            break;
          }
        }

      notifyListeners(); // Ενημέρωση των listeners για την αλλαγή
    }
  }

  void cancelCard(CardP card1) {
    if (_matchFacts.containsKey(card1.half)) {
      _matchFacts[card1.half]!.removeWhere((card) => card is CardP && card == card1);

      for (Player player in card1.team.players){
        if ("${player.name.substring(0,1)}. ${player.surname}"==card1.name){
          card1.isYellow? player.cancelYellowCard() : player.cancelRedCard();
          break;
        }
      }

      notifyListeners(); // Ενημέρωση των listeners για την αλλαγή
    }
  }


}

class Goal extends MatchFact {
  Goal({
    required String scorerName,
    required int homeScore,
    required int awayScore,
    required int minute,
    String? assistName,
    required bool isHomeTeam,
    required Team team,
    required int half
  })  : _homeScore = homeScore,
        _awayScore = awayScore,
        _assistName = assistName,
        super(scorerName, team, minute, isHomeTeam,half) {
    // Ενημέρωση του παίκτη που σκόραρε
    for (Player player in team.players) {
      if ("${player.name.substring(0, 1)}. ${player.surname}" == scorerName) {
        player.scoredGoal();
        break;
      }
    }
    TopPlayersHandle().playerScored(scorerName);
  }

  final int _homeScore, _awayScore;
  final String? _assistName;

  String get scorerName => _name;
  int get homeScore => _homeScore;
  int get awayScore => _awayScore;
  String? get assistName => _assistName;
}

class CardP extends MatchFact {
  CardP({
    required String playerName,
    required Team team,
    required bool isYellow,
    required int minute,
    required bool isHomeTeam,
    required int half
  })  : _isYellow = isYellow,
        super(playerName, team, minute, isHomeTeam,half);

  final bool _isYellow;
  bool get isYellow => _isYellow;
}

class MatchFact extends ChangeNotifier {
  MatchFact(this._name, this._team, this._minute, this._isHomeTeam,this._half);

  final String _name;
  final Team _team;
  final int _minute;
  final bool _isHomeTeam;
  final int _half;
  String get timeString {
    return ((_minute ~/ 60)+1).toString().padLeft(2, '0');
  }
  String get name => _name;
  Team get team=> _team;
  bool get isHomeTeam => _isHomeTeam;
  int get half => _half;
}
