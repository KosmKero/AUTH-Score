import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled1/globals.dart';
import 'package:untitled1/globals.dart' as global;

import '../Data_Classes/basketball/basketMatch.dart';
import '../Data_Classes/basketball/basketPlayer.dart';
import '../Data_Classes/basketball/basketTeam.dart';

class BasketTeamsHandle {
  // --- 1. ΔΙΑΧΕΙΡΙΣΗ ΟΜΑΔΩΝ ΜΠΑΣΚΕΤ ---

  Future<void> addNewTeam(basketTeam team) async {
    await FirebaseFirestore.instance
        .collection('basket')
        .doc(thisYearNow.toString())
        .collection("teams") // Σωστό Path μπάσκετ!
        .doc(team.name)
        .set({
      'Name': team.name,
      'NameEnglish': team.nameEnglish,
      'Coach': team.coach,
      'Matches': team.matches,
      'Wins': team.wins,
      'Losses': team.losses, // Προσοχή: Χωρίς Draws!
      'Group': team.group,
      'Foundation Year': team.foundationYear,
      'Titles': team.titles,
      'initials': team.initials,
      'position': team.position,
      'Players': _convertPlayersToMap(team.players),
    });
  }

  // Βοηθητική μέθοδος για να μη γεμίζει ο κώδικας
  Map<String, dynamic> _convertPlayersToMap(List<BasketPlayer> players) {
    Map<String, dynamic> map = {};
    for (var player in players) {
      String key = "${player.name}${player.surname}${player.number}";
      map[key] = player.toMap2();
    }
    return map;
  }

  Future<List<basketTeam>> getAllTeamsByYear(int year) async {
    List<basketTeam> allTeams = [];

    try {
      var teamsDoc = await FirebaseFirestore.instance
          .collection('basket')
          .doc(year.toString())
          .collection("teams")
          .get();

      if (teamsDoc.docs.isNotEmpty) {
        for (var team in teamsDoc.docs) {
          try {
            String name = team.get("Name") ?? "";
            String nameE = team.get('NameEnglish') ?? "";
            int matches = team.get("Matches") ?? 0;
            int wins = team.get("Wins") ?? 0;
            int losses = team.get("Losses") ??
                (team.data().containsKey("Losses") ? team.get("Losses") : 0);
            int group = team.get("Group") ?? 0;
            int foundationYear = team.get("Foundation Year") ?? 0;
            int titles = team.get("Titles") ?? 0;
            String coach = team.get("Coach") ?? "";
            int position = team.get("position") ?? 0;
            String initials = team.get("initials") ?? "";

            List<BasketPlayer> players = [];

            if (team.data().containsKey("Players") &&
                team.get("Players") != null) {
              Map<String, dynamic> playersData =
                  team.get("Players") as Map<String, dynamic>;

              playersData.forEach((key, playerData) {
                players.add(BasketPlayer(
                  playerData["Name"] ?? "",
                  playerData['Surname'] ?? "",
                  playerData['Position'] ?? 0,
                  playerData['Points'] ?? 0, // Points αντί για Goals!
                  playerData['Number'] ?? 0,
                  playerData['TeamName'] ?? name,
                  playerData["teamNameEnglish"] ?? nameE,
                ));
              });
            }

            List<String> lastFive = [];
            if (team.data().containsKey("LastFive") &&
                team.get("LastFive") != null) {
              lastFive = List<String>.from(team.get("LastFive"));
            }

            allTeams.add(basketTeam(
                name,
                nameE,
                matches,
                wins,
                losses,
                group,
                foundationYear,
                titles,
                coach,
                position,
                initials,
                coach,
                players,
                lastFive));
          } catch (e) {
            print(
                "Error processing basket team document: ${team.id}, Error: $e");
          }
        }
      }
    } catch (e) {
      print("Error fetching basket teams: $e");
    }

    return allTeams;
  }

  Future<List<basketTeam>> getAllTeams() async {
    return await getAllTeamsByYear(thisYearNow);
  }

  basketTeam? getTeamFromList(String name, List<basketTeam> teamList) {
    try {
      return teamList.firstWhere((team) => team.name == name);
    } catch (e) {
      print("Error getting basket team: $e");
      return null;
    }
  }

  // --- 2. ΣΤΑΤΙΣΤΙΚΑ & ΙΣΤΟΡΙΚΟ ---

  Future<List<String>> getPreviousResults(String name) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('basket')
        .doc(thisYearNow.toString())
        .collection("teams")
        .where("Name", isEqualTo: name)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final teamDoc = querySnapshot.docs.first;
      if (teamDoc.data().containsKey("LastFive")) {
        return List<String>.from(teamDoc.get("LastFive"));
      }
    }
    return [];
  }

  // --- 3. ΔΙΑΧΕΙΡΙΣΗ ΑΓΩΝΩΝ (Match CRUD) ---

  Future<void> addMatch(basketTeam home, basketTeam away, int day, int month,
      int year, int game, bool isGroupPhase, int time, String type) async {
    try {
      String matchId =
          "${home.nameEnglish}$day$month$year$game${away.nameEnglish}";

      await FirebaseFirestore.instance
          .collection("basket")
          .doc(global.thisYearNow.toString())
          .collection("matches")
          .doc(matchId)
          .set({
        'Awayteam': away.name,
        'Hometeam': home.name,
        "homeTeamEnglish": home.nameEnglish,
        "awayTeamEnglish": away.nameEnglish,
        'Day': day,
        'Month': month,
        'Year': year,
        'Game': game,
        'HasMatchStarted': false,
        'IsGroupPhase': isGroupPhase,
        'Time': time,
        'Type': type,
        'HomeScore': 0,
        'AwayScore': 0,
        'PeriodScores': {}, // Άδειο Map για τα δεκάλεπτα
        'PlayerPoints': {
          'home': {},
          'away': {}
        }, // Άδειο Map για πόντους παικτών
        "HasMatchFinished": false,
        "CurrentPeriod": 0,
        "IsPeriodEnded": false,
      });
    } catch (e) {
      print("❌ Error adding basket match: $e");
    }
  }

  Future<void> deleteMatch(BasketMatch match) async {
    try {
      await FirebaseFirestore.instance
          .collection("basket")
          .doc(thisYearNow.toString())
          .collection("matches")
          .doc(match.matchDocId)
          .delete();

      await FirebaseFirestore.instance
          .collection('votes')
          .doc(
              '${match.homeTeam.nameEnglish}${match.awayTeam.nameEnglish}${match.dateString}')
          .set({
        'cancelled': true,
        'hasMatchFinished': true,
        'statsUpdated': false
      }, SetOptions(merge: true));

      print('Το έγγραφο του αγώνα μπάσκετ διαγράφηκε επιτυχώς!');
    } catch (e) {
      print('Σφάλμα κατά τη διαγραφή του αγώνα: $e');
    }
  }

  // --- 4. ΣΤΟΙΧΗΜΑ & ΠΟΣΟΣΤΑ (ΜΟΝΟ 1 Ή 2 ΣΤΟ ΜΠΑΣΚΕΤ) ---

  Future<List<num>> getPercentages(String key) async {
    final doc =
        await FirebaseFirestore.instance.collection('votes').doc(key).get();

    if (doc.exists) {
      Map<String, dynamic> userVotes = doc.get("userVotes") ?? {};

      int homeVotes = 0;
      int awayVotes = 0;

      for (var vote in userVotes.values) {
        switch (vote) {
          case "1":
            homeVotes++;
            break;
          case "2":
            awayVotes++;
            break;
        }
      }

      int totalVotes = homeVotes + awayVotes;
      if (totalVotes == 0) return [0, 0]; // Επιστρέφει μόνο 2 θέσεις

      return [
        homeVotes / totalVotes * 100,
        awayVotes / totalVotes * 100,
      ];
    }

    return [];
  }

  // --- 5. ΑΓΑΠΗΜΕΝΑ (Favorites) ---
  // Αν χρησιμοποιείς την ίδια λίστα για όλα τα αθλήματα, ο κώδικας είναι σχεδόν ίδιος
  // Σου προτείνω να αφήσεις τα Αγαπημένα στο UserHandle για να μην τα γράφεις 2 φορές,
  // αλλά αν τα θες εδώ:

  Future<bool> isFavouriteTeam(String teamName) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: globalUser.username)
        .where("Favourite Teams", arrayContains: teamName)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
}
