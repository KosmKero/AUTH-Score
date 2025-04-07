import 'package:flutter/material.dart';
import 'package:untitled1/API/Match_Handle.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';
import 'package:untitled1/main.dart';
import 'Data_Classes/MatchDetails.dart';
import 'Data_Classes/Team.dart';
import 'globals.dart';
import 'matchesContainer.dart';


class FavoritePage extends StatefulWidget
{
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoriteContainerState();
}

class _FavoriteContainerState extends State<FavoritePage> {
  late List<MatchDetails> teamMatches = [];
  Team? selectedTeam;


  Future<void> loadFavouriteTeams() async {
    TeamsHandle teamsHandle = TeamsHandle();
    favouriteTeams = await teamsHandle.getAllFavouriteTeams(globalUser.username);

    if (favouriteTeams.isNotEmpty) {
      selectedTeam = favouriteTeams[0];
      refreshList();
    }

    setState(() {}); // Για να ανανεώσει το UI με τα νέα δεδομένα
  }


  @override
  void initState() {
    super.initState();
    loadFavouriteTeams(); // Καλέι την async μέθοδο
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkModeOn? darkModeBackGround:Colors.white, // Dark mode background
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: favouriteTeams.isNotEmpty
                ? DropdownButton<Team>(
              value: selectedTeam,
              dropdownColor: const Color.fromARGB(255, 48, 48, 48), // Optional: dark dropdown
              style: const TextStyle(color: Colors.white), // Text color in dropdown
              items: favouriteTeams.map<DropdownMenuItem<Team>>((Team team) {
                return DropdownMenuItem<Team>(
                  value: team,
                  child: Text(team.name),
                );
              }).toList(),
              onChanged: (Team? newValue) {
                setState(() {
                  selectedTeam = newValue;
                  refreshList();
                });
              },
            )
                : const SizedBox.shrink(),
          ),
          Expanded(
            flex: 10,
            child: isLoggedIn
                ? (favouriteTeams.isNotEmpty
                ? matchesContainer(matches: teamMatches)
                : Center(
              child: Text(
                greek
                    ? "Δεν έχεις ακόμα αγαπημένες ομάδες"
                    : "You don't have any favorite teams yet",
                style: TextStyle(
                  fontSize: greek ? 23 : 21,
                  fontWeight: FontWeight.bold,
                  color:darkModeOn? Colors.white : Colors.black87, // Text color
                ),
                textAlign: TextAlign.center,
              ),
            ))
                : Center(
              child: Text(
                greek
                    ? "Πρέπει να είσαι συνδεδεμένος για να δείς τις αγαπημένες σου ομάδες"
                    : "You must be signed in to see your favorite teams!",
                style: TextStyle(
                  fontSize: greek ? 23 : 21,
                  fontWeight: FontWeight.bold,
                    color:darkModeOn? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }


  List<MatchDetails> refreshList() {
    teamMatches.clear();
    if (favouriteTeams.isNotEmpty) {
        for (MatchDetails match in MatchHandle().getAllMatches())
        {
          if (match.homeTeam.name == selectedTeam?.name ||
              match.awayTeam.name == selectedTeam?.name) {
            teamMatches.add(match);
          }
        }

    }
    return teamMatches;
  }
}
