//mport 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';
import 'package:untitled1/Team_Display_Page_Package/Team_Details_Widget.dart';
import 'package:untitled1/Team_Display_Page_Package/Team_Matches_Widget.dart';
import 'package:untitled1/Team_Display_Page_Package/Team_Players_Display_Widget.dart';
import 'package:untitled1/championship_details/football/football_top_players_page.dart';
import 'package:untitled1/globals.dart';
import 'package:untitled1/main.dart';

import '../Data_Classes/Player.dart';
import '../Data_Classes/Team.dart';
import '../Firebase_Handle/firebase_screen_stats_helper.dart';
import 'editTeamPage.dart';
import '../Firebase_Handle/TeamsHandle.dart';

class TeamDisplayPage extends StatefulWidget {
  const TeamDisplayPage(this.team, {super.key});
  final Team team;

  @override
  State<TeamDisplayPage> createState() => _TeamDisplayPageState();
}

class _TeamDisplayPageState extends State<TeamDisplayPage> {
  late Team team;

  @override
  void initState() {
    super.initState();
    team = widget.team; // Αρχικά παίρνει την ομάδα που του πασάραμε
  }

  int selectedIndex = 0;

  void _changeSection(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Team_page', screenClass: 'Team page');

    FirebaseAnalytics.instance.logEvent(
      name: 'team_clicked',
      parameters: {
        'team_name': widget.team.nameEnglish,
      },
    );



    return Scaffold(
      //ΑΦΟΡΑ ΤΟ ΟΝΟΜΑ ΠΑΝΩ ΣΤΗΝ ΣΕΛΙΔΑ
        appBar: AppBar(
            backgroundColor: darkModeNotifier.value
                ? const Color(0xFF121212)
                : const Color.fromARGB(250, 46, 90, 136),
            iconTheme: const IconThemeData(color: Colors.white),
            title: Row(
              children: [
                SizedBox(height: 33, width: 33, child: team.image),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: Text(
                    greek ? team.displayGreek : team.displayEnglish,
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow
                        .ellipsis, // για ασφάλεια αν είναι πολύ μεγάλο
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
              if (globalUser.controlTheseTeamsFootball(widget.team.name, null) || globalUser.isUpperAdmin)
                IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    tooltip: greek ? "Επεξεργασία" : "Edit",
                    onPressed: () async {
                      bool? didChange = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditTeamScreen(team: team),
                        ),
                      );

                      if (didChange == true) {
                        await loadTeams();

                        Team? updatedTeam =
                        TeamsHandle().getTeamFromList(team.name, teams);

                        if (!context.mounted) return;

                        if (updatedTeam != null) {
                          setState(() {
                            team = updatedTeam;
                          });


                          setState(() {});
                        }
                      }
                    }),

              if (TeamsHandle().canDeleteTeam(team))
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
                  tooltip: greek ? "Διαγραφή Ομάδας" : "Delete Team",
                  onPressed: () => _showDeleteTeamDialog(context, team),
                ),

              isFavourite(
                team: team,
              ),
              const SizedBox(width: 8)
            ]),
        body: Scaffold(
            backgroundColor: darkModeNotifier.value
                ? const Color(0xFF121212)
                : lightModeBackGround,
            body: Column(
              children: [
                //Text(team.name,style: TextStyle(color: Color.fromARGB(100, 255, 10, 40),)),
                _NavigationButtons(onSectionChange: _changeSection),
                _sectionChooser(
                  selectedIndex,
                  team,
                )
              ],
            )));
  }


  void _showDeleteTeamDialog(BuildContext context, Team team) {
    bool isDark = darkModeNotifier.value;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          greek ? "⚠️ Διαγραφή Ομάδας" : "⚠️ Delete Team",
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
        content: Text(
          greek
              ? "Είστε σίγουρος ότι θέλετε να διαγράψετε την ομάδα '${team.displayName}'; Αυτή η ενέργεια είναι μόνιμη."
              : "Are you sure you want to delete '${team.displayName}'? This action is permanent.",
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(greek ? "Ακύρωση" : "Cancel", style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              // 💡 1. Αποθηκεύουμε τα εργαλεία πλοήγησης ΠΡΙΝ τα await!
              // Έτσι δεν μας νοιάζει αν θα αλλάξει το context αργότερα.
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              navigator.pop(); // 2. Κλείνει το Dialog επιβεβαίωσης

              // 3. Εμφανίζουμε το Loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext loadingCtx) => const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
              );

              try {
                // 4. Διαγραφή από τη Βάση
                await TeamsHandle().deleteTeamCompletely(team);

                // 5. Ξαναφορτώνουμε τα δεδομένα (εδώ χανόταν το context πριν!)
                await loadTeams();

                // 6. Κλείνουμε το κυκλάκι (χρησιμοποιώντας τον αποθηκευμένο navigator)
                navigator.pop();

                // 7. Μήνυμα Επιτυχίας
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(greek ? "Η ομάδα διαγράφηκε επιτυχώς." : "Team deleted successfully."),
                    backgroundColor: Colors.green,
                  ),
                );

                // 8. Επιστροφή στην προηγούμενη σελίδα (του Navigator της σελίδας)
                navigator.pop(true);

              } catch (e) {
                // Αν γίνει λάθος, κλείνουμε το κυκλάκι με ασφάλεια
                navigator.pop();

                messenger.showSnackBar(
                  SnackBar(
                    content: Text("Σφάλμα διαγραφής: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(greek ? "Διαγραφή" : "Delete", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }


}

//ΑΦΟΡΑ ΤΑ 3 ΚΟΥΜΠΙΑ ΚΑΤΩ ΑΠΟ ΤΟ ΟΝΟΜΑ!!
class _NavigationButtons extends StatefulWidget {
  final Function(int) onSectionChange;

  const _NavigationButtons({Key? key, required this.onSectionChange})
      : super(key: key);

  @override
  State<_NavigationButtons> createState() => _NavigationButtonsState();
}

class _NavigationButtonsState extends State<_NavigationButtons> {
  int selectedIndex = 0;

  void _onButtonPressed(int index) {
    setState(() {
      selectedIndex = index;
    });
    widget.onSectionChange(index); // Notify parent widget
  }

  //ΔΗΜΙΟΥΡΓΕΙ ΤΟΝ ΧΩΡΟ ΤΩΝ 3 ΚΟΥΜΠΙΩΝ
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
            _buildTextButton(greek ? "Παίχτες" : "Players", 2),
            const SizedBox(width: 15),
            _buildTextButton(greek ? "Κορυφαίοι Παίχτες" : "Top Players", 3),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  //ΔΗΜΙΟΥΡΓΕΙ ΤΑ 3 ΚΟΥΜΠΙΑ(ΛΕΠΤΟΜΕΡΕΙΕΣ ΑΓΩΝΕΣ ΚΑΙ ΠΑΙΧΤΕΣ)
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
              color: isSelected
                  ? const Color.fromARGB(250, 46, 90, 136)
                  : darkModeNotifier.value
                  ? Colors.white
                  : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w700,
              //backgroundColor: darkModeNotifier.value==true?Colors.black87: lightModeBackGround
            ),
          ),
          const SizedBox(height: 3), // Απόσταση μεταξύ κειμένου και γραμμής
          if (isSelected)
            Container(
              width: 60, // Μήκος γραμμής
              height: 3, // Πάχος γραμμής
              color: const Color.fromARGB(250, 46, 90, 136), // Χρώμα γραμμής
            ),
        ],
      ),
    );
  }
}

//ελεγχει την κατασταση για το αν η ομαδα ειναι στα αγαπημενα ή οχι.
class isFavourite extends StatefulWidget {
  final Team team;

  const isFavourite({super.key, required this.team});

  @override
  State<isFavourite> createState() => _isFavouriteState();
}

class _isFavouriteState extends State<isFavourite> {
  bool isFavourite = false;
  final TeamsHandle teamsHandle = TeamsHandle();

  @override
  void initState() {
    super.initState();
    _checkIfFavourite(); // Κάνε τον αρχικό έλεγχο εδώ
  }

  Future<void> _checkIfFavourite() async {
    if (isLoggedIn) {
      bool result = globalUser.favoriteList.contains(widget.team
          .name); //      await teamsHandle.isFavouriteTeam(widget.team.name);
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

        // 1. Optimistic Update (άμεσο setState)
        setState(() {
          isFavourite = !isFavourite;
        });

        try {
          if (isFavourite) {
            await teamsHandle.addFavouriteTeam(widget.team.name);
            // Κλήση της νέας έξυπνης μεθόδου αντί της addFavoriteTeam
            globalUser.updateFootballMatchesNotificationsOnFavoriteChange(widget.team.name, true);
          } else {
            await teamsHandle.removeFavouriteTeam(widget.team.name);
            // Κλήση της νέας έξυπνης μεθόδου αντί της removeFavoriteTeam
            globalUser.updateFootballMatchesNotificationsOnFavoriteChange(widget.team.name, false);
          }
        }catch (e) {
          // 2. Αν υπάρξει σφάλμα, κάνε revert το UI
          setState(() {
            isFavourite = !isFavourite; // γύρνα το πίσω
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: greek
                  ? const Text('Κάτι πήγε στραβά. Προσπάθησε ξανά.')
                  : const Text('Something went wrong. Please try again.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      icon: Icon(
        isFavourite ? Icons.favorite : Icons.favorite_border,
        color: isFavourite ? Colors.red : Colors.grey,
      ),
    );
  }
}

Widget _sectionChooser(int selectedIndex, Team team) {
  switch (selectedIndex) {
    case 0:
      return TeamDetailsWidget(team: team);
    case 1:
      return TeamMatchesWidget(team: team);
    case 2:
      return TeamPlayersDisplayWidget(team: team);
    case 3:
      return TopPlayersPage(
        List.from(team.players)..sort((a, b) => b.goals.compareTo(a.goals)),
      );

    default:
      return TeamDetailsWidget(team: team);
  }
}