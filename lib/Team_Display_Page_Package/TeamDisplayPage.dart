//import 'package:firebase_analytics/firebase_analytics.dart';
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

class TeamDisplayPage extends StatefulWidget {
  const TeamDisplayPage(this.team, {super.key});
  final Team team;

  @override
  State<TeamDisplayPage> createState() => _TeamDisplayPageState();
}

class _TeamDisplayPageState extends State<TeamDisplayPage> {
  late Team team;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    team = widget.team; // Αρχικά παίρνει την ομάδα που του πασάραμε
  }

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

    // Το theme παίρνεται ΜΙΑ φορά για όλη την οθόνη
    final theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
          // Το backgroundColor και το iconTheme αφαιρέθηκαν!
          // Το AppBarTheme αναλαμβάνει τα πάντα.
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
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Arial',
                      fontStyle: FontStyle.italic,
                      // Το color: Colors.white αφαιρέθηκε (παίρνει το foregroundColor)
                    ),
                  ),
                )
              ],
            ),
            actions: [
              if (globalUser.controlTheseTeamsFootball(widget.team.name, null) || globalUser.isUpperAdmin)
                IconButton(
                    icon: const Icon(Icons.edit), // Το color αφαιρέθηκε
                    tooltip: greek ? "Επεξεργασία" : "Edit",
                    onPressed: () async {
                      bool? didChange = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTeamScreen(team: team),
                        ),
                      );

                      if (didChange == true) {
                        await loadTeams();
                        Team? updatedTeam = TeamsHandle().getTeamFromList(team.name, teams);

                        if (!context.mounted) return;

                        if (updatedTeam != null) {
                          setState(() {
                            team = updatedTeam;
                          });
                        }
                      }
                    }),

              if (TeamsHandle().canDeleteTeam(team))
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded), // Το color αφαιρέθηκε
                  tooltip: greek ? "Διαγραφή Ομάδας" : "Delete Team",
                  onPressed: () => _showDeleteTeamDialog(context, team),
                ),

              isFavourite(team: team),
              const SizedBox(width: 8)
            ]),
        // Αφαιρέθηκε το background color από τα Scaffold
        body: Scaffold(
            body: Column(
              children: [
                _NavigationButtons(onSectionChange: _changeSection),
                _sectionChooser(
                  selectedIndex,
                  team,
                )
              ],
            )));
  }

  void _showDeleteTeamDialog(BuildContext context, Team team) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: theme.cardColor, // Δυναμικό χρώμα (σκούρο ή άσπρο)
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          greek ? "⚠️️ Διαγραφή Ομάδας" : "⚠️ Delete Team",
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          greek
              ? "Είστε σίγουρος ότι θέλετε να διαγράψετε την ομάδα '${team.displayName}'; Αυτή η ενέργεια είναι μόνιμη."
              : "Are you sure you want to delete '${team.displayName}'? This action is permanent.",
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(greek ? "Ακύρωση" : "Cancel", style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error, // Ένα σωστό κόκκινο από το theme
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
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
                await TeamsHandle().deleteTeamCompletely(team);
                await loadTeams();
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(greek ? "Η ομάδα διαγράφηκε επιτυχώς." : "Team deleted successfully."),
                    backgroundColor: Colors.green,
                  ),
                );
                navigator.pop(true);
              } catch (e) {
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

class _NavigationButtons extends StatefulWidget {
  final Function(int) onSectionChange;

  const _NavigationButtons({Key? key, required this.onSectionChange}) : super(key: key);

  @override
  State<_NavigationButtons> createState() => _NavigationButtonsState();
}

class _NavigationButtonsState extends State<_NavigationButtons> {
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
            _buildTextButton(greek ? "Λεπτομέρειες" : "Details", 0, context),
            const SizedBox(width: 15),
            _buildTextButton(greek ? "Αγώνες" : "Matches", 1, context),
            const SizedBox(width: 15),
            _buildTextButton(greek ? "Παίχτες" : "Players", 2, context),
            const SizedBox(width: 15),
            _buildTextButton(greek ? "Κορυφαίοι Παίχτες" : "Top Players", 3, context),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildTextButton(String text, int index, BuildContext context) {
    bool isSelected = selectedIndex == index;
    final theme = Theme.of(context);

    // Το χρώμα πλέον έρχεται από το Theme.
    final Color activeColor = theme.primaryColor;
    final Color inactiveColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

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
              color: isSelected ? activeColor : inactiveColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          if (isSelected)
            Container(
              width: 60,
              height: 3,
              color: activeColor, // Δυναμικό χρώμα υπογράμμισης
            ),
        ],
      ),
    );
  }
}

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
    _checkIfFavourite();
  }

  Future<void> _checkIfFavourite() async {
    if (isLoggedIn) {
      bool result = globalUser.favoriteList.contains(widget.team.name);
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

        try {
          if (isFavourite) {
            await teamsHandle.addFavouriteTeam(widget.team.name);
            globalUser.updateFootballMatchesNotificationsOnFavoriteChange(widget.team.name, true);
          } else {
            await teamsHandle.removeFavouriteTeam(widget.team.name);
            globalUser.updateFootballMatchesNotificationsOnFavoriteChange(widget.team.name, false);
          }
        } catch (e) {
          setState(() {
            isFavourite = !isFavourite;
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