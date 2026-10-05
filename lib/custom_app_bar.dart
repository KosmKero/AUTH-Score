import 'package:flutter/material.dart';

import 'API/BasketballMatchHandle.dart';
import 'API/Match_Handle.dart';
import 'API/top_players_handle.dart';
import 'Firebase_Handle/user_handle_in_base.dart';
import 'Match_Details_Package/add_match_page.dart';
import 'Search_Page.dart';
import 'Team_Basket_Display_Package/add_team_screen.dart';
import 'Team_Display_Page_Package/addTeamScreen.dart';
import 'basketMatches/add_match_basketball.dart';
import 'globals.dart';
import 'main.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(String)? onOptionSelected;
  final String? selectedOption;

  const CustomAppBar({
    super.key,
    this.onOptionSelected,
    this.selectedOption,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (context, isDarkMode, _) {
        return ValueListenableBuilder<String>(
          valueListenable: selectedSport,
          builder: (context, currentSport, _) {
            return AppBar(
              title: const Text(
                "UniScore",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: isDarkMode ?  const Color(0xFF1E1E1E) : const Color.fromARGB(250, 46, 90, 136),
              actions: [
                /*
                PopupMenuButton<String>(
                  icon: Icon(
                    currentSport == 'football' ? Icons.sports_soccer : Icons.sports_basketball,
                    color: Colors.white,
                  ),
                  tooltip: greek ? 'Επιλογή Αθλήματος' : 'Select Sport',
                  color: isDarkMode ? Colors.grey[900] : Colors.white,
                  onSelected: (String value) {
                    selectedSport.value = value;
                    if (onOptionSelected != null) {
                      onOptionSelected!(value);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'football',
                      child: Row(
                        children: [
                          Icon(
                            Icons.sports_soccer,
                            color: currentSport == 'football' ? Colors.blue : (isDarkMode ? Colors.white : Colors.black),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            greek ? 'Ποδόσφαιρο' : 'Football',
                            style: TextStyle(
                              fontWeight: currentSport == 'football' ? FontWeight.bold : FontWeight.normal,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'basketball',
                      child: Row(
                        children: [
                          Icon(
                            Icons.sports_basketball,
                            color: currentSport == 'basketball' ? Colors.orange : (isDarkMode ? Colors.white : Colors.black),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            greek ? 'Μπάσκετ' : 'Basketball',
                            style: TextStyle(
                              fontWeight: currentSport == 'basketball' ? FontWeight.bold : FontWeight.normal,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                 */
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: NotificationsForAllChampionship(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchPage()),
                      );
                    },
                  ),
                ),
                if (globalUser.isUpperAdmin)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                      tooltip: greek ? "Προσθήκη Αγώνα" : "Add Match",
                      onPressed: () async {
                        bool? didChange;

                        // 1. ΕΛΕΓΧΟΣ ΑΘΛΗΜΑΤΟΣ: ΠΟΔΟΣΦΑΙΡΟ
                        if (selectedSport.value == 'football') {
                          didChange = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AddMatchScreen()),
                          );

                          if (didChange == true) {
                            await loadTeams();
                            await loadMatches();
                            MatchHandle().initializeMatches(matches);
                            TopPlayersHandle().initializeList(teams);
                          }
                        }
                        // 2. ΕΛΕΓΧΟΣ ΑΘΛΗΜΑΤΟΣ: ΜΠΑΣΚΕΤ
                        else {
                          didChange = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BasketballAddMatchScreen()),
                          );

                          if (didChange == true) {
                            // Ανανέωση των ομάδων (φορτώνει ποδόσφαιρο ΚΑΙ μπάσκετ)
                            await loadTeams();

                            // Ξαναφορτώνουμε τους αγώνες μπάσκετ για να εμφανιστεί ο νέος αγώνας!
                            await BasketballMatchHandle().loadAllBasketballData(thisYearNow, basketTeams);
                          }
                        }

                        // 3. ΕΝΗΜΕΡΩΣΗ ΤΟΥ UI
                        if (didChange == true) {
                          if (!context.mounted) return;
                          if (onOptionSelected != null) {
                            onOptionSelected!(selectedSport.value);
                          }
                        }
                      },
                    ),
                  ),
                if (globalUser.isUpperAdmin)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: IconButton(
                      icon: const Icon(Icons.group_add, color: Colors.white),
                      tooltip: greek ? "Προσθήκη Ομάδας" : "Add Team",
                      onPressed: () async {
                        bool? didChange;

                        // 1. ΕΛΕΓΧΟΣ ΑΘΛΗΜΑΤΟΣ: ΠΟΔΟΣΦΑΙΡΟ
                        if (selectedSport.value == 'football') {
                          didChange = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddTeamScreen()),
                          );

                          if (didChange == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(greek ? "Ανανέωση δεδομένων ποδοσφαίρου..." : "Refreshing football data..."),
                                duration: const Duration(seconds: 1),
                                backgroundColor: Colors.blue,
                              ),
                            );

                            await loadTeams();
                            await loadMatches();
                            MatchHandle().initializeMatches(matches);
                            TopPlayersHandle().initializeList(teams);
                          }
                        }
                        // 2. ΕΛΕΓΧΟΣ ΑΘΛΗΜΑΤΟΣ: ΜΠΑΣΚΕΤ
                        else {
                          didChange = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BasketballAddTeamScreen()),
                          );

                          if (didChange == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(greek ? "Ανανέωση δεδομένων μπάσκετ..." : "Refreshing basketball data..."),
                                duration: const Duration(seconds: 1),
                                backgroundColor: Colors.orange, // Πορτοκαλί για μπάσκετ
                              ),
                            );

                            // Η loadTeams στο main.dart (ή globals.dart) συνήθως φορτώνει και τα 2 αθλήματα
                            await loadTeams();

                            // Ανανεώνουμε και τα παιχνίδια σε περίπτωση που επηρεάζονται
                            await BasketballMatchHandle().loadAllBasketballData(thisYearNow, basketTeams);
                          }
                        }

                        // 3. ΕΝΗΜΕΡΩΣΗ ΤΟΥ UI
                        if (didChange == true) {
                          if (!context.mounted) return;
                          if (onOptionSelected != null) {
                            onOptionSelected!(selectedSport.value);
                          }
                        }
                      },
                    ),
                  ),
                const SizedBox(width: 8),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class NotificationsForAllChampionship extends StatelessWidget {
  const NotificationsForAllChampionship({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: loggedInNotifications,
      builder: (context, isLogged, child) {
        if (!isLogged) {
          return IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => _showLoginWarning(context),
          );
        }

        // Παρακολουθούμε ποιο άθλημα είναι επιλεγμένο αυτή τη στιγμή!
        return ValueListenableBuilder<String>(
            valueListenable: selectedSport,
            builder: (context, currentSport, _) {

              // Επιλέγουμε τον σωστό ValueNotifier βάσει αθλήματος
              // (Θα πρέπει να φτιάξεις το globalUser.notifyAllBasketMatches αν δεν υπάρχει)
              ValueNotifier<bool> currentNotifier = currentSport == 'football'
                  ? globalUser.notifyAllMatches
                  : globalUser.notifyAllBasketMatches;

              return ValueListenableBuilder<bool>(
                valueListenable: currentNotifier,
                builder: (context, active, child) {
                  return IconButton(
                    tooltip: greek
                        ? (currentSport == 'football' ? "Ειδοποιήσεις (Ποδόσφαιρο)" : "Ειδοποιήσεις (Μπάσκετ)")
                        : (currentSport == 'football' ? "Football Notifications" : "Basketball Notifications"),
                    onPressed: () {
                      bool newValue = !active;

                      if (currentSport == 'football') {
                        globalUser.setNotifyAllMatches(newValue);
                        UserHandleBase().setNotifyAllMatches(newValue); // Η παλιά σου συνάρτηση
                      } else {
                        globalUser.setNotifyAllBasketMatches(newValue);
                        UserHandleBase().setNotifyAllBasketMatches(newValue);
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(newValue
                              ? (greek ? "Ενεργοποιήθηκαν!" : "Enabled!")
                              : (greek ? "Απενεργοποιήθηκαν." : "Disabled.")),
                          duration: const Duration(milliseconds: 1300),
                          backgroundColor: newValue
                              ? (currentSport == 'football' ? Colors.blue : Colors.orange)
                              : Colors.grey[700],
                        ));
                      }
                    },
                    icon: Icon(
                      active ? Icons.notifications_active : Icons.notifications_none,
                      color: active
                          ? (currentSport == 'football' ? Colors.amber : Colors.orange)
                          : Colors.white,
                    ),
                  );
                },
              );
            }
        );
      },
    );
  }

  void _showLoginWarning(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(greek ? "Πρέπει να συνδεθείς για να έχεις ειδοποιήσεις" : "Please log in"),
      duration: const Duration(milliseconds: 1300),
      backgroundColor: Colors.redAccent.withOpacity(0.9),
    ));
  }
}