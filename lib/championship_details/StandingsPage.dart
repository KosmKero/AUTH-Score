import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Team_Display_Page_Package/TeamDisplayPage.dart';
import 'package:untitled1/main.dart';

import '../Data_Classes/MatchDetails.dart';
import '../Data_Classes/Team.dart';
import '../globals.dart';

class StandingsPage extends StatefulWidget {
  StandingsPage(this.seasonYear);
  int seasonYear;
  @override
  State<StandingsPage> createState() => StandingsPage1();
}

class StandingsPage1 extends State<StandingsPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = darkModeNotifier.value;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Expanded(
      child: Container(
        color: isDark ? Color(0xFF121212) : lightModeBackGround,
        child: Column(children: [
          SizedBox(height: screenHeight * 0.01),
          Text(greek?"Βαθμολογικός Πίνακας":"Standings Table",
              style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.white,
                  fontFamily: 'Arial',
              )),
          SizedBox(height: screenHeight * 0.01),
          Expanded(
              child: SingleChildScrollView(
                  child: Column(
                    children: [
                      buildGroupStandings(1),
                      buildGroupStandings(2),
                      buildGroupStandings(3),
                      buildGroupStandings(4)
                    ],
                  )))
        ]),
      ),
    );
  }

  Widget buildGroupStandings(int group) {
    final isDark = darkModeNotifier.value;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
    topTeams.addAll(groupTeams.take(4));

    final Color rowColor1 = isDark ? Color.fromARGB(255, 55, 55, 55) : Color.fromARGB(255, 235, 244, 255);
    final Color rowColor2 = isDark ? Color.fromARGB(255, 45, 45, 45) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color headerTextColor = isDark ? Colors.white70 : Colors.black54;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenHeight * 0.01
      ),
      elevation: isDark ? 2 : 4,
      color: isDark ? Color.fromARGB(255, 50, 50, 50) : Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.02,
          vertical: screenHeight * 0.01
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greek ? "Όμιλος $group" : "Group $group",
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: screenHeight * 0.005),
            LayoutBuilder(
              builder: (context, constraints) {
                // Calculate column widths based on available space
                final availableWidth = constraints.maxWidth;
                final positionWidth = availableWidth * 0.065;
                final teamWidth = availableWidth * 0.39;
                final statsWidth = availableWidth * 0.085;
                final pointsWidth = availableWidth * 0.12;



                return DataTable(
                  columnSpacing: 0,
                  headingRowHeight: screenHeight * 0.05,
                  dataRowHeight: screenHeight * 0.07,
                  headingTextStyle: TextStyle(
                    color: headerTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.03,
                  ),
                  dataTextStyle: TextStyle(
                    color: textColor,
                    fontSize: screenWidth * 0.03,
                  ),
                  columns: [
                    DataColumn(
                      label: Container(
                        width: positionWidth,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "  #",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: headerTextColor,
                            fontSize: screenWidth * 0.03,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        width: teamWidth,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          greek ? "Ομάδα" : "Team",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: headerTextColor,
                            fontSize: screenWidth * 0.03,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        width: statsWidth,
                        child: Center(
                          child: Text(
                            greek ? "Π" : "G",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: headerTextColor,
                              fontSize: screenWidth * 0.03,
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        width: statsWidth,
                        child: Center(
                          child: Text(
                            greek ? "Ν" : "W",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: headerTextColor,
                              fontSize: screenWidth * 0.03,
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        width: statsWidth,
                        child: Center(
                          child: Text(
                            greek ? "Ι" : "D",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: headerTextColor,
                              fontSize: screenWidth * 0.03,
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        width: statsWidth,
                        child: Center(
                          child: Text(
                            greek ? "Η" : "L",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: headerTextColor,
                              fontSize: screenWidth * 0.03,
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        width: pointsWidth,
                        child: Center(
                          child: Text(
                            greek ? "Πόντοι" : "Points",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: headerTextColor,
                              fontSize: screenWidth * 0.03,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: List<DataRow>.generate(groupTeams.length, (index) {
                    final team = groupTeams[index];
                    final rowColor = index % 2 == 0 ? rowColor1 : rowColor2;
                    final isPromotionSpot = index < 4;

                    return DataRow(
                      color: WidgetStateProperty.all(rowColor),
                      cells: [
                        DataCell(
                          Container(
                            width: positionWidth,
                            alignment: Alignment.centerLeft,
                            child: isPromotionSpot
                                ? Container(
                                    width: screenWidth * 0.06,
                                    height: screenWidth * 0.06,
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.green.shade700 : Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        (index + 1).toString(),
                                        style: TextStyle(
                                          color: isDark ? Colors.white : Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenWidth * 0.03,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: screenWidth * 0.06,
                                    height: screenWidth * 0.06,
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.grey.shade700 : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        (index + 1).toString(),
                                        style: TextStyle(
                                          color: isDark ? Colors.white : Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenWidth * 0.03,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: teamWidth,
                            alignment: Alignment.centerLeft,
                            child: TextButton(
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
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: statsWidth,
                            child: Center(
                              child: Text(
                                team.totalGames.toString(),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: screenWidth * 0.03,
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: statsWidth,
                            child: Center(
                              child: Text(
                                team.wins.toString(),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: screenWidth * 0.03,
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: statsWidth,
                            child: Center(
                              child: Text(
                                team.draws.toString(),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: screenWidth * 0.03,
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: statsWidth,
                            child: Center(
                              child: Text(
                                team.losses.toString(),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: screenWidth * 0.03,
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: pointsWidth,
                            child: Center(
                              child: Text(
                                team.totalPoints.toString(),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: screenWidth * 0.03,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                );
              },
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              greek ? "Οι 4 πρώτοι περνούν στην επόμενη φάση." : "Top 4 teams advance to the next round.",
              style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.white70 : Colors.black54
              ),
            ),
          ],
        ),
      ),
    );
  }
}
