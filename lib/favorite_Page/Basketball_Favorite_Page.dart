import 'package:flutter/material.dart';
import 'package:untitled1/API/BasketballMatchHandle.dart';
import 'package:untitled1/Firebase_Handle/BasketTeamsHandle.dart';
import 'package:untitled1/main.dart';
import '../Data_Classes/basketball/basketMatch.dart'; // Αντικατάσταση
import '../Data_Classes/basketball/basketTeam.dart'; // Αντικατάσταση
import '../Firebase_Handle/firebase_screen_stats_helper.dart';
import '../globals.dart';
import '../mContainers/BasketballContainer.dart';

class BasketballFavoritePage extends StatefulWidget {
  const BasketballFavoritePage({super.key});

  @override
  State<BasketballFavoritePage> createState() => _BasketballFavoritePageState();
}

class _BasketballFavoritePageState extends State<BasketballFavoritePage> {
  // Αλλάξαμε τον τύπο της λίστας
  late List<BasketMatch> teamMatches = [];

  // Αλλάξαμε τον τύπο της ομάδας
  basketTeam? selectedTeam; // Το null σημαίνει "Όλες οι αγαπημένες ομάδες"

  Future<void> loadFavouriteTeams() async {
    // Χρησιμοποιούμε το Handle του Μπάσκετ
    BasketTeamsHandle teamsHandle = BasketTeamsHandle();

    // ΠΡΟΣΟΧΗ: Χρειάζεσαι μια ξεχωριστή λίστα στο globals.dart (π.χ. favouriteBasketTeams)
    favoriteTeamsBasket = BasketTeamsHandle().getAllFavouriteTeams(globalUser.username);

    if (favoriteTeamsBasket.isNotEmpty) {
      selectedTeam = null;
      refreshList();
    } else {
      selectedTeam = null;
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadFavouriteTeams();
  }

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Favorite Basket teams page', screenClass: 'Favorite Basket teams page');

    return Scaffold(
      backgroundColor: darkModeNotifier.value ? const Color(0xFF121212) : lightModeBackGround,
      body: Column(
        children: [
          if (favoriteTeamsBasket.isNotEmpty)
            Container(
              height: 60,
              width: double.infinity,
              color: darkModeNotifier.value ? const Color(0xFF121212) : lightModeBackGround,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                itemCount: favoriteTeamsBasket.length + 1,
                itemBuilder: (context, index) {
                  bool isAllOption = index == 0;
                  // Αλλάξαμε τον τύπο σε basketTeam
                  basketTeam? currentChipTeam = isAllOption ? null : favoriteTeamsBasket[index - 1];
                  bool isSelected = selectedTeam == currentChipTeam;

                  return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        label: Text(
                          isAllOption ? (greek ? 'ΟΛΕΣ' : 'ALL') : currentChipTeam!.name,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontFamily: "Arial",
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (darkModeNotifier.value ? Colors.white70 : Colors.black87),
                          ),
                        ),
                        selected: isSelected,
                        showCheckmark: false,
                        selectedColor: const Color.fromARGB(250, 46, 90, 136),
                        backgroundColor: darkModeNotifier.value ? Colors.grey[900] : Colors.white,
                        elevation: isSelected ? 4 : 0,
                        pressElevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : (darkModeNotifier.value ? Colors.grey[800]! : Colors.grey[300]!),
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

          Expanded(
            child: isLoggedIn
                ? (favoriteTeamsBasket.isNotEmpty
            // Χρησιμοποιούμε το BasketballContainer
                ? BasketballContainer(matches: teamMatches, type: 2)
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

  List<BasketMatch> refreshList() {
    teamMatches.clear();

    if (favoriteTeamsBasket.isNotEmpty) {
      // Τραβάμε τα ματς του μπάσκετ
      List<BasketMatch> allMatches = BasketballMatchHandle().getAllMatches();

      for (BasketMatch match in allMatches) {
        if (selectedTeam == null) {
          bool isFavMatch = favoriteTeamsBasket.any((t) => t.name == match.homeTeam.name || t.name == match.awayTeam.name);
          if (isFavMatch) {
            teamMatches.add(match);
          }
        } else {
          if (match.homeTeam.name == selectedTeam!.name || match.awayTeam.name == selectedTeam!.name) {
            teamMatches.add(match);
          }
        }
      }
    }
    return teamMatches;
  }
}