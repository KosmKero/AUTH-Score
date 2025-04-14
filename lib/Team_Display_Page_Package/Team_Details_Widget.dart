import 'package:flutter/material.dart';
import 'package:untitled1/Team_Display_Page_Package/edit_team_page.dart';
import '../Data_Classes/Team.dart';
import '../Match_Details_Package/Match_Not_Started/DetailsMatchNotStarted.dart';
import '../championship_details/StandingsPage.dart';
import '../globals.dart';

//ΟΛΗ Η ΚΛΑΣΗ ΑΦΟΡΑ ΤΗΝ ΚΑΤΑΣΚΕΥΗ ΤΟΥ ΠΩΣ ΘΑ ΕΜΦΑΝΙΖΕΤΑΙ ΤΑ ΚΥΚΛΑΚΙΑ ΜΕ ΤΗΝ ΝΙΚΗ , ΙΣΟΠΑΛΙΑ, ΗΤΤΑ.
//ΑΝΑΦΕΡΕΙ ΕΠΙΣΗΣΒ ΤΗΝ ΒΑΘΜΟΛΟΓΙΑ
class TeamDetailsWidget extends StatefulWidget {
  const TeamDetailsWidget({super.key, required this.team});
  final Team team;

  @override
  State<TeamDetailsWidget> createState() => _TeamDetailsWidgetState();
}

class _TeamDetailsWidgetState extends State<TeamDetailsWidget> {
  @override
  build(BuildContext context) {
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TeamFormWidget(
                team: widget.team,
              ),
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
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              StandingsPage1().buildGroupStandings(widget.team.group),
            ]),
          ),
          SizedBox(
            height: 25,
          ),
          Card(
            //ΑΦΟΡΑ ΤΙΣ ΠΛΗΡΟΦΟΡΙΕΣ ΣΤΟ ΚΑΤΩ ΜΕΡΟΣ ΤΗΝ ΟΘΟΝΗΣ
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: EdgeInsets.all(15),
            child: Column(
              children: [
                if (globalUser.controlTheseTeams(widget.team.name, null))
                  IconButton(
                      onPressed: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TeamEditPage(widget.team)));
                        setState(() {

                        });

                      },
                      icon: Icon(Icons.edit)),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.start, // Στοίχιση αριστερά-δεξιά
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 2),
                      child: Icon(Icons.event, color: Colors.blueAccent),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'Έτος ίδρυσης:',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 130),
                        child: Text(
                          '${widget.team.foundationYear}',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.start, // Στοίχιση αριστερά-δεξιά
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.emoji_events,
                        color: Color.fromARGB(255, 202, 188, 0),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 9),
                      child: Text(
                        'Τίτλοι:',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 225),
                        child: Text(
                          '${widget.team.titles}',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
                //ΓΙΑ ΤΟΝ ΠΡΟΠΟΝΗΤΗ!!
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.start, // Στοίχιση αριστερά-δεξιά
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 2),
                      child: Icon(Icons.person, color: Colors.blueAccent),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'Προπονητής:',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 90),
                        child: Text(
                          '${widget.team.coach}',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )));
  }
}

//ΑΦΟΡΑ ΤΗΝ ΚΑΤΑΣΚΕΥΗ ΤΩΝ ΟΝΟΜΑΤΩΝ ΤΩΝ ΟΜΑΔΩΝ ΣΤΟ ΚΑΤΩ ΜΕΡΟΣ
class TeamFormWidget extends StatelessWidget {
  final Team team;

  const TeamFormWidget({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: getFinalFive(team.name),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // ή κάποιο placeholder
        } else if (snapshot.hasError) {
          return const Text("Error loading results");
        } else {
          final results = snapshot.data ?? [];
          final displayResults =
              results.length == 6 ? results.sublist(1) : results;

          return Padding(
            padding: EdgeInsets.only(left: 1, top: 10),
            child: Row(
              children: [
                // Team Name
                SizedBox(
                  width: 155,
                  child: Text(
                    team.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                SizedBox(width: 30),
                Row(
                  children: displayResults
                      .map((result) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: _buildResultIcon(result),
                          ))
                      .toList(),
                ),
              ],
            ),
          );
        }
      },
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

    return Icon(icon, color: color, size: 30);
  }
}
