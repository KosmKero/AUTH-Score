import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Data_Classes/MatchDetails.dart';

import '../Data_Classes/Team.dart';
import '../globals.dart';
import '../main.dart';
import 'TeamDisplayPage.dart';

class OneGroupStandings extends StatefulWidget {
  OneGroupStandings({super.key,required this.group,required this.seasonYear});
  int group;
  int seasonYear;

  @override
  State<OneGroupStandings> createState() => _OneGroupStandingsState();
}

class _OneGroupStandingsState extends State<OneGroupStandings> {
  @override
  Widget build(BuildContext context) {
    return _buildGroupStandings(widget.group);
  }

  Widget _buildGroupStandings(int group) {
    // Φιλτράρισμα και ταξινόμηση ομάδων του ομίλου
    List<Team> groupTeams = teams
        .where((team) => team.group == group)
        .toList();

    DateTime seasonStart = DateTime(widget.seasonYear, 9, 1);
    DateTime seasonEnd = DateTime(widget.seasonYear + 1, 6, 30);

    List<MatchDetails> validMatches = previousMatches.where((match) {
      DateTime matchDate = DateTime(match.year, match.month, match.day);
      return match.isGroupPhase &&
          matchDate.isAfter(seasonStart.subtract(Duration(days: 1))) &&
          matchDate.isBefore(seasonEnd.add(Duration(days: 1)));
    }).toList();


    groupTeams.sort((a, b) {
      int pointsCompare = b.totalPoints.compareTo(a.totalPoints);
      if (pointsCompare != 0) return pointsCompare;

      // Βρες ομάδες με ίδιους βαθμούς
      List<Team> tiedTeams = groupTeams
          .where((t) => t.totalPoints == a.totalPoints)
          .toList();

      if (!tiedTeams.any((t) => t.name == b.name)) {
        // Αν το b δεν είναι καν στην ισοβαθμία, δεν έχει νόημα tie-breaker
        return 0;
      }



      // Αν η ισοβαθμία είναι πάνω από 2 ομάδες
      if (tiedTeams.length > 2) {
        Map<String, int> teamPoints = {
          for (var t in tiedTeams) t.name: 0,
        };

        for (var match in validMatches) {
          if (teamPoints.containsKey(match.homeTeam.name) &&
              teamPoints.containsKey(match.awayTeam.name)) {
            if (match.scoreHome > match.scoreAway) {
              teamPoints[match.homeTeam.name] = teamPoints[match.homeTeam.name]! + 3;
            } else if (match.scoreHome == match.scoreAway) {
              teamPoints[match.homeTeam.name] = teamPoints[match.homeTeam.name]! + 1;
              teamPoints[match.awayTeam.name] = teamPoints[match.awayTeam.name]! + 1;
            } else {
              teamPoints[match.awayTeam.name] = teamPoints[match.awayTeam.name]! + 3;
            }
          }
        }

        int multiCompare = teamPoints[b.name]!.compareTo(teamPoints[a.name]!);
        if (multiCompare != 0) return multiCompare;
      } else {
        // Αν είναι μόνο δύο ομάδες
        final headToHead = validMatches.where((match) =>
        (match.homeTeam.name == a.name && match.awayTeam.name == b.name) ||
            (match.homeTeam.name == b.name && match.awayTeam.name == a.name)
        );

        int aPoints = 0;
        int bPoints = 0;

        for (var match in headToHead) {
          if (match.homeTeam.name == a.name) {
            if (match.scoreHome > match.scoreAway) aPoints += 3;
            else if (match.scoreHome == match.scoreAway) {
              aPoints += 1;
              bPoints += 1;
            } else bPoints += 3;
          } else {
            if (match.scoreAway > match.scoreHome) aPoints += 3;
            else if (match.scoreAway == match.scoreHome) {
              aPoints += 1;
              bPoints += 1;
            } else bPoints += 3;
          }
        }

        int headToHeadCompare = bPoints.compareTo(aPoints);
        if (headToHeadCompare != 0) return headToHeadCompare;
      }

      // Τελευταίο κριτήριο: διαφορά τερμάτων
      return b.goalDifference.compareTo(a.goalDifference);
    });


    // Προσθήκη των πρώτων 4 στην λίστα με τις topTeams
    topTeams.addAll(groupTeams.take(4));

    // Εναλλασσόμενα χρώματα γραμμών
    final Color rowColor1 = darkModeNotifier.value ? Color(0xFF2D2D2D) : Color.fromARGB(255, 214, 230, 255);
    final Color rowColor2 = darkModeNotifier.value ? Color(0xFF1E1E1E) : Colors.white;

    return Card(
      color: darkModeNotifier.value ? Color(0xFF1E1E1E) : Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greek ? "Όμιλος $group" : "Group $group",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkModeNotifier.value ? Colors.white : Colors.black
              ),
            ),
            const SizedBox(height: 4),
            DataTable(
              columnSpacing: 20.0,
              headingRowHeight: 40.0,
              dataRowHeight: 60.0,
              headingTextStyle: TextStyle(
                  color: darkModeNotifier.value ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold
              ),
              dataTextStyle: TextStyle(
                  color: darkModeNotifier.value ? Colors.white : Colors.black
              ),
              columns: [
                _buildColumn("  #", numeric: false),
                _buildColumn(greek ? "Ομάδα" : "Team"),
                _buildColumn(greek ? "Π" : "G", numeric: true),
                _buildColumn(greek ? "Ν" : "W", numeric: true),
                _buildColumn(greek ? "Ι" : "D", numeric: true),
                _buildColumn(greek ? "Η" : "L", numeric: true),
                DataColumn(
                  label: Center(
                    child: Text(
                      greek ? "Πόντοι" : "Points",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: darkModeNotifier.value ? Colors.white : Colors.black
                      ),
                    ),
                  ),
                  numeric: true,
                ),
              ],
              rows: List<DataRow>.generate(groupTeams.length, (index) {
                final team = groupTeams[index];
                final rowColor = index % 2 == 0 ? rowColor1 : rowColor2;
                final isPromotionSpot = index < 4;

                return DataRow(
                  color: MaterialStateProperty.all(rowColor),
                  cells: [
                    DataCell(
                      isPromotionSpot
                          ? Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            (index + 1).toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: darkModeNotifier.value ? Colors.grey[700] : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(
                              color: darkModeNotifier.value ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataCell(TextButton(
                      onPressed: () async {
                        if (!mounted) return;
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TeamDisplayPage(team)),
                        );
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      child: Text(
                        team.name,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: darkModeNotifier.value ? Colors.white : Colors.black
                        ),
                      ),
                    )),
                    DataCell(Text(
                      team.totalGames.toString(),
                      style: TextStyle(
                          color: darkModeNotifier.value ? Colors.white : Colors.black
                      ),
                    )),
                    DataCell(Text(
                      team.wins.toString(),
                      style: TextStyle(
                          color: darkModeNotifier.value ? Colors.white : Colors.black
                      ),
                    )),
                    DataCell(Text(
                      team.draws.toString(),
                      style: TextStyle(
                          color: darkModeNotifier.value ? Colors.white : Colors.black
                      ),
                    )),
                    DataCell(Text(
                      team.losses.toString(),
                      style: TextStyle(
                          color: darkModeNotifier.value ? Colors.white : Colors.black
                      ),
                    )),
                    DataCell(
                      Center(
                        child: Text(
                          team.totalPoints.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: darkModeNotifier.value ? Colors.white : Colors.black
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              greek ? "Οι 4 πρώτοι περνούν στην επόμενη φάση." : "Top 4 teams advance to the next round.",
              style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: darkModeNotifier.value ? Colors.white70 : Colors.black54
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataColumn _buildColumn(String label, {bool numeric = false}) {
    return DataColumn(
      label: Center(
        child: Text(
          label,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: darkModeNotifier.value ? Colors.white : Colors.black
          ),
        ),
      ),
      numeric: numeric,
    );
  }
}
