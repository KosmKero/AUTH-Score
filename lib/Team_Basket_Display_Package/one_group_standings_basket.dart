import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/API/BasketballMatchHandle.dart';
import 'package:untitled1/Firebase_Handle/BasketTeamsHandle.dart';

import '../../Data_Classes/basketball/basketMatch.dart';
import '../../Data_Classes/basketball/basketTeam.dart';
import '../../globals.dart';
import '../../main.dart';
import 'Basket_Team_Display_Page.dart';

class BasketballOneGroupStandings extends StatefulWidget {
  BasketballOneGroupStandings({super.key, required this.group, required this.seasonYear});
  final int group;
  final int seasonYear;

  @override
  State<BasketballOneGroupStandings> createState() => _BasketballOneGroupStandingsState();
}

class _BasketballOneGroupStandingsState extends State<BasketballOneGroupStandings> {
  List<basketTeam> sortedGroupTeams = [];

  @override
  void initState() {
    super.initState();
    _calculateStandings();
  }

  void _calculateStandings() {
    // Παίρνουμε τις ομάδες από τη global λίστα του μπάσκετ
    List<basketTeam> groupTeams = basketTeams.where((team) => team.group == widget.group).toList();

    DateTime seasonStart = DateTime(widget.seasonYear, 9, 1);
    DateTime seasonEnd = DateTime(widget.seasonYear + 1, 6, 30);

    // Παίρνουμε τα ματς από τη global λίστα του μπάσκετ
    List<BasketMatch> validMatches = BasketballMatchHandle().getPreviousMatches().where((match) {
      DateTime matchDate = DateTime(match.year, match.month, match.day);
      return match.isGroupPhase &&
          matchDate.isAfter(seasonStart.subtract(const Duration(days: 1))) &&
          matchDate.isBefore(seasonEnd.add(const Duration(days: 1)));
    }).toList();

    String cleanName(String name) => name.trim().toLowerCase();

    groupTeams.sort((a, b) {
      // Κριτήριο 1: Συνολικοί Βαθμοί
      int pointsCompare = b.totalPoints.compareTo(a.totalPoints);
      if (pointsCompare != 0) return pointsCompare;

      // --- ΕΝΑΡΞΗ ΛΟΓΙΚΗΣ ΙΣΟΒΑΘΜΙΑΣ (MINI-LEAGUE) ΜΠΑΣΚΕΤ ---

      List<basketTeam> tiedTeams = groupTeams.where((t) => t.totalPoints == a.totalPoints).toList();

      var miniLeagueMatches = validMatches.where((match) {
        bool isHomeTied = tiedTeams.any((t) => cleanName(t.name) == cleanName(match.homeTeam.name));
        bool isAwayTied = tiedTeams.any((t) => cleanName(t.name) == cleanName(match.awayTeam.name));
        return isHomeTied && isAwayTied;
      }).toList();

      int aH2hPoints = 0;
      int bH2hPoints = 0;

      for (var match in miniLeagueMatches) {
        String homeName = cleanName(match.homeTeam.name);
        String awayName = cleanName(match.awayTeam.name);
        String nameA = cleanName(a.name);
        String nameB = cleanName(b.name);

        // Πόντοι για ομάδα Α (Νίκη = 2, Ήττα = 1)
        if (homeName == nameA) {
          if (match.homeScore > match.awayScore) aH2hPoints += 2;
          else if (match.homeScore < match.awayScore) aH2hPoints += 1;
        } else if (awayName == nameA) {
          if (match.awayScore > match.homeScore) aH2hPoints += 2;
          else if (match.awayScore < match.homeScore) aH2hPoints += 1;
        }

        // Πόντοι για ομάδα Β (Νίκη = 2, Ήττα = 1)
        if (homeName == nameB) {
          if (match.homeScore > match.awayScore) bH2hPoints += 2;
          else if (match.homeScore < match.awayScore) bH2hPoints += 1;
        } else if (awayName == nameB) {
          if (match.awayScore > match.homeScore) bH2hPoints += 2;
          else if (match.awayScore < match.homeScore) bH2hPoints += 1;
        }
      }

      print("Comparing Basket ${a.name} vs ${b.name}: H2H Pts: $aH2hPoints - $bH2hPoints");

      // Κριτήριο 2: Head-to-Head Βαθμοί
      if (bH2hPoints != aH2hPoints) return bH2hPoints.compareTo(aH2hPoints);

      // --- ΤΕΛΟΣ ΛΟΓΙΚΗΣ ΙΣΟΒΑΘΜΙΑΣ ---

      // Κριτήριο 3: Διαφορά Πόντων (Points Difference)
      return b.pointsDifference.compareTo(a.pointsDifference);
    });

    // Ενημέρωση της global λίστας topBasketTeams
    topTeamsBasket.removeWhere((t) => groupTeams.any((g) => g.name == t.name));
    for (var topTeam in groupTeams.take(4)) {
      topTeamsBasket.add(topTeam);
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

    const double posWidth = 26.0;
    const double logoWidth = 24.0;
    const double statWidth = 28.0;
    const double pointsWidth = 46.0;
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
              child: Text(
                greek ? "Όμιλος ${widget.group}" : "Group ${widget.group}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
            const SizedBox(height: 8),

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
                  statCell(greek ? "Η" : "L", statWidth, color: headerTextColor), // Αφαιρέθηκε η Ισοπαλία (D)
                  statCell(greek ? "ΠΟΝ" : "PTS", pointsWidth, color: headerTextColor),
                  statCell(greek ? "ΒΑΘ" : "PTS", ptsWidth, color: headerTextColor, isBold: true),
                ],
              ),
            ),

            ...List.generate(sortedGroupTeams.length, (index) {
              final team = sortedGroupTeams[index];
              final rowColor = index % 2 == 0 ? rowColor1 : rowColor2;
              final isPromotionSpot = index < 4;

              return InkWell(
                onTap: () async {
                  if (!mounted) return;
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => BasketballTeamDisplayPage(team)));
                  if (mounted) _calculateStandings();
                },
                child: Container(
                  color: rowColor,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  child: Row(
                    children: [
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

                      SizedBox(
                        width: logoWidth,
                        height: logoWidth,
                        child: team.image,
                      ),
                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          team.name,
                          style: TextStyle(fontWeight: FontWeight.w600, color: textColor, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      statCell(team.totalGames.toString(), statWidth),
                      statCell(team.wins.toString(), statWidth),
                      statCell(team.losses.toString(), statWidth), // Μόνο Νίκες - Ήττες
                      statCell("${team.pointsFor}:${team.pointsAgainst}", pointsWidth),

                      statCell(team.totalPoints.toString(), ptsWidth, isBold: true, color: isDark ? Colors.lightBlueAccent : Colors.blue.shade700),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.green.shade700 : Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      greek
                          ? "Οι 4 πρώτοι περνούν στην επόμενη φάση"
                          : "Top 4 teams advance to the next round",
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}