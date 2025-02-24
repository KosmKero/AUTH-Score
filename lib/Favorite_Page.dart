import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/main.dart';
import 'Match.dart';
import 'Team.dart';
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
          child: DropdownButton<Team>(
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
              }),
        ),
        Expanded(
          flex: 10,
          child: matchesContainer(
            matches: teamMatches,
          ),
        ),
      ],
    );
  }

  List<Match> refreshList() {
    teamMatches.clear();
    for (Match match in matches) {
      if (match.homeTeam.name == selectedTeam?.name || match.awayTeam.name == selectedTeam?.name) {
        teamMatches.add(match);
      }
    }
    return teamMatches;
  }
}
