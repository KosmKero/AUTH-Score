import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/API/top_players_handle.dart';
import 'package:untitled1/main.dart';

import '../Data_Classes/Player.dart';

class TopPlayersProvider extends StatelessWidget {

  const TopPlayersProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TopPlayersHandle(),
      child: Consumer<TopPlayersHandle>(
        builder: (context, topPlayersHandle, child) {
          return _TopPlayersPage(topPlayersHandle.topPlayers);
        },
      ),
    );
  }
}

class _TopPlayersPage extends StatefulWidget {
  _TopPlayersPage(this.playersList){
    print(playersList.length);
  }
  final List<Player> playersList;
  @override
  State<_TopPlayersPage> createState() => _TopPlayersView();
}

class _TopPlayersView extends State<_TopPlayersPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(height: 20),
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
              },
            ),
          ),
        ],
      ),
    );
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
            Text("${player.name} ${player.surname}"),
            Text(player.position == 2
                ? "Επιθετικός"
                : player.position == 1
                    ? "Μέσος"
                    : "Τερματοφύλακας")
          ],
        ),
        Text(player.goals.toString())
      ],
    );
  }
}
