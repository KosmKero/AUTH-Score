import 'package:flutter/material.dart';
import 'package:untitled1/Team_Display_Page_Package/one_group_standings.dart';
import '../Data_Classes/Team.dart';
import '../Firebase_Handle/firebase_screen_stats_helper.dart';
// import '../Match_Details_Package/Match_Not_Started/DetailsMatchNotStarted.dart'; // Αν δεν χρησιμοποιείται, το αφαιρούμε
import '../Match_Details_Package/Match_Not_Started/DetailsMatchNotStarted.dart';
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

    // 1. Παίρνουμε το theme ΜΙΑ φορά στην αρχή της build()
    final theme = Theme.of(context);

    return Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                  color: theme.cardColor, // Δυναμικό χρώμα κάρτας
                  margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.02,
                      vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            greek ? "Αποτελέσματα τελευταίων αγωνιστικών" : "Last match results",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color), // Δυναμικό χρώμα κειμένου
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: TeamFormWidget(
                            team: widget.team,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  )),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Column(
                  children: [
                    Text(greek ? "Βαθμολογία" : "Standings",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color)), // Δυναμικό χρώμα
                    const SizedBox(height: 3),
                    GroupStandingsWidget(group: widget.team.group),
                  ],
                ),
              ),
              const SizedBox(
                height: 1,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Card(
                  shadowColor: Colors.black,
                  color: theme.cardColor, // Δυναμικό χρώμα κάρτας
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.02,
                      vertical: 15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 2),
                                // Δυναμικό χρώμα εικονιδίου
                                child: Icon(Icons.event, color: theme.primaryColor),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  greek ? 'Έτος ίδρυσης:' : 'Founded:',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Arial",
                                      letterSpacing: 0.3,
                                      color: theme.textTheme.bodyLarge?.color),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                              padding: const EdgeInsets.only(right: 7),
                              child: Text(
                                '${widget.team.foundationYear}',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: theme.textTheme.bodyLarge?.color),
                              )),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(
                                  Icons.emoji_events,
                                  color: Colors.amber, // Semantic Color (Χρυσό για τρόπαια)
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 9),
                                child: Text(
                                  greek ? 'Τίτλοι:' : 'Titles:',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Arial",
                                      color: theme.textTheme.bodyLarge?.color),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                              padding: const EdgeInsets.only(right: 7),
                              child: Text(
                                '${widget.team.titles}',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: theme.textTheme.bodyLarge?.color),
                              )),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 2),
                                // Δυναμικό χρώμα εικονιδίου
                                child: Icon(Icons.person, color: theme.primaryColor),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  greek ? 'Προπονητής:' : 'Coach:',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Arial",
                                      color: theme.textTheme.bodyLarge?.color),
                                ),
                              ),
                            ],
                          ),
                          Flexible(
                            child: Padding(
                                padding: const EdgeInsets.only(right: 7, left: 10),
                                child: Text(
                                  widget.team.coach,
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: theme.textTheme.bodyLarge?.color),
                                )),
                          ),
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
class TeamFormWidget extends StatefulWidget {
  final Team team;
  const TeamFormWidget({super.key, required this.team});

  @override
  State<TeamFormWidget> createState() => _TeamFormWidgetState();
}

class _TeamFormWidgetState extends State<TeamFormWidget> {
  late Future<List<String>> _formFuture;

  @override
  void initState() {
    super.initState();
    _formFuture = getFinalFive(widget.team.name);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return FutureBuilder<List<String>>(
      future: _formFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(color: theme.primaryColor); // Δυναμικό spinner
        } else if (snapshot.hasError) {
          return Text(
            greek ? "Σφάλμα φόρτωσης" : "Loading Error",
            style: TextStyle(color: theme.colorScheme.error),
          );
        } else {
          final results = snapshot.data ?? [];
          final displayResults = results.length == 6 ? results.sublist(1) : results;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: displayResults
                .map((result) => Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
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

    // Τα χρώματα εδώ παραμένουν γιατί είναι Semantic (Νίκη=Πράσινο, Ήττα=Κόκκινο)
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