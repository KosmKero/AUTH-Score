import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Team_Display_Page_Package/TeamDisplayPage.dart';
import 'package:untitled1/main.dart';

import '../Data_Classes/Team.dart';
import '../globals.dart';

class StandingsPage extends StatefulWidget {
  @override
  State<StandingsPage> createState() => StandingsPage1();
}

class StandingsPage1 extends State<StandingsPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = darkModeNotifier.value;
    return Expanded(
      child: Container(
        color: isDark ? Color(0xFF121212) : lightModeBackGround,
        child: Column(children: [
          SizedBox(height: 5,),
          Text(greek?"Βαθμολογικός Πίνακας":"Standings Table",
              style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.white,
                  fontFamily: 'Arial',
              )),
          SizedBox(height: 8,),
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
    List<Team> groupTeams = teams.where((team) => team.group == group).toList()
      ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    topTeams.addAll(groupTeams.take(4));

    final Color rowColor1 = isDark ? Color.fromARGB(255, 55, 55, 55) : Color.fromARGB(255, 235, 244, 255);
    final Color rowColor2 = isDark ? Color.fromARGB(255, 45, 45, 45) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color headerTextColor = isDark ? Colors.white70 : Colors.black54;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
      elevation: isDark ? 2 : 4,
      color: isDark ? Color.fromARGB(255, 50, 50, 50) : Colors.white,
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
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            DataTable(
              columnSpacing: 20.0,
              headingRowHeight: 40.0,
              dataRowHeight: 60.0,
              headingTextStyle: TextStyle(
                color: headerTextColor,
                fontWeight: FontWeight.bold,
              ),
              dataTextStyle: TextStyle(color: textColor),
              columns: [
                _buildColumn("  #", numeric: false, textColor: headerTextColor),
                _buildColumn(greek ? "Ομάδα" : "Team", textColor: headerTextColor),
                _buildColumn(greek ? "Π" : "G", numeric: true, textColor: headerTextColor),
                _buildColumn(greek ? "Ν" : "W", numeric: true, textColor: headerTextColor),
                _buildColumn(greek ? "Ι" : "D", numeric: true, textColor: headerTextColor),
                _buildColumn(greek ? "Η" : "L", numeric: true, textColor: headerTextColor),
                DataColumn(
                  label: Center(
                    child: Text(
                      greek ? "Πόντοι" : "Points",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: headerTextColor,
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
                  color: WidgetStateProperty.all(rowColor),
                  cells: [
                    DataCell(
                      isPromotionSpot
                          ? Container(
                        width: 26,
                        height: 26,
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
                            ),
                          ),
                        ),
                      )
                          : Container(
                        width: 26,
                        height: 26,
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
                      child: Text(team.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    )),
                    DataCell(Text(team.totalGames.toString(), style: TextStyle(color: textColor))),
                    DataCell(Text(team.wins.toString(), style: TextStyle(color: textColor))),
                    DataCell(Text(team.draws.toString(), style: TextStyle(color: textColor))),
                    DataCell(Text(team.losses.toString(), style: TextStyle(color: textColor))),
                    DataCell(
                      Center(
                        child: Text(
                          team.totalPoints.toString(),
                          style: TextStyle(color: textColor),
                          textAlign: TextAlign.center,
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
                  color: isDark ? Colors.white70 : Colors.black54
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataColumn _buildColumn(String label, {bool numeric = false, required Color textColor}) {
    return DataColumn(
      label: Center(
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
      numeric: numeric,
    );
  }
}
