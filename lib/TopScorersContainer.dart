import 'dart:ffi';

import 'package:flutter/material.dart';
import 'Scorer.dart';

class topScorersContainer extends StatelessWidget {
  final List<Scorer> topScorers;

  topScorersContainer({super.key, required List<Scorer> topScorers})
    : topScorers = List.from(topScorers)..sort((a, b) => b.goals.compareTo(a.goals));


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      //padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.deepOrange,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Align label to the start
        children: [
          const Padding(
            padding: EdgeInsets.only(
                bottom: 0.2, top: 2), // Add space below the label

            child: Text(
              "Top Scorers",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: buildcont()),
            ),
          ),
        ],
      ),
    );
  }

  //δημιουργια κοντεινερ ετσι επειδη δεν μπορουμε ευκολα να βαλουμε φορ στο children
  List<Widget> buildcont() {
    List<Widget> widgets = [];
    for (int i = 0; i < topScorers.length; i++) {
      widgets.add(scorerContainer(scorer: topScorers[i]));

      if (i < topScorers.length - 1) {
        widgets.add(
          Container(
            //height: double.infinity, // Height of the divider
            width: 0.7, // Width of the divider
            color: Colors.grey, // Color of the divider
          ),
        );
      }
    }
    return widgets;
  }
}

// 🔹 Custom Container για κάθε Scorer
class scorerContainer extends StatelessWidget {
  final Scorer scorer;
  const scorerContainer({super.key, required this.scorer});

  @override
  Widget build(BuildContext context) {
    return Container(
      //height: 50,
      color: Colors.deepOrange,
      width: 85,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Κεντρική ευθυγράμμιση
        children: [
          Text(
            scorer.getName(),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            scorer.getGoals().toString(),
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
