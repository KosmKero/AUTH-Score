import 'package:flutter/material.dart';
import 'dart:math';

import '../API/Match_Handle.dart';
import '../Data_Classes/MatchDetails.dart';
import '../Data_Classes/Team.dart';
import '../Data_Classes/match_facts.dart';
import '../Firebase_Handle/TeamsHandle.dart';
import '../globals.dart';
import '../main.dart' as global;

// 💡 Ιστορικά δεδομένα τοπικά στο αρχείο (για να μην πειράξεις το globals.dart)
List<MatchDetails> historicalMatches = [];

class StatsPage extends StatefulWidget {
  final MatchDetails match;

  const StatsPage({super.key, required this.match});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistoricalData();
  }

  Future<void> _fetchHistoricalData() async {
    if (historicalMatches.isEmpty) {
      await WinProbabilityCalculator.loadHistoricalMatchesBackground();
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final home = widget.match.homeTeam;
    final away = widget.match.awayTeam;

    // --- 1. ΥΠΟΛΟΓΙΣΜΟΙ LIVE ΑΓΩΝΑ ---
    int currentHomeYellow = 0, currentAwayYellow = 0;
    int currentHomeRed = 0, currentAwayRed = 0;

    if (widget.match.hasMatchStarted) {
      for (int i = 0; i < 4; i++) {
        if (widget.match.matchFact.containsKey(i)) {
          for (var fact in widget.match.matchFact[i]!) {
            if (fact is CardP) {
              if (fact.isHomeTeam) {
                fact.isYellow ? currentHomeYellow++ : currentHomeRed++;
              } else {
                fact.isYellow ? currentAwayYellow++ : currentAwayRed++;
              }
            }
          }
        }
      }
    }

    // --- 2. ΥΠΟΛΟΓΙΣΜΟΙ ΙΣΤΟΡΙΚΩΝ ΣΤΑΤΙΣΤΙΚΩΝ ---
    final homeStats = _calculatePastStats(home, global.previousMatches, widget.match.matchDateTime);
    final awayStats = _calculatePastStats(away, global.previousMatches, widget.match.matchDateTime);

    final int homeMatches = homeStats['matches']! > 0 ? homeStats['matches']! : 1;
    final int awayMatches = awayStats['matches']! > 0 ? awayStats['matches']! : 1;

    final int homeGoalsFor = homeStats['goalsFor']!;
    final int awayGoalsFor = awayStats['goalsFor']!;
    final int homeGoalsAgainst = homeStats['goalsAgainst']!;
    final int awayGoalsAgainst = awayStats['goalsAgainst']!;

    final int homeCleanSheets = homeStats['cleanSheets']!;
    final int awayCleanSheets = awayStats['cleanSheets']!;
    final int homeSeasonYellows = homeStats['yellowCards']!;
    final int awaySeasonYellows = awayStats['yellowCards']!;
    final int homeSeasonReds = homeStats['redCards']!;
    final int awaySeasonReds = awayStats['redCards']!;

    final double homeGoalsPerMatch = homeGoalsFor / homeMatches;
    final double awayGoalsPerMatch = awayGoalsFor / awayMatches;

    // --- 3. ΠΙΘΑΝΟΤΗΤΕΣ ΝΙΚΗΣ & ΑΚΡΙΒΕΣ ΣΚΟΡ ---
    final Map<String, dynamic> advancedProbs = WinProbabilityCalculator.calculateProbabilities(
      teamA: home,
      teamB: away,
      teamAMatches: homeMatches,
      teamAGoalsFor: homeGoalsFor,
      teamAGoalsAgainst: homeGoalsAgainst,
      teamBMatches: awayMatches,
      teamBGoalsFor: awayGoalsFor,
      teamBGoalsAgainst: awayGoalsAgainst,
      currentSeasonMatches: global.previousMatches,
      historicalMatches: historicalMatches,
      isGroupPhase: widget.match.isGroupPhase,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 📊 ΜΠΑΡΑ ΠΙΘΑΝΟΤΗΤΩΝ ΚΑΙ ΑΚΡΙΒΕΣ ΣΚΟΡ
          _buildSectionTitle(greek ? "Πιθανότητα Νίκης" : "Win Probability"),
          WinProbabilityBar(
            prob1: advancedProbs['prob1'],
            probX: advancedProbs['probX'],
            prob2: advancedProbs['prob2'],
          ),
          const SizedBox(height: 8),

          Center(
            child: Text(
              greek
                  ? "Πιο πιθανό σκορ: ${advancedProbs['exactScore']} (${advancedProbs['exactProb'].toStringAsFixed(1)}%)"
                  : "Most likely score: ${advancedProbs['exactScore']} (${advancedProbs['exactProb'].toStringAsFixed(1)}%)",
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                color: darkModeNotifier.value ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 20),

          // ⚽ ΕΠΙΘΕΣΗ & ΑΜΥΝΑ
          _buildSectionTitle(greek ? "Συνολικά Τέρματα (Έως τότε)" : "Goals (Up to match)"),
          StatRowBuilder(
            title: greek ? "Γκολ Υπέρ" : "Goals For",
            homeValue: homeGoalsFor.toDouble(),
            awayValue: awayGoalsFor.toDouble(),
            isLowerBetter: false,
            formatAsInt: true,
          ),
          StatRowBuilder(
            title: greek ? "Γκολ Κατά" : "Goals Against",
            homeValue: homeGoalsAgainst.toDouble(),
            awayValue: awayGoalsAgainst.toDouble(),
            isLowerBetter: true,
            formatAsInt: true,
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          // 📈 ΕΙΔΙΚΑ ΣΤΑΤΙΣΤΙΚΑ
          _buildSectionTitle(greek ? "Αποδόσεις (Έως τότε)" : "Performances (Up to match)"),
          StatRowBuilder(
            title: greek ? "Ανέπαφες Εστίες (Clean Sheets)" : "Clean Sheets",
            homeValue: homeCleanSheets.toDouble(),
            awayValue: awayCleanSheets.toDouble(),
            isLowerBetter: false,
            formatAsInt: true,
          ),
          StatRowBuilder(
            title: greek ? "Κίτρινες Σεζόν" : "Season Yellows",
            homeValue: homeSeasonYellows.toDouble(),
            awayValue: awaySeasonYellows.toDouble(),
            isLowerBetter: true,
            formatAsInt: true,
          ),
          StatRowBuilder(
            title: greek ? "Κόκκινες Σεζόν" : "Season Reds",
            homeValue: homeSeasonReds.toDouble(),
            awayValue: awaySeasonReds.toDouble(),
            isLowerBetter: true,
            formatAsInt: true,
          ),
          StatRowBuilder(
            title: greek ? "Γκολ / Αγώνα (Επίθεση)" : "Goals Scored / Match",
            homeValue: homeGoalsPerMatch,
            awayValue: awayGoalsPerMatch,
            isLowerBetter: false,
            formatAsInt: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: darkModeNotifier.value ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }

  Map<String, int> _calculatePastStats(Team team, List<MatchDetails> seasonMatches, DateTime currentMatchTime) {
    int matches = 0, wins = 0, goalsFor = 0, goalsAgainst = 0;
    int cleanSheets = 0, yellowCards = 0, redCards = 0;

    final pastMatches = seasonMatches.where((m) =>
    (m.homeTeam.name == team.name || m.awayTeam.name == team.name) &&
        m.matchDateTime.isBefore(currentMatchTime)
    ).toList();

    for (var m in pastMatches) {
      bool isHome = m.homeTeam.name == team.name;
      matches++;

      if (isHome) {
        goalsFor += m.scoreHome;
        goalsAgainst += m.scoreAway;
        if (m.scoreHome > m.scoreAway) wins++;
        if (m.scoreAway == 0) cleanSheets++;
      } else {
        goalsFor += m.scoreAway;
        goalsAgainst += m.scoreHome;
        if (m.scoreAway > m.scoreHome) wins++;
        if (m.scoreHome == 0) cleanSheets++;
      }

      for (int i = 0; i < 4; i++) {
        if (m.matchFact.containsKey(i)) {
          for (var fact in m.matchFact[i]!) {
            if (fact is CardP && fact.isHomeTeam == isHome) {
              fact.isYellow ? yellowCards++ : redCards++;
            }
          }
        }
      }
    }

    return {
      'matches': matches, 'wins': wins, 'goalsFor': goalsFor, 'goalsAgainst': goalsAgainst,
      'cleanSheets': cleanSheets, 'yellowCards': yellowCards, 'redCards': redCards,
    };
  }
}

// ---------------------------------------------------------
// WIDGETS ΚΑΙ ΒΟΗΘΗΤΙΚΕΣ ΚΛΑΣΕΙΣ
// ---------------------------------------------------------

class WinProbabilityBar extends StatelessWidget {
  final double prob1;
  final double probX;
  final double prob2;

  const WinProbabilityBar({super.key, required this.prob1, required this.probX, required this.prob2});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("1 (${prob1.toStringAsFixed(1)}%)", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              Text("X (${probX.toStringAsFixed(1)}%)", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              Text("2 (${prob2.toStringAsFixed(1)}%)", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            ],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Row(
            children: [
              Expanded(flex: (prob1 * 10).round(), child: Container(height: 12, color: Colors.blue)),
              Expanded(flex: (probX * 10).round(), child: Container(height: 12, color: Colors.grey[400])),
              Expanded(flex: (prob2 * 10).round(), child: Container(height: 12, color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}

class StatRowBuilder extends StatelessWidget {
  final String title;
  final double homeValue;
  final double awayValue;
  final bool isLowerBetter;
  final bool formatAsInt;
  final bool allowNegative;
  final String suffix;

  const StatRowBuilder({
    super.key, required this.title, required this.homeValue, required this.awayValue,
    required this.isLowerBetter, required this.formatAsInt, this.allowNegative = false, this.suffix = "",
  });

  @override
  Widget build(BuildContext context) {
    bool isHomeBetter = false, isAwayBetter = false;

    if (homeValue != awayValue) {
      if (isLowerBetter) {
        isHomeBetter = homeValue < awayValue;
        isAwayBetter = awayValue < homeValue;
      } else {
        isHomeBetter = homeValue > awayValue;
        isAwayBetter = awayValue > homeValue;
      }
    }

    final Color betterColor = Colors.blue;
    final Color worseColor = darkModeNotifier.value ? Colors.grey[700]! : Colors.grey[300]!;
    final Color neutralColor = Colors.grey;

    final Color homeColor = (homeValue == awayValue) ? neutralColor : (isHomeBetter ? betterColor : worseColor);
    final Color awayColor = (homeValue == awayValue) ? neutralColor : (isAwayBetter ? betterColor : worseColor);

    String homeStr = formatAsInt ? homeValue.round().toString() : homeValue.toStringAsFixed(1);
    String awayStr = formatAsInt ? awayValue.round().toString() : awayValue.toStringAsFixed(1);

    double safeHome = max(0, allowNegative ? homeValue.abs() : homeValue);
    double safeAway = max(0, allowNegative ? awayValue.abs() : awayValue);
    double total = safeHome + safeAway;

    double homeWidth = total > 0 ? (safeHome / total) : 0.0;
    double awayWidth = total > 0 ? (safeAway / total) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$homeStr$suffix", style: TextStyle(fontSize: 16, fontWeight: isHomeBetter ? FontWeight.bold : FontWeight.normal, color: darkModeNotifier.value ? Colors.white : Colors.black)),
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: darkModeNotifier.value ? Colors.grey[400] : Colors.grey[700])),
              Text("$awayStr$suffix", style: TextStyle(fontSize: 16, fontWeight: isAwayBetter ? FontWeight.bold : FontWeight.normal, color: darkModeNotifier.value ? Colors.white : Colors.black)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Align(alignment: Alignment.centerRight, child: FractionallySizedBox(widthFactor: homeWidth, child: Container(height: 6, decoration: BoxDecoration(color: homeColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4))))))),
              const SizedBox(width: 4),
              Expanded(child: Align(alignment: Alignment.centerLeft, child: FractionallySizedBox(widthFactor: awayWidth, child: Container(height: 6, decoration: BoxDecoration(color: awayColor, borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4))))))),
            ],
          ),
        ],
      ),
    );
  }
}

class WinProbabilityCalculator {
  static int _factorial(int n) {
    if (n == 0 || n == 1) return 1;
    int result = 1;
    for (int i = 2; i <= n; i++) result *= i;
    return result;
  }

  static double _poisson(int k, double lambda) {
    return (pow(lambda, k) * exp(-lambda)) / _factorial(k);
  }

  static double _calculateTeamPPG(String teamName, List<MatchDetails> allPastMatches) {
    int points = 0, matches = 0;
    for (var m in allPastMatches) {
      if (m.homeTeam.name == teamName) {
        matches++;
        if (m.scoreHome > m.scoreAway) points += 3;
        else if (m.scoreHome == m.scoreAway) points += 1;
      } else if (m.awayTeam.name == teamName) {
        matches++;
        if (m.scoreAway > m.scoreHome) points += 3;
        else if (m.scoreHome == m.scoreAway) points += 1;
      }
    }
    return matches == 0 ? 1.3 : (points / matches);
  }

  static double _calculateSoS(String teamName, List<MatchDetails> allPastMatches, double leagueAvgPPG) {
    List<String> opponents = [];
    for (var m in allPastMatches) {
      if (m.homeTeam.name == teamName) opponents.add(m.awayTeam.name);
      else if (m.awayTeam.name == teamName) opponents.add(m.homeTeam.name);
    }
    if (opponents.isEmpty) return 1.0;

    double opponentsTotalPPG = 0;
    for (var opp in opponents) opponentsTotalPPG += _calculateTeamPPG(opp, allPastMatches);
    return (opponentsTotalPPG / opponents.length) / leagueAvgPPG;
  }

  // 💡 Δείκτης Φόρμας (Momentum)
  static double _calculateFormMultiplier(Team team) {
    if (team.last5Results.isEmpty) return 1.0;

    int formPoints = 0;
    int validGames = 0;

    for (String res in team.last5Results) {
      if (res == "W") formPoints += 3;
      else if (res == "D") formPoints += 1;
      if (res != "") validGames++;
    }

    if (validGames == 0) return 1.0;
    double formRatio = formPoints / (validGames * 3.0);
    return 0.90 + (formRatio * 0.20); // 0.90 έως 1.10
  }

  static Map<String, dynamic> calculateProbabilities({
    required Team teamA,
    required Team teamB,
    required int teamAMatches, required int teamAGoalsFor, required int teamAGoalsAgainst,
    required int teamBMatches, required int teamBGoalsFor, required int teamBGoalsAgainst,
    required List<MatchDetails> currentSeasonMatches,
    required List<MatchDetails> historicalMatches,
    required bool isGroupPhase,
  }) {
    if (teamAMatches == 0 || teamBMatches == 0 || currentSeasonMatches.isEmpty) {
      return {'prob1': 33.3, 'probX': 33.4, 'prob2': 33.3, 'exactScore': 'N/A', 'exactProb': 0.0};
    }

    int currentLeagueMatches = currentSeasonMatches.length;
    int currentLeagueGoals = 0, currentLeaguePoints = 0;

    for (var m in currentSeasonMatches) {
      currentLeagueGoals += (m.scoreHome + m.scoreAway);
      currentLeaguePoints += (m.scoreHome != m.scoreAway) ? 3 : 2;
    }

    double currentLeagueAvgGoals = currentLeagueGoals / (currentLeagueMatches * 2);
    if (currentLeagueAvgGoals == 0) currentLeagueAvgGoals = 1.5;
    double currentLeagueAvgPPG = currentLeaguePoints / (currentLeagueMatches * 2);
    if (currentLeagueAvgPPG == 0) currentLeagueAvgPPG = 1.3;

    double teamASoS = _calculateSoS(teamA.name, currentSeasonMatches, currentLeagueAvgPPG);
    double teamBSoS = _calculateSoS(teamB.name, currentSeasonMatches, currentLeagueAvgPPG);

    double currentAttackA = teamAMatches > 0 ? ((teamAGoalsFor / teamAMatches) / currentLeagueAvgGoals) * teamASoS : 1.0;
    double currentDefenseA = teamAMatches > 0 ? ((teamAGoalsAgainst / teamAMatches) / currentLeagueAvgGoals) / teamASoS : 1.0;

    double currentAttackB = teamBMatches > 0 ? ((teamBGoalsFor / teamBMatches) / currentLeagueAvgGoals) * teamBSoS : 1.0;
    double currentDefenseB = teamBMatches > 0 ? ((teamBGoalsAgainst / teamBMatches) / currentLeagueAvgGoals) / teamBSoS : 1.0;

    double histAttackA = 1.0, histDefenseA = 1.0, histAttackB = 1.0, histDefenseB = 1.0;
    int histMatchesA = 0, histMatchesB = 0;

    if (historicalMatches.isNotEmpty) {
      int histGoalsForA = 0, histGoalsAgainstA = 0, histGoalsForB = 0, histGoalsAgainstB = 0;
      int histLeagueGoals = 0;

      for (var m in historicalMatches) {
        histLeagueGoals += (m.scoreHome + m.scoreAway);

        if (m.homeTeam.name == teamA.name || m.awayTeam.name == teamA.name) {
          histMatchesA++;
          histGoalsForA += m.homeTeam.name == teamA.name ? m.scoreHome : m.scoreAway;
          histGoalsAgainstA += m.homeTeam.name == teamA.name ? m.scoreAway : m.scoreHome;
        }
        if (m.homeTeam.name == teamB.name || m.awayTeam.name == teamB.name) {
          histMatchesB++;
          histGoalsForB += m.homeTeam.name == teamB.name ? m.scoreHome : m.scoreAway;
          histGoalsAgainstB += m.homeTeam.name == teamB.name ? m.scoreAway : m.scoreHome;
        }
      }

      double histLeagueAvgGoals = histLeagueGoals / (historicalMatches.length * 2);
      if (histLeagueAvgGoals == 0) histLeagueAvgGoals = 1.5;

      if (histMatchesA > 0) {
        histAttackA = ((histGoalsForA / histMatchesA) / histLeagueAvgGoals);
        histDefenseA = ((histGoalsAgainstA / histMatchesA) / histLeagueAvgGoals);
      }
      if (histMatchesB > 0) {
        histAttackB = ((histGoalsForB / histMatchesB) / histLeagueAvgGoals);
        histDefenseB = ((histGoalsAgainstB / histMatchesB) / histLeagueAvgGoals);
      }
    }

    double k = 3.0;
    double weightCurrentA = (histMatchesA == 0) ? 1.0 : (teamAMatches / (teamAMatches + k));
    double weightHistA = 1.0 - weightCurrentA;

    double weightCurrentB = (histMatchesB == 0) ? 1.0 : (teamBMatches / (teamBMatches + k));
    double weightHistB = 1.0 - weightCurrentB;

    double finalAttackA = (currentAttackA * weightCurrentA) + (histAttackA * weightHistA);
    double finalDefenseA = (currentDefenseA * weightCurrentA) + (histDefenseA * weightHistA);

    double finalAttackB = (currentAttackB * weightCurrentB) + (histAttackB * weightHistB);
    double finalDefenseB = (currentDefenseB * weightCurrentB) + (histDefenseB * weightHistB);

    double formA = _calculateFormMultiplier(teamA);
    double formB = _calculateFormMultiplier(teamB);

    double xGA = finalAttackA * finalDefenseB * currentLeagueAvgGoals * formA;
    double xGB = finalAttackB * finalDefenseA * currentLeagueAvgGoals * formB;

    if (!isGroupPhase) {
      double avgXG = (xGA + xGB) / 2;
      xGA = (xGA * 0.60) + (avgXG * 0.40);
      xGB = (xGB * 0.60) + (avgXG * 0.40);
    }

    if (xGA < 0.1) xGA = 0.1;
    if (xGB < 0.1) xGB = 0.1;

    double prob1 = 0.0, probX = 0.0, prob2 = 0.0;
    double maxScoreProb = 0.0;
    String mostLikelyScore = "0-0";

    for (int i = 0; i <= 8; i++) {
      for (int j = 0; j <= 8; j++) {
        double probMatrix = _poisson(i, xGA) * _poisson(j, xGB);

        if (i > j) prob1 += probMatrix;
        else if (i == j) probX += probMatrix;
        else prob2 += probMatrix;

        if (probMatrix > maxScoreProb) {
          maxScoreProb = probMatrix;
          mostLikelyScore = "$i-$j";
        }
      }
    }

    double totalProb = prob1 + probX + prob2;
    if (totalProb == 0) return {'prob1': 33.3, 'probX': 33.4, 'prob2': 33.3, 'exactScore': 'N/A', 'exactProb': 0.0};

    return {
      'prob1': (prob1 / totalProb) * 100,
      'probX': (probX / totalProb) * 100,
      'prob2': (prob2 / totalProb) * 100,
      'exactScore': mostLikelyScore,
      'exactProb': (maxScoreProb / totalProb) * 100,
    };
  }

  static Future<List<MatchDetails>> loadHistoricalMatchesBackground() async {
    try {
      List<MatchDetails> allPastMatches = [];
      int currentSeason = thisYearNow;

      List<int> pastYears = [currentSeason - 1, currentSeason - 2];

      for (int pastYear in pastYears) {
        List<Team> list = await TeamsHandle().getAllTeamsByYear(pastYear);
        List<MatchDetails> matches = await MatchHandle().getMatchesByYear(pastYear, list);
        allPastMatches.addAll(matches);
      }

      historicalMatches = allPastMatches;
      print("✅ Φορτώθηκαν ${historicalMatches.length} ιστορικά ματς από τα $pastYears");
      return historicalMatches;
    } catch (e) {
      print("❌ Σφάλμα κατά τη φόρτωση ιστορικών ματς: $e");
      return [];
    }
  }
}