import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Data_Classes/Team.dart';
import '../globals.dart';
import 'TeamDisplayPage.dart';

class OneGroupStandings extends StatefulWidget {
  OneGroupStandings({super.key,required this.group});
  int group;

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
    List<Team> groupTeams = teams.where((team) => team.group == group).toList()
      ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    // Προσθήκη των πρώτων 4 στην λίστα με τις topTeams
    topTeams.addAll(groupTeams.take(4));

    // Εναλλασσόμενα χρώματα γραμμών
    final Color rowColor1 = darkModeNotifier.value ? Color(0xFF2D2D2D) : Color.fromARGB(255, 214, 230, 255);
    final Color rowColor2 = darkModeNotifier.value ? Color(0xFF1E1E1E) : Colors.white;

    return Card(
      color: darkModeNotifier.value ? Color(0xFF1E1E1E) : Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
      elevation: 4,
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
                  color: darkModeNotifier.value ? Colors.white : Colors.black
              ),
            ),
            const SizedBox(height: 4),
            DataTable(
              columnSpacing: 20.0,
              headingRowHeight: 40.0,
              dataRowHeight: 60.0,
              headingTextStyle: TextStyle(
                  color: darkModeNotifier.value ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold
              ),
              dataTextStyle: TextStyle(
                  color: darkModeNotifier.value ? Colors.white : Colors.black
              ),
              columns: [
                _buildColumn("  #", numeric: false),
                _buildColumn(greek ? "Ομάδα" : "Team"),
                _buildColumn(greek ? "Π" : "G", numeric: true),
                _buildColumn(greek ? "Ν" : "W", numeric: true),
                _buildColumn(greek ? "Ι" : "D", numeric: true),
                _buildColumn(greek ? "Η" : "L", numeric: true),
                DataColumn(
                  label: Center(
                    child: Text(
                      greek ? "Πόντοι" : "Points",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: darkModeNotifier.value ? Colors.white : Colors.black
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
                  color: MaterialStateProperty.all(rowColor),
                  cells: [
                    DataCell(
                      isPromotionSpot
                          ? Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            (index + 1).toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: darkModeNotifier.value ? Colors.grey[700] : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(
                              color: darkModeNotifier.value ? Colors.white : Colors.black,
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
                      child: Text(
                        team.name,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: darkModeNotifier.value ? Colors.white : Colors.black
                        ),
                      ),
                    )),
                    DataCell(Text(
                      team.totalGames.toString(),
                      style: TextStyle(
                          color: darkModeNotifier.value ? Colors.white : Colors.black
                      ),
                    )),
                    DataCell(Text(
                      team.wins.toString(),
                      style: TextStyle(
                          color: darkModeNotifier.value ? Colors.white : Colors.black
                      ),
                    )),
                    DataCell(Text(
                      team.draws.toString(),
                      style: TextStyle(
                          color: darkModeNotifier.value ? Colors.white : Colors.black
                      ),
                    )),
                    DataCell(Text(
                      team.losses.toString(),
                      style: TextStyle(
                          color: darkModeNotifier.value ? Colors.white : Colors.black
                      ),
                    )),
                    DataCell(
                      Center(
                        child: Text(
                          team.totalPoints.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: darkModeNotifier.value ? Colors.white : Colors.black
                          ),
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
                  color: darkModeNotifier.value ? Colors.white70 : Colors.black54
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataColumn _buildColumn(String label, {bool numeric = false}) {
    return DataColumn(
      label: Center(
        child: Text(
          label,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: darkModeNotifier.value ? Colors.white : Colors.black
          ),
        ),
      ),
      numeric: numeric,
    );
  }
}
