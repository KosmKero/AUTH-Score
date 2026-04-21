import 'package:flutter/material.dart';
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
  State<TeamPlayersDisplayWidget> createState() =>
      _TeamPlayersDisplayWidgetState();
}

class _TeamPlayersDisplayWidgetState extends State<TeamPlayersDisplayWidget> {
  List<Player> positionList(int pos) {
    return widget.team.players
        .where((player) => player.position == pos)
        .toList();
  }

  void _updatePlayerList(Player newPlayer) {
    setState(() {
      widget.team.addPlayer(newPlayer);
    });
  }

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(
        screenName: 'Team players', screenClass: 'Team players page');

    bool isCaptain = globalUser.controlTheseTeamsFootball(widget.team.name, null) || globalUser.isUpperAdmin;

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(), // Πιο ομαλό scroll
        child: Column(
          children: [
            if (isCaptain)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    onPressed: _openAddPlayerScreen,
                    icon: const Icon(Icons.add),
                    label: Text(greek ? "Προσθήκη" : "Add"),
                  ),
                ),
              ),

            _buildPositionSection(0, positionList(0)),
            _buildPositionSection(1, positionList(1)),
            _buildPositionSection(2, positionList(2)),
            _buildPositionSection(3, positionList(3)),

            if (isCaptain)
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 30, left: 16, right: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.3))
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blueAccent),
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
        builder: (context) => AddPlayerScreen(
          team: widget.team,
          onPlayerAdded: _updatePlayerList,
        ),
      ),
    );

    if (newPlayer != null && newPlayer is Player && mounted) {
      setState(() {});
    }
  }

  Widget _buildPositionSection(int position, List<Player> players) {
    if (players.isEmpty) return const SizedBox.shrink(); // Αν δεν έχει παίκτες, μην δείχνεις άδειο κουτί

    String pos;
    if (position == 0) {
      pos = greek ? "Τερματοφύλακες" : "Goalkeepers";
    } else if (position == 1) {
      pos = greek ? "Αμυντικοί" : "Defenders";
    } else if (position == 2) {
      pos = greek ? "Μέσοι" : "Midfielders";
    } else {
      pos = greek ? "Επιθετικοί" : "Forwards";
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

  Widget playerName(Player player) {
    bool isCaptain = globalUser.controlTheseTeamsFootball(widget.team.name, null) || globalUser.isUpperAdmin;
    bool isDark = darkModeNotifier.value;

    return GestureDetector(
      onDoubleTap: isCaptain ? () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerEditPage(
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
        color: Colors.transparent, // Για να πιάνει το tap σε όλο το πλάτος
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Κυκλικό Avatar με το νούμερο της φανέλας μέσα
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isDark ? Colors.grey[700] : Colors.blue[100],
                  child: Text(
                    player.number.toString(),
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.blue[900],
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

              ],
            ),

            if (isCaptain)
              Padding(
                padding: const EdgeInsets.only(left: 48.0, top: 6.0),
                child: Row(
                  children: [
                    // 1. Συμμετοχές
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "${greek ? 'Συμμετοχές' : 'Apps'}: ${player.appearances}",
                        style: const TextStyle(fontSize: 11, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // 2. Κάρτα Υγείας
                    _buildHealthCardStatus(player.cardExpiryDate),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Ελέγχει την ημερομηνία και επιστρέφει το πατητό εικονίδιο (Tooltip)
  Widget _buildHealthCardStatus(DateTime? issueDate) {
    if (issueDate == null) {
      return const Tooltip(
        message: "Χωρίς Κάρτα Υγείας",
        triggerMode: TooltipTriggerMode.tap,
        showDuration: Duration(seconds: 3),
        child: Icon(Icons.error, color: Colors.red, size: 18),
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final expiration = DateTime(issueDate.year + 1, issueDate.month, issueDate.day);
    final daysLeft = expiration.difference(today).inDays;

    if (daysLeft < 0) {
      return const Tooltip(
        message: "Ληγμένη Κάρτα!",
        triggerMode: TooltipTriggerMode.tap,
        showDuration: Duration(seconds: 3),
        child: Icon(Icons.cancel, color: Colors.red, size: 18), // Λίγο μικρότερο εικονίδιο για κομψότητα
      );
    } else if (daysLeft <= 30) {
      return Tooltip(
        message: "Λήγει σε $daysLeft μέρες",
        triggerMode: TooltipTriggerMode.tap,
        showDuration: const Duration(seconds: 3),
        child: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
      );
    } else {
      return const Tooltip(
        message: "Έγκυρη Κάρτα Υγείας",
        triggerMode: TooltipTriggerMode.tap,
        showDuration: Duration(seconds: 2),
        child: Icon(Icons.check_circle, color: Colors.green, size: 18),
      );
    }
  }
}