import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'API/BasketballMatchHandle.dart';
import 'Data_Classes/basketball/basketMatch.dart';
import 'Data_Classes/basketball/basketTeam.dart';
import 'Firebase_Handle/BasketTeamsHandle.dart';
import 'Firebase_Handle/betting_result_update.dart';
import 'Match_Details_Package/StatsPage.dart';
import 'Match_Details_Package/add_match_page.dart';
import 'Profile/admin/pinWatch.dart';
import 'Team_Basket_Display_Package/add_team_screen.dart';
import 'Team_Display_Page_Package/addTeamScreen.dart';
import 'basketMatches/add_match_basketball.dart';
import 'championship_details/StandingsOrKnockoutsChooserPage.dart';
import 'favorite_Page/favorite_Chooser.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:untitled1/API/Match_Handle.dart';
import 'package:untitled1/API/top_players_handle.dart';
import 'package:untitled1/Data_Classes/Team.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';
import 'package:untitled1/Firebase_Handle/user_handle_in_base.dart';
import 'package:untitled1/championship_details/football/football_sector_chooser.dart';
import 'API/NotificationService.dart';
import 'favorite_Page/Football_Favorite_Page.dart';
import 'Firebase_Handle/firebase_screen_stats_helper.dart';
import 'HomePage.dart';
import 'Data_Classes/Player.dart';
import 'Profile/Profile_Page.dart';
import 'Search_Page.dart';
import 'Data_Classes/MatchDetails.dart';
import 'ad_manager.dart';
import 'globals.dart';

List<MatchDetails> upcomingMatches = [];
List<MatchDetails> previousMatches = [];
List<List<MatchDetails>> matches = [];

List<Team> favouriteTeamsFootball = [];
List<basketTeam> favoriteTeamsBasket = [];
List<Player> players = [];

Future<void> loadUser(User user) async {
  UserHandleBase userHandle = UserHandleBase();
  userHandle.getUser(user);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Αρχικοποίηση Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // 2. Καταγραφή σφαλμάτων εκτός Flutter
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // 3. Ρύθμιση Remote Config
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 15),
      minimumFetchInterval: kDebugMode ? Duration.zero : const Duration(hours: 12),
    ));

    await remoteConfig.setDefaults(const {
      "has_home_sponsor": false,
      "home_sponsor_image_url": "",
      "home_sponsor_link": "",
      "has_match_sponsor": false,
      "match_sponsor_image_url": "",
      "match_sponsor_link": "",
      "has_splash_sponsor": false,
      "splash_logo_url": "",
      'has_top20_sponsor': false,
      'top20_sponsor_link': '',
      "logoVersion": "1"
    });

    remoteConfig.fetchAndActivate().catchError((e) => print("Remote Config error: $e"));

    await Future.delayed(const Duration(milliseconds: 100));

    User? user = FirebaseAuth.instance.currentUser;
    await initTracking();

    if (user != null) {
      loadUser(user);
    }
    print("✅ Firebase initialized successfully!");
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Opened', screenClass: 'Opened');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      routes: {
        '/home': (context) => const LoadingScreen(),
      },
      home: const LoadingScreen(),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String _loadingMessage = "Initializing...";
  bool _hasError = false;
  final String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _loadData();
    if (isLoggedIn) {
      _loadLanguage();
    }
  }

  Future<void> _loadLanguage() async {
    UserHandleBase userHandle = UserHandleBase();
    userHandle.loadLanguage(globalUser.username);
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _loadingMessage = "Loading teams...";
      });
      //await loadYear();
      //await WinProbabilityCalculator.evaluateModel(2025);
      //await WinProbabilityCalculator.evaluateModel(2026);


      await loadTeams();
      initia();

      setState(() {
        _loadingMessage = "Loading matches...";
      });
      await loadMatches();

      setState(() {
        _loadingMessage = "Setting up data...";
      });
      MatchHandle().initializeMatches(matches);
      TopPlayersHandle().initializeList(teams);

      await BasketballMatchHandle().loadAllBasketballData(thisYearNow, basketTeams);

      setState(() {
        _loadingMessage = "All set!";
      });
      bool hasSplashSponsor = FirebaseRemoteConfig.instance.getBool('has_splash_sponsor');
      int delayMilliseconds = hasSplashSponsor ? 1200 : 200;

      await Future.delayed(Duration(milliseconds: delayMilliseconds));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );

        if (pendingMatchId != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            NotificationService.navigateToMatch(pendingMatchId!);
            pendingMatchId = null;
          });
        }
      }
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFF97B4C3),
      body: Center(
        child: _hasError ? _buildErrorWidget() : _buildLoadingWidget(),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    final double screenHeight = MediaQuery.of(context).size.height;
    bool hasSplashSponsor = FirebaseRemoteConfig.instance.getBool('has_splash_sponsor');
    String splashLogoUrl = FirebaseRemoteConfig.instance.getString('splash_logo_url');

    return Stack(
      alignment: Alignment.center,
      children: [
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 29),
              Text(
                "UniScore",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: screenHeight / 2 + 50,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              Text(
                _loadingMessage,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
        if (hasSplashSponsor && splashLogoUrl.isNotEmpty)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Powered by",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                SmartBanner(
                  hasSponsor: hasSplashSponsor,
                  height: FirebaseRemoteConfig.instance.getDouble('splash_screen_sponsor_image_height'),
                  sponsorImageUrl: splashLogoUrl,
                  customBgColor: (MediaQuery.of(context).platformBrightness == Brightness.dark)
                      ? const Color(0xFF121212)
                      : const Color(0xFF97B4C3),
                )
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 70, color: Colors.red),
        const SizedBox(height: 20),
        const Text(
          "Error Loading Data",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _hasError = false;
              _loadingMessage = "Retrying...";
            });
            _loadData();
          },
          child: const Text("Retry"),
        ),
      ],
    );
  }
}

Future<void> loadTeams() async {
  TeamsHandle teamsHandle = TeamsHandle();
  teams = await teamsHandle.getAllTeams();

  BasketTeamsHandle basketHandle = BasketTeamsHandle();
  basketTeams = await basketHandle.getAllTeams();
}

Future<void> loadYear() async {
  final doc = await FirebaseFirestore.instance.collection('ThisYear').doc('2026').get();
  final data = doc.data();
  if (data != null && data.containsKey('year')) {
    thisYearNow = data['year'] as int;
  }
}

Future<void> loadMatches() async {
  TeamsHandle teamsHandle = TeamsHandle();
  upcomingMatches = await teamsHandle.getMatches("upcoming");
  previousMatches = await teamsHandle.getMatches("previous");
  matches = [upcomingMatches, previousMatches];
}




class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _selectedOption = "Ποδόσφαιρο";

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void onOptionSelected(String value) {
    setState(() {
      _selectedOption = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onOptionSelected: onOptionSelected,
        selectedOption: _selectedOption,
      ),
      body: _buildBody(_selectedIndex),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ------------------------ APP BAR ------------------------
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(String)? onOptionSelected;
  final String? selectedOption;

  const CustomAppBar({
    super.key,
    this.onOptionSelected,
    this.selectedOption,
  });

  @override // ΔΙΟΡΘΩΘΗΚΕ: Αφαιρέθηκε το διπλό @override
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

// ------------------------ BOTTOM NAVIGATION ------------------------
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // ΔΙΟΡΘΩΘΗΚΕ: Το Bottom Navigation ακούει πλέον το επιλεγμένο άθλημα για να αλλάζει εικονίδιο
    return ValueListenableBuilder<String>(
      valueListenable: selectedSport,
      builder: (context, currentSport, _) {
        return BottomNavigationBar(
          backgroundColor: darkModeNotifier.value ? Colors.grey[850] : Colors.black87,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
                icon: Icon(currentSport == 'football' ? Icons.sports_soccer : Icons.sports_basketball),
                label: greek ? "Αγώνες" : "Games"),
            BottomNavigationBarItem(
                icon: const Icon(Icons.emoji_events),
                label: greek ? "Πρωτάθλημα" : "Championship"),
            BottomNavigationBarItem(
                icon: const Icon(Icons.favorite), // Προσθήκη const
                label: greek ? "Αγαπημένα" : "Favorite"),
            BottomNavigationBarItem(
                icon: const Icon(Icons.person), // Προσθήκη const
                label: greek ? "Προφίλ" : "Profile"),
          ],
          currentIndex: currentIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.white,
          onTap: onTap,
        );
      },
    );
  }
}

// ------------------------ BODY CONTENT ------------------------
Widget _buildBody(int selectedIndex) {
  switch (selectedIndex) {
    case 0:
      return HomePage();
    case 1:
      return StandingsOrKnockoutsChooserPage();
    case 2:
      return FavoritePage();
    case 3:
      return ProfilePage(user: globalUser);
    default:
      return HomePage();
  }
}