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
    final Color rowColor1 = Colors.grey.shade200;
    final Color rowColor2 = Colors.white;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greek ? "Όμιλος $group" : "Group $group",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            DataTable(
              columnSpacing: 20.0,
              headingRowHeight: 40.0,
              dataRowHeight: 60.0,
              columns: [
                _buildColumn("  #", numeric: false),
                _buildColumn(greek ? "Ομάδα" : "Team"),
                _buildColumn(greek ? "Π" : "G", numeric: true),
                _buildColumn(greek ? "Ν" : "W", numeric: true),
                _buildColumn(greek ? "Ι" : "D", numeric: true),
                _buildColumn(greek ? "Η" : "L", numeric: true),
                DataColumn(
                  label: Center(  // Κεντραρισμένο κείμενο στην κεφαλίδα
                    child: Text(
                      greek ? "Πόντοι" : "Points",
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
                        decoration: const BoxDecoration(
                          color: Colors.grey,
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
                      ),
                    ),
                    DataCell(TextButton(
                      onPressed: () async {
                        // Πρώτα ελέγχεις αν το widget είναι ακόμη ενεργό (mounted)
                        if (!mounted) return;

                        // Εκτέλεση του Navigator
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TeamDisplayPage(team)),
                        );

                        // Αν το widget είναι ακόμη ενεργό, κάνεις το setState()
                        if (mounted) {
                          setState(() {});
                        }
                      },


                      child: Text(team.name,style: TextStyle(fontSize: 12),),
                    )),
                    DataCell(Text(team.totalGames.toString())),
                    DataCell(Text(team.wins.toString())),
                    DataCell(Text(team.draws.toString())),
                    DataCell(Text(team.losses.toString())),
                    DataCell(
                      Center(  // Κεντραρισμένο κείμενο για τους πόντους
                        child: Text(
                          team.totalPoints.toString(),
                          textAlign: TextAlign.center,  // Κεντραρισμένο
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
              style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  DataColumn _buildColumn(String label, {bool numeric = false}) {
    return DataColumn(
      label: Center(  // Κεντραρισμένο κείμενο στις επικεφαλίδες
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      numeric: numeric,
    );
  }
}
