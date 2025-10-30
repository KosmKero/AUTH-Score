import 'package:flutter/material.dart';
import 'package:untitled1/Team_Display_Page_Package/edit_team_page.dart';
import 'package:untitled1/Team_Display_Page_Package/one_group_standings.dart';
import '../Data_Classes/Team.dart';
import '../Firebase_Handle/firebase_screen_stats_helper.dart';
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
  Widget build(BuildContext context) {
    logScreenViewSta(
        screenName: 'Team arxiki', screenClass: 'Team arxiki page');

    return Expanded(
        child: SingleChildScrollView(
      child: Column(
        children: [
          Card(
              color: darkModeNotifier.value ? Color(0xFF1E1E1E) : Colors.white,
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.01,
                  vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        "Αποτελέσματα τελευταίων αγωνιστικών",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkModeNotifier.value
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: TeamFormWidget(
                        team: widget.team,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              )),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: Column(
              children: [
                Text("Βαθμολογία",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: darkModeNotifier.value
                            ? Colors.white
                            : Colors.white)),
                SizedBox(height: 3),
                GroupStandingsWidget(group: widget.team.group),
              ],
            ),
          ),
          SizedBox(
            height: 1,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: Card(
              shadowColor: Colors.black,
              color: darkModeNotifier.value ? Color(0xFF1E1E1E) : Colors.white,
              //ΑΦΟΡΑ ΤΙΣ ΠΛΗΡΟΦΟΡΙΕΣ ΣΤΟ ΚΑΤΩ ΜΕΡΟΣ ΤΗΝ ΟΘΟΝΗΣ
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.01,
                  vertical: 15),
              child: Column(
                children: [
                  if (globalUser.controlTheseTeams(widget.team.name, null))
                    IconButton(
                        onPressed: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TeamEditPage(widget.team)));
                          if (!mounted) return;

                          setState(() {});
                        },
                        icon: Icon(Icons.edit)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // Στοίχιση αριστερά-δεξιά
                    children: [
                      Row(
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Arial",
                                  letterSpacing: 0.3,
                                  color: darkModeNotifier.value
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                          padding: EdgeInsets.only(right: 7),
                          child: Text(
                            '${widget.team.foundationYear}',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: darkModeNotifier.value
                                    ? Colors.white
                                    : Colors.black),
                          )),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // Στοίχιση αριστερά-δεξιά
                    children: [
                      Row(
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Arial",
                                  color: darkModeNotifier.value
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                          padding: EdgeInsets.only(right: 7),
                          child: Text(
                            '${widget.team.titles}',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: darkModeNotifier.value
                                    ? Colors.white
                                    : Colors.black),
                          )),
                    ],
                  ),
                  SizedBox(height: 10),
                  //ΓΙΑ ΤΟΝ ΠΡΟΠΟΝΗΤΗ!!
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // Στοίχιση αριστερά-δεξιά
                    children: [
                      Row(
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Arial",
                                  color: darkModeNotifier.value
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                          padding: EdgeInsets.only(right: 7),
                          child: Text(
                            '${widget.team.coach}',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: darkModeNotifier.value
                                    ? Colors.white
                                    : Colors.black),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    ));
  }
}

//ΑΦΟΡΑ ΤΗΝ ΚΑΤΑΣΚΕΥΗ ΤΩΝ ΟΝΟΜΑΤΩΝ ΤΩΝ ΟΜΑΔΩΝ ΣΤΟ ΚΑΤΩ ΜΕΡΟΣ
class TeamFormWidget extends StatelessWidget {
  final Team team;

  TeamFormWidget({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<List<String>>(
      future: getFinalFive(team.name),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text("Error loading results");
        } else {
          final results = snapshot.data ?? [];
          final displayResults =
              results.length == 6 ? results.sublist(1) : results;

          return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: displayResults
                    .map((result) => Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.015),
                          child: _buildResultIcon(result, screenWidth),
                        ))
                    .toList(),
          );
        }
      },
    );
  }

  Widget _buildResultIcon(String result, double screenWidth) {
    IconData icon;
    Color color;

    switch (result) {
      case "W":
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case "D":
        icon = Icons.remove_circle;
        color = Colors.orange;
        break;
      case "L":
        icon = Icons.cancel;
        color = Colors.red;
        break;
      default:
        icon = Icons.circle;
        color = Colors.grey;
    }

    return Icon(icon, color: color, size: screenWidth * 0.075);
  }
}

class GroupStandingsWidget extends StatelessWidget {
  final int group;

  const GroupStandingsWidget({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    int seasonYear = now.month > 8 ? now.year : now.year - 1;
    return OneGroupStandings(group: group, seasonYear: seasonYear);
  }
}
