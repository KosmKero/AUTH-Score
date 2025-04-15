import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/API/top_players_handle.dart';
import 'package:untitled1/main.dart';

import '../Data_Classes/Player.dart';
import '../globals.dart';

class TopPlayersProvider extends StatelessWidget {

  const TopPlayersProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TopPlayersHandle(),
      child: Consumer<TopPlayersHandle>(
        builder: (context, topPlayersHandle, child) {
          return TopPlayersPage(topPlayersHandle.topPlayers);
        },
      ),
    );
  }
}

class TopPlayersPage extends StatefulWidget {
  const TopPlayersPage(this.playersList, {super.key});
  final List<Player> playersList;
  @override
  State<TopPlayersPage> createState() => _TopPlayersView();
}

class _TopPlayersView extends State<TopPlayersPage> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
          color: darkModeNotifier.value?Color(0xFF121212): lightModeBackGround,
          child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10,horizontal: 16),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Ευθυγραμμίζει το κείμενο αριστερά
              children: [
              // Προσθήκη του τίτλου
              Text(
              "Γκολ",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                color: Colors.white
              ),
              ),
              SizedBox(height: 10), // Απόσταση πριν από τη λίστα

              // Λίστα παικτών
              Expanded(
              child: ListView.builder(
              itemCount: widget.playersList.length,
              itemBuilder: (context, index) {
              return Column(
              children: [
              playerCard(widget.playersList[index], index),
              Divider(thickness: 1, color: Colors.black),
              ],
              );
              }))]),
              ),
        ));
  }

  Widget playerCard(Player player, int i) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text((i + 1).toString()),
            SizedBox(width: 10,),
            SizedBox(
                height: 40,
                width: 40,
                child: Image.asset('fotos/randomUserPic.png')
            ),
          ],
        ),

        Column(
          children: [
            Text("${player.name} ${player.surname}",
              style: TextStyle(color:Colors.white,
                  fontFamily: "Arial",
                fontSize: 15.5
              )
              ,),
            Text(player.position == 3 ? "Επιθετικός" : player.position == 2 ? "Μέσος" : player.position == 1?"Αμυντικός":"Τερματοφύλακας",
               style: TextStyle(
                   color:Colors.white,
                   fontFamily: "Arial",
                   fontSize: 15.5
               ),
            )
          ],
        ),
        Text(player.goals.toString(),
        style: TextStyle(
            color:Colors.white,
            fontFamily: "Arial",
            fontSize: 15.5
        ),)
      ],
    );
  }
}
