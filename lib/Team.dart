import 'package:untitled1/TeamDisplayPage.dart';

class Team {

  late List<Player> _players;


  // Constructor with optional values
  Team(this.name,this._matches, this._wins, this._losses, this._draws,this._group, [List<Player>? players]) {
    _players = players ?? []; // Initialize players list if null
  }
  String name;
  int _matches, _wins, _losses, _draws;
  final int _group;
  bool _isFavourite=false;

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
class Player {
  final String _name, _surname;
  late int _goals, _numOfYellowCards, _numOfRedCards;

  // Constructor
  Player(this._name, this._surname, this._goals,
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

}