import 'package:flutter/material.dart';
import '../Data_Classes/Team.dart';
import '../Team_Display_Page_Package/TeamDisplayPage.dart';
import '../main.dart';
import '../Data_Classes/Match.dart';

class StandingPageOneGroup extends StatefulWidget {
  const StandingPageOneGroup({super.key,required this.team});
  final Team team;
  @override
  State<StandingPageOneGroup> createState() => _StandingPageOneGroupState();
}

class _StandingPageOneGroupState extends State<StandingPageOneGroup> {
  @override
  Widget build(BuildContext context) {
    return _buildGroupStandings(widget.team.group);
  }
  Widget _buildGroupStandings(int group) {
    List<Team> groupTeams = [];
    for (Team team in teams) {
      if (team.group == group) {
        groupTeams.add(team);
      }
    }
    groupTeams.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    return Card(
        margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Όμιλος $group",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              DataTable(
                columnSpacing: 20.0,
                headingRowHeight: 40.0,
                columns: const [
                  DataColumn(label: Text("Ομάδα")),
                  DataColumn(
                      label: Text("Π", textAlign: TextAlign.center),
                      numeric: true),
                  DataColumn(
                      label: Text("Ν", textAlign: TextAlign.center),
                      numeric: true),
                  DataColumn(
                      label: Text("Ι", textAlign: TextAlign.center),
                      numeric: true),
                  DataColumn(
                      label: Text("Η", textAlign: TextAlign.center),
                      numeric: true),
                  DataColumn(
                      label: Text("Πόντοι", textAlign: TextAlign.center),
                      numeric: true)
                ],
                rows: groupTeams
                    .map(
                      (team) => DataRow(cells: [
                    DataCell(TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TeamDisplayPage(team)),
                        );
                      },
                      child: Text(team.name,),
                    )),
                    DataCell(Text(team.totalGames.toString())),
                    DataCell(Text(team.wins.toString())),
                    DataCell(Text(team.draws.toString())),
                    DataCell(Text(team.losses.toString())),
                    DataCell(Text(team.totalPoints.toString())),
                  ]),
                )
                    .toList(),
              )
            ],
          ),
        ));
  }
}
