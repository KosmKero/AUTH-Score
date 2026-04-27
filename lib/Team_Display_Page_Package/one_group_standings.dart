import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Data_Classes/MatchDetails.dart';

import '../Data_Classes/Team.dart';
import '../globals.dart';
import '../main.dart';
import 'TeamDisplayPage.dart';

class OneGroupStandings extends StatefulWidget {
  OneGroupStandings({super.key, required this.group, required this.seasonYear});
  int group;
  int seasonYear;

  @override
  State<OneGroupStandings> createState() => _OneGroupStandingsState();
}

class _OneGroupStandingsState extends State<OneGroupStandings> {
  List<Team> sortedGroupTeams = [];

  @override
  void initState() {
    super.initState();
    _calculateStandings();
  }

  void _calculateStandings() {
    List<Team> groupTeams = teams.where((team) => team.group == widget.group).toList();

    DateTime seasonStart = DateTime(widget.seasonYear, 9, 1);
    DateTime seasonEnd = DateTime(widget.seasonYear + 1, 6, 30);

    List<MatchDetails> validMatches = previousMatches.where((match) {
      DateTime matchDate = DateTime(match.year, match.month, match.day);
      return match.isGroupPhase &&
          matchDate.isAfter(seasonStart.subtract(const Duration(days: 1))) &&
          matchDate.isBefore(seasonEnd.add(const Duration(days: 1)));
    }).toList();

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
            if (match.scoreHome > match.scoreAway) aPoints += 3;
            else if (match.scoreHome == match.scoreAway) { aPoints += 1; bPoints += 1; }
            else bPoints += 3;
          } else {
            if (match.scoreAway > match.scoreHome) aPoints += 3;
            else if (match.scoreAway == match.scoreHome) { aPoints += 1; bPoints += 1; }
            else bPoints += 3;
          }
        }
        int headToHeadCompare = bPoints.compareTo(aPoints);
        if (headToHeadCompare != 0) return headToHeadCompare;
      }

      return b.goalDifference.compareTo(a.goalDifference);
    });

    // Ενημέρωση της global λίστας topTeams
    for (var topTeam in groupTeams.take(4)) {
      if (!topTeams.any((t) => t.name == topTeam.name)) {
        topTeams.add(topTeam);
      }
    }

    setState(() {
      sortedGroupTeams = groupTeams;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = darkModeNotifier.value;
    final screenWidth = MediaQuery.of(context).size.width;

    final Color rowColor1 = isDark ? const Color(0xFF2D2D2D) : const Color.fromARGB(255, 235, 243, 255);
    final Color rowColor2 = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color headerTextColor = isDark ? Colors.white54 : Colors.black54;

    // Σταθερά πλάτη για τέλεια στοίχιση
    const double posWidth = 26.0;
    const double logoWidth = 24.0;
    const double statWidth = 28.0;
    const double goalsWidth = 46.0;
    const double ptsWidth = 32.0;

    Widget statCell(String text, double width, {bool isBold = false, Color? color}) {
      return SizedBox(
        width: width,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color ?? textColor,
              fontFamily: 'Arial',
            ),
          ),
        ),
      );
    }

    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Αποτρέπει το overflow
          children: [
            // ΤΙΤΛΟΣ ΟΜΙΛΟΥ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
              child: Text(
                greek ? "Όμιλος ${widget.group}" : "Group ${widget.group}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
            const SizedBox(height: 8),

            // ΚΕΦΑΛΙΔΑ (Header Row)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 1)),
              ),
              child: Row(
                children: [
                  SizedBox(width: posWidth, child: Center(child: Text("#", style: TextStyle(color: headerTextColor, fontSize: 11, fontWeight: FontWeight.bold)))),
                  const SizedBox(width: logoWidth + 8),
                  Expanded(child: Text(greek ? "ΟΜΑΔΑ" : "TEAM", style: TextStyle(color: headerTextColor, fontSize: 11, fontWeight: FontWeight.bold))),
                  statCell(greek ? "ΑΓ" : "P", statWidth, color: headerTextColor),
                  statCell(greek ? "Ν" : "W", statWidth, color: headerTextColor),
                  statCell(greek ? "Ι" : "D", statWidth, color: headerTextColor),
                  statCell(greek ? "Η" : "L", statWidth, color: headerTextColor),
                  statCell(greek ? "ΓΚΟΛ" : "GLS", goalsWidth, color: headerTextColor),
                  statCell(greek ? "ΒΑΘ" : "PTS", ptsWidth, color: headerTextColor, isBold: true),
                ],
              ),
            ),

            // ΛΙΣΤΑ ΟΜΑΔΩΝ
            ...List.generate(sortedGroupTeams.length, (index) {
              final team = sortedGroupTeams[index];
              final rowColor = index % 2 == 0 ? rowColor1 : rowColor2;
              final isPromotionSpot = index < 4;

              return InkWell(
                onTap: () async {
                  if (!mounted) return;
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => TeamDisplayPage(team)));
                  if (mounted) _calculateStandings();
                },
                child: Container(
                  color: rowColor,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  child: Row(
                    children: [
                      // Θέση (#)
                      SizedBox(
                        width: posWidth,
                        child: Center(
                          child: isPromotionSpot
                              ? Container(
                            width: 20, height: 20,
                            decoration: BoxDecoration(color: isDark ? Colors.green.shade700 : Colors.green, shape: BoxShape.circle),
                            child: Center(child: Text((index + 1).toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                          )
                              : Text((index + 1).toString(), style: TextStyle(color: headerTextColor, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Σήμα Ομάδας
                      SizedBox(
                        width: logoWidth,
                        height: logoWidth,
                        child: team.image,
                      ),
                      const SizedBox(width: 8),

                      // Όνομα Ομάδας
                      Expanded(
                        child: Text(
                          team.name,
                          style: TextStyle(fontWeight: FontWeight.w600, color: textColor, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Στατιστικά
                      statCell(team.totalGames.toString(), statWidth),
                      statCell(team.wins.toString(), statWidth),
                      statCell(team.draws.toString(), statWidth),
                      statCell(team.losses.toString(), statWidth),
                      statCell("${team.goalsFor}:${team.goalsAgainst}", goalsWidth),

                      // Πόντοι
                      statCell(team.totalPoints.toString(), ptsWidth, isBold: true, color: isDark ? Colors.lightBlueAccent : Colors.blue.shade700),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),

            // ΥΠΟΣΗΜΕΙΩΣΗ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Text(
                greek ? "Οι 4 πρώτοι περνούν στην επόμενη φάση." : "Top 4 teams advance to the next round.",
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: isDark ? Colors.white70 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}