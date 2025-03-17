import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/standings_or_knockouts_package/StandingsPage.dart';
import 'package:untitled1/standings_or_knockouts_package/knock_outs_page.dart';



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
          children: [
            TextButton(onPressed:() {
              buttonPushed(0);
            }, child: Text("Βαθμολογία")),
            TextButton(onPressed:() {
              buttonPushed(1);
            }, child: Text("Νοκ Άουτς"))
          ],
        ),
        Expanded(child: _bodyChooser(indexChoice))
      ],
    );
  }

  Widget _bodyChooser(int index){
    if (index==0){
      return StandingsPage();
    }
    else {
      return KnockOutsPage();
    }
  }

}
