import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/TopScorersContainer.dart';
import 'package:untitled1/matchesContainer.dart';
import 'API/Match_Handle.dart';
import 'Match_Details_Package/add_match_page.dart';
import 'Scorer.dart';
import 'globals.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool upcomingMatches = true;
  List<Scorer> topScorers = [
    Scorer("paulos", 30, "c"),
    Scorer("lito", 15, "c"),
    Scorer("billy", 13, "csd"),
    Scorer("glaros", 10, "c"),
    Scorer("paulito", 10, "c"),
    Scorer("lama", 15, "csd"),
  ];

  void changeMatches() {
    setState(() {
      upcomingMatches = !upcomingMatches;
    });
  }

  Future<void> addi() async {}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (globalUser.isAdmin)
          Container(
              color: darkModeNotifier.value ?Color(0xFF121212) : lightModeBackGround,
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: darkModeNotifier.value
                          ? darkModeBackGround
                          : Color.fromARGB(250, 74, 111, 150)),
                  onPressed: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddMatchScreen(),
                        ));
                  },
                  child: Text(
                    "Προσθήκη Αγώνα",
                    style: TextStyle(
                      color: darkModeNotifier.value ? Colors.white : Colors.white,
                      fontFamily: 'Arial',
                      fontWeight: FontWeight.bold,
                      fontSize: 16.5,
                      wordSpacing: 1,
                      letterSpacing: 0.5,
                    ),
                  )
              )
          ),
        Container(
            color: darkModeNotifier.value
                ?Color(0xFF121212)
                : lightModeBackGround,
            width: double.infinity,
            height: 60,
            child: TextButton(
                onPressed: () {
                  changeMatches();
                },
                child: upcomingMatches
                    ? Row(
                  children: [
                    Icon(CupertinoIcons.back,
                      color: darkModeNotifier.value ? Colors.white : Colors.white,
                      size: 19,),
                    Text(
                      "Προηγούμενοι αγώνες",
                      style: TextStyle(
                          color: darkModeNotifier.value ? Colors.white : Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Arial",
                          letterSpacing: 0.5
                      ),
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Επερχόμενοι αγώνες",
                      style: TextStyle(
                          color: darkModeNotifier.value ? Colors.white : Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Arial",
                          letterSpacing: 0.5
                      ),
                    ),
                    Icon(CupertinoIcons.right_chevron,
                      color: darkModeNotifier.value ? Colors.white : Colors.white,
                      size: 19,),
                  ],
                ))),
        /* Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [ Color.fromARGB(150, 105, 165, 227), Color.fromARGB(150, 105, 165, 227)], // Δύο χρώματα
              begin: Alignment.topCenter, // Ξεκινάει από πάνω
              end: Alignment.bottomCenter, // Καταλήγει κάτω
              stops: [0.5, 0.5], // Χωρίζει το container 50-50
            ),
          ),
          height: 90, // Ύψος για το scorers container
          child: topScorersContainer(
            topScorers: topScorers,
          ),
        ),
         */
        Expanded(
          //βαζει ολα τα match που ακολουθουν
          // flex: 5, // Το κάτω μέρος είναι μικρότερο
          child: Container(
            color: darkModeNotifier.value
                ? Color(0xFF121212)
                : lightModeBackGround,
            child: upcomingMatches
                ? matchesContainer(
                matches: MatchHandle().getUpcomingMatches(), type: 1)
                : matchesContainer(
              matches: MatchHandle().getPreviousMatches(),
              type: 1,
            ),
          ),
        ),
      ],
    );
  }
}
