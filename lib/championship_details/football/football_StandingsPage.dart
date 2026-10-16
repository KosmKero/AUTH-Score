import 'package:flutter/material.dart';
import 'package:untitled1/Team_Display_Page_Package/TeamDisplayPage.dart';

import '../../Data_Classes/MatchDetails.dart';
import '../../Data_Classes/Team.dart';
import '../../Firebase_Handle/firebase_screen_stats_helper.dart';
import '../../appTheme_colors.dart';
import '../../globals.dart';
import '../../main.dart';
// Φρόντισε να κάνεις import το αρχείο με το AppTheme σου!
// import '../../appTheme_colors.dart';

class StandingsPage extends StatefulWidget {
  const StandingsPage(this.seasonYear, this.teamsList, this.seasonMatches, {super.key});

  final int seasonYear;
  final List<Team> teamsList;
  final List<MatchDetails> seasonMatches;

  @override
  State<StandingsPage> createState() => StandingsPage1();
}

class StandingsPage1 extends State<StandingsPage> {
  Map<int, List<Team>> sortedGroups = {};

  late List<Team> localTeams;
  late List<MatchDetails> localMatches;

  @override
  void initState() {
    super.initState();
    localTeams = List.from(widget.teamsList);
    localMatches = List.from(widget.seasonMatches);
    _calculateAllGroups();
  }

  @override
  void didUpdateWidget(covariant StandingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seasonYear != widget.seasonYear ||
        oldWidget.seasonMatches != widget.seasonMatches) {
      localTeams = List.from(widget.teamsList);
      localMatches = List.from(widget.seasonMatches);
      _calculateAllGroups();
    }
  }

  void _calculateAllGroups() {
    topTeams.clear();

    for (int group = 1; group <= 4; group++) {
      // 1. Φιλτράρισμα ομάδων ανά όμιλο
      List<Team> groupTeams = localTeams.where((team) => team.group == group).toList();

      // 2. Ταξινόμηση αποκλειστικά βάσει της έτοιμης θέσης (ισχύει για φέτος και πέρυσι)
      groupTeams.sort((a, b) => a.position.compareTo(b.position));

      // 3. Αποθήκευση στο Map και στην global λίστα
      sortedGroups[group] = groupTeams;
      topTeams.addAll(groupTeams.take(4));
    }

    if (mounted) {
      setState(() {});
    }
  }


  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Standings Page', screenClass: 'Standings Page');

    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                          color: isDark ? Colors.white : Colors.black87,
                          fontFamily: 'Arial',
                        )),
                    SizedBox(height: screenHeight * 0.01),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // ΠΑΙΡΝΟΥΜΕ ΤΑ ΧΡΩΜΑΤΑ ΑΠΟ ΤΟ APP THEME
    final Color rowColor1 = isDark ? AppTheme.tableRowDark1 : AppTheme.tableRowLight1;
    final Color rowColor2 = isDark ? AppTheme.tableRowDark2 : AppTheme.tableRowLight2;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color headerTextColor = isDark ? Colors.white54 : Colors.black54;

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
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
              child: Text(
                greek ? "Όμιλος $group" : "Group $group",
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
                  statCell(greek ? "Ι" : "D", statWidth, color: headerTextColor),
                  statCell(greek ? "Η" : "L", statWidth, color: headerTextColor),
                  statCell(greek ? "ΓΚΟΛ" : "GLS", goalsWidth, color: headerTextColor),
                  statCell(greek ? "ΒΑΘ" : "PTS", ptsWidth, color: headerTextColor, isBold: true),
                ],
              ),
            ),

            ...List.generate(groupTeams.length, (index) {
              final team = groupTeams[index];
              final rowColor = index % 2 == 0 ? rowColor1 : rowColor2;
              final isPromotionSpot = index < 4;

              return InkWell(
                onTap: () async {
                  bool? didChange = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TeamDisplayPage(team))
                  );

                  if (didChange == true && mounted) {
                    if (widget.seasonYear == thisYearNow) {
                      localTeams = List.from(teams);
                      localMatches = List.from(previousMatches);
                    }
                    _calculateAllGroups();
                  }
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
                            // ΧΡΩΜΑ ΠΡΟΚΡΙΣΗΣ ΑΠΟ ΤΟ APP THEME
                            decoration: BoxDecoration(color: isDark ? AppTheme.promotionDark : AppTheme.promotionLight, shape: BoxShape.circle),
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
                          team.displayName,
                          style: TextStyle(fontWeight: FontWeight.w600, color: textColor, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      statCell(team.totalGames.toString(), statWidth),
                      statCell(team.wins.toString(), statWidth),
                      statCell(team.draws.toString(), statWidth),
                      statCell(team.losses.toString(), statWidth),
                      statCell("${team.goalsFor}:${team.goalsAgainst}", goalsWidth),

                      // ΠΟΝΤΟΙ - ΧΡΩΜΑ ΑΠΟ ΤΟ APP THEME
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
                    // ΧΡΩΜΑ ΠΡΟΚΡΙΣΗΣ ΣΤΟ ΥΠΟΜΝΗΜΑ ΑΠΟ ΤΟ APP THEME
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.promotionDark : AppTheme.promotionLight,
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