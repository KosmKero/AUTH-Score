import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Data_Classes/Player.dart';
import '../Data_Classes/Team.dart';
import '../Firebase_Handle/firebase_screen_stats_helper.dart';
import '../globals.dart';
import 'add_player_page.dart';
import 'edit_player_page.dart';

class TeamPlayersDisplayWidget extends StatefulWidget {
  const TeamPlayersDisplayWidget({super.key, required this.team});
  final Team team;

  @override
  State<TeamPlayersDisplayWidget> createState() => _TeamPlayersDisplayWidgetState();
}

class _TeamPlayersDisplayWidgetState extends State<TeamPlayersDisplayWidget> {
  List<Player> positionList(int pos) {
    return widget.team.players.where((player) => player.position == pos).toList();
  }

  void _updatePlayerList(Player newPlayer) {
    setState(() {
      widget.team.addPlayer(newPlayer);  // Προσθέτουμε τον νέο παίκτη στην ομάδα
    });
  }

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Team players',screenClass: 'Team players page');


    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            (globalUser.controlTheseTeams(widget.team.name,null)) ? addPlayer() : SizedBox.shrink(),
            playersCard(0, positionList(0)),
            playersCard(1, positionList(1)),
            playersCard(2, positionList(2)),
            playersCard(3, positionList(3)),
            if((globalUser.controlTheseTeams(widget.team.name,null)))
              Padding(
                padding: EdgeInsets.only(top: 20,left: 10),
                child: Text(
                  greek? "*Για να επεξεργαστείς ένα παίκτη κάνε double-tap πάνω του.": "*To edit a player, double-tap on their name.",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Arial',
                    color: darkModeNotifier.value ? Colors.white : Colors.black
                  ),
                ),
              ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
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
    players.sort((a, b) => a.number.compareTo(b.number));

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color:darkModeNotifier.value? Color(0xFF121212):Colors.white,
        ),
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
                  fontFamily: 'Arial',
                  color: darkModeNotifier.value?Colors.white:Colors.black
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
                    Divider(height: 10, thickness: 1, color: darkModeNotifier.value?Colors.white:Colors.black)
                  ],
                )).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget playerName(Player player) {
    return GestureDetector(
      onDoubleTap: (globalUser.controlTheseTeams(widget.team.name,null)) ?  () async {
        final updatedPlayer = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerEditPage(
              player: player,
              team: widget.team,
            ),
          ),
        );
        if (updatedPlayer is bool && updatedPlayer==true){
          setState(() {
            final index = widget.team.players.indexWhere((p) => p.name == player.name && p.number==player.number);
            if (index != -1) {
              widget.team.players.removeAt(index);
            }
          });
        } else if (updatedPlayer != null && updatedPlayer is Player) {
          setState(() {
           //Βρες τη θέση του παλιού παίκτη και αντικατάστησέ τον
           final index = widget.team.players.indexWhere((p) => p.name == player.name && p.number==player.number);
           if (index != -1) {
             widget.team.players[index] = updatedPlayer;
           }

          });
        }
      } : null,

      child: Column(
        children: [
          Row(children: [
            SizedBox(
                width: 31, height: 31, child: Image.asset('fotos/randomUserPic.png')),
            SizedBox(width: 10),
            Text(" ${player.number < 10 ? ' ${player.number}' : '${player.number}'}", style: TextStyle(color: darkModeNotifier.value?Colors.white:Colors.black,
                fontFamily: "Arial",
                fontSize: 15,
                fontWeight: FontWeight.bold
            )
            ),
            SizedBox(width: 10,),

                Text(" ${player.name} ${player.surname}",
                style: TextStyle(
                  color:darkModeNotifier.value?Colors.white:Colors.black,
                  fontFamily: "Arial",
                  fontSize: 16.5
                ),),
                //για ηλικία παικτών
                //Row(
                //  mainAxisAlignment: MainAxisAlignment.start,
                //  children: [
//
                //    Text("  ${player.age} έτη", style: TextStyle(color:darkModeNotifier.value?Colors.white:Colors.black,
                //      fontFamily: "Arial",
                //      fontSize: 15
                //      )
                //    ),
                //  ],
                //),

          ]),
          SizedBox(height: 3),
        ],
      ),
    );
  }


  Widget addPlayer() {
    return IconButton(
      onPressed: () async {
        final newPlayer = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddPlayerScreen(
              team: widget.team,
              onPlayerAdded: _updatePlayerList,  // Περνάμε το callback
            ),
          ),
        );

        // Αν το νέο player δεν είναι null, ανανεώνουμε την UI με το setState
        if (newPlayer != null && newPlayer is Player) {
          setState(() {});
        }
      },
      icon: Icon(
        Icons.add,
        color: darkModeNotifier.value?Colors.white:Colors.black,
      ),
    );
  }
}

