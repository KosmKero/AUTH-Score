import 'package:flutter/material.dart';
import 'package:untitled1/Team_Basket_Display_Package/BasketTeamDetails.dart';

import '../Data_Classes/basketball/basketTeam.dart';
import '../Firebase_Handle/BasketTeamsHandle.dart';
import '../Firebase_Handle/firebase_screen_stats_helper.dart';
import '../Team_Display_Page_Package/Team_Details_Widget.dart';
import '../championship_details/basket/basketball_standings_page.dart';
import '../globals.dart';
import 'Basket_Team_Matches_Widget.dart';
import 'Basket_Team_Players_Display.dart';


class BasketballTeamDisplayPage extends StatefulWidget {
  const BasketballTeamDisplayPage(this.team, {super.key});
  final basketTeam team;

  @override
  State<BasketballTeamDisplayPage> createState() => _BasketballTeamDisplayPageState();
}

class _BasketballTeamDisplayPageState extends State<BasketballTeamDisplayPage> {
  int selectedIndex = 0;

  void _changeSection(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Basket Team page', screenClass: 'Basket Team page');

    return Scaffold(
        appBar: AppBar(
            backgroundColor: darkModeNotifier.value ? const Color(0xFF121212) : const Color.fromARGB(250, 46, 90, 136),
            iconTheme: const IconThemeData(color: Colors.white),
            title: Row(
              children: [
                SizedBox(height: 33, width: 33, child: widget.team.image),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    widget.team.name,
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Arial',
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
            actions: [
              isFavouriteBasket(team: widget.team), // Κλήση της νέας κλάσης αγαπημένων
            ]),
        body: Scaffold(
            backgroundColor: darkModeNotifier.value ? const Color(0xFF121212) : lightModeBackGround,
            body: Column(
              children: [
                _NavigationButtonsBasket(onSectionChange: _changeSection),
                _sectionChooserBasket(selectedIndex, widget.team)
              ],
            )));
  }
}

// ΑΦΟΡΑ ΤΑ 3 ΚΟΥΜΠΙΑ ΚΑΤΩ ΑΠΟ ΤΟ ΟΝΟΜΑ
class _NavigationButtonsBasket extends StatefulWidget {
  final Function(int) onSectionChange;

  const _NavigationButtonsBasket({Key? key, required this.onSectionChange}) : super(key: key);

  @override
  State<_NavigationButtonsBasket> createState() => _NavigationButtonsBasketState();
}

class _NavigationButtonsBasketState extends State<_NavigationButtonsBasket> {
  int selectedIndex = 0;

  void _onButtonPressed(int index) {
    setState(() {
      selectedIndex = index;
    });
    widget.onSectionChange(index);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65,
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 10),
            _buildTextButton(greek ? "Λεπτομέρειες" : "Details", 0),
            const SizedBox(width: 15),
            _buildTextButton(greek ? "Αγώνες" : "Matches", 1),
            const SizedBox(width: 15),
            _buildTextButton(greek ? "Παίκτες" : "Players", 2),
            const SizedBox(width: 15),
            _buildTextButton(greek ? "Κορυφαίοι Παίκτες" : "Top Players", 3),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildTextButton(String text, int index) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        _onButtonPressed(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 17,
              // ΔΙΟΡΘΩΣΗ: Στο Light Mode όταν δεν είναι επιλεγμένο θα είναι μαύρο για να φαίνεται!
              color: isSelected
                  ? Colors.orange // Βάλαμε πορτοκαλί για το μπάσκετ!
                  : (darkModeNotifier.value ? Colors.white : Colors.black87),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          if (isSelected)
            Container(
              width: 60,
              height: 3,
              color: Colors.orange, // Πορτοκαλί γραμμή
            ),
        ],
      ),
    );
  }
}

// ΕΛΕΓΧΕΙ ΑΝ Η ΟΜΑΔΑ ΜΠΑΣΚΕΤ ΕΙΝΑΙ ΣΤΑ ΑΓΑΠΗΜΕΝΑ
class isFavouriteBasket extends StatefulWidget {
  final basketTeam team;

  const isFavouriteBasket({super.key, required this.team});

  @override
  State<isFavouriteBasket> createState() => _isFavouriteBasketState();
}

class _isFavouriteBasketState extends State<isFavouriteBasket> {
  bool isFavourite = false;
  final BasketTeamsHandle basketTeamsHandle = BasketTeamsHandle();

  @override
  void initState() {
    super.initState();
    _checkIfFavourite();
  }

  Future<void> _checkIfFavourite() async {
    if (isLoggedIn) {
      // ΕΛΕΓΧΟΣ ΣΤΗ ΛΙΣΤΑ ΤΟΥ ΜΠΑΣΚΕΤ
      bool result = globalUser.favoriteListBasket.contains(widget.team.name);
      setState(() {
        isFavourite = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        if (!isLoggedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: greek
                  ? const Text('Πρέπει να συνδεθείς για να έχεις αγαπημένες ομάδες!')
                  : const Text('You have to log in to have favourite teams!'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        }

        setState(() {
          isFavourite = !isFavourite;
        });

        if (isFavourite) {
          // 1. Ενημέρωση βάσης
          await basketTeamsHandle.addFavouriteTeam(widget.team.name);

          // 2. Ενημέρωση τοπικής λίστας ΚΑΙ UI αγώνων
          globalUser.updateBasketMatchesNotificationsOnFavoriteChange(widget.team.name, true);
        } else {
          // 1. Ενημέρωση βάσης
          await basketTeamsHandle.removeFavouriteTeam(widget.team.name);

          // 2. Ενημέρωση τοπικής λίστας ΚΑΙ UI αγώνων
          globalUser.updateBasketMatchesNotificationsOnFavoriteChange(widget.team.name, false);
        }
      },
      icon: Icon(
        isFavourite ? Icons.favorite : Icons.favorite_border,
        color: isFavourite ? Colors.red : Colors.grey,
      ),
    );
  }
}

// ΕΠΙΛΟΓΕΑΣ ΥΠΟ-ΣΕΛΙΔΩΝ ΜΠΑΣΚΕΤ
Widget _sectionChooserBasket(int selectedIndex, basketTeam team) {
  switch (selectedIndex) {
    case 0:
      return TeamDetailsWidgetBasketball(team: team,);
    case 1:
      return BasketballTeamMatchesWidget(team: team,);
    case 2:
      return BasketballTeamPlayersDisplayWidget(team: team,);
    case 3:
      return BasketballTopPlayersPage(
        List.from(team.players)..sort((a, b) => b.points.compareTo(a.points)),
      );

    default:
      return Center(child: Text("Details Placeholder"));
  }
}