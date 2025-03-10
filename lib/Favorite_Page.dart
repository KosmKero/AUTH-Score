import 'package:flutter/material.dart';
import 'package:untitled1/API/Match_Handle.dart';
import 'package:untitled1/main.dart';
import 'Data_Classes/Match.dart';
import 'Data_Classes/Team.dart';
import 'matchesContainer.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoriteContainerState();
}

class _FavoriteContainerState extends State<FavoritePage> {
  late List<Match> teamMatches = [];
  Team? selectedTeam;

  @override
  void initState() {
    super.initState();
    if (favouriteTeams.isNotEmpty) {
      selectedTeam = favouriteTeams[0];
      refreshList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child:  favouriteTeams.isNotEmpty ? DropdownButton<Team>(
              value: selectedTeam,
              items: favouriteTeams.map<DropdownMenuItem<Team>>((Team team) {
                return DropdownMenuItem<Team>(
                  value: team,
                  child: Text(team.name), // Χρήση του πεδίου name
                );
              }).toList(),
              onChanged: (Team? newValue) {
                setState(() {

                  selectedTeam = newValue; // Ενημέρωση του επιλεγμένου παίκτη
                  refreshList();
                });
              }) : SizedBox.shrink(),
        ),
        Expanded(
          flex: 10,
          child: favouriteTeams.isNotEmpty ? matchesContainer(
            matches: teamMatches ,
          ) : Center(child: Text("Δεν έχεις ακόμα αγαπημένες ομάδες",style:  TextStyle(fontSize: 25,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
        ),
      ],
    );
  }

  List<Match> refreshList() {
    teamMatches.clear();
    if (favouriteTeams.isNotEmpty) {
        for (Match match in MatchHandle().getAllMatches()) {
          if (match.homeTeam.name == selectedTeam?.name ||
              match.awayTeam.name == selectedTeam?.name) {
            teamMatches.add(match);
          }
        }

    }
    return teamMatches;
  }
}
