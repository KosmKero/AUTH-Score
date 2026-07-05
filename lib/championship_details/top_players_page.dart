import 'package:cached_network_image/cached_network_image.dart';
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
  // Βοηθητική συνάρτηση για τη θέση
  String getPositionName(int pos) {
    if (pos == 3) return "Επιθετικός";
    if (pos == 2) return "Μέσος";
    if (pos == 1) return "Αμυντικός";
    return "Τερματοφύλακας";
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = darkModeNotifier.value;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
                : [lightModeBackGround, lightModeBackGround.withValues(alpha: 0.8)],
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
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.sports_soccer,
                      color: isDark ? Colors.white : Colors.black,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      greek ? "Κορυφαίοι Σκόρερ" : "Top Scorers",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
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
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.playersList.length > 15 ? 15 : widget.playersList.length,
                  itemBuilder: (context, index) {
                    return playerCard(widget.playersList[index], index, isDark);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget playerCard(Player player, int i, bool isDark) {

    final String imageUrl = "https://firebasestorage.googleapis.com/v0/b/auth-score-742c5.firebasestorage.app/o/logos%2F${player.teamNameEnglish.toUpperCase()}.png?alt=media&v=2";

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.1),
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
                        : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      (i + 1).toString(),
                      style: TextStyle(
                        color: i < 3 ? Colors.white : (isDark ? Colors.white : Colors.black),
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
                    color: Colors.white, // Κρατάμε το άσπρο φόντο για να φαίνονται καλά τα PNG
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (context, url) => Image.asset('fotos/default_team_logo.png', fit: BoxFit.contain),
                    errorWidget: (context, url, error) => Image.asset('fotos/default_team_logo.png', fit: BoxFit.contain),
                    fit: BoxFit.contain,
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
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    getPositionName(player.position),
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.black.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: darkModeNotifier.value
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                player.goals.toString(),
                style: TextStyle(
                  color:  darkModeNotifier.value ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w900, // Πολύ παχύ για να ξεχωρίζει
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}