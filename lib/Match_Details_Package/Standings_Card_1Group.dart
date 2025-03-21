import 'package:flutter/material.dart';
import '../Data_Classes/Team.dart';
import '../Team_Display_Page_Package/TeamDisplayPage.dart';
import '../main.dart';
import '../Data_Classes/Match.dart';

//ΑΥΤΗ Η ΚΛΑΣΗ ΑΦΟΡΑ ΟΤΑΝ ΠΟΑΤΑΕΙ ΤΟ ΚΟΥΜΠΙ ¨ΒΑΘΜΟΛΟΓΙΑ" ΓΙΑ ΤΟΝ ΚΑΘΕ ΑΓΩΝΑ
class StandingPageOneGroup extends StatefulWidget {
  const StandingPageOneGroup({super.key,required this.team});
  final Team team;
  @override
  State<StandingPageOneGroup> createState() => _StandingPageOneGroupState();
}

//ΑΦΟΡΑ ΤΗΝ ΚΑΡΤΕΛΑ ΓΙΑ ΤΙΣ ΒΑΘΜΟΛΟΓΙΕΣ !!!
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
        elevation: 6,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10),
                child:
                Text("Όμιλος $group",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 16,),
              DataTable(
                columnSpacing: 23.0,
                headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blueGrey[300]!),
                headingRowHeight: 45.0,
                dataRowHeight: 55.0,
                columns: const [
                  DataColumn( //ΣΤΗΝΟΥΜΕ ΤΙΣ ΣΤΗΛΕΣΣ

                      label:
                      Padding(
                        padding: EdgeInsets.only(left:10),
                          child: Text("Ομάδα",textAlign: TextAlign.start,
                      )),
                  ),
                  DataColumn(
                      label: Padding(
                        padding: EdgeInsets.only(left:10),
                        child:
                          Text("Π", textAlign: TextAlign.start),),
                      numeric: true,

                  ),
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
                ], //ΠΑΟ Ε
                rows: groupTeams.map( //ΒΑΖΟΥΜΕ ΤΑ ΣΤΟΙΧΕΙΑ ΓΙΑ ΤΗΝ ΚΑΘΕ ΟΜΑΔΑ!! ΣΟΣΟΣΣΣ
                      (team) => DataRow(color:WidgetStateColor.resolveWith(
                              (states) => groupTeams.indexOf(team) % 2 == 0
                              ? Colors.teal[50]!
                              : Colors.white),
                          cells: [
                    DataCell(TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TeamDisplayPage(team)),
                        );
                      },
                      child: Padding(
                        padding:EdgeInsets.only(right: 8) ,
                        child:
                        Text(team.name,),)
                    )),
                    DataCell(Text(team.totalGames.toString())),
                    DataCell(Text(team.wins.toString())),
                    DataCell(Text(team.draws.toString())),
                    DataCell(Text(team.losses.toString())),
                    DataCell(
                      Padding(
                        padding: EdgeInsets.only(right: 12),
                        child:
                        Text(team.totalPoints.toString()))),
                  ]),
                )
                    .toList(),
              )
            ],
          ),
        ));
  }
}
