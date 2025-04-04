import 'dart:ui';

import 'package:untitled1/Team_Display_Page_Package/TeamDisplayPage.dart';
import 'package:flutter/material.dart';

import 'Player.dart';

class Team {

  late List<Player> _players;
  List<String>  last5Results=["W","D","L","W","D"];


  // Constructor with optional values
  Team(this.name,this._matches, this._wins, this._losses, this._draws,this._group,this._foundationYear,this._titles,this._coach,[List<Player>? players] ) {
    _players = players ?? []; // Initialize players list if null
  }
  final int? _foundationYear;
  String name;
  String _coach;
  int _matches, _wins, _losses, _draws, _titles;
  final int _group;
  bool _isFavourite=false;
  static int n=0;

  final Image _image1=Image.asset('fotos/csdfootball.png');
  final Image _image2=Image.asset('fotos/teamlogo.png');
  // Getters
  int get matches => _matches;
  int get wins => _wins;
  int get losses => _losses;
  int get draws => _draws;
  int get group => _group;
  List<Player> get players => _players;
  int get totalPoints=> (3*_wins+_draws);
  int get totalGames=> ( _wins + _draws + _losses );
  bool get isFavourite => _isFavourite;
  int? get foundationYear=> _foundationYear;
  int get titles=>_titles;

  List<Player> get getPlayers => _players;

  String get coach => _coach;

  Image get image {
    if (n%2==0) {
      n++;
      return _image1;
    } else {
      n++;
      return _image2;
    }

  }

  // Method to add a player
  void addPlayer(Player player) {
    _players.add(player);
  }
  void increaseWins(){
    _wins++;
  }
  void increaseLoses(){
    _losses++;
  }
  void increaseDraws(){
    _draws++;
  }
  bool changeFavourite(){
    _isFavourite=!_isFavourite;
    return _isFavourite;
  }

}
