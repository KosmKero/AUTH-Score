import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import '../Data_Classes/MatchDetails.dart';
import '../Data_Classes/Team.dart';
import '../Data_Classes/match_facts.dart';
import '../Data_Classes/match_prediction.dart';
import '../globals.dart';

class StatsPage extends StatefulWidget {
  final MatchDetails match;

  const StatsPage({super.key, required this.match});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  bool _isLoading = true;
  bool _hasError = false;

  Map<String, dynamic> _pastStatsA = {};
  Map<String, dynamic> _pastStatsB = {};

  // Μεταβλητές για το Snapshot Pattern (Κλειδωμένα Δεδομένα)
  MatchPrediction? _lockedPrediction;
  int? _lockedHomeMatches, _lockedHomeGoalsFor, _lockedHomeGoalsAgainst;
  int? _lockedAwayMatches, _lockedAwayGoalsFor, _lockedAwayGoalsAgainst;

  @override
  void initState() {
    super.initState();
    _loadAverages();
  }

  Future<void> _loadAverages() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final homeName = widget.match.homeTeam.name;
      final awayName = widget.match.awayTeam.name;

      // 1. Υπολογισμός Season Year (π.χ. Οκτ 2026 -> Σεζόν 2027)
      final matchMonth = widget.match.month;
      final matchCalendarYear = widget.match.year;
      final seasonYear = matchMonth >= 8 ? matchCalendarYear + 1 : matchCalendarYear;

      // 2. Έλεγχος αν το ματς ΕΧΕΙ ΛΗΞΕΙ (Κλείδωμα δεδομένων)
      if (widget.match.hasMatchFinished) {
        var matchDoc = await FirebaseFirestore.instance
            .collection('year')
            .doc(seasonYear.toString())
            .collection('matches')
            .doc(widget.match.matchDocId)
            .get();

        if (matchDoc.exists && matchDoc.data()!.containsKey('lockedProb1')) {
          final data = matchDoc.data()!;
          _lockedPrediction = MatchPrediction(
            prob1: (data['lockedProb1'] ?? 33.3).toDouble(),
            probX: (data['lockedProbX'] ?? 33.4).toDouble(),
            prob2: (data['lockedProb2'] ?? 33.3).toDouble(),
            exactScore: data['lockedScore'] ?? "N/A",
            exactProb: (data['lockedScoreProb'] ?? 0.0).toDouble(),
          );

          _lockedHomeMatches = data['lockedHomeMatches'];
          _lockedHomeGoalsFor = data['lockedHomeGoalsFor'];
          _lockedHomeGoalsAgainst = data['lockedHomeGoalsAgainst'];

          _lockedAwayMatches = data['lockedAwayMatches'];
          _lockedAwayGoalsFor = data['lockedAwayGoalsFor'];
          _lockedAwayGoalsAgainst = data['lockedAwayGoalsAgainst'];
        }
      }

      // 3. Αν δεν υπάρχουν κλειδωμένα νούμερα, κάνουμε live υπολογισμό!
      if (_lockedPrediction == null) {
        await Future.wait([
          WinProbabilityCalculator.loadLeagueAverages(seasonYear),
          WinProbabilityCalculator.getLastYearStats(homeName, seasonYear).then((val) => _pastStatsA = val),
          WinProbabilityCalculator.getLastYearStats(awayName, seasonYear).then((val) => _pastStatsB = val),
        ]);
      }
    } catch (e) {
      print("Σφάλμα στο StatsPage: $e");
      if (mounted) setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[400], size: 48),
              const SizedBox(height: 16),
              Text(
                greek ? "Αποτυχία φόρτωσης στατιστικών." : "Failed to load statistics.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkModeNotifier.value ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadAverages,
                icon: const Icon(Icons.refresh),
                label: Text(greek ? "Επανάληψη" : "Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final home = widget.match.homeTeam;
    final away = widget.match.awayTeam;

    // --- 1. ΥΠΟΛΟΓΙΣΜΟΙ LIVE ΑΓΩΝΑ (Κίτρινες/Κόκκινες στο ΣΗΜΕΡΙΝΟ ματς) ---
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

    // --- 2. ΣΤΑΤΙΣΤΙΚΑ ΣΕΖΟΝ (Κλειδωμένα αν έληξε, Live αν δεν έχει λήξει) ---
    final int homeMatches = _lockedHomeMatches ?? (home.matches > 0 ? home.matches : 1);
    final int awayMatches = _lockedAwayMatches ?? (away.matches > 0 ? away.matches : 1);

    final int homeGoalsFor = _lockedHomeGoalsFor ?? home.goalsFor;
    final int awayGoalsFor = _lockedAwayGoalsFor ?? away.goalsFor;

    final int homeGoalsAgainst = _lockedHomeGoalsAgainst ?? home.goalsAgainst;
    final int awayGoalsAgainst = _lockedAwayGoalsAgainst ?? away.goalsAgainst;

    final double homeGoalsPerMatch = homeGoalsFor / homeMatches;
    final double awayGoalsPerMatch = awayGoalsFor / awayMatches;

    final double homeGoalsAgainstPerMatch = homeGoalsAgainst / homeMatches;
    final double awayGoalsAgainstPerMatch = awayGoalsAgainst / awayMatches;

    // --- 3. ΠΙΘΑΝΟΤΗΤΕΣ ΝΙΚΗΣ & ΑΚΡΙΒΕΣ ΣΚΟΡ ---
    final MatchPrediction prediction = _lockedPrediction ?? WinProbabilityCalculator.calculateProbabilities(
      teamA: home,
      teamB: away,
      pastStatsA: _pastStatsA,
      pastStatsB: _pastStatsB,
      isGroupPhase: widget.match.isGroupPhase,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 📊 ΜΠΑΡΑ ΠΙΘΑΝΟΤΗΤΩΝ
          _buildSectionTitle(greek ? "Πιθανότητα Νίκης" : "Win Probability"),
          WinProbabilityBar(
            prob1: prediction.prob1,
            probX: prediction.probX,
            prob2: prediction.prob2,
          ),
          const SizedBox(height: 8),

          Center(
            child: Text(
              greek
                  ? "Πιο πιθανό σκορ: ${prediction.exactScore} (${prediction.exactProb.toStringAsFixed(1)}%)"
                  : "Most likely score: ${prediction.exactScore} (${prediction.exactProb.toStringAsFixed(1)}%)",
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

          // 🟨 ΣΤΑΤΙΣΤΙΚΑ ΤΡΕΧΟΝΤΟΣ ΑΓΩΝΑ (Μόνο αν έχει ξεκινήσει)
          if (widget.match.hasMatchStarted) ...[
            _buildSectionTitle(greek ? "Στατιστικά Αγώνα" : "Match Stats"),
            StatRowBuilder(
              title: greek ? "Κίτρινες" : "Yellow Cards",
              homeValue: currentHomeYellow.toDouble(),
              awayValue: currentAwayYellow.toDouble(),
              isLowerBetter: true,
              formatAsInt: true,
            ),
            StatRowBuilder(
              title: greek ? "Κόκκινες" : "Red Cards",
              homeValue: currentHomeRed.toDouble(),
              awayValue: currentAwayRed.toDouble(),
              isLowerBetter: true,
              formatAsInt: true,
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
          ],

          // ⚽ ΕΠΙΘΕΣΗ & ΑΜΥΝΑ
          _buildSectionTitle(greek ? "Συνολικά Τέρματα Φέτος" : "Total Goals This Season"),
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

          // 📈 ΕΙΔΙΚΑ ΣΤΑΤΙΣΤΙΚΑ (Μέσοι Όροι)
          _buildSectionTitle(greek ? "Αποδόσεις Φέτος" : "Performances This Season"),
          StatRowBuilder(
            title: greek ? "Γκολ / Αγώνα (Επίθεση)" : "Goals Scored / Match",
            homeValue: homeGoalsPerMatch,
            awayValue: awayGoalsPerMatch,
            isLowerBetter: false,
            formatAsInt: false,
          ),
          StatRowBuilder(
            title: greek ? "Γκολ Κατά / Αγώνα (Άμυνα)" : "Goals Conceded / Match",
            homeValue: homeGoalsAgainstPerMatch,
            awayValue: awayGoalsAgainstPerMatch,
            isLowerBetter: true, // Εδώ το χαμηλότερο είναι καλύτερο
            formatAsInt: false,
          ),

          const SizedBox(height: 20),
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
}

// =========================================================
// ΑΛΓΟΡΙΘΜΟΣ & ΥΠΟΛΟΓΙΣΤΗΣ
// =========================================================

class WinProbabilityCalculator {
  static double? cachedLeagueAvgGoals;

  static int _factorial(int n) {
    if (n == 0 || n == 1) return 1;
    int result = 1;
    for (int i = 2; i <= n; i++) result *= i;
    return result;
  }

  static double _poisson(int k, double lambda) {
    return (pow(lambda, k) * exp(-lambda)) / _factorial(k);
  }

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
    return 0.85 + (formRatio * 0.40);
  }

  // 1. ΔΙΑΒΑΖΕΙ ΤΟΝ ΜΕΣΟ ΟΡΟ ΠΡΩΤΑΘΛΗΜΑΤΟΣ (Βάσει Season Year)
  static Future<void> loadLeagueAverages(int seasonYear) async {
    if (cachedLeagueAvgGoals != null) return;

    try {
      var doc = await FirebaseFirestore.instance
          .collection('year')
          .doc(seasonYear.toString())
          .collection('stats')
          .doc('league')
          .get();

      if (doc.exists) {
        int totalMatches = doc.data()?['totalMatches'] ?? 0;
        int totalGoals = doc.data()?['totalGoals'] ?? 0;
        cachedLeagueAvgGoals = totalMatches > 0 ? (totalGoals / (totalMatches * 2)) : 1.5;
      } else {
        cachedLeagueAvgGoals = 1.5;
      }
    } catch (e) {
      cachedLeagueAvgGoals = 1.5;
    }
  }

  // 2. ΔΙΑΒΑΖΕΙ ΤΗΝ ΠΕΡΣΙΝΗ ΠΟΡΕΙΑ ΤΗΣ ΟΜΑΔΑΣ
  static Future<Map<String, dynamic>> getLastYearStats(String teamName, int seasonYear) async {
    try {
      int lastYear = seasonYear - 1;

      var doc = await FirebaseFirestore.instance
          .collection('year')
          .doc(lastYear.toString())
          .collection('teams')
          .doc(teamName)
          .get();

      if (doc.exists) {
        return {
          'matches': doc.data()?['Matches'] ?? doc.data()?['matches'] ?? 0,
          'goalsFor': doc.data()?['goalsFor'] ?? 0,
          'goalsAgainst': doc.data()?['goalsAgainst'] ?? 0,
        };
      }
    } catch (e) {
      print("Σφάλμα λήψης περσινών στατιστικών: $e");
    }
    return {'matches': 0, 'goalsFor': 0, 'goalsAgainst': 0};
  }

  // 3. Ο ΥΒΡΙΔΙΚΟΣ ΑΛΓΟΡΙΘΜΟΣ ΠΟΥ ΠΑΝΤΡΕΥΕΙ ΦΕΤΟΣ ΜΕ ΠΕΡΥΣΙ
  static MatchPrediction calculateProbabilities({
    required Team teamA,
    required Team teamB,
    required Map<String, dynamic> pastStatsA,
    required Map<String, dynamic> pastStatsB,
    required bool isGroupPhase,
    double? overrideFormA, // ΝΕΟ
    double? overrideFormB, // ΝΕΟ
  }) {
    double leagueAvgGoals = (cachedLeagueAvgGoals != null && cachedLeagueAvgGoals! > 0)
        ? cachedLeagueAvgGoals!
        : 1.5;
    double pastWeight = 0.25;

    // ΓΗΠΕΔΟΥΧΟΣ
    double virtualMatchesA = (pastStatsA['matches'] > 0) ? (pastStatsA['matches'] * pastWeight) : 1.0;
    double virtualGoalsForA = (pastStatsA['matches'] > 0) ? (pastStatsA['goalsFor'] * pastWeight) : (1.0 * leagueAvgGoals);
    double virtualGoalsAgainstA = (pastStatsA['matches'] > 0) ? (pastStatsA['goalsAgainst'] * pastWeight) : (1.0 * leagueAvgGoals);

    // ΦΙΛΟΞΕΝΟΥΜΕΝΟΣ
    double virtualMatchesB = (pastStatsB['matches'] > 0) ? (pastStatsB['matches'] * pastWeight) : 1.0;
    double virtualGoalsForB = (pastStatsB['matches'] > 0) ? (pastStatsB['goalsFor'] * pastWeight) : (1.0 * leagueAvgGoals);
    double virtualGoalsAgainstB = (pastStatsB['matches'] > 0) ? (pastStatsB['goalsAgainst'] * pastWeight) : (1.0 * leagueAvgGoals);

    // ΜΕΙΞΗ
    double matchesA = teamA.matches + virtualMatchesA;
    if (matchesA <= 0) matchesA = 1.0;
    double goalsForA = teamA.goalsFor + virtualGoalsForA;
    double goalsAgainstA = teamA.goalsAgainst + virtualGoalsAgainstA;

    double matchesB = teamB.matches + virtualMatchesB;
    if (matchesB <= 0) matchesB = 1.0;
    double goalsForB = teamB.goalsFor + virtualGoalsForB;
    double goalsAgainstB = teamB.goalsAgainst + virtualGoalsAgainstB;

    // --- ΠΡΟΣΤΑΣΙΑ (Small Sample Size) ---
    double capAvg(double value, double matches) {
      double avg = value / matches;
      return (avg > 4.0) ? 4.0 : avg; // Ταβάνι τα 4 γκολ/ματς, ώστε να μην βγάζει NaN, αλλά να επιτρέπει υψηλά σκορ
    }

    double attackA = capAvg(teamA.goalsFor + virtualGoalsForA, matchesA) / leagueAvgGoals;
    double defenseA = capAvg(teamA.goalsAgainst + virtualGoalsAgainstA, matchesA) / leagueAvgGoals;
    double attackB = capAvg(teamB.goalsFor + virtualGoalsForB, matchesB) / leagueAvgGoals;
    double defenseB = capAvg(teamB.goalsAgainst + virtualGoalsAgainstB, matchesB) / leagueAvgGoals;

    // Ταβάνι πολλαπλασιαστών (επιτρέπουμε το 2.5 αντί για το 2.0 για να αναδεικνύονται οι υπερ-ομάδες)
    attackA = min(attackA, 2.5);
    defenseA = min(defenseA, 2.5);
    attackB = min(attackB, 2.5);
    defenseB = min(defenseB, 2.5);

    // ΑΛΛΑΓΗ ΕΔΩ: Χρήση του override form (από τη βάση) ή του υπολογισμένου
    double formA = overrideFormA ?? _calculateFormMultiplier(teamA);
    double formB = overrideFormB ?? _calculateFormMultiplier(teamB);

    // --- Ο ΠΟΛΛΑΠΛΑΣΙΑΣΤΙΚΟΣ ΤΥΠΟΣ ---
    // Εδώ η άμυνα-παιδική χαρά (2.5) και η επίθεση-φωτιά (2.5) πολλαπλασιάζονται (2.5 * 2.5)
    double xGA = (attackA * defenseB) * leagueAvgGoals * formA;
    double xGB = (attackB * defenseA) * leagueAvgGoals * formB;

    if (!isGroupPhase) {
      double avgXG = (xGA + xGB) / 2;
      xGA = (xGA * 0.75) + (avgXG * 0.25);
      xGB = (xGB * 0.75) + (avgXG * 0.25);
    }

    // Ασφάλεια: Αποτρέπουμε εξωγήινα νούμερα, αλλά επιτρέπουμε σκορ μέχρι 6-6
    xGA = xGA.clamp(0.1, 5.0);
    xGB = xGB.clamp(0.1, 5.0);

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
    if (totalProb == 0) return MatchPrediction.empty();

    return MatchPrediction(
      prob1: (prob1 / totalProb) * 100,
      probX: (probX / totalProb) * 100,
      prob2: (prob2 / totalProb) * 100,
      exactScore: mostLikelyScore,
      exactProb: (maxScoreProb / totalProb) * 100,
    );
  }

  // ----------------------------------------------------------------------
  // ΒΟΗΘΗΤΙΚΟ SCRIPT ΓΙΑ BACKFILL ΠΑΛΑΙΟΤΕΡΩΝ ΕΤΩΝ (Προαιρετική χρήση)
  // ----------------------------------------------------------------------
  static Future<void> generateLeagueStatsForPastYear(int year) async {
    print("⏳ Ξεκινάει ο υπολογισμός για το $year...");
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('year')
          .doc(year.toString())
          .collection('matches')
          .where('hasMatchFinished', isEqualTo: true)
          .get();

      int totalMatches = 0;
      int totalGoals = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        int homeGoals = data['GoalHome'] ?? 0;
        int awayGoals = data['GoalAway'] ?? 0;
        totalMatches++;
        totalGoals += (homeGoals + awayGoals);
      }

      if (totalMatches > 0) {
        await FirebaseFirestore.instance
            .collection('year')
            .doc(year.toString())
            .collection('stats')
            .doc('league')
            .set({
          'totalMatches': totalMatches,
          'totalGoals': totalGoals,
        }, SetOptions(merge: true));
        print("✅ Επιτυχία για το $year! Βρέθηκαν $totalMatches ματς με $totalGoals συνολικά γκολ.");
      }
    } catch (e) {
      print("❌ Σφάλμα κατά τον υπολογισμό του $year: $e");
    }
  }

  // --- ΝΕΟ: Διαβάζει δυναμικά τα 5 τελευταία ματς απευθείας από τη βάση ---
  static Future<double> _calculateDynamicFormMultiplier(String teamName, int seasonYear) async {
    try {
      // Κατεβάζουμε τα ματς όπου η ομάδα είναι Γηπεδούχος
      final homeMatchesSnapshot = await FirebaseFirestore.instance
          .collection('year')
          .doc(seasonYear.toString())
          .collection('matches')
          .where('hasMatchFinished', isEqualTo: true)
          .where('Hometeam', isEqualTo: teamName)
          .get();

      // Κατεβάζουμε τα ματς όπου η ομάδα είναι Φιλοξενούμενη
      final awayMatchesSnapshot = await FirebaseFirestore.instance
          .collection('year')
          .doc(seasonYear.toString())
          .collection('matches')
          .where('hasMatchFinished', isEqualTo: true)
          .where('Awayteam', isEqualTo: teamName)
          .get();

      // Ενώνουμε τις 2 λίστες και ταξινομούμε βάσει χρόνου (πιο πρόσφατα πρώτα)
      List<QueryDocumentSnapshot> allMatches = [
        ...homeMatchesSnapshot.docs,
        ...awayMatchesSnapshot.docs
      ];

      if (allMatches.isEmpty) return 1.0;

      // Ταξινόμηση Φθίνουσα
      allMatches.sort((a, b) {
        int timeA = (a.data() as Map<String, dynamic>)['TimeStarted'] ?? 0;
        int timeB = (b.data() as Map<String, dynamic>)['TimeStarted'] ?? 0;
        return timeB.compareTo(timeA);
      });

      int gamesToCheck = min(5, allMatches.length);
      int formPoints = 0;
      int validGames = 0;

      for (int i = 0; i < gamesToCheck; i++) {
        var matchData = allMatches[i].data() as Map<String, dynamic>;

        int homeGoals = matchData['GoalHome'] ?? 0;
        int awayGoals = matchData['GoalAway'] ?? 0;
        bool isHome = (matchData['Hometeam'] == teamName);

        if (isHome) {
          if (homeGoals > awayGoals) formPoints += 3;
          else if (homeGoals == awayGoals) formPoints += 1;
        } else {
          if (awayGoals > homeGoals) formPoints += 3;
          else if (awayGoals == homeGoals) formPoints += 1;
        }
        validGames++;
      }

      if (validGames == 0) return 1.0;
      double formRatio = formPoints / (validGames * 3.0);

      return 0.85 + (formRatio * 0.40);
    } catch (e) {
      print("Σφάλμα στον υπολογισμό δυναμικής φόρμας: $e");
      return 1.0;
    }
  }

  // ----------------------------------------------------------------------
  // BACKFILL SCRIPT ΓΙΑ ΠΑΛΑΙΑ ΜΑΤΣ
  // ----------------------------------------------------------------------
  static Future<void> backfillLockedPredictionsForYear(int year) async {
    print("⏳ Ξεκινάει το Backfill για τα ματς του $year...");
    try {
      final matchesQuery = await FirebaseFirestore.instance
          .collection('year')
          .doc(year.toString())
          .collection('matches')
          .where('hasMatchFinished', isEqualTo: true)
          .get();

      int updatedCount = 0;

      await loadLeagueAverages(year);

      for (var matchDoc in matchesQuery.docs) {
        final data = matchDoc.data();

        if (data.containsKey('lockedProb1')) continue;

        String homeName = data['Hometeam'] ?? "";
        String awayName = data['Awayteam'] ?? "";

        if (homeName.isEmpty || awayName.isEmpty) continue;

        var homeTeamData = await FirebaseFirestore.instance.collection('year').doc(year.toString()).collection('teams').doc(homeName).get();
        var awayTeamData = await FirebaseFirestore.instance.collection('year').doc(year.toString()).collection('teams').doc(awayName).get();

        var pastStatsA = await getLastYearStats(homeName, year);
        var pastStatsB = await getLastYearStats(awayName, year);

        Team dummyHome = Team(
            homeName, homeName, homeName, homeName,
            homeTeamData.data()?['Matches'] ?? 1, 0, 0, 0, 1, 0, 0, "", 0, "",
            homeTeamData.data()?['goalsFor'] ?? 0,
            homeTeamData.data()?['goalsAgainst'] ?? 0
        );

        Team dummyAway = Team(
            awayName, awayName, awayName, awayName,
            awayTeamData.data()?['Matches'] ?? 1, 0, 0, 0, 1, 0, 0, "", 0, "",
            awayTeamData.data()?['goalsFor'] ?? 0,
            awayTeamData.data()?['goalsAgainst'] ?? 0
        );

        // Υπολογισμός Δυναμικής Φόρμας
        double formA = await _calculateDynamicFormMultiplier(homeName, year);
        double formB = await _calculateDynamicFormMultiplier(awayName, year);

        MatchPrediction prediction = calculateProbabilities(
          teamA: dummyHome,
          teamB: dummyAway,
          pastStatsA: pastStatsA,
          pastStatsB: pastStatsB,
          isGroupPhase: data['IsGroupPhase'] ?? true,
          overrideFormA: formA, // Πέρασμα του υπολογισμένου formA
          overrideFormB: formB, // Πέρασμα του υπολογισμένου formB
        );

        await matchDoc.reference.update({
          'lockedProb1': prediction.prob1,
          'lockedProbX': prediction.probX,
          'lockedProb2': prediction.prob2,
          'lockedScore': prediction.exactScore,
          'lockedScoreProb': prediction.exactProb,
          'lockedHomeMatches': dummyHome.matches,
          'lockedHomeGoalsFor': dummyHome.goalsFor,
          'lockedHomeGoalsAgainst': dummyHome.goalsAgainst,
          'lockedAwayMatches': dummyAway.matches,
          'lockedAwayGoalsFor': dummyAway.goalsFor,
          'lockedAwayGoalsAgainst': dummyAway.goalsAgainst,
        });

        updatedCount++;
        print("✅ Ενημερώθηκε το ματς: $homeName vs $awayName");
      }

      print("🎉 Το Backfill ολοκληρώθηκε! Ενημερώθηκαν $updatedCount αγώνες για το $year.");
    } catch (e) {
      print("❌ Σφάλμα κατά το backfill του $year: $e");
    }
  }

  // ----------------------------------------------------------------------
  // SCRIPT ΓΙΑ ΑΞΙΟΛΟΓΗΣΗ ΤΟΥ ΜΟΝΤΕΛΟΥ (BACKTESTING)
  // ----------------------------------------------------------------------
// ----------------------------------------------------------------------
// SCRIPT ΓΙΑ ΑΞΙΟΛΟΓΗΣΗ ΤΟΥ ΜΟΝΤΕΛΟΥ (BACKTESTING)
// ----------------------------------------------------------------------
  static Future<void> evaluateModel(int year) async {
    print("⏳ Ξεκινάει η αξιολόγηση του μοντέλου για το $year...");
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('year')
          .doc(year.toString())
          .collection('matches')
          .where('hasMatchFinished', isEqualTo: true)
          .get();

      int totalMatches = 0;
      int correct1X2 = 0;
      int correctExactScore = 0;
      double totalBrierScore = 0.0;

      // --- ΝΕΕΣ ΜΕΤΑΒΛΗΤΕΣ ---
      double totalGoalError = 0.0;
      int correctOverUnder = 0;
      int validScoreMatches = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        int homeGoals = data['GoalHome'] ?? 0;
        int awayGoals = data['GoalAway'] ?? 0;
        String actualResult = "X";
        if (homeGoals > awayGoals) actualResult = "1";
        if (homeGoals < awayGoals) actualResult = "2";
        String actualScore = "$homeGoals-$awayGoals";

        if (!data.containsKey('lockedProb1')) continue;

        double prob1 = (data['lockedProb1'] ?? 0.0) / 100.0;
        double probX = (data['lockedProbX'] ?? 0.0) / 100.0;
        double prob2 = (data['lockedProb2'] ?? 0.0) / 100.0;
        String predictedScore = data['lockedScore'] ?? "N/A";

        totalMatches++;

        String predictedResult = "X";
        if (prob1 > probX && prob1 > prob2) predictedResult = "1";
        if (prob2 > prob1 && prob2 > probX) predictedResult = "2";

        if (predictedResult == actualResult) correct1X2++;
        if (predictedScore == actualScore) correctExactScore++;

        double o1 = (actualResult == "1") ? 1.0 : 0.0;
        double oX = (actualResult == "X") ? 1.0 : 0.0;
        double o2 = (actualResult == "2") ? 1.0 : 0.0;

        num brier = pow(prob1 - o1, 2) + pow(probX - oX, 2) + pow(prob2 - o2, 2);
        totalBrierScore += brier;

        // --- ΝΕΟΣ ΥΠΟΛΟΓΙΣΜΟΣ: Απόκλιση Γκολ & Over/Under ---
        if (predictedScore != "N/A" && predictedScore.contains("-")) {
          List<String> pGoals = predictedScore.split("-");
          if (pGoals.length == 2) {
            int pHome = int.tryParse(pGoals[0]) ?? 0;
            int pAway = int.tryParse(pGoals[1]) ?? 0;

            // Μέσο απόλυτο σφάλμα (MAE): |Προβλεπόμενα Home - Πραγματικά Home| + |Προβλεπόμενα Away - Πραγματικά Away|
            totalGoalError += (pHome - homeGoals).abs() + (pAway - awayGoals).abs();

            // Έλεγχος Over/Under 2.5
            bool actualOver25 = (homeGoals + awayGoals) > 2;
            bool predictedOver25 = (pHome + pAway) > 2;
            if (actualOver25 == predictedOver25) {
              correctOverUnder++;
            }

            validScoreMatches++;
          }
        }
      }

      if (totalMatches > 0) {
        double accuracy1X2 = (correct1X2 / totalMatches) * 100;
        double accuracyExactScore = (correctExactScore / totalMatches) * 100;
        double avgBrierScore = totalBrierScore / totalMatches;

        // Υπολογισμός νέων δεικτών
        double avgGoalError = validScoreMatches > 0 ? (totalGoalError / validScoreMatches) : 0.0;
        double accuracyOverUnder = validScoreMatches > 0 ? (correctOverUnder / validScoreMatches) * 100 : 0.0;

        print("\n✅ Αξιολόγηση Μοντέλου για $year ($totalMatches αγώνες):");
        print("--------------------------------------------------");
        print("🎯 Ποσοστό επιτυχίας Σημείου (1Χ2): ${accuracy1X2.toStringAsFixed(1)}%");
        print("⚖️ Brier Score (Ακρίβεια σιγουριάς): ${avgBrierScore.toStringAsFixed(3)} (Κάτω από 0.6 είναι καλό)");
        print("--------------------------------------------------");
        print("⚽ Ποσοστό επιτυχίας Ακριβούς Σκορ: ${accuracyExactScore.toStringAsFixed(1)}%");
        print("📈 Ποσοστό επιτυχίας Over/Under 2.5: ${accuracyOverUnder.toStringAsFixed(1)}%");
        print("📏 Μέση Απόκλιση Γκολ (MAE): ${avgGoalError.toStringAsFixed(2)} γκολ ανά αγώνα");
        print("--------------------------------------------------\n");
      } else {
        print("Δεν βρέθηκαν αγώνες με αποθηκευμένες προβλέψεις για το $year.");
      }
    } catch (e) {
      print("❌ Σφάλμα κατά την αξιολόγηση: $e");
    }
  }}

// =========================================================
// WIDGETS
// =========================================================

class WinProbabilityBar extends StatelessWidget {
  final double prob1;
  final double probX;
  final double prob2;

  const WinProbabilityBar({super.key, required this.prob1, required this.probX, required this.prob2});

  @override
  Widget build(BuildContext context) {
    //Έλεγχος Ασφαλείας για NaN (Not a Number) ή Infinity
    final bool isInvalid = prob1.isNaN || probX.isNaN || prob2.isNaN ||
        prob1.isInfinite || probX.isInfinite || prob2.isInfinite ||
        (prob1 == 0 && probX == 0 && prob2 == 0);

    // Αν κάτι πάει στραβά στα μαθηματικά, δείξε το 33-33-33 για να μην κρασάρει το app
    final double safeProb1 = isInvalid ? 33.3 : prob1;
    final double safeProbX = isInvalid ? 33.4 : probX;
    final double safeProb2 = isInvalid ? 33.3 : prob2;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("1 (${safeProb1.toStringAsFixed(1)}%)", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              Text("X (${safeProbX.toStringAsFixed(1)}%)", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              Text("2 (${safeProb2.toStringAsFixed(1)}%)", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            ],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Row(
            children: [
              // Χρησιμοποιούμε τις ασφαλείς μεταβλητές
              Expanded(flex: (safeProb1 * 10).round(), child: Container(height: 12, color: Colors.blue)),
              Expanded(flex: (safeProbX * 10).round(), child: Container(height: 12, color: Colors.grey[400])),
              Expanded(flex: (safeProb2 * 10).round(), child: Container(height: 12, color: Colors.red)),
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