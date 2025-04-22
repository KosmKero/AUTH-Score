import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/API/top_players_handle.dart';
import 'package:untitled1/Match_Details_Package/Match_Not_Started/DetailsMatchNotStarted.dart';
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
                      return FutureBuilder<Widget>(
                        future: playerCard(widget.playersList[index], index),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: LinearProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Text("Σφάλμα φόρτωσης κάρτας παίκτη");
                          } else {
                            return Column(
                              children: [
                                snapshot.data!,
                                Divider(
                                  thickness: 1,
                                  color: darkModeNotifier.value ? Colors.white : Colors.black,
                                ),
                              ],
                            );
                          }
                        },
                      );
                    },
                  ),
                )
              ]),
              ),
        ));
  }

  Future<Widget> playerCard(Player player, int i) async {
    Image image = await loadTeamImage(player.teamName);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 80, // ή όσο χρειάζεται
          child: Row(
            children: [
              Text(
                (i + 1).toString(),
                style: TextStyle(
                  color: darkModeNotifier.value ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(width: 10),
              Container(
                height: 40,
                width: 40,
                padding: EdgeInsets.all(6),
                decoration: darkModeNotifier.value
                    ? BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                )
                    : null,
                child: image,
              ),
            ],
          ),
        ),
        SizedBox(
          width: 160, // ίδιο πλάτος για να ευθυγραμμιστούν
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${player.name} ${player.surname}",
                style: TextStyle(color: Colors.white, fontSize: 15.5),
              ),
              Text(
                player.position == 3
                    ? "Επιθετικός"
                    : player.position == 2
                    ? "Μέσος"
                    : player.position == 1
                    ? "Αμυντικός"
                    : "Τερματοφύλακας",
                style: TextStyle(color: Colors.white, fontSize: 15.5),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 40, // για γκολ
          child: Text(
            player.goals.toString(),
            style: TextStyle(color: Colors.white, fontSize: 15.5),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }


  Future<bool> assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Image> loadTeamImage(String teamName) async {
    String path = 'logos/$teamName.png';
    bool exists = await assetExists(path);

    return Image.asset(
      exists ? path : 'fotos/default_team_logo.png',
      fit: BoxFit.contain,
    );
  }

}
