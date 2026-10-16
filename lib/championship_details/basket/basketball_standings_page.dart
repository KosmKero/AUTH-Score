import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Data_Classes/basketball/basketMatch.dart';
import '../../Data_Classes/basketball/basketTeam.dart';
import '../../Data_Classes/basketball/basketPlayer.dart'; // ΑΛΛΑΓΗ: Import τον BasketPlayer
import '../../Firebase_Handle/firebase_screen_stats_helper.dart';
import '../../Team_Display_Page_Package/TeamDisplayPage.dart';
import '../../globals.dart';

// ==========================================
// STANDINGS PAGE EIDIKA GIA BASKET
// ==========================================
class BasketballStandingsPage extends StatefulWidget {
  const BasketballStandingsPage(this.seasonYear, this.teamsList, this.seasonMatches, {super.key});

  final int seasonYear;
  final List<basketTeam> teamsList;
  final List<BasketMatch> seasonMatches;

  @override
  State<BasketballStandingsPage> createState() => _BasketballStandingsPageState();
}

class _BasketballStandingsPageState extends State<BasketballStandingsPage> {
  Map<int, List<basketTeam>> sortedGroups = {};

  @override
  void initState() {
    super.initState();
    _calculateAllGroups();
  }

  @override
  void didUpdateWidget(covariant BasketballStandingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seasonYear != widget.seasonYear || oldWidget.seasonMatches != widget.seasonMatches) {
      _calculateAllGroups();
    }
  }

  void _calculateAllGroups() {
    DateTime seasonStart = DateTime(widget.seasonYear, 9, 1);
    DateTime seasonEnd = DateTime(widget.seasonYear + 1, 6, 30);

    List<BasketMatch> validMatches = widget.seasonMatches.where((match) {
      DateTime matchDate = DateTime(match.year, match.month, match.day);
      // ΔΙΟΡΘΩΣΗ ΕΔΩ: Προστέθηκε το isGroupPhase
      return match.isGroupPhase &&
          matchDate.isAfter(seasonStart.subtract(const Duration(days: 1))) &&
          matchDate.isBefore(seasonEnd.add(const Duration(days: 1)));
    }).toList();

    for (int group = 1; group <= 4; group++) {
      List<basketTeam> groupTeams = widget.teamsList.where((team) => team.group == group).toList();

      groupTeams.sort((a, b) {
        if (b.totalPoints != a.totalPoints) {
          return b.totalPoints.compareTo(a.totalPoints);
        }
        // Ισοβαθμία: Διαφορά πόντων
        int overallGD = b.pointsDifference.compareTo(a.pointsDifference);
        if (overallGD != 0) return overallGD;
        // Καλύτερη Επίθεση
        return b.pointsFor.compareTo(a.pointsFor);
      });

      sortedGroups[group] = groupTeams;
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Basket Standings', screenClass: 'Basket Standings');
    final isDark = darkModeNotifier.value;
    final screenWidth = MediaQuery.of(context).size.width;

    return Expanded(
      child: Container(
        color: isDark ? const Color(0xFF121212) : lightModeBackGround,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
              Text(greek ? "Βαθμολογικός Πίνακας" : "Standings Table",
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    fontFamily: 'Arial',
                  )),
              SizedBox(height: 10),
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
      ),
    );
  }

  Widget buildGroupStandings(int group, List<basketTeam> groupTeams) {
    final isDark = darkModeNotifier.value;
    final textColor = isDark ? Colors.white : Colors.black87;
    final headerTextColor = isDark ? Colors.white54 : Colors.black54;

    Widget statCell(String text, double width, {bool isBold = false, Color? color}) {
      return SizedBox(
        width: width,
        child: Center(
          child: Text(text, style: TextStyle(fontSize: 13.0, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: color ?? textColor, fontFamily: 'Arial')),
        ),
      );
    }

    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
              child: Text(greek ? "Όμιλος $group" : "Group $group", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.black12))),
              child: Row(
                children: [
                  SizedBox(width: 26, child: Center(child: Text("#", style: TextStyle(color: headerTextColor, fontSize: 11, fontWeight: FontWeight.bold)))),
                  const SizedBox(width: 32),
                  Expanded(child: Text(greek ? "ΟΜΑΔΑ" : "TEAM", style: TextStyle(color: headerTextColor, fontSize: 11, fontWeight: FontWeight.bold))),
                  statCell(greek ? "ΑΓ" : "P", 28, color: headerTextColor),
                  statCell(greek ? "Ν" : "W", 28, color: headerTextColor),
                  statCell(greek ? "Η" : "L", 28, color: headerTextColor),
                  statCell(greek ? "ΠΟΝ" : "PTS", 46, color: headerTextColor),
                  statCell(greek ? "ΒΑΘ" : "PTS", 32, color: headerTextColor, isBold: true),
                ],
              ),
            ),
            ...List.generate(groupTeams.length, (index) {
              final team = groupTeams[index];
              return Container(
                color: index % 2 == 0 ? (isDark ? const Color(0xFF2D2D2D) : const Color.fromARGB(255, 235, 243, 255)) : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 26,
                      child: Center(child: Text((index + 1).toString(), style: TextStyle(color: headerTextColor, fontWeight: FontWeight.bold, fontSize: 12))),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(width: 24, height: 24, child: team.image),
                    const SizedBox(width: 8),
                    Expanded(child: Text(team.name, style: TextStyle(fontWeight: FontWeight.w600, color: textColor, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    statCell(team.totalGames.toString(), 28),
                    statCell(team.wins.toString(), 28),
                    statCell(team.losses.toString(), 28),
                    statCell("${team.pointsFor}:${team.pointsAgainst}", 46),
                    statCell(team.totalPoints.toString(), 32, isBold: true, color: isDark ? Colors.lightBlueAccent : Colors.blue.shade700),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// TOP PLAYERS EIDIKA GIA BASKET
// ==========================================
class BasketballTopPlayersPage extends StatelessWidget {
  const BasketballTopPlayersPage(this.playersList, {super.key});

  // ΔΙΟΡΘΩΣΗ ΕΔΩ: BasketPlayer αντί για Player
  final List<BasketPlayer> playersList;

  String getPositionName(int pos) {
    if (pos == 1) return "Playmaker";
    if (pos == 2) return "Guard";
    if (pos == 3) return "Forward";
    if (pos == 4) return "Center";
    return "Άγνωστο";
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = darkModeNotifier.value;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark ? [const Color(0xFF1E1E1E), const Color(0xFF121212)] : [lightModeBackGround, lightModeBackGround.withValues(alpha: 0.8)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.sports_basketball, color: isDark ? Colors.white : Colors.black, size: 20),
                    const SizedBox(width: 8),
                    Text(greek ? "Πρώτοι Σκόρερ" : "Top Scorers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, fontFamily: "Arial")),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: playersList.length > 15 ? 15 : playersList.length,
                  itemBuilder: (context, index) {
                    final player = playersList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text("${index + 1}.", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${player.name} ${player.surname}", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600)),
                                Text(getPositionName(player.position), style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12)),
                              ],
                            ),
                          ),
                          // ΔΙΟΡΘΩΣΗ ΕΔΩ: player.points αντί για player.goals
                          Text(player.points.toString() + " PTS", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}