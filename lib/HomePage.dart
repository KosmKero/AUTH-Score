import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/TopScorersContainer.dart';
import 'package:untitled1/matchesContainer.dart';
import 'API/Match_Handle.dart';
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

  void changeMatches(){

    setState(() {
      upcomingMatches = !upcomingMatches;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            color: darkModeNotifier.value?darkModeBackGround: Color.fromARGB(150, 60, 80, 150),
            width: double.infinity,
            height: 60,
            child: TextButton( //ΚΑΤΩ ΑΠΟ ΤΟ APPBAR
                onPressed: () {
                  changeMatches();
                },
                child: upcomingMatches
                    ? Row(
                        children: [
                          Icon(CupertinoIcons.back),
                          Text(
                            "Προηγούμενοι αγώνες",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Επερχόμενοι αγώνες",
                            style: TextStyle(color: Colors.white),
                          ),
                          Icon(CupertinoIcons.right_chevron),
                        ],
                        )
            )
        ),
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
        Expanded( //βαζει ολα τα match που ακολουθουν
          // flex: 5, // Το κάτω μέρος είναι μικρότερο
          child: Container(
            color: darkModeNotifier.value?darkModeBackGround:Color.fromARGB(150, 60, 80, 150),
            child: upcomingMatches? matchesContainer(matches: MatchHandle().getUpcomingMatches(),type:1) :
            matchesContainer(
              matches: MatchHandle().getPreviousMatches(),
              type: 1,
            ),
          ),
        ),
      ],
    );
  }
}
