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
        .collection("teams")
        .doc(team.name)
        .set({
      'Name': team.name,
      'NameEnglish': team.nameEnglish,
      'Coach': team.coach,
      'Matches': team.matches,
      'Wins': team.wins,
      'Losses': team.losses,
      'Group': team.group,
      'Foundation Year': team.foundationYear,
      'Titles': team.titles,
      'initials': team.initials,
      'position': team.position,
      'pointsFor': team.pointsFor,       // ΠΡΟΣΤΕΘΗΚΕ: Για τη διαφορά πόντων
      'pointsAgainst': team.pointsAgainst, // ΠΡΟΣΤΕΘΗΚΕ
      'Players': _convertPlayersToMap(team.players),
    }, SetOptions(merge: true)); // Καλό είναι να έχει merge για ασφάλεια
  }

  List<basketTeam> getAllFavouriteTeams(String name) {
    List<basketTeam> fTeams = [];
    List<String> teamNames = globalUser.favoriteListBasket;

    // Σιγουρέψου ότι η μεταβλητή basketTeams υπάρχει στο globals.dart
    for (basketTeam team in basketTeams) {
      for (String teamName in teamNames) {
        if (teamName == team.name) {
          fTeams.add(team);
        }
      }
    }
    return fTeams;
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
          "Favourite Teams Basket": FieldValue.arrayUnion([teamName]),
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
          "Favourite Teams Basket": FieldValue.arrayRemove([teamName]),
        });
      }
    } catch (e) {
      print("Error removing favourite team: $e");
    }
  }

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
            // ΠΑΙΡΝΟΥΜΕ ΟΛΟ ΤΟ MAP ΓΙΑ ΑΣΦΑΛΕΙΑ!
            Map<String, dynamic> data = team.data();

            String name = data["Name"] ?? "";
            String nameE = data['NameEnglish'] ?? ""; // Διορθώθηκε το quote
            int matches = data["Matches"] ?? 0;
            int wins = data["Wins"] ?? 0;
            int losses = data["Losses"] ?? 0; // Δες πόσο πιο καθαρό είναι τώρα!
            int group = data["Group"] ?? 0;
            int foundationYear = data["Foundation Year"] ?? 0;
            int titles = data["Titles"] ?? 0;
            String coach = data["Coach"] ?? "";
            int position = data["position"] ?? 0;
            String initials = data["initials"] ?? "";

            // Πόντοι Υπέρ/Κατά για τις ισοβαθμίες!
            int pointsFor = data["pointsFor"] ?? 0;
            int pointsAgainst = data["pointsAgainst"] ?? 0;

            List<BasketPlayer> players = [];

            if (data.containsKey("Players") && data["Players"] != null) {
              // Σίγουρο cast σε Map
              Map<String, dynamic> playersData = Map<String, dynamic>.from(data["Players"]);

              playersData.forEach((key, value) {
                // Ρητό cast του κάθε παίκτη
                Map<String, dynamic> playerData = Map<String, dynamic>.from(value);

                players.add(BasketPlayer(
                    playerData["Name"] ?? "",
                    playerData['Surname'] ?? "",
                    playerData['Position'] ?? 0,
                    playerData['Points'] ?? 0,
                    playerData['Number'] ?? 0,
                    playerData['TeamName'] ?? name,
                    playerData["teamNameEnglish"] ?? nameE,
                    playerData['id'] ?? key // Ασφαλής λήψη του UUID
                ));
              });
            }

            List<String> lastFive = [];
            if (data.containsKey("LastFive") && data["LastFive"] != null) {
              lastFive = List<String>.from(data["LastFive"]);
            }

            // Δημιουργία Ομάδας
            basketTeam newTeam = basketTeam(
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
                coach, // coachName
                players,
                lastFive
            );

            // Φόρτωση των πόντων (αν υπάρχουν)
            if (pointsFor > 0) newTeam.increasePointsFor(pointsFor);
            if (pointsAgainst > 0) newTeam.increasePointsAgainst(pointsAgainst);

            allTeams.add(newTeam);

          } catch (e) {
            print("Error processing basket team document: ${team.id}, Error: $e");
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
      // 1. Ζητάμε από το Firebase ένα κενό Document.
      DocumentReference newMatchRef = FirebaseFirestore.instance
          .collection("basket")
          .doc(global.thisYearNow.toString())
          .collection("matches")
          .doc();

      // 2. Αποθηκεύουμε τα δεδομένα σε αυτό το νέο Document
      await newMatchRef.set({
        'matchId': newMatchRef.id,
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
        'PeriodScores': {},
        'PlayerPoints': {'home': {}, 'away': {}},
        "HasMatchFinished": false,
        "CurrentPeriod": 0,
        "IsPeriodEnded": false,
        "slot": 0,
      });

      print("✅ Basket match added successfully with Auto-ID: ${newMatchRef.id}");
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
          .doc('${match.homeTeam.nameEnglish}${match.awayTeam.nameEnglish}${match.dateString}')
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

  // ΠΡΟΣΤΕΘΗΚΕ: Απαραίτητο για το BasketballStandingsOrKnockoutsChooserPage
  Future<List<BasketMatch>> getMatchesByYear(int year, List<basketTeam> loadedTeams) async {
    List<BasketMatch> matches = [];

    try {
      var matchDocs = await FirebaseFirestore.instance
          .collection('basket')
          .doc(year.toString())
          .collection("matches")
          .get();

      if (matchDocs.docs.isEmpty) return matches;

      for (var matchDoc in matchDocs.docs) {
        var data = matchDoc.data();
        basketTeam? homeTeam = getTeamFromList(data["Hometeam"] ?? "", loadedTeams);
        basketTeam? awayTeam = getTeamFromList(data["Awayteam"] ?? "", loadedTeams);

        if (homeTeam == null || awayTeam == null) continue;

        Map<int, Map<String, int>> parsedPeriodScores = {};
        if (data.containsKey('PeriodScores')) {
          (data['PeriodScores'] as Map<String, dynamic>).forEach((key, value) {
            parsedPeriodScores[int.parse(key)] = {
              'home': value['home'] ?? 0,
              'away': value['away'] ?? 0,
            };
          });
        }

        BasketMatch match = BasketMatch(
          matchDoc.id,
          homeTeam, awayTeam,
          data['HomeScore'] ?? 0, data['AwayScore'] ?? 0, parsedPeriodScores,
          data['IsGroupPhase'] ?? false, data['Game'] ?? 0, data['Time'] ?? 0,
          data['Day'] ?? 0, data['Month'] ?? 0, data['Year'] ?? 0,
          data['HasMatchStarted'] ?? false, data['HasMatchFinished'] ?? false, data['CurrentPeriod'] ?? 0,
        );
        matches.add(match);
      }
    } catch (e) {
      print("❌ Error fetching basket matches: $e");
    }
    return matches;
  }

  // ΠΡΟΣΤΕΘΗΚΕ: Απαραίτητο για το BasketballKnockOutsPage
  Future<Map<int, BasketMatch>> getPlayOffMatches(int yearo) async {
    Map<int, BasketMatch> playOffMatches = {};

    try {
      var matchDocs = await FirebaseFirestore.instance
          .collection('basket')
          .doc(yearo.toString())
          .collection("matches")
          .where("IsGroupPhase", isEqualTo: false)
          .get();

      if (matchDocs.docs.isEmpty) return {};

      List<basketTeam> allTeams = await getAllTeamsByYear(yearo);

      for (var matchDoc in matchDocs.docs) {
        var data = matchDoc.data();
        basketTeam? homeTeam = getTeamFromList(data["Hometeam"] ?? "", allTeams);
        basketTeam? awayTeam = getTeamFromList(data["Awayteam"] ?? "", allTeams);

        if (homeTeam == null || awayTeam == null) continue;

        Map<int, Map<String, int>> parsedPeriodScores = {};
        if (data.containsKey('PeriodScores')) {
          (data['PeriodScores'] as Map<String, dynamic>).forEach((key, value) {
            parsedPeriodScores[int.parse(key)] = {
              'home': value['home'] ?? 0,
              'away': value['away'] ?? 0,
            };
          });
        }

        BasketMatch match = BasketMatch(
          matchDoc.id,
          homeTeam, awayTeam,
          data['HomeScore'] ?? 0, data['AwayScore'] ?? 0, parsedPeriodScores,
          data['IsGroupPhase'] ?? false, data['Game'] ?? 0, data['Time'] ?? 0,
          data['Day'] ?? 0, data['Month'] ?? 0, data['Year'] ?? 0,
          data['HasMatchStarted'] ?? false, data['HasMatchFinished'] ?? false, data['CurrentPeriod'] ?? 0,
        );

        int g = match.game;
        int slotFirebase = data['slot'] ?? 0;

        // Λογική Μπάσκετ (έστω ότι ξεκινούν από τους 8)
        int slot = (g == 8) ? 0 : (g == 4) ? 4 : 6;
        playOffMatches[slot + slotFirebase] = match;
      }
    } catch (e) {
      print("❌ Error fetching basket playoffs: $e");
    }

    return playOffMatches;
  }

  // --- 4. ΣΤΟΙΧΗΜΑ & ΠΟΣΟΣΤΑ ---

  Future<List<num>> getPercentages(String key) async {
    final doc =
    await FirebaseFirestore.instance.collection('votes').doc(key).get();

    if (doc.exists) {
      Map<String, dynamic> userVotes = doc.get("userVotes") ?? {};
      int homeVotes = 0;
      int awayVotes = 0;

      for (var vote in userVotes.values) {
        switch (vote) {
          case "1": homeVotes++; break;
          case "2": awayVotes++; break;
        }
      }

      int totalVotes = homeVotes + awayVotes;
      if (totalVotes == 0) return [0, 0];

      return [
        homeVotes / totalVotes * 100,
        awayVotes / totalVotes * 100,
      ];
    }
    return [];
  }

  // --- 5. ΑΓΑΠΗΜΕΝΑ (Favorites) ---

  Future<bool> isFavouriteTeam(String teamName) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: globalUser.username)
        .where("Favourite Teams Basket", arrayContains: teamName) // ΔΙΟΡΘΩΘΗΚΕ ΑΠΟ 'Favourite Teams'
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
}