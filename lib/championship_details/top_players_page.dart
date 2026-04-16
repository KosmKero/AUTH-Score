import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/API/top_players_handle.dart';

import '../Data_Classes/Player.dart';
import '../Data_Classes/Team.dart';
import '../Firebase_Handle/firebase_screen_stats_helper.dart';
import '../globals.dart';

class TopPlayersProvider extends StatelessWidget {
  final List<Team> teamsList;

  const TopPlayersProvider({super.key, required this.teamsList});

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Top Players Page', screenClass: 'Top Players Page');

    return ChangeNotifierProvider(
      create: (_) {
        final handle = TopPlayersHandle();
        handle.initializeList(teamsList);
        return handle;
      },
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: darkModeNotifier.value
                ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
                : [lightModeBackGround, lightModeBackGround.withOpacity(0.8)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: darkModeNotifier.value ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.sports_soccer,
                      color: darkModeNotifier.value ? Colors.white : Colors.black,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Κορυφαίοι Σκόρερ",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkModeNotifier.value ? Colors.white : Colors.black,
                        fontFamily: "Arial",
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Players List
              Expanded(
                child: ListView.builder(
                  itemCount: widget.playersList.length > 15 ? 15 : widget.playersList.length,
                  itemBuilder: (context, index) {
                    return playerCard(widget.playersList[index], index);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget playerCard(Player player, int i) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12), // Το padding μπήκε στο Container
        decoration: BoxDecoration(
          color: darkModeNotifier.value
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: darkModeNotifier.value
                  ? Colors.black.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Rank and Team Logo
            SizedBox(
              width: 80,
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: i < 3
                          ? const [Colors.amber, Color(0xFFC0C0C0), Color(0xFFCD7F32)][i]
                          : darkModeNotifier.value
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        (i + 1).toString(),
                        style: TextStyle(
                          color: i < 3 ? Colors.white : (darkModeNotifier.value ? Colors.white : Colors.black),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 32,
                    width: 32,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: darkModeNotifier.value
                              ? Colors.black.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'logos/${player.teamNameEnglish}.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'fotos/default_team_logo.png',
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Player Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${player.name} ${player.surname}",
                      style: TextStyle(
                        color: darkModeNotifier.value ? Colors.white : Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      player.position == 3
                          ? "Επιθετικός"
                          : player.position == 2
                          ? "Μέσος"
                          : player.position == 1
                          ? "Αμυντικός"
                          : "Τερματοφύλακας",
                      style: TextStyle(
                        color: darkModeNotifier.value
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Goals
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: darkModeNotifier.value
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  player.goals.toString(),
                  style: TextStyle(
                    color: darkModeNotifier.value ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}