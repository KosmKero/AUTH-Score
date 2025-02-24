import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/TopScorersContainer.dart';
import 'package:untitled1/matchesContainer.dart';
import 'Scorer.dart';
import 'main.dart';

class HomePage extends StatefulWidget {



  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  List<Scorer> topScorers = [
    Scorer("paulos", 30, "c"),
    Scorer("lito", 15, "c"),
    Scorer("billy", 13, "csd"),
    Scorer("glaros", 10, "c"),
    Scorer("paulito", 10, "c"),
    Scorer("lama", 15, "csd"),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [ Color.fromARGB(255, 177, 37, 32), Colors.deepOrange], // Δύο χρώματα
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
        Expanded(
          // flex: 5, // Το κάτω μέρος είναι μικρότερο
          child: Container(
            color: Colors.deepOrange,
            child: matchesContainer(matches: matches,),
          ),
        ),
      ],
    );
  }
}
