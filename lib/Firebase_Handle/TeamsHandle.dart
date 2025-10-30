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
    await FirebaseFirestore.instance
        .collection('year').doc(thisYearNow.toString()).collection("teams")
        .doc(team.name)
        .set({
      'Name': team.name,
      'Coach': team.coach,
      'Matches': team.matches,
      'Wins': team.wins,
      'Losses': team.losses,
      'Draws': team.draws,
      'Group': team.group,
      'Foundation Year': team.foundationYear,
      'Titles': team.titles,
      'initials':team.initials,
      'Players': team.players.map((player) => {
        'Name': player.name,
        'Age': player.age,
        'Position': player.position,
        'Goals': player.goals,
        'Number': player.number,
        'Surname': player.surname,
        'TeamName': player.teamName,
      }).toList(), // fixed here
    });
    }

  Future<List<Team>> getAllTeams() async {
    List<Team> allTeams = [];

    try {
      var teamsDoc = await FirebaseFirestore.instance.collection('year').doc(thisYearNow.toString()).collection("teams").get();

      if (teamsDoc.docs.isNotEmpty) {
        for (var team in teamsDoc.docs) {
          try {
            // Safely get values with null checking
            String name = team.get("Name") ?? "";
            String nameE = team.get('NameEnglish') ?? "";
            int matches = team.get("Matches") ?? 0;
            int wins = team.get("Wins") ?? 0;
            int losses = team.get("Loses") ?? 0;  // Note: "Loses" vs "Losses"
            int draws = team.get("Draws") ?? 0;
            int group = team.get("Group") ?? 0;
            int foundationYear = team.get("Foundation Year") ?? 0;
            int titles = team.get("Titles") ?? 0;
            String coach = team.get("Coach") ?? "";
            int position = team.get("position") ?? 0;
            String initials = team.get("initials");

            // Convert the raw player data from Firestore into Player objects
            List<Player> players = [];

            if (team.get("Players") != null) {
              Map<String, dynamic> playersData = team.get("Players") as Map<String, dynamic>;

              playersData.forEach((name, playerData) {
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
                  playerData["teamNameEnglish"] ?? ""
                ));
              });
            }

            // Now create the Team with the properly converted Player list
            allTeams.add(Team(
                name,
                nameE,
                matches,
                wins,
                losses,
                draws,
                group,
                foundationYear,
                titles,
                coach,
                position,
                initials,
                players
            ));
          } catch (e) {
            print("Error processing team document: ${team.id}, Error: $e");
            // Continue to the next document instead of failing the entire operation
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
            // Safely get values with null checking
            String name = team.get("Name") ?? "";
            String nameE = team.get('NameEnglish') ?? "";
            int matches = team.get("Matches") ?? 0;
            int wins = team.get("Wins") ?? 0;
            int losses = team.get("Loses") ?? 0;  // Note: "Loses" vs "Losses"
            int draws = team.get("Draws") ?? 0;
            int group = team.get("Group") ?? 0;
            int foundationYear = team.get("Foundation Year") ?? 0;
            int titles = team.get("Titles") ?? 0;
            String coach = team.get("Coach") ?? "";
            int position = team.get("position") ?? 0;
            String initials = team.get("initials");

            // Convert the raw player data from Firestore into Player objects
            List<Player> players = [];

            if (team.get("Players") != null) {
              Map<String, dynamic> playersData = team.get("Players") as Map<String, dynamic>;

              playersData.forEach((name, playerData) {
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
                    playerData["teamNameEnglish"] ?? ""
                ));
              });
            }

            // Now create the Team with the properly converted Player list
            allTeams.add(Team(
                name,
                nameE,
                matches,
                wins,
                losses,
                draws,
                group,
                foundationYear,
                titles,
                coach,
                position,
                initials,
                players
            ));
          } catch (e) {
            print("Error processing team document: ${team.id}, Error: $e");
            // Continue to the next document instead of failing the entire operation
          }
        }
      }
    } catch (e) {
      print("Error fetching teams: $e");
    }

    return allTeams;
  }


  Future<void> addMatch(Team home, Team away, int day, int month, int year, int game, bool hasStarted, bool isGroupPhase, int time, String type,int goalHome,int goalAway) async {
    try
    {
      final hour = time ~/ 100;
      final minute = time % 100;

      final dateTime = DateTime(year, month, day, hour, minute);
      final timestamp = Timestamp.fromDate(dateTime);


        await FirebaseFirestore.instance
            .collection("year").doc(global.thisYearNow.toString()).collection("matches")
            .doc(home.nameEnglish+day.toString()+month.toString()+year.toString()+game.toString()+away.nameEnglish) // Improved unique ID
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
          "slot":0

        });
    }
    catch (e)
    {
      print("❌ Error adding match: $e");
    }
  }


  Future<void> deleteMatch(MatchDetails match) async {
    try {
      await FirebaseFirestore.instance
          .collection("year").doc(thisYearNow.toString()).collection("matches")
          .doc(match.matchKey)
          .delete();
      navigatorKey.currentState?.pushReplacementNamed('/home');
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
          playerData["teamNameEnglish"] ?? ""
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
      return teams.firstWhere(
            (team) => team.name == name,
      );
    } catch (e) {
      print("Error getting team: $e");
      return null;
    }
  }

  Team? getTeamFromList(String name,List<Team> teamList ) {
    try {
      return teamList.firstWhere(
            (team) => team.name == name,
      );
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

      // Χρησιμοποιούμε Future.wait για να κάνουμε τις κλήσεις παράλληλα
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
            penalties: (data['penalties'] as List<dynamic>? ?? [])
                .map((p) => PenaltyShoot.fromMap(Map<String, dynamic>.from(p)))
                .toList(),
          slot: data["slot"] ?? 0

        );
        if (!match.isGroupPhase){

         int g= match.game;
         int slot = (g==16) ? 0 : (g==8) ? 8 : (g==4) ? 12 : 14;

          playOffMatches[slot+ match.slot] = match;

        }

        return match;
      }).toList();

      // Εκτελούνται όλες παράλληλα
      var completedMatches = await Future.wait(matchFutures);

      // Φιλτράρουμε τα null (όσα απορρίψαμε λόγω ελλιπών δεδομένων)
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
      int position = i + 1; // Η θέση ξεκινά από 1
      team.setPosition(position); // Αν υπάρχει μεταβλητή θέσης στο μοντέλο

      await FirebaseFirestore.instance
          .collection('teams')
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

      // Χρησιμοποιούμε Future.wait για να κάνουμε τις κλήσεις παράλληλα
      List<Future<MatchDetails?>> matchFutures = matchDocs.docs.map((matchDoc) async {
        var data = matchDoc.data() as Map<String, dynamic>;
        String homeTeamName = data["Hometeam"] ?? "";
        String awayTeamName = data["Awayteam"] ?? "";
        Team? homeTeam = await getTeam(homeTeamName);
        Team? awayTeam = await getTeam(awayTeamName);

        if (homeTeam == null || awayTeam == null) {
          print(
              "⚠️ Skipping match due to missing team data: $homeTeamName vs $awayTeamName");
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
            hasFirstHalfExtraTimeFinished:
            data['hasFirstHalfExtraTimeFinished'] ?? false,
            hasExtraTimeFinished: data['hasExtraTimeFinished'] ?? false,
            hasExtraTimeStarted: data['hasExtraTimeStarted'] ?? false,
            hasSecondHalfExtraTimeStarted:
            data['hasSecondHalfExtraTimeStarted'] ?? false,
            scoreAwayExtraTime: data['GoalAwayExtraTime'] ?? 0,
            scoreHomeExtraTime: data['GoalHomeExtraTime'] ?? 0,
            penalties: (data['penalties'] as List<dynamic>? ?? [])
                .map((p) => PenaltyShoot.fromMap(Map<String, dynamic>.from(p)))
                .toList(),
            slot: data["slot"] ?? 0,
          );

          int g= match.game;
          int slot = (g==16) ? 0 : (g==8) ? 8 : (g==4) ? 12 : 14;

          playOffMatches[slot+ match.slot] = match;


        return match;
      }
      }).toList();


      // Εκτελούνται όλες παράλληλα
      var completedMatches = await Future.wait(matchFutures);

      // Φιλτράρουμε τα null (όσα απορρίψαμε λόγω ελλιπών δεδομένων)
      matches = completedMatches.whereType<MatchDetails>().toList();

      print("✅ Loaded ${matches.length} matches for type playoffs.");
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
      // Βρες το έγγραφο του χρήστη με βάση το username
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("username", isEqualTo: globalUser.username)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        // Υποθέτουμε ότι το username είναι μοναδικό, οπότε παίρνουμε το πρώτο
        DocumentReference userDocRef = userSnapshot.docs.first.reference;

        // Κάνε ενημέρωση της λίστας των αγαπημένων ομάδων
        await userDocRef.update({
          "Favourite Teams": FieldValue.arrayUnion([teamName]),
        });
      } else {
        print("User not found");
      }
    } catch (e) {
      print("Error adding favourite team: $e");
    }
  }


  Future<void> removeFavouriteTeam(String teamName) async {
    try {
      // Βρες το έγγραφο του χρήστη με βάση το username
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("username", isEqualTo: globalUser.username)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        // Υποθέτουμε ότι το username είναι μοναδικό
        DocumentReference userDocRef = userSnapshot.docs.first.reference;

        // Αφαίρεσε την ομάδα από τη λίστα
        await userDocRef.update({
          "Favourite Teams": FieldValue.arrayRemove([teamName]),
        });
      } else {
        print("User not found");
      }
    } catch (e) {
      print("Error removing favourite team: $e");
    }
  }



  Future<List<String>> getAllFavouriteTeamsNames(String name) async {
    List<String> fTeams = [];

    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: name)  // Use the passed name parameter
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      // Assuming username is unique
      DocumentSnapshot userDoc = userSnapshot.docs.first;

      // Check if the field exists and is a List
      if (userDoc.data() != null && (userDoc.data() as Map<String, dynamic>).containsKey("Favourite Teams")) {
        // Convert to List<String>
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
  
  
  Future<List<String>> getPreviousResults(String name) async
  {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('year').doc(thisYearNow.toString()).collection("teams")
        .where("Name", isEqualTo: name)
        .get();
    
    if(querySnapshot.docs.isNotEmpty)
      {
        final teamDoc = querySnapshot.docs.first;
        return List<String>.from(teamDoc.get("LastFive"));

      }

    return [];
  }

  /*
  Future<void> addDraw(String home,String away) async{
    final querySnapshot = await FirebaseFirestore.instance
        .collection("matches")
        .where("Hometeam", isEqualTo: home)
        .where("Awayteam", isEqualTo: away)
        .get();

    if(querySnapshot.docs.isNotEmpty)
      {
        final matchDoc = querySnapshot.docs.first;
        matchDoc.reference.update({"Draws": FieldValue.delete()});
      }
  }

   */


  Future<void> addAllValues(String home,String away,String selection) async{
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
          case "1":
            homeVotes++;
            break;
          case "2":
            awayVotes++;
            break;
          case "X":
            drawVotes++;
            break;
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







/*
  ΣΥΝΑΡΤΗΣΗ ΓΙΑ ΝΑ ΚΑΝΕΙ ΑΝΑΝΕΩΣΗ ΤΑ ΑΠΟΤΕΛΕΣΜΑΤΑ ΣΕ ΚΑΘΕ ΟΜΑΔΑ ΜΕΤΑ ΤΗΝ ΛΗΞΗ ΤΟΥ ΑΓΩΝΑ!!!!!
  Future<void> addResult(String name, String result) async
  {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("teams")
        .where("Name", isEqualTo: name)
        .get();

    if(querySnapshot.docs.isNotEmpty) {
      final teamDoc = querySnapshot.docs.first;
      final lastFive = List<String>.from(teamDoc.get("LastFive"));

      for (var i = 0; i < 4; i++){
        lastFive[i] = lastFive[i + 1];

      }

      lastFive[4] = result;

      await teamDoc.reference.update({"LastFive": lastFive});

    }



  }

   */

  /*List<MatchDetails> getMatchUps() {

    List<Team> firstBracket = [];
    List<Team> secondBracket = [];
    List<List<Team>> bracketResults = [];

    for(Team team in topTeams)
      {
        if(team.group ==1 || team.group ==2) {
          firstBracket.add(team);
        }
        else {
          secondBracket.add(team);
        }
      }

    bracketResults.add(firstBracket);
    bracketResults.add(secondBracket);

    List<MatchDetails> matches1 = [];
    List<MatchDetails> matches2 = [];

    for(var i=0;i<2;i++)
      {
        matches1.add(MatchDetails(
            homeTeam: firstBracket[i],
            awayTeam: firstBracket[firstBracket.length-i-1],
            hasMatchStarted: false,
            time: 1510,
            day: 1,
            month: 6,
            year: 2025,
            isGroupPhase: false,
            game: 1,
            scoreHome: -1,
            scoreAway: -1));

        matches1.add(MatchDetails(
            homeTeam: firstBracket[i==0?4-i:5],
            awayTeam: firstBracket[i==0?4-i-1:2],
            hasMatchStarted: false,
            time: 1510,
            day: 1,
            month: 6,
            year: 2025,
            isGroupPhase: false,
            game: 1,
            scoreHome: -1,
            scoreAway: -1));
      }


    for(var i=0;i<2;i++)
    {
      matches2.add(MatchDetails(
          homeTeam: secondBracket[i],
          awayTeam: secondBracket[firstBracket.length-i-1],
          hasMatchStarted: false,
          time: 1510,
          day: 1,
          month: 6,
          year: 2025,
          isGroupPhase: false,
          game: 1,
          scoreHome: -1,
          scoreAway: -1));

      matches2.add(MatchDetails(
          homeTeam: secondBracket[i==0?4-i:5],
          awayTeam: secondBracket[i==0?4-i-1:2],
          hasMatchStarted: false,
          time: 1510,
          day: 1,
          month: 6,
          year: 2025,
          isGroupPhase: false,
          game: 1,
          scoreHome: -1,
          scoreAway: -1));
    }

    int i=0;
    int j=0;
    List<MatchDetails> finalBracket = [];
    while(i<matches1.length && j<matches2.length)
      {
        if(i==j) {
          finalBracket.add(matches1[i]);
          i++;
        }
        else{
          finalBracket.add(matches2[j]);
          j++;
        }

      }

      finalBracket.add(matches2[j]);
      return finalBracket;

  }

   */



}
