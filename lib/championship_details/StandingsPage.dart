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

  Widget buildGroupStandings(int group, List<Team> groupTeams) {
    final isDark = darkModeNotifier.value;
    final screenWidth = MediaQuery.of(context).size.width;

    final Color rowColor1 = isDark ? const Color(0xFF2D2D2D) : const Color.fromARGB(255, 235, 243, 255);
    final Color rowColor2 = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color headerTextColor = isDark ? Colors.white54 : Colors.black54;

    const double posWidth = 26.0;
    const double logoWidth = 24.0;
    const double statWidth = 28.0; // Αντί για 22, για να χωράνε διψήφια άνετα
    const double goalsWidth = 46.0; // Αντί για 38, για το "12:10"
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
      // 🛠️ Αυξήσαμε λίγο το margin για να μην κολλάει το Card στα πλάγια
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ΤΙΤΛΟΣ ΟΜΙΛΟΥ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
              child: Text(
                greek ? "Όμιλος $group" : "Group $group",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
            const SizedBox(height: 8),

            // ΚΕΦΑΛΙΔΑ (Header Row)
            Container(
              // 🛠️ Μεγαλύτερο horizontal padding για να αναπνέει
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
            ...List.generate(groupTeams.length, (index) {
              final team = groupTeams[index];
              final rowColor = index % 2 == 0 ? rowColor1 : rowColor2;
              final isPromotionSpot = index < 4;

              return InkWell(
                onTap: () async {
                  if (!mounted) return;
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => TeamDisplayPage(team)));
                  if (mounted) _calculateAllGroups();
                },
                child: Container(
                  color: rowColor,
                  // 🛠️ Μεγαλύτερο horizontal padding και εδώ
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  child: Row(
                    children: [
                      // Θέση (#)
                      SizedBox(
                        width: posWidth,
                        child: Center(
                          child: isPromotionSpot
                              ? Container(
                            width: 20, height: 20, // 🛠️ Λίγο μεγαλύτερο κυκλάκι
                            decoration: BoxDecoration(color: isDark ? Colors.green.shade700 : Colors.green, shape: BoxShape.circle),
                            child: Center(child: Text((index + 1).toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                          )
                              : Text((index + 1).toString(), style: TextStyle(color: headerTextColor, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 4), // Κενό ανάμεσα σε αριθμό και Logo

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
          ],
        ),
      ),
    );
  }

}