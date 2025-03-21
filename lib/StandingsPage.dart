import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Team_Display_Page_Package/TeamDisplayPage.dart';
import 'package:untitled1/main.dart';

import 'Data_Classes/Team.dart';

class StandingsPage extends StatefulWidget {
  @override
  State<StandingsPage> createState() => _StandingsPage();
}

class _StandingsPage extends State<StandingsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(150, 60, 80, 150),
      child: Column(children: [
        Text("Βαθμολογικός Πίνακας",
            style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Expanded(
            child: SingleChildScrollView(
                child: Column(
          children: [
            _buildGroupStandings(1),
            _buildGroupStandings(2),
            _buildGroupStandings(3),
            _buildGroupStandings(4)
          ],
        )))
      ]),
    );
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
                dataRowHeight: 60,
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
                          child: Text(team.name),
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
