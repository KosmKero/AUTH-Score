import 'package:hive/hive.dart';
part 'hiveOfflineSave.g.dart';


@HiveType(typeId: 0)
class MatchModel {
  @HiveField(0)
  final String homeTeam;

  @HiveField(1)
  final String awayTeam;

  @HiveField(2)
  final int homeScore; // GoalHome

  @HiveField(3)
  final int awayScore; // GoalAway

  @HiveField(4)
  final DateTime startTime;

  @HiveField(5)
  final int day;

  @HiveField(6)
  final int month;

  @HiveField(7)
  final int year;

  @HiveField(8)
  final int time; // π.χ. 1715

  @HiveField(9)
  final String type; // "previous"

  @HiveField(10)
  final bool isGroupPhase;

  @HiveField(11)
  final String homeTeamEnglish;

  @HiveField(12)
  final String awayTeamEnglish;

  @HiveField(13)
  final List<Goal> facts;       // λίστα με γκολ

  @HiveField(14)
  final List<Penalty> penalties; // λίστα με πέναλτι

  MatchModel({
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.startTime,
    required this.day,
    required this.month,
    required this.year,
    required this.time,
    required this.type,
    required this.isGroupPhase,
    required this.homeTeamEnglish,
    required this.awayTeamEnglish,
    required this.facts,
    required this.penalties,
  });
}

@HiveType(typeId: 1)
class Goal {
  @HiveField(0)
  final String scorerName;

  @HiveField(1)
  final String assistName;

  @HiveField(2)
  final int homeScore;

  @HiveField(3)
  final int awayScore;

  @HiveField(4)
  final int minute;

  @HiveField(5)
  final String team;

  @HiveField(6)
  final bool isHomeTeam;

  @HiveField(7)
  final int half;

  @HiveField(8)
  final String type;

  Goal({
    required this.scorerName,
    required this.assistName,
    required this.homeScore,
    required this.awayScore,
    required this.minute,
    required this.team,
    required this.isHomeTeam,
    required this.half,
    required this.type,
  });
}

@HiveType(typeId: 2)
class Penalty {
  @HiveField(0)
  final bool isHomeTeam;

  @HiveField(1)
  final bool isScored;

  @HiveField(2)
  final DateTime timestamp;

  Penalty({
    required this.isHomeTeam,
    required this.isScored,
    required this.timestamp,
  });
}


