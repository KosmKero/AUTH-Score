import 'package:flutter/cupertino.dart';
import 'Team.dart';

abstract class MatchFact extends ChangeNotifier {
  final String name;
  final Team team;
  final int minute;
  final bool isHomeTeam;
  final int half;
  final String type;

  MatchFact({
    required this.name,
    required this.team,
    required this.minute,
    required this.isHomeTeam,
    required this.half,
    required this.type,
  });

  String get timeString {
    return ((minute ~/ 60) + 1).toString().padLeft(2, '0');
  }

  // Κοινό toMap για όλους
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'playerName': name,
      'team': team.name,
      'minute': minute,
      'isHomeTeam': isHomeTeam,
      'half': half,
    };
  }
}

// --- ΤΟ ΓΚΟΛ (CHILD CLASS) ---
class Goal extends MatchFact {
   int homeScore;
   int awayScore;
  final String? assistName;

  Goal({
    required String scorerName,
    required this.homeScore,
    required this.awayScore,
    required int minute,
    this.assistName,
    required bool isHomeTeam,
    required Team team,
    required int half,
  }) : super(
    name: scorerName,
    team: team,
    minute: minute,
    isHomeTeam: isHomeTeam,
    half: half,
    type: 'goal',
  );

  factory Goal.fromMap(Map<String, dynamic> map, Team team) {
    return Goal(
      scorerName: map['playerName'] ?? map['scorerName'] ?? "Άγνωστος",
      homeScore: map['homeScore'] ?? 0,
      awayScore: map['awayScore'] ?? 0,
      assistName: map['assistName'] == "null" ? null : map['assistName'],
      minute: map['minute'] ?? 0,
      isHomeTeam: map['isHomeTeam'] ?? true,
      team: team,
      half: map['half'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'homeScore': homeScore,
      'awayScore': awayScore,
      'assistName': assistName ?? "null",
    });
    return map;
  }
}

// --- Η ΚΑΡΤΑ (CHILD CLASS) ---
class CardP extends MatchFact {
  final bool isYellow;
  final bool isSecondYellow;
  final String? reason;

  CardP({
    required super.name,
    required this.isYellow,
    this.isSecondYellow = false,
    this.reason,
    required super.minute,
    required super.isHomeTeam,
    required super.team,
    required super.half,
  }) : super(type: 'card');

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'isYellow': isYellow,
      'isSecondYellow': isSecondYellow,
      'reason': reason,
    });
    return map;
  }

  factory CardP.fromMap(Map<String, dynamic> map, Team team) {
    return CardP(
      name: map['playerName'] ?? map['name'] ?? "Άγνωστος",
      isYellow: map['isYellow'] ?? true,
      isSecondYellow: map['isSecondYellow'] ?? false,
      reason: map['reason'],
      minute: map['minute'] ?? 0,
      isHomeTeam: map['isHomeTeam'] ?? true,
      team: team,
      half: map['half'] ?? 0,
    );
  }
}

// --- Η ΑΛΛΑΓΗ (CHILD CLASS) ---
class Substitution extends MatchFact {
  final String playerIn; // Το key (π.χ. Γιάννης7) για τον κώδικα
  final String playerOut;
  final String playerInName;
  final String playerOutName;

  Substitution({
    required this.playerIn,
    required this.playerOut,
    required this.playerInName,
    required this.playerOutName,
    required int minute,
    required bool isHomeTeam,
    required Team team,
    required int half,
  }) : super(
    // Τώρα αποθηκεύεται πανέμορφα και στο name του MatchFact
    name: '$playerInName (IN) - $playerOutName (OUT)',
    team: team,
    minute: minute,
    isHomeTeam: isHomeTeam,
    half: half,
    type: 'sub',
  );

  factory Substitution.fromMap(Map<String, dynamic> map, Team team) {
    return Substitution(
      playerIn: map['playerIn'] ?? "Άγνωστος",
      playerOut: map['playerOut'] ?? "Άγνωστος",
      playerInName: map['playerInName'] ?? "Άγνωστος",
      playerOutName: map['playerOutName'] ?? "Άγνωστος",
      minute: map['minute'] ?? 0,
      isHomeTeam: map['isHomeTeam'] ?? true,
      team: team,
      half: map['half'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'playerIn': playerIn,
      'playerOut': playerOut,
      'playerInName': playerInName,
      'playerOutName': playerOutName,
    });
    return map;
  }
}