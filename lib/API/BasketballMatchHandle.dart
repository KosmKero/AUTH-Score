import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';
import 'package:untitled1/globals.dart';

import '../Data_Classes/basketball/basketMatch.dart';
import '../Data_Classes/basketball/basketTeam.dart';

class BasketballMatchHandle {
  static final BasketballMatchHandle _instance =
  BasketballMatchHandle._internal();
  static List<List<BasketMatch>> matchesList =
  []; // [0] = Upcoming, [1] = Previous

  // Ιδιωτικός constructor
  BasketballMatchHandle._internal();

  // Μέθοδος για επιστροφή του ίδιου instance (Singleton)
  factory BasketballMatchHandle() {
    return _instance;
  }

  Future<void> loadAllBasketballData(int year, List<basketTeam> teams) async {
    // 1. Τραβάμε τα matches
    List<BasketMatch> allMatches = await getMatchesByYear(year, teams);

    // 2. Τα χωρίζουμε
    List<BasketMatch> upcoming =
    allMatches.where((m) => !m.hasMatchFinished).toList();
    List<BasketMatch> previous =
    allMatches.where((m) => m.hasMatchFinished).toList();

    // 3. Αρχικοποιούμε το Singleton
    initializeMatches([upcoming, previous]);
  }

  void initializeMatches(List<List<BasketMatch>> matchList) {
    matchesList = matchList;
  }

  Future<void> matchFinished(BasketMatch match) async {
    matchesList[0].remove(match);
    matchesList[1].add(match);

    await FirebaseFirestore.instance
        .collection("basket")
        .doc(thisYearNow.toString())
        .collection('matches')
        .doc(match.matchKey) // ΔΙΟΡΘΩΣΗ: Αλλαγή από matchDocId σε matchKey (είναι το ίδιο)
        .set({'Type': 'previous'}, SetOptions(merge: true));
  }

  Future<void> matchNotFinished(BasketMatch match) async {
    if (matchesList[1].contains(match)) {
      matchesList[1].remove(match);
      matchesList[0].add(match);

      await FirebaseFirestore.instance
          .collection("basket")
          .doc(thisYearNow.toString())
          .collection('matches')
          .doc(match.matchKey) // ΔΙΟΡΘΩΣΗ: Αλλαγή από matchDocId σε matchKey
          .set({'Type': "upcoming"}, SetOptions(merge: true));
    }
  }

  // Μέθοδοι για πρόσβαση στα δεδομένα
  List<BasketMatch> getUpcomingMatches() =>
      matchesList.isNotEmpty ? matchesList[0] : [];
  List<BasketMatch> getPreviousMatches() =>
      matchesList.length > 1 ? matchesList[1] : [];

  List<BasketMatch> getAllMatches() {
    if (matchesList.isEmpty) return [];

    List<BasketMatch> allMatches = matchesList.expand((i) => i).toList();

    allMatches.sort((b, a) {
      int yearCompare = a.year.compareTo(b.year);
      if (yearCompare != 0) return yearCompare;

      int monthCompare = a.month.compareTo(b.month);
      if (monthCompare != 0) return monthCompare;

      int dayCompare = a.day.compareTo(b.day);
      if (dayCompare != 0) return dayCompare;

      return a.time.compareTo(b.time);
    });

    return allMatches;
  }

  // Αυτή η συνάρτηση "τραβάει" όλα τα ματς από το Firebase και τα κάνει Object (BasketMatch)
  Future<List<BasketMatch>> getMatchesByYear(
      int year, List<basketTeam> teamsList) async {
    List<BasketMatch> matches = [];

    try {
      var matchDocs = await FirebaseFirestore.instance
          .collection('basket')
          .doc(year.toString())
          .collection("matches")
          .get();

      if (matchDocs.docs.isEmpty) {
        print("⚠️ No basket matches found.");
        return matches;
      }

      List<Future<BasketMatch?>> matchFutures =
      matchDocs.docs.map((matchDoc) async {
        var data = matchDoc.data();

        // Διαβάζουμε τα ονόματα των ομάδων
        String homeTeamName = data["Hometeam"] ?? "";
        String awayTeamName = data["Awayteam"] ?? "";

        basketTeam? homeTeam;
        try {
          homeTeam = teamsList.firstWhere(
                (t) => t.name == homeTeamName || t.nameEnglish == homeTeamName,
          );
        } catch (e) {
          // Αν δεν τη βρει, το homeTeam μένει null, δεν κρασάρει το app
        }

        // Βρίσκουμε την Away Team με ασφάλεια
        basketTeam? awayTeam;
        try {
          awayTeam = teamsList.firstWhere(
                (t) => t.name == awayTeamName || t.nameEnglish == awayTeamName,
          );
        } catch (e) {
          // Αν δεν τη βρει, το awayTeam μένει null
        }

        // Αν κάποια ομάδα λείπει, αγνοούμε ΜΟΝΟ ΑΥΤΟ το ματς και προχωράμε στα επόμενα
        if (homeTeam == null || awayTeam == null) {
          print(
              "⚠️ Skipping basket match due to missing team data: $homeTeamName vs $awayTeamName");
          return null;
        }

        // --- Διάβασμα των Δεκαλέπτων από το Firebase ---
        Map<int, Map<String, int>> periodScores = {};
        if (data.containsKey('PeriodScores')) {
          Map<String, dynamic> fetchedPeriods = data['PeriodScores'];
          fetchedPeriods.forEach((key, value) {
            int periodKey = int.parse(key);
            periodScores[periodKey] = {
              'home': value['home'] ?? 0,
              'away': value['away'] ?? 0,
            };
          });
        }

        // Δημιουργία του BasketMatch Object
        BasketMatch match = BasketMatch(
          matchDoc.id, // Περάσαμε το ID του εγγράφου στον constructor (βλ. προηγούμενη συζήτηση)
          homeTeam,
          awayTeam,
          data["HomeScore"] ?? 0,
          data["AwayScore"] ?? 0,
          periodScores,
          data["IsGroupPhase"] ?? false,
          data["Game"] ?? 0,
          data["Time"] ?? 0,
          data["Day"] ?? 0,
          data["Month"] ?? 0,
          data["Year"] ?? 0,
          data['HasMatchStarted'] ?? false,
          data["HasMatchFinished"] ?? false,
          data["CurrentPeriod"] ?? 0,
        );

        // Αν το Firestore έχει αποθηκευμένο αν έχει τελειώσει η περίοδος, μπορούμε να το περάσουμε
        // match.setPeriodEnded(data["IsPeriodEnded"] ?? false);

        return match;
      }).toList();

      var completedMatches = await Future.wait(matchFutures);
      matches = completedMatches.whereType<BasketMatch>().toList();

      matches.sort((b, a) {
        int yearCompare = a.year.compareTo(b.year);
        if (yearCompare != 0) return yearCompare;

        int monthCompare = a.month.compareTo(b.month);
        if (monthCompare != 0) return monthCompare;

        int dayCompare = a.day.compareTo(b.day);
        if (dayCompare != 0) return dayCompare;

        return a.time.compareTo(b.time);
      });

      print("✅ Loaded ${matches.length} basket matches.");
    } catch (e) {
      print("❌ Error fetching basket matches: $e");
    }

    return matches;
  }

  // ---------------------------------------------------------------------------
  // --- ΣΥΝΑΡΤΗΣΕΙΣ ΓΙΑ ΑΛΛΑΓΗ ΣΕΖΟΝ (MIGRATION) ΣΤΟ ΜΠΑΣΚΕΤ ---
  // ---------------------------------------------------------------------------

  // Αντιγράφει τις ομάδες μπάσκετ στη νέα χρονιά
  static Future<void> migrateBasketTeams(String oldYear, String newYear) async {
    final firestore = FirebaseFirestore.instance;

    final snapshot = await firestore
        .collection('basket')
        .doc(oldYear)
        .collection('teams')
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();

      // Μπορείς να μηδενίσεις νίκες/ήττες/βαθμούς κατά τη μεταφορά αν θέλεις
      data['Wins'] = 0;
      data['Losses'] = 0;
      data['Matches'] = 0;
      data['pointsFor'] = 0;
      data['pointsAgainst'] = 0;

      await firestore
          .collection('basket')
          .doc(newYear)
          .collection('teams')
          .doc(doc.id)
          .set(data);
    }
    print("✅ Basket Teams Migrated to $newYear");
  }

  // Μηδενίζει τα στατιστικά των ΠΑΙΚΤΩΝ ΜΠΑΣΚΕΤ (πόντους κλπ) για τη νέα χρονιά
  static Future<void> resetBasketPlayerData(String seasonYear) async {
    final firestore = FirebaseFirestore.instance;
    final teamsRef = firestore
        .collection('basket')
        .doc(seasonYear)
        .collection("teams");

    final snapshot = await teamsRef.get();

    WriteBatch batch = firestore.batch();
    int opCount = 0;
    const int batchLimit = 450; // Το Firestore επιτρέπει 500 writes ανά batch

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final players = data["Players"] as Map<String, dynamic>?;

      if (players != null) {
        Map<String, dynamic> updates = {};

        // Στο μπάσκετ μηδενίζουμε τα 'Points' (και ό,τι άλλο έχεις π.χ. Assists, Rebounds αν προσθέσεις)
        players.forEach((playerKey, _) {
          updates["Players.$playerKey.Points"] = 0;
        });

        batch.update(doc.reference, updates);
        opCount++;

        if (opCount >= batchLimit) {
          await batch.commit();
          batch = firestore.batch();
          opCount = 0;
        }
      }
    }

    if (opCount > 0) {
      await batch.commit();
    }
    print("✅ Basket Player Stats Reset for $seasonYear");
  }
}