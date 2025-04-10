import 'package:flutter/material.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';
import '../../Data_Classes/MatchDetails.dart';
import '../../Data_Classes/Team.dart';
import '../../Team_Display_Page_Package/TeamDisplayPage.dart';
import '../../globals.dart';


//ΤΟ ΚΟΜΜΑΤΙ ΑΥΤΟ ΑΦΟΡΑ ΟΛΟ ΤΟ ΥΠΟΛΟΙΠΟ ΜΕΡΟΣ ΤΗΣ ΣΕΛΙΔΑΣ
class DetailsMatchNotStarted extends StatelessWidget {
  const DetailsMatchNotStarted({super.key, required this.match});
  final MatchDetails match;
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(height: 70,),
            Padding(
              padding: EdgeInsets.only(right: 10),
              child:Text(
                greek?'Ποιός Θα κερδίσει?🏆':"Who will win?🏆",
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    fontStyle: FontStyle.italic
                ),
              ),
            ),
            SizedBox(height: 8),
            BettingChooser(homeTeam:match.homeTeam.name,awayTeam:  match.awayTeam.name), //TO KOYMΠΙ ΜΕ ΤΙΣ 3 ΕΠΙΛΟΓΕΣ (1Χ2)
            SizedBox(
              height: 70,
            ),
            Text(
              greek?'Αποτελέσματα τελευταίων 5 αγωνιστικών:':"Result of the last 5 games:",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(
              height: 1,
            ),
            Padding( //ΑΦΟΡΑ ΤΗΝ ΑΠΟΣΤΑΣΗ ΑΠΟ ΤΑ ΚΥΚΛΑΚΙΑ ΜΕ ΤΟ ΟΝΟΜΑ
              padding: const EdgeInsets.symmetric(horizontal:10.0),
              child: Column(
                children: [ //ΔΗΜΙΟΥΡΓΕΙ ΤΙΣ ΟΜΑΔΕΣ
                  TeamFormWidget(team: match.homeTeam),
                  SizedBox(height: 5),
                  TeamFormWidget(team: match.awayTeam),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            )
          ],
        ));
  }
}


Future<List<num>> loadPercentages(String homeTeam, String awayTeam, String selection) async {
  TeamsHandle teamsHandle = TeamsHandle();
  return teamsHandle.getPercentages(homeTeam, awayTeam, selection);
}

class BettingChooser extends StatefulWidget {
  final String homeTeam;
  final String awayTeam;

  const BettingChooser({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
  });

  @override
  State<BettingChooser> createState() => _BettingChooserState();
}

class _BettingChooserState extends State<BettingChooser> {
  TeamsHandle teamsHandle = TeamsHandle();
  String _selected = '';
  bool hasChosen = false;
  List<num> percentages = [];

  void _updateCount(String value) async {
    if (hasChosen) return;

    // First perform the async work
    final loadedPercentages = await loadPercentages(
      widget.homeTeam,
      widget.awayTeam,
      value,
    );

    // Then update the state
    if (mounted) {
      setState(() {
        hasChosen = true;
        _selected = value;
        percentages = loadedPercentages;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: Column(
      children: [
        SizedBox(
          width: 320,
        child: SegmentedButton<String>(
          segments: [
            ButtonSegment(value: '1', label: Text(hasChosen ? percentages[0].toStringAsFixed(2)  : "1",
              style:  TextStyle(fontSize: 15,),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              ),
            ),

            ButtonSegment(value: 'X', label: Text(hasChosen ? percentages[2].toStringAsFixed(2) :'X',style: TextStyle(fontSize: 15),)),

            ButtonSegment(value: '2', label: Text(hasChosen ? percentages[1].toStringAsFixed(2) :'2',style: TextStyle(fontSize: 15,))),
          ],
          style: ButtonStyle(
              fixedSize: WidgetStateProperty.all(Size(540, 50)),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(9),side: BorderSide(color: Colors.black,width: 1.5))),
              backgroundColor: WidgetStateProperty.all(Color.fromARGB(255, 243, 246, 255)),
          ),
          showSelectedIcon: true,
          selected: _selected != null ? {_selected!} : {},
          onSelectionChanged: hasChosen
              ? null
              : (newSelection) {
            _updateCount(newSelection.first);
          },
        ),
        ),
        SizedBox(height: 10),
       ],
      )
    );
  }
}


Future<List<String>> getFinalFive(String teamName) async{

  TeamsHandle teamsHandle = TeamsHandle();
  return teamsHandle.getPreviousResults(teamName);
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
        }
        else if (snapshot.hasError)
        {
          return const Text("Error loading results");
        } else {
          final results = snapshot.data ?? [];

          return Padding(
            padding: EdgeInsets.only(left: 1, top: 10),
            child: Row(
              children: [
                // Team Name
                SizedBox(
                  width: 155,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TeamDisplayPage(team)),
                      );
                    },
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
                ),
                SizedBox(width: 30),
                Row(
                  children: results
                      .map((result) => Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 3),
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
