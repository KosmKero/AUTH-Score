import 'package:flutter/material.dart';
import 'Scorer.dart';

class topScorersContainer extends StatelessWidget {

  final List<Scorer> topScorers = [
    Scorer("paulos", 30, "c"),Scorer("lito", 15, "c"),
    Scorer("billy", 13, "csd"),Scorer("glaros", 10, "c"),
    Scorer("paulito", 10, "c"),Scorer("kosmas", 15, "csd")
  ];

  topScorersContainer({super.key}){
  topScorers.sort((a, b) => b.goals.compareTo(a.goals));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85, // Καθορισμένο ύψος
      //padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.greenAccent,
        //borderRadius: BorderRadius.circular(15),
      ),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.center, // Align label to the start
    children: [
    const Padding(
    padding: EdgeInsets.only(bottom: 0.2), // Add space below the label

    child: Text(
    "Top Scorers",
    style: TextStyle(
    color: Colors.black,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    ),
    ),
    ),
      Expanded(
      child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
        children:  buildcont() ),
    ),
    ),
    ],
    ),
    );
  }
  //δημιουργια κοντεινερ ετσι επειδη δεν μπορουμε ευκολα να βαλουμε φορ στο children
  List<Widget> buildcont(){
    List<Widget> widgets=[];
    for (int i = 0; i < topScorers.length; i++) {
      widgets.add(scorerContainer(scorer: topScorers[i]));

      if (i < topScorers.length - 1) {
        widgets.add(
          Container(
            height: double.infinity, // Height of the divider
            width: 0.5, // Width of the divider
            color: Colors.green, // Color of the divider
          ),
        );
      }
    }
    return widgets;
  }
}




// 🔹 Custom Container για κάθε Scorer
class scorerContainer extends StatelessWidget{
  final Scorer scorer;
  const scorerContainer({super.key, required this.scorer});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.greenAccent,
      height: double.infinity,
      width: 85,
        alignment: Alignment.center,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Κεντρική ευθυγράμμιση
          children: [
          Text(
          scorer.getName(),
      style: const TextStyle(color: Colors.black, fontSize: 16),
    ),
    Text(
    scorer.getGoals().toString(),
    style: const TextStyle(color: Colors.black, fontSize: 14),
    ),
    ],
    ),
    );
  }
}