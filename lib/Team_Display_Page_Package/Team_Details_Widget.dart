import 'package:flutter/material.dart';
import '../Data_Classes/Team.dart';
import '/Match_Details_Package/Standings_Card_1Group.dart';

class TeamDetailsWidget extends StatelessWidget {
  const TeamDetailsWidget({super.key, required this.team});
  final Team team;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Expanded(
            child: SingleChildScrollView(
      child: Column(
        children: [
          Card(
              child: Column(
            children: [
              Text(
                "Φόρμα Ομάδας",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TeamFormWidget(results: team.last5Results),
              SizedBox(
                height: 15,
              )
            ],
          )),
          Card(
            child: Column(children: [
              Padding(
                padding: EdgeInsets.only(bottom: 10, top: 25),
                child: Text("Βαθμολογία",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              StandingPageOneGroup(
                team: team,
              ),
            ]),
          ),
          SizedBox(height: 15,),
          Card(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Στοίχιση αριστερά-δεξιά
                  children: [
                    Text(
                      'Έτος ίδρυσης:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${team.foundationYear}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Στοίχιση αριστερά-δεξιά
                  children: [
                    Text(
                      'Τίτλοι:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${team.titles}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          )
          ,
        ],
      ),
    )));
  }
}

class TeamFormWidget extends StatelessWidget {
  final List<String> results; // "W" for Win, "D" for Draw, "L" for Loss

  const TeamFormWidget({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 10),
            ...results.map((result) => _buildResultIcon(result))
          ],
        ),
      ],
    );
  }

  Widget _buildResultIcon(String result) {
    IconData icon;
    Color color;

    switch (result) {
      case "W":
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case "D":
        icon = Icons.remove_circle;
        color = Colors.grey;
        break;
      case "L":
        icon = Icons.cancel;
        color = Colors.red;
        break;
      default:
        icon = Icons.circle;
        color = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Icon(icon, color: color, size: 30),
    );
  }
}
