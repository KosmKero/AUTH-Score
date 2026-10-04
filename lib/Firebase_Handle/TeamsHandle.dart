import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Data_Classes/MatchDetails.dart';
import '../Data_Classes/Penaltys.dart';
import '../API/hiveOfflineSave.dart';
import '../Data_Classes/Player.dart';
import '../Data_Classes/Team.dart';
import '../globals.dart';
import '../globals.dart' as global;
import '../main.dart';

class TeamsHandle {

  Future<void> addNewTeam(Team team) async {
    try {
      await FirebaseFirestore.instance
          .collection('year')
          .doc(thisYearNow.toString())
          .collection("teams")
          .doc(team.name)
          .set(team.toMap(), SetOptions(merge: true));

      print("Η ομάδα ${team.name} προστέθηκε επιτυχώς!");
    } catch (e) {
      print("Σφάλμα κατά την προσθήκη της ομάδας: $e");
    }
  }

  Future<void> updateTeamDetails(
      String teamNameId,
      String newDisplayName,
      String newDisplayNameEnglish,
      String newInitials,
      String newCoach,
      int newFoundationYear,
      int newGroup,
      int? newTitles) async {

    Map<String, dynamic> dataToUpdate = {
      'displayEnglish': newDisplayNameEnglish,
      'displayGreek' : newDisplayName,
      'initials': newInitials,
      'Coach': newCoach,
      'Foundation Year': newFoundationYear,
      'Group': newGroup,
    };

    if (newTitles != null) {
      dataToUpdate['Titles'] = newTitles;
    }
    await FirebaseFirestore.instance
        .collection('year').doc(thisYearNow.toString()).collection("teams")
        .doc(teamNameId)
        .update(dataToUpdate);
  }

  Future<List<Team>> getAllTeams() async {
    List<Team> allTeams = [];

    try {
      var teamsDoc = await FirebaseFirestore.instance
          .collection('year')
          .doc(thisYearNow.toString())
          .collection("teams")
          .get();

      if (teamsDoc.docs.isNotEmpty) {
        for (var team in teamsDoc.docs) {
          try {
            Map<String, dynamic> data = team.data();

            String name = data["Name"] ?? "";
            String nameE = data['NameEnglish'] ?? "";

            String displayName = data['displayGreek'] ?? name;
            String displayNameEnglish = data['displayEnglish'] ?? nameE;

            int matches = data["Matches"] ?? 0;
            int wins = data["Wins"] ?? 0;
            int losses = data["Loses"] ?? 0;
            int draws = data["Draws"] ?? 0;
            int group = data["Group"] ?? 0;
            int foundationYear = data["Foundation Year"] ?? 0;
            int titles = data["Titles"] ?? 0;
            String coach = data["Coach"] ?? "";
            int position = data["position"] ?? 0;
            String initials = data["initials"] ?? "";
            int goalsFor = data['goalsFor'] ?? 0;
            int goalsAgainst = data['goalsAgainst'] ?? 0;

            List<Player> players = [];

            if (data["Players"] != null) {
              Map<String, dynamic> playersData = data["Players"] as Map<String, dynamic>;

              playersData.forEach((playerKey, playerData) {
                DateTime? expiryDate;
                if (playerData['healthCardExpiry'] != null) {
                  expiryDate = (playerData['healthCardExpiry'] as Timestamp).toDate();
                }

                players.add(Player(
                    playerData["Name"] ?? "",
                    playerData['Surname'] ?? "",
                    playerData['Position'] ?? 0,
                    playerData['Goals'] ?? 0,
                    playerData['Number'] ?? 0,
                    playerData['TeamName'] ?? "",
                    playerData['numOfYellowCards'] ?? 0,
                    playerData['numOfRedCards'] ?? 0,
                    playerData["teamNameEnglish"] ?? "",
                    expiryDate,
                    playerData['Appearances'] ?? 0,
                    playerData['id']
                ));
              });
            }

            allTeams.add(Team(name, nameE, displayName, displayNameEnglish, matches, wins, losses, draws, group, foundationYear, titles, coach, position, initials, goalsFor, goalsAgainst, players));
          } catch (e) {
            print("Error processing team document: ${team.id}, Error: $e");
          }
        }
      }
    } catch (e) {
      print("Error fetching teams: $e");
    }

    return allTeams;
  }

  Future<List<Team>> getAllTeamsByYear(int year) async {
    List<Team> allTeams = [];

    try {
      var teamsDoc = await FirebaseFirestore.instance
          .collection('year')
          .doc(year.toString())
          .collection("teams")
          .get();

      if (teamsDoc.docs.isNotEmpty) {
        for (var team in teamsDoc.docs) {
          try {
            Map<String, dynamic> data = team.data();

            String name = data["Name"] ?? "";
            String nameE = data['NameEnglish'] ?? "";

            String displayName = data['displayGreek'] ?? name;
            String displayNameEnglish = data['displayEnglish'] ?? nameE;

            int matches = data["Matches"] ?? 0;
            int wins = data["Wins"] ?? 0;
            int losses = data["Loses"] ?? 0;
            int draws = data["Draws"] ?? 0;
            int group = data["Group"] ?? 0;
            int foundationYear = data["Foundation Year"] ?? 0;
            int titles = data["Titles"] ?? 0;
            String coach = data["Coach"] ?? "";
            int position = data["position"] ?? 0;
            String initials = data["initials"] ?? "";
            int goalsAgainst = data['goalsAgainst'] ?? 0;
            int goalsFor = data['goalsFor'] ?? 0;

            List<Player> players = [];

            if (data["Players"] != null) {
              Map<String, dynamic> playersData = data["Players"] as Map<String, dynamic>;

              playersData.forEach((playerKey, playerData) {
                DateTime? expiryDate;
                if (playerData['healthCardExpiry'] != null) {
                  expiryDate = (playerData['healthCardExpiry'] as Timestamp).toDate();
                }

                players.add(Player(
                    playerData["Name"] ?? "",
                    playerData['Surname'] ?? "",
                    playerData['Position'] ?? 0,
                    playerData['Goals'] ?? 0,
                    playerData['Number'] ?? 0,
                    playerData['TeamName'] ?? "",
                    playerData['numOfYellowCards'] ?? 0,
                    playerData['numOfRedCards'] ?? 0,
                    playerData["teamNameEnglish"] ?? "",
                    expiryDate,
                    playerData['Appearances'] ?? 0,
                    playerData['id']
                ));
              });
            }

            allTeams.add(Team(name, nameE, displayName, displayNameEnglish, matches, wins, losses, draws, group, foundationYear, titles, coach, position, initials, goalsFor, goalsAgainst, players));
          } catch (e) {
            print("Error processing team document: ${team.id}, Error: $e");
          }
        }
      }
    } catch (e) {
      print("Error fetching teams: $e");
    }

    return allTeams;
  }

  // ΔΗΜΙΟΥΡΓΙΑ ΑΓΩΝΑ ΜΕ AUTO-ID
  Future<void> addMatch(Team home, Team away, int day, int month, int year, int game, bool hasStarted, bool isGroupPhase, int time, String type, int goalHome, int goalAway) async {
    try {
      final hour = time ~/ 100;
      final minute = time % 100;
      final dateTime = DateTime(year, month, day, hour, minute);
      final timestamp = Timestamp.fromDate(dateTime);

      // 1. Δημιουργούμε DocumentReference χωρίς όρισμα για να πάρουμε μοναδικό Auto-ID
      final matchDocRef = FirebaseFirestore.instance
          .collection("year")
          .doc(global.thisYearNow.toString())
          .collection("matches")
          .doc();

      final String newMatchId = matchDocRef.id;

      await matchDocRef.set({
        'matchDocId': newMatchId, // Αποθηκεύουμε και το ID μέσα στο έγγραφο
        'Awayteam': away.name,
        'Hometeam': home.name,
        "homeTeamEnglish": home.nameEnglish,
        "awayTeamEnglish": away.nameEnglish,
        'Day': day,
        'Month': month,
        'Year': year,
        'Game': game,
        'HasMatchStarted': hasStarted,
        'IsGroupPhase': isGroupPhase,
        'Time': time,
        'Type': type,
        'GoalHome': goalHome,
        'GoalAway': goalAway,
        "hasMatchFinished": false,
        "hasSecondHalfStarted": false,
        "hasFirstHalfFinished": false,
        'startTime': timestamp,
        "notified": false,
        'hasExtraTimeFinished': false,
        'hasSecondHalfExtraTimeStarted': false,
        'hasFirstHalfExtraTimeFinished': false,
        'hasExtraTimeStarted': false,
        'GoalHomeExtraTime': 0,
        'GoalAwayExtraTime': 0,
        'penalties': [],
        'shootoutOver': false,
        "slot": 0,
        'homeSquad': [],
        'homeStarters': [],
        'awaySquad': [],
        'awayStarters': [],
        'homeSubsIn': [],
        'awaySubsIn': [],
        'homeSubsOut': [],
        'awaySubsOut': [],
        'temporaryNumbers': {},
      });

      // 2. Σύνδεση του εγγράφου ψήφων απευθείας με το newMatchId
      await FirebaseFirestore.instance
          .collection('votes')
          .doc(newMatchId)
          .set({
        'matchId': newMatchId,
        'homeTeam': home.name,
        'awayTeam': away.name,
        'startTime': timestamp,
        'cancelled': false,
        'hasMatchFinished': false,
        'statsUpdated': false,
      }, SetOptions(merge: true));

    } catch (e) {
      print("❌ Error adding match: $e");
    }
  }

  Future<void> deleteMatch(MatchDetails match) async {
    try {
      final String docId = match.matchDocId;

      await FirebaseFirestore.instance
          .collection("year")
          .doc(thisYearNow.toString())
          .collection("matches")
          .doc(docId)
          .delete();

      await FirebaseFirestore.instance
          .collection('votes')
          .doc(docId)
          .set({
        'cancelled': true,
        'hasMatchFinished': true,
        'statsUpdated': false
      }, SetOptions(merge: true));

      print('Το έγγραφο διαγράφηκε επιτυχώς!');
    } catch (e) {
      print('Σφάλμα κατά τη διαγραφή του εγγράφου: $e');
    }
  }

  Team? getTeam(String name) {
    try {
      return teams.firstWhere((team) => team.name == name);
    } catch (e) {
      print("Error getting team: $e");
      return null;
    }
  }

  Team? getTeamFromList(String name, List<Team> teamList) {
    try {
      return teamList.firstWhere((team) => team.name == name);
    } catch (e) {
      print("Error getting team: $e");
      return null;
    }
  }

  Future<List<MatchDetails>> getMatches(String type) async {
    List<MatchDetails> matches = [];

    try {
      var matchDocs = await FirebaseFirestore.instance
          .collection('year')
          .doc(thisYearNow.toString())
          .collection("matches")
          .where("Type", isEqualTo: type)
          .get();

      if (matchDocs.docs.isEmpty) {
        print("⚠️ No matches found for type '$type'.");
        return matches;
      }

      List<Future<MatchDetails?>> matchFutures = matchDocs.docs.map((matchDoc) async {
        var data = matchDoc.data();
        String homeTeamName = data["Hometeam"] ?? "";
        String awayTeamName = data["Awayteam"] ?? "";
        Team? homeTeam = await getTeam(homeTeamName);
        Team? awayTeam = await getTeam(awayTeamName);

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
          penalties: (data['penalties'] as List<dynamic>? ?? []).map((p) => PenaltyShoot.fromMap(Map<String, dynamic>.from(p))).toList(),
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

        if (!match.isGroupPhase){
          int g = match.game;
          int slot = (g == 16) ? 0 : (g == 8) ? 8 : (g == 4) ? 12 : 14;
          playOffMatches[slot + match.slot] = match;
        }

        return match;
      }).toList();

      var completedMatches = await Future.wait(matchFutures);
      matches = completedMatches.whereType<MatchDetails>().toList();

      print("✅ Loaded ${matches.length} matches for type '$type'.");
    } catch (e) {
      print("❌ Error fetching matches of type '$type': $e");
    }

    return matches;
  }

  Future<void> sortTeams(int group) async {
    List<Team> groupTeams = teams.where((team) => team.group == group).toList()
      ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    for (int i = 0; i < groupTeams.length; i++) {
      Team team = groupTeams[i];
      int position = i + 1;
      team.setPosition(position);

      await FirebaseFirestore.instance
          .collection("year").doc(thisYearNow.toString()).collection('teams')
          .doc(team.name)
          .set({'position': position}, SetOptions(merge: true));
    }
  }

//  Βάλαμε το 'List<Team> yearTeams' στα ορίσματα!
  Future<Map<int, MatchDetails>> getPlayOffMatches(int yearo, List<Team> yearTeams) async {
    try {
      var matchDocs = await FirebaseFirestore.instance
          .collection('year').doc(yearo.toString()).collection("matches")
          .where("IsGroupPhase", isEqualTo: false)
          .get();

      if (matchDocs.docs.isEmpty) {
        print("⚠️ No matches found for type playoffs.");
        return {};
      }

      playOffMatches = {};

      List<Future<MatchDetails?>> matchFutures = matchDocs.docs.map((matchDoc) async {
        var data = matchDoc.data();
        String homeTeamName = data["Hometeam"] ?? "";
        String awayTeamName = data["Awayteam"] ?? "";

        // Ψάχνουμε στη λίστα ΤΗΣ ΧΡΟΝΙΑΣ που επιλέξαμε
        Team? homeTeam = getTeamFromList(homeTeamName, yearTeams);
        Team? awayTeam = getTeamFromList(awayTeamName, yearTeams);

        print("================== DEBUG PLAY-OFFS ($yearo) ==================");
        print("👉 Ψάχνω το ματς: '$homeTeamName' vs '$awayTeamName'");
        print("👉 Η λίστα yearTeams περιέχει: ${yearTeams.map((t) => t.name).toList()}");
        print("👉 Βρέθηκαν; Home: ${homeTeam?.name}, Away: ${awayTeam?.name}");
        print("=============================================================");

        if (homeTeam == null || awayTeam == null) {
          print("⚠️ Αγνοήθηκε ματς: Δεν βρέθηκε η ομάδα στο έτος $yearo ($homeTeamName vs $awayTeamName)");
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
          penalties: (data['penalties'] as List<dynamic>? ?? []).map((p) => PenaltyShoot.fromMap(Map<String, dynamic>.from(p))).toList(),
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

        int g = match.game;
        int slot = (g == 16) ? 0 : (g == 8) ? 8 : (g == 4) ? 12 : 14;

        playOffMatches[slot + match.slot] = match;
        return match;
      }).toList();

      await Future.wait(matchFutures);

    } catch (e) {
      print("❌ Error fetching matches of type playoffs: $e");
    }

    return playOffMatches;
  }
  Future<bool> isFavouriteTeam(String teamName) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: globalUser.username)
        .where("Favourite Teams", arrayContains: teamName)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> addFavouriteTeam(String teamName) async {
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("username", isEqualTo: globalUser.username)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        DocumentReference userDocRef = userSnapshot.docs.first.reference;
        await userDocRef.update({
          "Favourite Teams": FieldValue.arrayUnion([teamName]),
        });
      }
    } catch (e) {
      print("Error adding favourite team: $e");
    }
  }

  Future<void> removeFavouriteTeam(String teamName) async {
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("username", isEqualTo: globalUser.username)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        DocumentReference userDocRef = userSnapshot.docs.first.reference;
        await userDocRef.update({
          "Favourite Teams": FieldValue.arrayRemove([teamName]),
        });
      }
    } catch (e) {
      print("Error removing favourite team: $e");
    }
  }

  Future<List<String>> getAllFavouriteTeamsNames(String name) async {
    List<String> fTeams = [];
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: name)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      DocumentSnapshot userDoc = userSnapshot.docs.first;
      if (userDoc.data() != null && (userDoc.data() as Map<String, dynamic>).containsKey("Favourite Teams")) {
        List<dynamic> teamList = userDoc.get("Favourite Teams");
        fTeams = teamList.map((team) => team.toString()).toList();
      }
    }
    return fTeams;
  }

  List<Team> getAllFavouriteTeams(String name) {
    List<Team> fTeams = [];
    List<String> teamNames = globalUser.favoriteList;

    for (Team team in teams) {
      for (String teamName in teamNames) {
        if (teamName == team.name) {
          fTeams.add(team);
        }
      }
    }
    return fTeams;
  }

  Future<List<String>> getPreviousResults(String name) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('year').doc(thisYearNow.toString()).collection("teams")
        .where("Name", isEqualTo: name)
        .get();

    if(querySnapshot.docs.isNotEmpty) {
      final teamDoc = querySnapshot.docs.first;
      return List<String>.from(teamDoc.get("LastFive"));
    }
    return [];
  }

  Future<List<num>> getPercentages(String matchIdKey) async {
    final doc = await FirebaseFirestore.instance
        .collection('votes')
        .doc(matchIdKey)
        .get();

    if (doc.exists) {
      Map<String, dynamic> userVotes = doc.get("userVotes") ?? {};

      int homeVotes = 0;
      int awayVotes = 0;
      int drawVotes = 0;

      for (var vote in userVotes.values) {
        switch (vote) {
          case "1": homeVotes++; break;
          case "2": awayVotes++; break;
          case "X": drawVotes++; break;
        }
      }

      int totalVotes = homeVotes + awayVotes + drawVotes;
      if (totalVotes == 0) return [0, 0, 0];

      return [
        homeVotes / totalVotes * 100,
        awayVotes / totalVotes * 100,
        drawVotes / totalVotes * 100,
      ];
    }
    return [];
  }

  bool canDeleteTeam(Team team) {
    // Έλεγχος στους ολοκληρωμένους αγώνες (Επίπεδη Λίστα)
    bool inPrevious = previousMatches.any((match) =>
    match.homeTeam.name == team.name || match.awayTeam.name == team.name
    );

    // Έλεγχος στους προγραμματισμένους αγώνες (Επίπεδη Λίστα)
    bool inUpcoming = upcomingMatches.any((match) =>
    match.homeTeam.name == team.name || match.awayTeam.name == team.name
    );

    // Επιστρέφει true ΜΟΝΟ αν ο χρήστης είναι Upper Admin ΚΑΙ η ομάδα δεν υπάρχει ΠΟΥΘΕΝΑ
    return globalUser.isUpperAdmin && !inPrevious && !inUpcoming;
  }

// 2. Η συνάρτηση οριστικής διαγραφής
  Future<void> deleteTeamCompletely(Team team) async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // Διπλή δικλείδα ασφαλείας: Αν δεν επιτρέπεται, σταματάει την εκτέλεση αμέσως.
    if (!canDeleteTeam(team)) {
      print("🚨 Η διαγραφή ακυρώθηκε: Η ομάδα έχει καταχωρημένους αγώνες.");
      return;
    }

    // Βρίσκουμε το Path (φάκελο) της ομάδας.
    // ΣΗΜΕΙΩΣΗ: Αν το Document ID στο Firestore είναι το όνομα, το αφήνεις ως έχει.
    // Αν είναι το uniqueKey, άλλαξε το .doc(team.name) σε .doc(team.uniqueKey)
    final teamRef = firestore
        .collection('year')
        .doc(thisYearNow.toString())
        .collection('teams')
        .doc(team.name);

    try {
      // 1. Καθαρισμός των Παικτών (Subcollection 'players')
      final playersSnapshot = await teamRef.collection('players').get();
      for (var doc in playersSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // 2. Διαγραφή της ίδιας της Ομάδας
      batch.delete(teamRef);

      // 3. Εκτέλεση όλων μαζί (Commit)
      await batch.commit();

      print("✅ Η ομάδα ${team.name} και όλοι οι παίκτες της διαγράφηκαν οριστικά!");

    } catch (e) {
      print("🚨 Σφάλμα κατά τη διαγραφή της ομάδας: $e");
      throw Exception("Αποτυχία διαγραφής: $e");
    }
  }

}