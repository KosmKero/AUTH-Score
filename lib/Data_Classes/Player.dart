class Player {
  final String _name, _surname;
  late int _goals, _numOfYellowCards, _numOfRedCards;
  int _position;

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
}