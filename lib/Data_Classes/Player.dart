import 'package:flutter/cupertino.dart';

import 'Team.dart';

class Player extends ChangeNotifier{
  final String _name, _surname;
  late int _goals, _numOfYellowCards, _numOfRedCards;
  int _position; //αν ειναι 0 ειναι τερματοφυλακας, αν ειναι 1 τότε είναι μέσος, αν ειανι 2 ειναι επιθετικος
  //Team _team;

  // Constructor
  Player(this._name, this._surname,this._position, this._goals,
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


  void scoredGoal(){
    _goals++;
  }
}