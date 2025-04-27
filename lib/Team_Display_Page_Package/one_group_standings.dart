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

    final isDark = darkModeNotifier.value;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Εναλλασσόμενα χρώματα γραμμών
    final Color rowColor1 = isDark ? Color(0xFF2D2D2D) : Color.fromARGB(255, 214, 230, 255);
    final Color rowColor2 = isDark ? Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color headerTextColor = isDark ? Colors.white70 : Colors.black54;

    return Card(
      color: isDark ? Color(0xFF1E1E1E) : Colors.white,
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.01,
        vertical: screenHeight * 0.01
      ),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.01,
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
                color: textColor
              ),
            ),
            SizedBox(height: screenHeight * 0.005),
            LayoutBuilder(
              builder: (context, constraints) {
                // Calculate column widths based on available space
                final availableWidth = constraints.maxWidth;
                final positionWidth = availableWidth * 0.09;
                final logoWidth = availableWidth * 0.06;
                final teamWidth = availableWidth * 0.385;
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
                        alignment: Alignment.center,
                        child: Text(
                          "#",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: headerTextColor,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        width: teamWidth,
                        alignment: Alignment.center,
                        child: Text(
                          greek ? "Ομάδα" : "Team",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: headerTextColor,
                            fontSize: screenWidth * 0.034,
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
                              fontSize: screenWidth * 0.033,
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
                              fontSize: screenWidth * 0.032,
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
                              fontSize: screenWidth * 0.032,
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
                              fontSize: screenWidth * 0.032,
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
                              fontSize: screenWidth * 0.032,
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
                      color: MaterialStateProperty.all(rowColor),
                      cells: [
                        DataCell(
                          Container(
                            width: positionWidth,
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(right: screenWidth * 0.01),
                            child: isPromotionSpot
                                ? Container(
                                    width: screenWidth *  0.07,
                                    height: screenWidth * 0.07,
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.green.shade700 : Colors.green,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: isDark ? Colors.black26 : Colors.green.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        (index + 1).toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenWidth * 0.033,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: screenWidth *  0.07,
                                    height: screenWidth * 0.07,
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        (index + 1).toString(),
                                        style: TextStyle(
                                          color: isDark ? Colors.white70 : Colors.black54,
                                          fontWeight: FontWeight.w500,
                                          fontSize: screenWidth * 0.033,
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
                              child: Row(
                                children: [
                                  Container(
                                    width:  screenWidth * 0.06,
                                    height: screenWidth * 0.06,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark ? Colors.grey.shade800 : Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: team.image,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Flexible(
                                    child: Text(
                                      team.name,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.029,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            //width: statsWidth,
                            child: Center(
                              child: Text(
                                team.totalGames.toString(),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: screenWidth * 0.034,
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            //width: statsWidth,
                            child: Center(
                              child: Text(
                                team.wins.toString(),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: screenWidth * 0.034,
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            //width: statsWidth,
                            child: Center(
                              child: Text(
                                team.draws.toString(),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: screenWidth * 0.034,
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            //width: statsWidth,
                            child: Center(
                              child: Text(
                                team.losses.toString(),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: screenWidth * 0.034,
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            //width: pointsWidth,
                            child: Center(
                              child: Text(
                                team.totalPoints.toString(),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: screenWidth * 0.034,
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
