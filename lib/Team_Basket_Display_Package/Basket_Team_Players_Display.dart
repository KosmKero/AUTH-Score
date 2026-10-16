import 'package:flutter/material.dart';
// TODO: Βάλε τα σωστά imports του Μπάσκετ σου
import '../../Data_Classes/basketball/basketPlayer.dart';
import '../../Data_Classes/basketball/basketTeam.dart';
import '../../Firebase_Handle/firebase_screen_stats_helper.dart';
import '../../globals.dart';
import 'add_player_screen_basketball.dart';
import 'edit_player_page_basketball.dart';

class BasketballTeamPlayersDisplayWidget extends StatefulWidget {
  const BasketballTeamPlayersDisplayWidget({super.key, required this.team});
  final basketTeam team;

  @override
  State<BasketballTeamPlayersDisplayWidget> createState() =>
      _BasketballTeamPlayersDisplayWidgetState();
}

class _BasketballTeamPlayersDisplayWidgetState extends State<BasketballTeamPlayersDisplayWidget> {

  List<BasketPlayer> positionList(int pos) {
    return widget.team.players
        .where((player) => player.position == pos)
        .toList();
  }

  void _updatePlayerList(BasketPlayer newPlayer) {
    setState(() {
      widget.team.addPlayer(newPlayer);
    });
  }

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Basket Team players', screenClass: 'Basket Team players page');

    bool isCaptain = globalUser.controlTheseTeamsBasket(widget.team.name, widget.team.nameEnglish) || globalUser.isUpperAdmin;

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            if (isCaptain)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600], // Πορτοκαλί για μπάσκετ!
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    onPressed: _openAddPlayerScreen,
                    icon: const Icon(Icons.add),
                    label: Text(greek ? "Προσθήκη" : "Add"),
                  ),
                ),
              ),

            // ΟΙ 3 ΒΑΣΙΚΕΣ ΚΑΤΗΓΟΡΙΕΣ
            _buildPositionSection(1, positionList(1)),
            _buildPositionSection(2, positionList(2)),
            _buildPositionSection(3, positionList(3)),

            if (isCaptain)
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 30, left: 16, right: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orangeAccent.withOpacity(0.3))
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orangeAccent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          greek
                              ? "Για να επεξεργαστείς ένα παίκτη κάνε double-tap πάνω του."
                              : "To edit a player, double-tap on their name.",
                          style: TextStyle(
                              fontSize: 13,
                              color: darkModeNotifier.value ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAddPlayerScreen() async {
     final newPlayer = await Navigator.push(
       context,
       MaterialPageRoute(
         builder: (context) => BasketballAddPlayerScreen(
           team: widget.team,
           onPlayerAdded: _updatePlayerList,
         ),
       ),
     );

     if (newPlayer != null && newPlayer is BasketPlayer && mounted) {
       setState(() {});
     }
  }

  Widget _buildPositionSection(int position, List<BasketPlayer> players) {
    if (players.isEmpty) return const SizedBox.shrink();

    String pos;
    // ΟΙ 3 ΘΕΣΕΙΣ ΜΕ ΕΛΛΗΝΙΚΗ ΜΕΤΑΦΡΑΣΗ
    if (position == 1) {
      pos = greek ? "Γκαρντ" : "Guards";
    } else if (position == 2) {
      pos = greek ? "Φόργουορντ" : "Forwards";
    } else {
      pos = greek ? "Σέντερ" : "Centers";
    }

    players.sort((a, b) => a.number.compareTo(b.number));

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
          color: darkModeNotifier.value ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: darkModeNotifier.value ? Colors.grey[900] : Colors.grey[50],
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))
            ),
            child: Text(
              pos,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkModeNotifier.value ? Colors.white : Colors.black87),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Column(
              children: players.map((player) => playerName(player)).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget playerName(BasketPlayer player) {
    bool isCaptain = globalUser.controlTheseTeamsBasket(widget.team.name, widget.team.nameEnglish) || globalUser.isUpperAdmin;
    bool isDark = darkModeNotifier.value;

    return GestureDetector(
      onDoubleTap: isCaptain ? () async {
         final result = await Navigator.push(
           context,
           MaterialPageRoute(
             builder: (context) => BasketballPlayerEditPage(
               player: player,
               team: widget.team,
             ),
           ),
         );

         if (result != null && mounted) {
           setState(() {});
         }
      } : null,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: isDark ? Colors.grey[700] : Colors.orange[100],
              child: Text(
                player.number.toString(),
                style: TextStyle(
                    color: isDark ? Colors.white : Colors.orange[900],
                    fontWeight: FontWeight.bold,
                    fontSize: 14
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "${player.surname} ${player.name}",
                style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Πόντοι του παίκτη
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "${player.points} pts",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}