import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/main.dart';

import 'Team.dart';

class TeamDisplayPage extends StatelessWidget{

  const TeamDisplayPage(this.team, {super.key});
  final Team team;
  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(title: Text(team.name),),
        body:Column(
      children: [
        Text(team.name,style: TextStyle(color: Color.fromARGB(100, 255, 10, 40),)),
        Row(
          children: [
            TextButton(onPressed: () {}, child: Text("Λεπτομέρειες")),
            TextButton(onPressed: () {}, child: Text("Ματς")),
            TextButton(onPressed: () {}, child: Text("Παίχτες")),
          ],
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child:
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
        children: [Text(favouriteTeams.toString()),isFavourite(team: team,),],
    )
        )
      ],

    )
      );
  }



}
class isFavourite extends StatefulWidget{
    final Team team;
   const isFavourite({super.key, required this.team});
  @override
  State<isFavourite> createState() => _isFavouriteState();
}

class _isFavouriteState extends State<isFavourite> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        setState(() {
          widget.team.changeFavourite(); // Toggle the favorite state
        });
        widget.team.isFavourite ? favouriteTeams.add(widget.team) : favouriteTeams.remove(widget.team);
      },
      icon: Icon(
        widget.team.isFavourite ?  Icons.favorite:  Icons.favorite_border, // Change icon based on state
        color: widget.team.isFavourite ? Colors.red : null , // Change color based on state
      ),
    );
  }
}