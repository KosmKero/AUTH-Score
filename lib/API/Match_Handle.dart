import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';
import 'package:untitled1/globals.dart';

import '../Data_Classes/MatchDetails.dart';
import '../Data_Classes/Penaltys.dart';
import '../Data_Classes/Player.dart';
import '../Data_Classes/Team.dart';

class MatchHandle {
  static final MatchHandle _instance = MatchHandle._internal();
  static List<List<MatchDetails>> matchesList = [[], []];

  MatchHandle._internal();

  factory MatchHandle() {
    return _instance;
  }

  void initializeMatches(List<List<MatchDetails>> matchList) {
    matchesList = matchList;
  }

  Future<void> matchFinished(MatchDetails match) async {
    if (matchesList.isNotEmpty && matchesList[0].contains(match)) {
      matchesList[0].remove(match);
      matchesList[1].add(match);
    }

    await FirebaseFirestore.instance
        .collection("year")
        .doc(thisYearNow.toString())
        .collection('matches')
        .doc(match.matchDocId)
        .set({'Type': 'previous'}, SetOptions(merge: true));

    // Υπολογισμός συμμετοχών
    Set<String> homePlayedKeys = {...match.homeStarters, ...match.homeSubsOut};
    Set<String> awayPlayedKeys = {...match.awayStarters, ...match.awaySubsOut};

    List<Future> updateTasks = [];

    for (String key in homePlayedKeys) {
      try {
        Player p = match.homeTeam.players.firstWhere((player) => player.uniqueKey == key);
        updateTasks.add(p.playerPlayed());
      } catch (e) {
        print("Δεν βρέθηκε ο παίκτης $key για αύξηση συμμετοχής");
      }
    }

    for (String key in awayPlayedKeys) {
      try {
        Player p = match.awayTeam.players.firstWhere((player) => player.uniqueKey == key);
        updateTasks.add(p.playerPlayed());
      } catch (e) {
        print("Δεν βρέθηκε ο παίκτης $key για αύξηση συμμετοχής");
      }
    }

    await Future.wait(updateTasks);
  }

  Future<void> matchNotFinished(MatchDetails match) async {
    if (matchesList.length > 1 && matchesList[1].contains(match)) {
      matchesList[1].remove(match);
      matchesList[0].add(match);

      await FirebaseFirestore.instance
          .collection("year")
          .doc(thisYearNow.toString())
          .collection('matches')
          .doc(match.matchDocId)
          .set({'Type': 'upcoming'}, SetOptions(merge: true));
    }

    Set<String> homePlayedKeys = {...match.homeStarters, ...match.homeSubsOut};
    Set<String> awayPlayedKeys = {...match.awayStarters, ...match.awaySubsOut};

    List<Future> updateTasks = [];

    for (String key in homePlayedKeys) {
      try {
        Player p = match.homeTeam.players.firstWhere((player) => player.uniqueKey == key);
        updateTasks.add(p.cancelPlayerPlayed());
      } catch (e) {
        print("Δεν βρέθηκε ο παίκτης $key για αφαίρεση συμμετοχής");
      }
    }

    for (String key in awayPlayedKeys) {
      try {
        Player p = match.awayTeam.players.firstWhere((player) => player.uniqueKey == key);
        updateTasks.add(p.cancelPlayerPlayed());
      } catch (e) {
        print("Δεν βρέθηκε ο παίκτης $key για αφαίρεση συμμετοχής");
      }
    }

    await Future.wait(updateTasks);
  }

  List<MatchDetails> getUpcomingMatches() => matchesList.isNotEmpty ? matchesList[0] : [];
  List<MatchDetails> getPreviousMatches() => matchesList.length > 1 ? matchesList[1] : [];

  List<MatchDetails> getAllMatches() {
    List<MatchDetails> allMatches = matchesList.expand((i) => i).toList();

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

  Future<List<MatchDetails>> getMatchesByYear(int year, List<Team> teamsList) async {
    List<MatchDetails> matches = [];

    try {
      var matchDocs = await FirebaseFirestore.instance
          .collection('year')
          .doc(year.toString())
          .collection("matches")
          .get();

      if (matchDocs.docs.isEmpty) {
        print("⚠️ No matches found.");
        return matches;
      }

      List<Future<MatchDetails?>> matchFutures = matchDocs.docs.map((matchDoc) async {
        var data = matchDoc.data();
        String homeTeamName = data["Hometeam"] ?? "";
        String awayTeamName = data["Awayteam"] ?? "";
        Team? homeTeam = TeamsHandle().getTeamFromList(homeTeamName, teamsList);
        Team? awayTeam = TeamsHandle().getTeamFromList(awayTeamName, teamsList);

        if (homeTeam == null || awayTeam == null) {
          print("⚠️ Skipping match due to missing team data: $homeTeamName vs $awayTeamName");
          return null;
        }

        MatchDetails match = MatchDetails(
          matchId: matchDoc.id,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          hasMatchStarted: data['HasMatchStarted'] ?? false,
          time: data["Time"] ?? 0,
          day: data["Day"] ?? 0,
          month: data["Month"] ?? 0,
          year: data["Year"] ?? 0,
          isGroupPhase: data["IsGroupPhase"] ?? false,
          game: data["Game"] ?? 0,
          scoreHome: data["GoalHome"] ?? -1,
          scoreAway: data["GoalAway"] ?? -1,
          hasMatchFinished: data["hasMatchFinished"] ?? false,
          hasSecondHalfStarted: data["hasSecondHalfStarted"] ?? false,
          hasFirstHalfFinished: data["hasFirstHalfFinished"] ?? false,
          timeStarted: data["TimeStarted"] ?? 0,
          hasFirstHalfExtraTimeFinished: data['hasFirstHalfExtraTimeFinished'] ?? false,
          hasExtraTimeFinished: data['hasExtraTimeFinished'] ?? false,
          hasExtraTimeStarted: data['hasExtraTimeStarted'] ?? false,
          hasSecondHalfExtraTimeStarted: data['hasSecondHalfExtraTimeStarted'] ?? false,
          scoreAwayExtraTime: data['GoalAwayExtraTime'] ?? 0,
          scoreHomeExtraTime: data['GoalHomeExtraTime'] ?? 0,
          penalties: (data['penalties'] as List<dynamic>? ?? [])
              .map((p) => PenaltyShoot.fromMap(Map<String, dynamic>.from(p)))
              .toList(),
          slot: data["slot"] ?? 0,
          homeSquad: List<String>.from(data['homeSquad'] ?? []),
          homeStarters: List<String>.from(data['homeStarters'] ?? []),
          awaySquad: List<String>.from(data['awaySquad'] ?? []),
          awayStarters: List<String>.from(data['awayStarters'] ?? []),
          homeSubsIn: List<String>.from(data['homeSubsIn'] ?? []),
          awaySubsIn: List<String>.from(data['awaySubsIn'] ?? []),
          homeSubsOut: List<String>.from(data['homeSubsOut'] ?? []),
          awaySubsOut: List<String>.from(data['awaySubsOut'] ?? []),
          temporaryNumbers: Map<String, int>.from(data['temporaryNumbers'] ?? {}),
          homeCaptain: data['homeCaptain'],
          awayCaptain: data['awayCaptain'],
          homeCoach: data['homeCoach'],
          awayCoach: data['awayCoach'],
          homeAssistant: data['homeAssistant'],
          awayAssistant: data['awayAssistant'],
          homeKitman: data['homeKitman'],
          awayKitman: data['awayKitman'],
        );

        if (data.containsKey('facts')) {
          final factsMap = Map<String, dynamic>.from(data['facts']);
          match.matchFact.addAll(await MatchFactsStorageHelper.decodeMatchFacts(factsMap, homeTeam, awayTeam));
        }

        return match;
      }).toList();

      var completedMatches = await Future.wait(matchFutures);
      matches = completedMatches.whereType<MatchDetails>().toList();

      matches.sort((b, a) {
        int yearCompare = a.year.compareTo(b.year);
        if (yearCompare != 0) return yearCompare;

        int monthCompare = a.month.compareTo(b.month);
        if (monthCompare != 0) return monthCompare;

        int dayCompare = a.day.compareTo(b.day);
        if (dayCompare != 0) return dayCompare;

        return a.time.compareTo(b.time);
      });

      print("✅ Loaded ${matches.length} matches.");
    } catch (e) {
      print("❌ Error fetching matches: $e");
    }

    return matches;
  }

  static Future<void> migrateMatches() async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('matches').get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      await firestore
          .collection('year')
          .doc('2025')
          .collection('matches')
          .doc(doc.id)
          .set(data);
    }
  }

  static Future<void> migrateTeams() async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('teams').get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      await firestore
          .collection('year')
          .doc("2026")
          .collection('teams')
          .doc(doc.id)
          .set(data);
    }
  }

  Future<void> resetPlayerData(String seasonYear) async {
    final firestore = FirebaseFirestore.instance;
    final teamsRef = firestore.collection('year').doc(seasonYear).collection("teams");

    final snapshot = await teamsRef.get();

    WriteBatch batch = firestore.batch();
    int opCount = 0;
    const int batchLimit = 450;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final players = data["Players"] as Map<String, dynamic>?;

      if (players != null) {
        Map<String, dynamic> updates = {};
        players.forEach((playerKey, _) {
          updates["Players.$playerKey.Goals"] = 0;
          updates["Players.$playerKey.numOfRedCards"] = 0;
          updates["Players.$playerKey.numOfYellowCards"] = 0;
          updates["Players.$playerKey.Appearances"] = 0;
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
  }
}