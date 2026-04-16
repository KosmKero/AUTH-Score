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

class TeamsHandle {

  Future<void> addNewTeam(Team team) async {
    try {
      await FirebaseFirestore.instance
          .collection('year')
          .doc(thisYearNow.toString())
          .collection("teams")
          .doc(team.name)
          .set(team.toMap(), SetOptions(merge: true)); // Χρησιμοποιούμε merge για ασφάλεια

      print("Η ομάδα ${team.name} προστέθηκε επιτυχώς!");
    } catch (e) {
      print("Σφάλμα κατά την προσθήκη της ομάδας: $e");
    }
  }

  Future<void> updateTeamDetails(
      String teamNameId,
      String newNameEnglish,
      String newInitials,
      String newCoach,
      int newFoundationYear,
      int newGroup,
      int? newTitles) async {

    Map<String, dynamic> dataToUpdate = {
      'NameEnglish': newNameEnglish,
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
      var teamsDoc = await FirebaseFirestore.instance.collection('year').doc(thisYearNow.toString()).collection("teams").get();

      if (teamsDoc.docs.isNotEmpty) {
        for (var team in teamsDoc.docs) {
          try {
            String name = team.get("Name") ?? "";
            String nameE = team.get('NameEnglish') ?? "";
            int matches = team.get("Matches") ?? 0;
            int wins = team.get("Wins") ?? 0;
            int losses = team.get("Loses") ?? 0;
            int draws = team.get("Draws") ?? 0;
            int group = team.get("Group") ?? 0;
            int foundationYear = team.get("Foundation Year") ?? 0;
            int titles = team.get("Titles") ?? 0;
            String coach = team.get("Coach") ?? "";
            int position = team.get("position") ?? 0;
            String initials = team.get("initials");

            List<Player> players = [];

            if (team.get("Players") != null) {
              Map<String, dynamic> playersData = team.get("Players") as Map<String, dynamic>;

              playersData.forEach((name, playerData) {
                DateTime? expiryDate;
                // ΔΙΟΡΘΩΘΗΚΕ ΕΔΩ: playerData χωρίς s
                if (playerData['healthCardExpiry'] != null) {
                  expiryDate = (playerData['healthCardExpiry'] as Timestamp).toDate();
                }

                players.add(Player(
                    playerData["Name"] ?? "",
                    playerData['Surname'] ?? "",
                    playerData['Position'] ?? 0,
                    playerData['Goals'] ?? 0,
                    playerData['Number'] ?? 0,
                    playerData['Age'] ?? 0,
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

            allTeams.add(Team(name, nameE, matches, wins, losses, draws, group, foundationYear, titles, coach, position, initials, players));
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
      var teamsDoc = await FirebaseFirestore.instance.collection('year').doc(year.toString()).collection("teams").get();

      if (teamsDoc.docs.isNotEmpty) {
        for (var team in teamsDoc.docs) {
          try {
            String name = team.get("Name") ?? "";
            String nameE = team.get('NameEnglish') ?? "";
            int matches = team.get("Matches") ?? 0;
            int wins = team.get("Wins") ?? 0;
            int losses = team.get("Loses") ?? 0;
            int draws = team.get("Draws") ?? 0;
            int group = team.get("Group") ?? 0;
            int foundationYear = team.get("Foundation Year") ?? 0;
            int titles = team.get("Titles") ?? 0;
            String coach = team.get("Coach") ?? "";
            int position = team.get("position") ?? 0;
            String initials = team.get("initials");

            List<Player> players = [];

            if (team.get("Players") != null) {
              Map<String, dynamic> playersData = team.get("Players") as Map<String, dynamic>;

              playersData.forEach((name, playerData) {
                DateTime? expiryDate;
                // ΔΙΟΡΘΩΘΗΚΕ ΕΔΩ: playerData χωρίς s
                if (playerData['healthCardExpiry'] != null) {
                  expiryDate = (playerData['healthCardExpiry'] as Timestamp).toDate();
                }

                players.add(Player(
                    playerData["Name"] ?? "",
                    playerData['Surname'] ?? "",
                    playerData['Position'] ?? 0,
                    playerData['Goals'] ?? 0,
                    playerData['Number'] ?? 0,
                    playerData['Age'] ?? 0,
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

            allTeams.add(Team(name, nameE, matches, wins, losses, draws, group, foundationYear, titles, coach, position, initials, players));
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

  Future<void> addMatch(Team home, Team away, int day, int month, int year, int game, bool hasStarted, bool isGroupPhase, int time, String type,int goalHome,int goalAway) async {
    try {
      final hour = time ~/ 100;
      final minute = time % 100;
      final dateTime = DateTime(year, month, day, hour, minute);
      final timestamp = Timestamp.fromDate(dateTime);

      await FirebaseFirestore.instance
          .collection("year").doc(global.thisYearNow.toString()).collection("matches")
          .doc(home.nameEnglish+day.toString()+month.toString()+year.toString()+game.toString()+away.nameEnglish)
          .set({
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
        "hasMatchFinished": false ,
        "hasSecondHalfStarted": false,
        "hasFirstHalfFinished":false,
        'startTime': timestamp,
        "notified":false,
        'hasExtraTimeFinished':false,
        'hasSecondHalfExtraTimeStarted': false,
        'hasFirstHalfExtraTimeFinished':false,
        'hasExtraTimeStarted':false,
        'GoalHomeExtraTime':0,
        'GoalAwayExtraTime':0,
        'penalties' : [],
        'shootoutOver':false,
        "slot":0,
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

      await FirebaseFirestore.instance
          .collection('votes')
          .doc('${home.nameEnglish}${away.nameEnglish}${day.toString().padLeft(2, '0')}.${month.toString().padLeft(2, '0')}.${(year % 100).toString().padLeft(2, '0')}')
          .set({

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
      await FirebaseFirestore.instance
          .collection("year").doc(thisYearNow.toString()).collection("matches")
          .doc(match.matchKey)
          .delete();

      await FirebaseFirestore.instance
          .collection('votes')
          .doc('${match.homeTeam.nameEnglish}${match.awayTeam.nameEnglish}${match.dateString}')
          .set({
        'cancelled': true,
        'hasMatchFinished': true,
        'statsUpdated':false
      }, SetOptions(merge: true));

      //navigatorKey.currentState?.pushReplacementNamed('/home');
      print('Το έγγραφο διαγράφηκε επιτυχώς!');
    } catch (e) {
      print('Σφάλμα κατά τη διαγραφή του εγγράφου: $e');
    }
  }

  Future<Team?> getTeam2(String name) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('year').doc(thisYearNow.toString()).collection("teams")
          .where("Name", isEqualTo: name)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("⚠️ Warning: Team '$name' not found in Firestore.");
        return null;
      }

      var doc = querySnapshot.docs.first;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      List<Player> players = (data['Players'] as Map<String, dynamic>? ?? {}).entries.map((entry) {
        final playerData = entry.value as Map<String, dynamic>;

        DateTime? expiryDate;
        if (playerData['healthCardExpiry'] != null) {
          expiryDate = (playerData['healthCardExpiry'] as Timestamp).toDate();
        }

        return Player(
            playerData["Name"] ?? "Unknown",
            playerData['Surname'] ?? "Unknown",
            playerData['Position'] ?? 0,
            playerData['Goals'] ?? 0,
            playerData['Number'] ?? 0,
            playerData['Age'] ?? 0,
            playerData['TeamName'] ?? "Unknown",
            playerData['numOfYellowCards'] ?? 0,
            playerData['numOfRedCards'] ?? 0,
            playerData["teamNameEnglish"] ?? "",
            expiryDate,
            playerData['Appearances'] ?? 0,
            playerData['id']
        );
      }).toList();

      return Team(
        data['Name'] ?? "Unknown",
        data['NameEnglish'] ?? "Unknown",
        data['Matches'] ?? 0,
        data['Wins'] ?? 0,
        data['Loses'] ?? 0,
        data['Draws'] ?? 0,
        data['Group'] ?? 0,
        data['Foundation Year'] ?? 0,
        data['Titles'] ?? 0,
        data['Coach'] ?? "Unknown",
        data['position'] ?? 0,
        data['initials'] ?? " ",
        players,
      );
    } catch (e) {
      print("❌ Error fetching team '$name': $e");
      return null;
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

  Team? getTeamFromList(String name,List<Team> teamList ) {
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
          .collection('year').doc(thisYearNow.toString()).collection("matches")
          .where("Type", isEqualTo: type)
          .get();

      if (matchDocs.docs.isEmpty) {
        print("⚠️ No matches found for type '$type'.");
        return matches;
      }

      List<Future<MatchDetails?>> matchFutures = matchDocs.docs.map((matchDoc) async {
        var data = matchDoc.data() as Map<String, dynamic>;
        String homeTeamName = data["Hometeam"] ?? "";
        String awayTeamName = data["Awayteam"] ?? "";
        Team? homeTeam = await getTeam(homeTeamName);
        Team? awayTeam = await getTeam(awayTeamName);

        if (homeTeam == null || awayTeam == null) {
          print("⚠️ Skipping match due to missing team data: $homeTeamName vs $awayTeamName");
          return null;
        }

        MatchDetails match = MatchDetails(
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

        if (!match.isGroupPhase){
          int g= match.game;
          int slot = (g==16) ? 0 : (g==8) ? 8 : (g==4) ? 12 : 14;
          playOffMatches[slot+ match.slot] = match;
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

      await FirebaseFirestore.instance.
          collection("year").doc(thisYearNow.toString()).collection('teams')
          .doc(team.name)
          .set({'position': position}, SetOptions(merge: true));
    }
  }

  Future<Map<int,MatchDetails>> getPlayOffMatches(int yearo) async {
    List<MatchDetails> matches = [];

    try {
      var matchDocs = await FirebaseFirestore.instance
          .collection('year').doc(yearo.toString()).collection("matches")
          .where("IsGroupPhase", isEqualTo: false)
          .get();

      if (matchDocs.docs.isEmpty) {
        print("⚠️ No matches found for type playoffs.");
        return {};
      }

      playOffMatches={};

      List<Future<MatchDetails?>> matchFutures = matchDocs.docs.map((matchDoc) async {
        var data = matchDoc.data() as Map<String, dynamic>;
        String homeTeamName = data["Hometeam"] ?? "";
        String awayTeamName = data["Awayteam"] ?? "";
        Team? homeTeam = await getTeam(homeTeamName);
        Team? awayTeam = await getTeam(awayTeamName);

        if (homeTeam == null || awayTeam == null) {
          return null;
        }
        if (data["IsGroupPhase"] == false) {
          MatchDetails match = MatchDetails(
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

          int g= match.game;
          int slot = (g==16) ? 0 : (g==8) ? 8 : (g==4) ? 12 : 14;

          playOffMatches[slot+ match.slot] = match;

          return match;
        }
        return null;
      }).toList();

      var completedMatches = await Future.wait(matchFutures);
      matches = completedMatches.whereType<MatchDetails>().toList();

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

    if(querySnapshot.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
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

  Future<void> addAllValues(String home,String away,String selection) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('year').doc(thisYearNow.toString()).collection("matches")
        .where("Hometeam", isEqualTo: home)
        .where("Awayteam", isEqualTo: away)
        .get();

    if(querySnapshot.docs.isNotEmpty){
      final matchDoc = querySnapshot.docs.first;
      if(selection=="1"){
        matchDoc.reference.update({"HomeVote": FieldValue.increment(1)});
      }
      else if(selection=="2"){
        matchDoc.reference.update({"AwayVote": FieldValue.increment(1)});
      }
      else{
        matchDoc.reference.update({"DrawVote": FieldValue.increment(1)});
      }
    }
  }

  Future<List<num>> getPercentages(String key) async {
    final doc = await FirebaseFirestore.instance
        .collection('votes')
        .doc(key)
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
}