import 'package:flutter/material.dart';
import 'package:untitled1/API/Match_Handle.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';
import 'package:untitled1/main.dart';
import '../Data_Classes/MatchDetails.dart';
import '../Data_Classes/Team.dart';
import '../Firebase_Handle/firebase_screen_stats_helper.dart';
import '../globals.dart';
import '../mContainers/matchesContainer.dart';

class FootballFavoritePage extends StatefulWidget {
  const FootballFavoritePage({super.key});

  @override
  State<FootballFavoritePage> createState() => _FavoriteContainerState();
}

class _FavoriteContainerState extends State<FootballFavoritePage> {
  late List<MatchDetails> teamMatches = [];
  Team? selectedTeam; // Το null σημαίνει "Όλες οι αγαπημένες ομάδες"

  Future<void> loadFavouriteTeams() async {
    TeamsHandle teamsHandle = TeamsHandle();
    favouriteTeamsFootball = teamsHandle.getAllFavouriteTeams(globalUser.username);

    if (favouriteTeamsFootball.isNotEmpty) {
      // Ξεκινάμε δείχνοντας "Όλες" (null) αντί για μόνο την πρώτη ομάδα!
      selectedTeam = null;
      refreshList();
    } else {
      selectedTeam = null;
    }

    setState(() {}); // Για να ανανεώσει το UI με τα νέα δεδομένα
  }

  @override
  void initState() {
    super.initState();
    loadFavouriteTeams();
  }

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Favorite teams page', screenClass: 'Favorite teams page');

    return Scaffold(
      backgroundColor: darkModeNotifier.value ? const Color(0xFF121212) : lightModeBackGround,
      body: Column(
        children: [
          // 1. Το νέο σταθερό οριζόντιο μενού με τα Chips
          if (favouriteTeamsFootball.isNotEmpty)
            Container(
              height: 60, // Σταθερό ύψος για να μην χαλάει το layout
              width: double.infinity,
        color: darkModeNotifier.value ? const Color(0xFF121212) : lightModeBackGround,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                itemCount: favouriteTeamsFootball.length + 1, // +1 για την επιλογή "Όλες"
                itemBuilder: (context, index) {
                  bool isAllOption = index == 0;
                  Team? currentChipTeam = isAllOption ? null : favouriteTeamsFootball[index - 1];
                  bool isSelected = selectedTeam == currentChipTeam;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      // 1. Μεγαλύτερο padding για να "αναπνέει" το κείμενο
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

                      label: Text(
                        isAllOption ? (greek ? 'ΟΛΕΣ' : 'ALL') : currentChipTeam!.displayName,
                        style: TextStyle(
                          fontSize: 14.5, // Ελάχιστα μεγαλύτερο
                          fontFamily: "Arial",
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? Colors.white // Λευκά γράμματα στο επιλεγμένο
                              : (darkModeNotifier.value ? Colors.white70 : Colors.black87),
                        ),
                      ),
                      selected: isSelected,
                      showCheckmark: false, // Κρατάμε κρυφό το "τικάκι" για μινιμαλισμό

                      // 2. Χρώματα
                      selectedColor: const Color.fromARGB(250, 46, 90, 136), // Το όμορφο ναυτικό μπλε που έχεις στο AppBar
                      backgroundColor: darkModeNotifier.value ? Colors.grey[900] : Colors.white,

                      // 3. Σκιά μόνο όταν είναι επιλεγμένο
                      elevation: isSelected ? 4 : 0,
                      pressElevation: 0,

                      // 4. Μοντέρνο Σχήμα (Απαλές καμπύλες + Διακριτικό περίγραμμα στα μη επιλεγμένα)
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25), // Πολύ στρογγυλεμένο
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent // Αν είναι πατημένο, κρύβουμε το περίγραμμα
                              : (darkModeNotifier.value ? Colors.grey[800]! : Colors.grey[300]!), // Διακριτικό περίγραμμα αλλιώς
                          width: 1.2,
                        ),
                      ),

                      onSelected: (bool selected) {
                        setState(() {
                          selectedTeam = currentChipTeam;
                          refreshList();
                        });
                      },
                    )
                  );
                },
              ),
            ),

          // 2. Οι αγώνες παίρνουν τον υπόλοιπο χώρο τέλεια
          Expanded(
            child: isLoggedIn
                ? (favouriteTeamsFootball.isNotEmpty
                ? matchesContainer(matches: teamMatches, type: 2)
                : Center(
              child: Text(
                greek
                    ? "Δεν έχεις ακόμα αγαπημένες ομάδες"
                    : "You don't have any favorite teams yet",
                style: TextStyle(
                  fontSize: greek ? 23 : 21,
                  fontWeight: FontWeight.bold,
                  color: darkModeNotifier.value ? Colors.white : Colors.black87,
                  fontFamily: "Arial",
                ),
                textAlign: TextAlign.center,
              ),
            ))
                : Center(
              child: Text(
                greek
                    ? "Πρέπει να είσαι συνδεδεμένος για να δεις τις αγαπημένες σου ομάδες"
                    : "You must be signed in to see your favorite teams!",
                style: TextStyle(
                  fontSize: greek ? 23 : 21,
                  fontWeight: FontWeight.bold,
                  color: darkModeNotifier.value ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }

  // 3. Η αναβαθμισμένη μέθοδος ανανέωσης λίστας
  List<MatchDetails> refreshList() {
    teamMatches.clear();

    if (favouriteTeamsFootball.isNotEmpty) {
      // Καλούμε τη βάση μία φορά εκτός loop για μέγιστη απόδοση
      List<MatchDetails> allMatches = MatchHandle().getAllMatches();

      for (MatchDetails match in allMatches) {
        if (selectedTeam == null) {
          // Αν έχει πατηθεί το "Όλες", κοιτάμε αν η γηπεδούχος ή η φιλοξενούμενη είναι στα αγαπημένα γενικώς
          bool isFavMatch = favouriteTeamsFootball.any((t) => t.name == match.homeTeam.name || t.name == match.awayTeam.name);
          if (isFavMatch) {
            teamMatches.add(match);
          }
        } else {
          // Αν έχει πατηθεί συγκεκριμένη ομάδα
          if (match.homeTeam.name == selectedTeam!.name || match.awayTeam.name == selectedTeam!.name) {
            teamMatches.add(match);
          }
        }
      }
    }
    return teamMatches;
  }
}