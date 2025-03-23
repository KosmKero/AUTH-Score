import 'package:flutter/material.dart';
import '../Data_Classes/Player.dart';
import '../Data_Classes/Team.dart';

class TeamPlayersDisplayWidget extends StatelessWidget {
  const TeamPlayersDisplayWidget({super.key, required this.team});
  final Team team;

  List<Player> posisionList(int pos) {
    return team.players.where((player) => player.position == pos).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          playersCard(0, posisionList(0)),
          playersCard(1, posisionList(1)),
          playersCard(2, posisionList(2)),
          playersCard(3, posisionList(3)),
        ],
      ),
    ));
  }

  Widget playersCard(int position, List<Player> players) {
    String pos;
    if (position == 0) {
      pos = "Τερματοφύλακας";
    } else if (position == 1) {
      pos = "Αμυντικός";
    } else if (position == 2) {
      pos = "Μέσος";
    } else {
      pos = "Επιθετικός";
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: (ShapeDecoration(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Color.fromARGB(20, 10, 20, 15))),

        //elevation: 4,
        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                pos,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 8),
              child: Column(
                children: players
                    .map((player) => Column(
                          children: [
                            playerName(player),
                            Divider(height: 10,thickness: 1,color: Colors.black45,)
                          ],
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget playerName(Player player) {
    return Column(
      children: [
        Row(children: [
          SizedBox(
              width: 31, height: 31, child: Image.asset('fotos/randomUserPic.png')),
          SizedBox(
            width: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${player.name} ${player.surname}",),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("${player.number}",style: TextStyle(color: Colors.black45),),
                  Text("   ${player.age} έτη",style: TextStyle(color: Colors.black45)),
                ],
              ),
            ],
          )
        ]),
        SizedBox(height: 3,),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
        //   child: Container(height: 1,width: double.infinity,color: Colors.black,),
        // )
      ],
    );
  }
}
