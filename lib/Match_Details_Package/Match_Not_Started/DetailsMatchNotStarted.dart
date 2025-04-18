import 'package:flutter/material.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';
import '../../Data_Classes/MatchDetails.dart';
import '../../Data_Classes/Team.dart';
import '../../Team_Display_Page_Package/TeamDisplayPage.dart';
import '../../globals.dart';
import 'betting_chooser.dart';


//ΤΟ ΚΟΜΜΑΤΙ ΑΥΤΟ ΑΦΟΡΑ ΟΛΟ ΤΟ ΥΠΟΛΟΙΠΟ ΜΕΡΟΣ ΤΗΣ ΣΕΛΙΔΑΣ
class DetailsMatchNotStarted extends StatelessWidget {
  const DetailsMatchNotStarted({super.key, required this.match});
  final MatchDetails match;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: darkModeNotifier.value?Color.fromARGB(255,30, 30, 30):Colors.white,
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
                    fontFamily: 'Arial',
                    color: darkModeNotifier.value?Colors.white:Colors.black
                ),
              ),
            ),
            SizedBox(height: 8),
            BettingChooser(match: match,), //TO KOYMΠΙ ΜΕ ΤΙΣ 3 ΕΠΙΛΟΓΕΣ (1Χ2)
            SizedBox(
              height: 70,
            ),
            Text(
              greek?'Αποτελέσματα τελευταίων 5 αγωνιστικών:':"Result of the last 5 games:",
              style: TextStyle(
                fontSize: 18,
                fontFamily: "Arial", color: darkModeNotifier.value?Colors.white:Colors.black
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

Future<List<num>> loadPercentages(MatchDetails match) async {
  TeamsHandle teamsHandle = TeamsHandle();
  return teamsHandle.getPercentages('${match.homeTeam.nameEnglish}${match.awayTeam.nameEnglish}${match.dateString}');
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
          final displayResults = results.length == 6 ? results.sublist(1) : results;

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
                        color: darkModeNotifier.value?Colors.white:Colors.black,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 30),
                Row(
                  children: displayResults.map((result) => Padding(
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

    return Icon(icon, color: color, size: 30);
  }
}
