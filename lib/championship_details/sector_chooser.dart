import 'package:flutter/material.dart';
import 'package:untitled1/championship_details/StandingsPage.dart';
import 'package:untitled1/championship_details/knock_outs_page.dart';
import 'package:untitled1/championship_details/top_players_page.dart';



class StandingsOrKnockoutsChooserPage extends StatefulWidget {
  const StandingsOrKnockoutsChooserPage({super.key});

  @override
  State<StandingsOrKnockoutsChooserPage> createState() => _StandingsOrKnockoutsChooserPageState();
}

class _StandingsOrKnockoutsChooserPageState extends State<StandingsOrKnockoutsChooserPage> {
  int indexChoice=0;
  void buttonPushed(int index){
    setState(() {
      indexChoice=index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(onPressed:() {
              buttonPushed(0);
            }, child: Text("Βαθμολογία")),
            TextButton(onPressed:() {
              buttonPushed(1);
            }, child: Text("Νοκ Άουτς")),
            TextButton(onPressed:() {
              buttonPushed(2);
            }, child: Text("Κορυφαίοι Παίχτες"))
          ],
        ),
        Expanded(child: (indexChoice==0)? StandingsPage() : (indexChoice==1)? KnockOutsPage():TopPlayersProvider())
      ],
    );
  }

}
