import 'package:flutter/material.dart';
import 'package:untitled1/Data_Classes/basketball/basketMatch.dart';
import 'package:untitled1/Data_Classes/basketball/basketTeam.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';
import '../../Data_Classes/MatchDetails.dart';
import '../../Data_Classes/Team.dart';
import '../../Team_Display_Page_Package/TeamDisplayPage.dart';
import '../../globals.dart';
import 'bettingChooserBasket.dart';

//ΤΟ ΚΟΜΜΑΤΙ ΑΥΤΟ ΑΦΟΡΑ ΟΛΟ ΤΟ ΥΠΟΛΟΙΠΟ ΜΕΡΟΣ ΤΗΣ ΣΕΛΙΔΑΣ
class BasketDetailsMatchNotStarted extends StatelessWidget {
  const BasketDetailsMatchNotStarted({super.key, required this.match});
  final basketMatch match;

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
              greek?'Ποιoς Θα κερδίσει;':"Who will win?",
              style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Arial',
                  color: darkModeNotifier.value?Colors.white:Colors.black
              ),
            ),
          ),
          SizedBox(height: 8),
          BettingChooserBasket(match: match,), //TO KOYMΠΙ ΜΕ ΤΙΣ 2 ΕΠΙΛΟΓΕΣ (12)
          SizedBox(
            height: 70,
          ),
          Center(
            child: Text(
              greek?'Αποτελέσματα τελευταίων αγωνιστικών:':"Result of the last games:",
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: "Arial", color: darkModeNotifier.value?Colors.white:Colors.black
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: Card(

              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),

              ),
              color: darkModeNotifier.value ? Color.fromARGB(255, 45, 45, 45) : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    TeamFormWidget(team: match.homeTeam),
                    SizedBox(height: 15),
                    TeamFormWidget(team: match.awayTeam),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
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
  final basketTeam team;

  const TeamFormWidget({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<List<String>>(
      future: getFinalFive(team.name),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        else if (snapshot.hasError) {
          return const Text("Error loading results");
        } else {
          final results = snapshot.data ?? [];
          final displayResults = results.length == 6 ? results.sublist(1) : results;

          return Padding(
            padding: EdgeInsets.only(left: 0, top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Team Name
                Expanded(
                  child: InkWell(
                  // onTap: () {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => TeamDisplayPage(team)),
                  //   );
                  // },
                    child: Row(
                      children: [
                        SizedBox(width: 10,),
                        SizedBox(
                            height: 25,
                            width: 25,
                            child: team.image),
                        SizedBox(width: 5,),
                        Flexible(
                          //width: teamNameWidth,
                          // alignment: Alignment.centerLeft,
                          child: Text(
                            team.name,
                            style: TextStyle(
                              fontSize: screenWidth * 0.036, // Responsive font size
                              fontWeight: FontWeight.w600,
                              color: darkModeNotifier.value?Colors.white:Colors.black,
                              letterSpacing: 1.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  //width: resultsWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: displayResults.map((result) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _buildResultIcon(result),
                    )).toList(),
                  ),
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
