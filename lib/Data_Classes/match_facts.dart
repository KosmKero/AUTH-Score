import 'package:flutter/cupertino.dart';

import 'Team.dart';



class MatchFact extends ChangeNotifier {
  MatchFact(this._name, this._team, this._minute, this._isHomeTeam, this._half);

  final String _name;
  final Team _team;
  final int _minute;
  final bool _isHomeTeam;
  final int _half;
  String get timeString {
    return ((_minute ~/ 60) + 1).toString().padLeft(2, '0');
  }

  String get name => _name;
  Team get team => _team;
  bool get isHomeTeam => _isHomeTeam;
  int get half => _half;
  int get minute => _minute;
}



class Goal extends MatchFact {
  Goal(
      {required String scorerName,
        required int homeScore,
        required int awayScore,
        required int minute,
        String? assistName,
        required bool isHomeTeam,
        required Team team,
        required int half})
      : _homeScore = homeScore,
        _awayScore = awayScore,
        _assistName = assistName,
        super(scorerName, team, minute, isHomeTeam, half);

  final int _homeScore, _awayScore;
  final String? _assistName;

  String get scorerName => _name;
  int get homeScore => _homeScore;
  int get awayScore => _awayScore;
  String? get assistName => _assistName;

  factory Goal.fromMap(Map<String, dynamic> map, Team team) {
    return Goal(
      scorerName: map['scorerName'],
      homeScore: map['homeScore'],
      awayScore: map['awayScore'],
      assistName: map['assistName'] == "null" ? null : map['assistName'],
      minute: map['minute'],
      isHomeTeam: map['isHomeTeam'],
      team: team,
      half: map['half'],
    );
  }

  Map<String, dynamic> toMap() {

    return {
      'type': "goal",
      'scorerName': scorerName,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'assistName': assistName ?? "null",
      'minute': minute,
      'isHomeTeam': isHomeTeam,
      'team': team.name,
      'half': half,
    };
  }
}

class CardP extends MatchFact {
  CardP(
      {required String playerName,
        required Team team,
        required bool isYellow,
        required int minute,
        required bool isHomeTeam,
        required int half})
      : _isYellow = isYellow,
        super(playerName, team, minute, isHomeTeam, half);

  final bool _isYellow;
  bool get isYellow => _isYellow;

  Map<String, dynamic> toMap() {
    return {
      'type': 'card', // προσθήκη τύπου για αναγνώριση
      'playerName': name,
      'minute': minute,
      'isYellow': isYellow,
      'isHomeTeam': isHomeTeam,
      'team': team.name,
      'half': half,
    };
  }

  factory CardP.fromMap(Map<String, dynamic> map, Team team) {
    return CardP(
      playerName: map['playerName'],
      minute: map['minute'],
      isYellow: map['isYellow'],
      isHomeTeam: map['isHomeTeam'],
      team: team,
      half: map['half'],
    );
  }
}
