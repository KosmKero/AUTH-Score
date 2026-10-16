import 'package:flutter/material.dart';
// TODO: Βάλε τα σωστά imports του Μπάσκετ σου
import '../../API/BasketballMatchHandle.dart';
import '../../Firebase_Handle/BasketTeamsHandle.dart';
import '../../Data_Classes/basketball/basketMatch.dart';
import '../../Data_Classes/basketball/basketTeam.dart';
import '../../Firebase_Handle/firebase_screen_stats_helper.dart';
import '../../globals.dart';
import '../SeletonTopScorers.dart';
import '../SkeletonKnockOuts.dart';
import '../SkeletonLoading.dart';
import 'basketball_knock_outs_page.dart';
import 'basketball_standings_page.dart';


class BasketballStandingsOrKnockoutsChooserPage extends StatefulWidget {
  const BasketballStandingsOrKnockoutsChooserPage({super.key});

  @override
  State<BasketballStandingsOrKnockoutsChooserPage> createState() => _BasketChooserState();
}

class _BasketChooserState extends State<BasketballStandingsOrKnockoutsChooserPage> {
  int indexChoice = 0;

  void _changeSection(int index) {
    setState(() {
      indexChoice = index;
    });
  }

  int selectedSeason = thisYearNow;
  List<int> seasons = [2026, 2025];

  List<basketTeam> teamList = []; // Αλλαγή σε basketTeam
  Map<int, BasketMatch> playOffMatches = {}; // Αλλαγή
  List<BasketMatch> currentSeasonGroupMatches = []; // Αλλαγή

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeMatches();
  }

  Future<void> initializeMatches() async {
    try {
      // Τραβάμε τα δεδομένα του Μπάσκετ
      var list = await BasketTeamsHandle().getAllTeamsByYear(selectedSeason);
      var initialPlayOffs = await BasketTeamsHandle().getPlayOffMatches(selectedSeason);
      var listM = await BasketballMatchHandle().getMatchesByYear(selectedSeason, list);

      if (mounted) {
        setState(() {
          teamList = list;
          playOffMatches = initialPlayOffs;
          currentSeasonGroupMatches = listM;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: darkModeNotifier.value ? const Color(0xFF121212) : lightModeBackGround,
      child: Column(
        children: [
          // Το μενού επιλογής Χρονιάς
          DropdownButton<int>(
            dropdownColor: darkModeNotifier.value ? const Color(0xFF121212) : Colors.white,
            value: selectedSeason,
            items: seasons.map((season) {
              return DropdownMenuItem<int>(
                value: season,
                child: Text("${season - 1}-$season", style: TextStyle(color: darkModeNotifier.value ? Colors.white : Colors.black87)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null && value != selectedSeason) {
                setState(() {
                  isLoading = true;
                  selectedSeason = value;
                });
                initializeMatches();
              }
            },
          ),

          // Τα 3 κουμπιά (Το widget _NavigationButtons παραμένει ίδιο με του ποδοσφαίρου, απλά αντίγραψέ το από το αρχείο σου)
          _NavigationButtonsBasket(onSectionChange: _changeSection),

          isLoading
              ? (indexChoice == 0 ? const SkeletonStandings() : indexChoice == 1 ? const SkeletonKnockouts() : const SkeletonTopPlayers())
              : indexChoice == 0
              ? BasketballStandingsPage(selectedSeason, teamList, currentSeasonGroupMatches) // Καλεί το Standings του Basket
              : (indexChoice == 1)
              ? BasketballKnockOutsPage(key: ValueKey(selectedSeason), playOffMatches: playOffMatches) // Καλεί τα KnockOuts του Basket
              : BasketballTopPlayersPage([]) // TODO: Δώσε τη λίστα με τους παίκτες του Μπάσκετ
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Το _NavigationButtonsBasket (Ακριβής αντιγραφή από το δικό σου αρχείο)
class _NavigationButtonsBasket extends StatefulWidget {
  final Function(int) onSectionChange;
  const _NavigationButtonsBasket({required this.onSectionChange});
  @override
  State<_NavigationButtonsBasket> createState() => _NavigationButtonsBasketState();
}

class _NavigationButtonsBasketState extends State<_NavigationButtonsBasket> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(width: 10),
          _buildTextButton(greek ? "Βαθμολογία" : "Standings", 0),
          const SizedBox(width: 15),
          _buildTextButton(greek ? "Νοκ Άουτ" : "Knock out", 1),
          const SizedBox(width: 15),
          _buildTextButton(greek ? "Κορυφαίοι Παίχτες" : "Best players", 2),
        ],
      ),
    );
  }
  Widget _buildTextButton(String text, int index) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => selectedIndex = index);
        widget.onSectionChange(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: TextStyle(fontSize: 16, color: isSelected ? Colors.orange : (darkModeNotifier.value ? Colors.white : Colors.black87), fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
          const SizedBox(height: 3),
          if (isSelected) Container(width: 70, height: 3, color: Colors.orange), // Έβαλα πορτοκαλί για να θυμίζει μπάσκετ!
        ],
      ),
    );
  }
}