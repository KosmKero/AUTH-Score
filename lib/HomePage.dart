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
    Scorer("kosmas", 15, "csd"),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1, // Το πάνω μέρος καταλαμβάνει μεγαλύτερο χώρο
          child: topScorersContainer(),
        ),
        Expanded(
          flex: 4, // Το κάτω μέρος είναι μικρότερο
          child: Container(
            color: Colors.green,
            child: matchesContainer(),
          ),
        ),
      ],
    );
  }
}
