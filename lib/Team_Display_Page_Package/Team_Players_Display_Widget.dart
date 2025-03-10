import 'package:flutter/material.dart';
import '../Data_Classes/Player.dart';
import '../Data_Classes/Team.dart';

class TeamPlayersDisplayWidget extends StatelessWidget {
  const TeamPlayersDisplayWidget({super.key, required this.team});
  final Team team;

  List<Player> posisionList(int pos) {
    return team.players.where((player) => player.position == pos).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          playersCard(0, posisionList(0)),
          playersCard(1, posisionList(1)),
          playersCard(2, posisionList(2)),
        ],
      ),
    ));
  }

  Widget playersCard(int position, List<Player> players) {
    String pos;
    if (position == 0) {
      pos = "Τερματοφύλακας";
    } else if (position == 1) {
      pos = "Μέσος";
    } else {
      pos = "Επιθετικός";
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 7),
      decoration:( ShapeDecoration(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),color: Color.fromARGB(70, 10, 50, 15))),

      //elevation: 4,
      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              pos,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 16),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Όνομα", style: TextStyle(fontWeight: FontWeight.bold)), ),
                  DataColumn(label: Text('Επίθετο', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Γκολ', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: players
                    .map(
                      (player) => DataRow(cells: [
                    DataCell(Text(player.name)),
                    DataCell(Text(player.surname)),
                    DataCell(Text(player.goals.toString())),
                  ]),
                )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
