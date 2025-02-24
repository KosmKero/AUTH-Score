import 'package:flutter/material.dart';
import 'Match.dart';


class MatchDetailsPage extends StatelessWidget {
  const MatchDetailsPage({super.key,required this.match});
  final Match match;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Card(

        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SizedBox(
              height: 100,
              child: Column(
                children: [
                  Text(match.homeTeam.name,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                  Text(match.scoreHome.toString(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),)

                ],
              ),
            ),
            SizedBox(height: 100,width: 20,),
            SizedBox(
              height: 100,
              child: Column(
                children: [
                  Text(match.timeString,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20))
                ],
              ),
            ),
            SizedBox(height: 100,width: 20,),
            SizedBox(
              height: 100,
              child: Column(
                children: [
                  Text(match.awayTeam.name,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
                  Text(match.scoreAway.toString(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),)
                ],
              ),
            )
          ],
        ),

      ),


    );
  }
}
