import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Data_Classes/MatchDetails.dart';

import '../Data_Classes/Team.dart';
// Βάλε εδώ το σωστό import για την κλάση AppTheme αν είναι αλλού
import '../appTheme_colors.dart';
import '../globals.dart';
import '../main.dart';
// import 'Standings_Preview_Screen.dart';
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
    // 1. Φιλτράρισμα ομάδων του ομίλου
    List<Team> groupTeams = teams.where((team) => team.group == widget.group).toList();

    // 2. Ταξινόμηση αποκλειστικά βάσει της έτοιμης θέσης (1, 2, 3...)
    groupTeams.sort((a, b) => a.position.compareTo(b.position));

    // 3. Ενημέρωση της global λίστας topTeams
    topTeams.removeWhere((t) => groupTeams.any((g) => g.name == t.name));
    for (var topTeam in groupTeams.take(4)) {
      topTeams.add(topTeam);
    }

    // 4. Ενημέρωση UI
    setState(() {
      sortedGroupTeams = groupTeams;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Διαβάζουμε το theme mode από το Flutter αυτόματα
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // ΠΑΙΡΝΟΥΜΕ ΤΑ ΧΡΩΜΑΤΑ ΑΠΟ ΤΟ AppTheme
    final Color rowColor1 = isDark ? AppTheme.tableRowDark1 : AppTheme.tableRowLight1;
    final Color rowColor2 = isDark ? AppTheme.tableRowDark2 : AppTheme.tableRowLight2;
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    greek ? "Όμιλος ${widget.group}" : "Group ${widget.group}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ],
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
                  bool? didChange = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TeamDisplayPage(team))
                  );

                  if (didChange == true && mounted) {
                    _calculateStandings();
                  }
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
                            // ΧΡΩΜΑ ΠΡΟΚΡΙΣΗΣ ΑΠΟ ΤΟ APP THEME
                            decoration: BoxDecoration(color: isDark ? Colors.green.shade700 : AppTheme.promotionGreen, shape: BoxShape.circle),
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
                          greek ? team.displayGreek : team.displayEnglish,
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
                      statCell(
                          team.totalPoints.toString(),
                          ptsWidth,
                          isBold: true,
                          color: isDark ? AppTheme.pointsDark : AppTheme.pointsLight
                      ),
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
                    // ΧΡΩΜΑ ΠΡΟΚΡΙΣΗΣ ΑΠΟ ΤΟ APP THEME (ΓΙΑ ΤΟ ΥΠΟΜΝΗΜΑ)
                    decoration: BoxDecoration(
                      color: isDark ? Colors.green.shade700 : AppTheme.promotionGreen,
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