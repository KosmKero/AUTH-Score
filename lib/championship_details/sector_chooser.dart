import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:untitled1/API/Match_Handle.dart';
import 'package:untitled1/Data_Classes/MatchDetails.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';
import 'package:untitled1/championship_details/StandingsPage.dart';
import 'package:untitled1/championship_details/knock_outs_page.dart';
import 'package:untitled1/championship_details/top_players_page.dart';

import '../API/top_players_handle.dart';
import '../Data_Classes/Team.dart';
import '../Firebase_Handle/firebase_screen_stats_helper.dart';
import '../globals.dart';



class StandingsOrKnockoutsChooserPage extends StatefulWidget {
  const StandingsOrKnockoutsChooserPage({super.key});

  @override
  State<StandingsOrKnockoutsChooserPage> createState() => _StandingsOrKnockoutsChooserPageState();
}

class _StandingsOrKnockoutsChooserPageState extends State<StandingsOrKnockoutsChooserPage> {
  int indexChoice=0;
  void _changeSection(int index) {
    setState(() {
      indexChoice = index;
    });
  }
  int selectedSeason = thisYearNow; // default
  List<int> seasons = [2026,2025];

  List<Team> teamList = teams;
  Map<int, MatchDetails> matchList = {};
  Map<int, List<Team>> cachedTeams = {};
  Map<int, Map<int, MatchDetails>>  cachedMatches= {};

  @override
  void initState() {
    initializeMatches();
  }

  Future<void> initializeMatches() async {
    playOffMatches= await TeamsHandle().getPlayOffMatches(thisYearNow);

  }


  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Championship Details Page',screenClass: 'Championship Details Page');

    DateTime now = DateTime.now();
    int seasonYear = now.month > 8 ? now.year : now.year - 1;

    bool isLoading;

    return Container(
      color:darkModeNotifier.value?Color(0xFF121212): lightModeBackGround,

      child: Column(
        children: [
          DropdownButton<int>(
            dropdownColor: darkModeNotifier.value?Color(0xFF121212): Colors.white,
            value: selectedSeason, // αυτό εμφανίζεται
            items: seasons.map((season) {
              return DropdownMenuItem<int>(
                value: season,
                child: Text("${season-1}-$season",style: TextStyle(color: darkModeNotifier.value ? Colors.white : lightModeText, ),),

              );
            }).toList(),
            onChanged: (value) async {
              if (value != null) {
                setState(() {
                  isLoading = true;
                });

                if (cachedTeams.containsKey(value)) {
                  //Map<int, MatchDetails> listPlay = await TeamsHandle().getPlayOffMatches(value);

                  setState(() {
                    teamList = cachedTeams[value]!;
                    matchList = cachedMatches[value]!;
                    TopPlayersHandle().initializeList(teamList);
                    selectedSeason = value;


                    playOffMatches = cachedMatches[value]!;
                    isLoading = false;
                  });
                } else {
                  List<Team> list = await TeamsHandle().getAllTeamsByYear(value);
                  //List<MatchDetails> listM = await MatchHandle().getMatchesByYear(value, list);
                  TopPlayersHandle().initializeList(list);
                  Map<int, MatchDetails> listPlay = await TeamsHandle().getPlayOffMatches(value);

                  cachedTeams[value] = list;
                  cachedMatches[value] = listPlay;

                  setState(() {
                    playOffMatches = listPlay;
                    selectedSeason = value;
                    teamList = list;
                    //matchList = listM;
                    isLoading = false;
                  });
                }
              }
            },

          ),


          // Row για τα κουμπιά πλοήγησης
          _NavigationButtons(onSectionChange: _changeSection),

          // Εδώ επιλέγουμε ποιο περιεχόμενο να εμφανίσουμε ανάλογα με την επιλογή
          indexChoice == 0
                ? StandingsPage(seasonYear, teamList)
                : (indexChoice == 1)
                ? KnockOutsPage(playOffMatches: playOffMatches,)
                : TopPlayersProvider(),
        ],
      ),
    );

  }

}

//ΑΦΟΡΑ ΤΑ 3 ΚΟΥΜΠΙΑ ΚΑΤΩ ΑΠΟ ΤΟ ΟΝΟΜΑ!!
class _NavigationButtons extends StatefulWidget {
  final Function(int) onSectionChange;

  const _NavigationButtons({Key? key, required this.onSectionChange})
      : super(key: key);

  @override
  State<_NavigationButtons> createState() => _NavigationButtonsState();
}

class _NavigationButtonsState extends State<_NavigationButtons> {
  int selectedIndex = 0;

  void _onButtonPressed(int index) {
    setState(() {
      selectedIndex = index;
    });
    widget.onSectionChange(index); // Notify parent widget
  }

  //ΔΗΜΙΟΥΡΓΕΙ ΤΟΝ ΧΩΡΟ ΤΩΝ 3 ΚΟΥΜΠΙΩΝ
  @override
  Widget build(BuildContext context) {
      return Container(
        //color:darkModeNotifier.value?Color(0xFF121212): lightModeBackGround,
        //height: 35,
        //width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(width: 10),
              _buildTextButton(greek?"Βαθμολογία":"Standings", 0),
              SizedBox(width: 15),
              _buildTextButton(greek?"Νοκ Άουτ":"Knock out", 1),
              SizedBox(width: 15),
              _buildTextButton(greek?"Κορυφαίοι Παίχτες":"Best players", 2),
            ],
          ),
        ),
      );
  }

  //ΔΗΜΙΟΥΡΓΕΙ ΤΑ 3 ΚΟΥΜΠΙΑ(ΛΕΠΤΟΜΕΡΕΙΕΣ ΑΓΩΝΕΣ ΚΑΙ ΠΑΙΧΤΕΣ)
  Widget _buildTextButton(String text, int index) {
    bool isSelected = selectedIndex == index;

    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth < 300 ? 15 : 17; // Μειώνει το μέγεθος της γραμματοσειράς για μικρότερες οθόνες


    return GestureDetector(
      onTap: () {
        _onButtonPressed(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: isSelected ?darkModeNotifier.value?Colors.blue: Color.fromARGB(255, 0, 35, 150) :darkModeNotifier.value?Colors.white: Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontFamily: "Arial"
            ),
          ),
          SizedBox(height: 3), // Απόσταση μεταξύ κειμένου και γραμμής
          if (isSelected)
            Container(
              width: 70, // Μήκος γραμμής
              height: 3, // Πάχος γραμμής
              color:darkModeNotifier.value?Colors.blue: Color.fromARGB(255, 0, 35, 150), // Χρώμα γραμμής
            ),
        ],
      ),
    );
  }
}