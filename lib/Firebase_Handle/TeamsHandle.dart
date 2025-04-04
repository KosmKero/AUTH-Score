import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled1/Data_Classes/MatchDetails.dart';

import '../Data_Classes/Player.dart';
import '../Data_Classes/Team.dart';

class TeamsHandle {


  Future<void> addNewTeam(Team team) async {
    await FirebaseFirestore.instance
        .collection('teams')
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
      var teamsDoc = await FirebaseFirestore.instance.collection('teams').get();

      if (teamsDoc.docs.isNotEmpty) {
        for (var team in teamsDoc.docs) {
          try {
            // Safely get values with null checking
            String name = team.get("Name") ?? "";
            int matches = team.get("Matches") ?? 0;
            int wins = team.get("Wins") ?? 0;
            int losses = team.get("Loses") ?? 0;  // Note: "Loses" vs "Losses"
            int draws = team.get("Draws") ?? 0;
            int group = team.get("Group") ?? 0;
            int foundationYear = team.get("Foundation Year") ?? 0;
            int titles = team.get("Titles") ?? 0;
            String coach = team.get("Coach") ?? "";

            // Convert the raw player data from Firestore into Player objects
            List<Player> players = [];

            if (team.get("Players") != null) {
              List<dynamic> playersData = team.get("Players") as List<dynamic>;

              for (var playerData in playersData) {
                players.add(Player(
                  playerData['Name'] ?? "",
                  playerData['Surname'] ?? "",
                  playerData['Goals'] ?? 0,
                  playerData['Position'] ?? "",
                  playerData['Number'] ?? 0,
                  playerData['Age'] ?? 0,
                  playerData['TeamName'] ?? "",
                ));
              }
            }

            // Now create the Team with the properly converted Player list
            allTeams.add(Team(
                name,
                matches,
                wins,
                losses,
                draws,
                group,
                foundationYear,
                titles,
                coach,
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


  Future<void> addMatch(Team team1, Team team2, int day, int month, int year, int game, bool hasStarted, bool isGroupPhase, int time, String type) async {
    try {
      await FirebaseFirestore.instance
          .collection('matches')
          .doc(team1.name+day.toString()+month.toString()+year.toString()+game.toString()+team2.name) // Improved unique ID
          .set({
        'Awayteam': team2.name,
        'Hometeam': team1.name,
        'Day': day,
        'Month': month,
        'Year': year,
        'Game': game,
        'HasMatchStarted': hasStarted,
        'IsGroupPhase': isGroupPhase,
        'Time': time,
        'Type': type,
      });
      print("✅ Match added successfully: ${team1.name} vs ${team2.name}");
    } catch (e) {
      print("❌ Error adding match: $e");
    }
  }


  Future<Team?> getTeam(String name) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .where("Name", isEqualTo: name)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("⚠️ Warning: Team '$name' not found in Firestore.");
        return null;
      }

      var doc = querySnapshot.docs.first;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      List<Player> players = (data['Players'] as List<dynamic>? ?? []).map((playerData) {
        return Player(
          playerData['Name'] ?? "Unknown",
          playerData['Surname'] ?? "Unknown",
          playerData['Goals'] ?? 0,
          playerData['Position'] ?? "Unknown",
          playerData['Number'] ?? 0,
          playerData['Age'] ?? 0,
          playerData['TeamName'] ?? "Unknown",
        );
      }).toList();

      return Team(
        data['Name'] ?? "Unknown",
        data['Matches'] ?? 0,
        data['Wins'] ?? 0,
        data['Loses'] ?? 0,
        data['Draws'] ?? 0,
        data['Group'] ?? 0,
        data['Foundation Year'] ?? 0,
        data['Titles'] ?? 0,
        data['Coach'] ?? "Unknown",
        players,
      );
    } catch (e) {
      print("❌ Error fetching team '$name': $e");
      return null;
    }
  }


  /// ✅ Get Matches from Firestore with Error Handling
  Future<List<MatchDetails>> getMatches(String type) async {
    List<MatchDetails> matches = [];

    try {
      var matchDocs = await FirebaseFirestore.instance
          .collection('matches')
          .where("Type", isEqualTo: type)
          .get();

      if (matchDocs.docs.isEmpty) {
        print("⚠️ No matches found for type '$type'.");
        return matches;
      }

      for (var matchDoc in matchDocs.docs)
      {
        var data = matchDoc.data();

        Team? homeTeam = await getTeam(data["Hometeam"]);
        Team? awayTeam = await getTeam(data["Awayteam"]);

        if (homeTeam == null || awayTeam == null)
        {
          print("⚠️ Skipping match due to missing team data: ${data["HomeTeam"]} vs ${data["AwayTeam"]}");
          continue;
        }

        matches.add(MatchDetails(
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          hasMatchStarted: data['HasMatchStarted'] ?? false,
          time: data["Time"] ?? 0,
          day: data["Day"] ?? 0,
          month: data["Month"] ?? 0,
          year: data["Year"] ?? 0,
          isGroupPhase: data["IsGroupPhase"] ?? false,
          game: data["Game"] ?? 0,
        ));
      }
      print("✅ Loaded ${matches.length} matches for type '$type'.");
    } catch (e) {
      print("❌ Error fetching matches of type '$type': $e");
    }

    return matches;
  }




}
