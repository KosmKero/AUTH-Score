import 'package:flutter/material.dart';
import '../Data_Classes/Team.dart';
import '/Match_Details_Package/Standings_Card_1Group.dart';

//ΟΛΗ Η ΚΛΑΣΗ ΑΦΟΡΑ ΤΗΝ ΚΑΤΑΣΚΕΥΗ ΤΟΥ ΠΩΣ ΘΑ ΕΜΦΑΝΙΖΕΤΑΙ ΤΑ ΚΥΚΛΑΚΙΑ ΜΕ ΤΗΝ ΝΙΚΗ , ΙΣΟΠΑΛΙΑ, ΗΤΤΑ.
//ΑΝΑΦΕΡΕΙ ΕΠΙΣΗΣΒ ΤΗΝ ΒΑΘΜΟΛΟΓΙΑ
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
                    "Αποτελέσματα τελευταίων 5 αγωνιστικών",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
              TeamFormWidget(results: team.last5Results),
              SizedBox(
                height: 17,
              )
            ],
          )),
          Card(
            child: Column(children: [

              Padding(
                padding: EdgeInsets.only(bottom: 10, top: 25),
                child: Text("Βαθμολογία",
                    style:
                        TextStyle(fontSize: 22,
                            fontWeight: FontWeight.bold)),
              ),
              StandingPageOneGroup(team: team,),
            ]),
          ),
          SizedBox(height: 25,),
          Card(//ΑΦΟΡΑ ΤΙΣ ΠΛΗΡΟΦΟΡΙΕΣ ΣΤΟ ΚΑΤΩ ΜΕΡΟΣ ΤΗΝ ΟΘΟΝΗΣ
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start, // Στοίχιση αριστερά-δεξιά
                  children: [
                    Padding(
                        padding: EdgeInsets.only(left: 2),
                      child: Icon(Icons.event,color: Colors.blueAccent),
                    ),
                    Padding(
                      padding:EdgeInsets.only(left: 10),
                      child:
                        Text(
                          'Έτος ίδρυσης:',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 120),
                      child: Text(
                      '${team.foundationYear}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      )
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start, // Στοίχιση αριστερά-δεξιά
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.emoji_events,color: Color.fromARGB(255, 202, 188, 0),),
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 9),
                    child:
                      Text(
                        'Τίτλοι:',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 185),
                      child: Text(
                      '${team.titles}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      )
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

//ΑΦΟΡΑ ΤΟ ΠΩς ΘΑ ΦΑΙΝΟΝΕΤΙΑ Ο ΠΙΝΑΚΑΣ
class TeamFormWidget extends StatelessWidget {
  final List<String> results; // "W" for Win, "D" for Draw, "L" for Loss

  const TeamFormWidget({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
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

  //δημιορυγει τα κυκλακια
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
