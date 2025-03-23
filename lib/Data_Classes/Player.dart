import 'package:flutter/cupertino.dart';

import 'Team.dart';

class Player extends ChangeNotifier{
  final String _name, _surname,_teamName;
  late int _goals, _numOfYellowCards, _numOfRedCards;
  int _position,_number,_age; //αν ειναι 0 ειναι τερματοφυλακας,αν ειναι 1 ειναι αμυντικος, αν ειναι 2 τότε είναι μέσος, αν ειανι 3 ειναι επιθετικος
  //Team _team;

  // Constructor
  Player(this._name, this._surname,this._position, this._goals,this._number,this._age,this._teamName,
      {int numOfYellowCards = 0, int numOfRedCards = 0}) {
    _numOfYellowCards = numOfYellowCards;
    _numOfRedCards = numOfRedCards;
  }

  // Getters
  String get name => _name;
  String get surname => _surname;
  int get goals => _goals;
  int get numOfYellowCards => _numOfYellowCards;
  int get numOfRedCards => _numOfRedCards;
  int get position => _position;
  int get age =>_age;
  int get number => _number;
  String get teamName=> _teamName;


  void scoredGoal(){
    _goals++;
  }
  void goalCancelled(){
    _goals--;
  }

  void gotYellowCard(){
    _numOfYellowCards++;
  }
  void gotRedCard(){
    _numOfRedCards++;
  }
  void cancelYellowCard(){
    _numOfYellowCards--;
  }
  void cancelRedCard(){
    _numOfRedCards--;
  }
}