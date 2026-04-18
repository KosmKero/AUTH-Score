import 'package:flutter/material.dart';
import 'package:untitled1/Team_Display_Page_Package/TeamDisplayPage.dart';

import '../Data_Classes/MatchDetails.dart';
import '../Data_Classes/Team.dart';
import '../Firebase_Handle/firebase_screen_stats_helper.dart';
import '../globals.dart';

class StandingsPage extends StatefulWidget {
  //Προσθέσαμε τα seasonMatches στον Constructor
  const StandingsPage(this.seasonYear, this.teamsList, this.seasonMatches, {super.key});

  final int seasonYear;
  final List<Team> teamsList;
  final List<MatchDetails> seasonMatches;

  @override
  State<StandingsPage> createState() => StandingsPage1();
}

class StandingsPage1 extends State<StandingsPage> {
  //Εδώ θα κρατάμε έτοιμους τους υπολογισμένους ομίλους (1 έως 4)
  Map<int, List<Team>> sortedGroups = {};

  @override
  void initState() {
    super.initState();
    // Οι υπολογισμοί γίνονται μια φορά όταν ανοίγει η οθόνη!
    _calculateAllGroups();
  }

  @override
  void didUpdateWidget(covariant StandingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Αν το Dropdown έστειλε άλλη χρονιά ή νέα ματς, κάνε ξανά τα μαθηματικά!
    if (oldWidget.seasonYear != widget.seasonYear ||
        oldWidget.seasonMatches != widget.seasonMatches) {
      _calculateAllGroups();
    }
  }

  void _calculateAllGroups() {
    DateTime seasonStart = DateTime(widget.seasonYear, 9, 1);
    DateTime seasonEnd = DateTime(widget.seasonYear + 1, 6, 30);

    List<MatchDetails> validMatches = widget.seasonMatches.where((match) {
      DateTime matchDate = DateTime(match.year, match.month, match.day);
      return match.isGroupPhase &&
          matchDate.isAfter(seasonStart.subtract(const Duration(days: 1))) &&
          matchDate.isBefore(seasonEnd.add(const Duration(days: 1)));
    }).toList();

    // Καθαρίζουμε την global λίστα για να μην έχουμε ποτέ διπλότυπα
    topTeams.clear();

    // Για κάθε όμιλο (1 έως 4), κάνουμε την ταξινόμηση
    for (int group = 1; group <= 4; group++) {
      List<Team> groupTeams = widget.teamsList.where((team) => team.group == group).toList();

      groupTeams.sort((a, b) {
        int pointsCompare = b.totalPoints.compareTo(a.totalPoints);
        if (pointsCompare != 0) return pointsCompare;

        List<Team> tiedTeams = groupTeams.where((t) => t.totalPoints == a.totalPoints).toList();

        if (!tiedTeams.any((t) => t.name == b.name)) return 0;

        if (tiedTeams.length > 2) {
          Map<String, int> teamPoints = { for (var t in tiedTeams) t.name: 0 };

          for (var match in validMatches) {
            if (teamPoints.containsKey(match.homeTeam.name) && teamPoints.containsKey(match.awayTeam.name)) {
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
          final headToHead = validMatches.where((match) =>
          (match.homeTeam.name == a.name && match.awayTeam.name == b.name) ||
              (match.homeTeam.name == b.name && match.awayTeam.name == a.name));

          int aPoints = 0;
          int bPoints = 0;

          for (var match in headToHead) {
            if (match.homeTeam.name == a.name) {
              if (match.scoreHome > match.scoreAway) {
                aPoints += 3;
              } else if (match.scoreHome == match.scoreAway) { aPoints += 1; bPoints += 1; }
              else {
                bPoints += 3;
              }
            } else {
              if (match.scoreAway > match.scoreHome) {
                aPoints += 3;
              } else if (match.scoreAway == match.scoreHome) { aPoints += 1; bPoints += 1; }
              else {
                bPoints += 3;
              }
            }
          }

          int headToHeadCompare = bPoints.compareTo(aPoints);
          if (headToHeadCompare != 0) return headToHeadCompare;
        }

        return b.goalDifference.compareTo(a.goalDifference);
      });

      // Αποθηκεύουμε τον ταξινομημένο όμιλο στο Map
      sortedGroups[group] = groupTeams;

      // Προσθέτουμε τους πρώτους 4 στην global λίστα
      topTeams.addAll(groupTeams.take(4));
    }

    // Ενημερώνουμε το UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Standings Page', screenClass: 'Standings Page');

    final isDark = darkModeNotifier.value;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Expanded(
      child: Container(
        color: isDark ? const Color(0xFF121212) : lightModeBackGround,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.01),
                    Text(greek ? "Βαθμολογικός Πίνακας" : "Standings Table",
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87, // Διόρθωσα το color στο light mode
                          fontFamily: 'Arial',
                        )),
                    SizedBox(height: screenHeight * 0.01),
                    // 3. Περιμένουμε να γίνει ο υπολογισμός πριν ζωγραφίσουμε
                    if (sortedGroups.isNotEmpty) ...[
                      buildGroupStandings(1, sortedGroups[1]!),
                      buildGroupStandings(2, sortedGroups[2]!),
                      buildGroupStandings(3, sortedGroups[3]!),
                      buildGroupStandings(4, sortedGroups[4]!)
                    ] else
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Η συνάρτηση δέχεται έτοιμη τη λίστα και μόνο ζωγραφίζει!
  Widget buildGroupStandings(int group, List<Team> groupTeams) {
    final isDark = darkModeNotifier.value;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final Color rowColor1 = isDark ? const Color(0xFF2D2D2D) : const Color.fromARGB(255, 214, 230, 255);
    final Color rowColor2 = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color headerTextColor = isDark ? Colors.white70 : Colors.black54;

    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01, vertical: screenHeight * 0.01),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01, vertical: screenHeight * 0.01),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greek ? "Όμιλος $group" : "Group $group",
              style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, color: textColor),
            ),
            SizedBox(height: screenHeight * 0.005),

            // Οριζόντιο Scroll για να μην σκάει σε μικρά κινητά
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Χρησιμοποιούμε μια σταθερή μικρή αφετηρία αν τα constraints είναι άπειρα (λόγω scrollview)
                  final availableWidth = screenWidth * 0.95;
                  final positionWidth = availableWidth * 0.09;
                  final teamWidth = availableWidth * 0.385;
                  final statsWidth = availableWidth * 0.085;
                  final pointsWidth = availableWidth * 0.12;

                  return DataTable(
                    columnSpacing: 0,
                    headingRowHeight: screenHeight * 0.05,
                    dataRowHeight: screenHeight * 0.07,
                    headingTextStyle: TextStyle(color: headerTextColor, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.03),
                    dataTextStyle: TextStyle(color: textColor, fontSize: screenWidth * 0.03),
                    columns: [
                      DataColumn(label: Container(width: positionWidth, alignment: Alignment.center, child: Text("#", style: TextStyle(fontWeight: FontWeight.bold, color: headerTextColor, fontSize: screenWidth * 0.04)))),
                      DataColumn(label: Container(alignment: Alignment.centerLeft, child: Text(greek ? "  Ομάδα" : "  Team", style: TextStyle(fontWeight: FontWeight.bold, color: headerTextColor, fontSize: screenWidth * 0.034)))),
                      DataColumn(label: SizedBox(width: statsWidth, child: Center(child: Text(greek ? "Π" : "G", style: TextStyle(fontWeight: FontWeight.bold, color: headerTextColor, fontSize: screenWidth * 0.033))))),
                      DataColumn(label: SizedBox(width: statsWidth, child: Center(child: Text(greek ? "Ν" : "W", style: TextStyle(fontWeight: FontWeight.bold, color: headerTextColor, fontSize: screenWidth * 0.032))))),
                      DataColumn(label: SizedBox(width: statsWidth, child: Center(child: Text(greek ? "Ι" : "D", style: TextStyle(fontWeight: FontWeight.bold, color: headerTextColor, fontSize: screenWidth * 0.032))))),
                      DataColumn(label: SizedBox(width: statsWidth, child: Center(child: Text(greek ? "Η" : "L", style: TextStyle(fontWeight: FontWeight.bold, color: headerTextColor, fontSize: screenWidth * 0.032))))),
                      DataColumn(label: SizedBox(width: pointsWidth, child: Center(child: Text(greek ? "Πόντοι" : "Points", style: TextStyle(fontWeight: FontWeight.bold, color: headerTextColor, fontSize: screenWidth * 0.032))))),
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
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(right: screenWidth * 0.01),
                              child: isPromotionSpot
                                  ? Container(
                                width: screenWidth * 0.07, height: screenWidth * 0.07,
                                decoration: BoxDecoration(color: isDark ? Colors.green.shade700 : Colors.green, shape: BoxShape.circle, boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.green.withValues(alpha:0.3), blurRadius: 4, offset: const Offset(0, 2))]),
                                child: Center(child: Text((index + 1).toString(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.033))),
                              )
                                  : Container(
                                width: screenWidth * 0.07, height: screenWidth * 0.07,
                                decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, shape: BoxShape.circle, border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300, width: 1)),
                                child: Center(child: Text((index + 1).toString(), style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.w500, fontSize: screenWidth * 0.033))),
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
                                  await Navigator.push(context, MaterialPageRoute(builder: (context) => TeamDisplayPage(team)));
                                  if (mounted) _calculateAllGroups();
                                },
                                child: Row(
                                  children: [
                                    SizedBox(width: screenWidth * 0.06, height: screenWidth * 0.06, child: team.image),
                                    SizedBox(width: screenWidth * 0.02),
                                    Flexible(child: Text(team.name, style: TextStyle(fontSize: screenWidth * 0.029, fontWeight: FontWeight.w600, color: textColor), softWrap: true, overflow: TextOverflow.visible)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          DataCell(SizedBox(child: Center(child: Text(team.totalGames.toString(), style: TextStyle(color: textColor, fontSize: screenWidth * 0.034))))),
                          DataCell(SizedBox(child: Center(child: Text(team.wins.toString(), style: TextStyle(color: textColor, fontSize: screenWidth * 0.034))))),
                          DataCell(SizedBox(child: Center(child: Text(team.draws.toString(), style: TextStyle(color: textColor, fontSize: screenWidth * 0.034))))),
                          DataCell(SizedBox(child: Center(child: Text(team.losses.toString(), style: TextStyle(color: textColor, fontSize: screenWidth * 0.034))))),
                          DataCell(SizedBox(child: Center(child: Text(team.totalPoints.toString(), style: TextStyle(color: textColor, fontSize: screenWidth * 0.034))))),
                        ],
                      );
                    }),
                  );
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
          ],
        ),
      ),
    );
  }
}