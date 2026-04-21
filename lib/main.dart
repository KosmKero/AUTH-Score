import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

//import 'API/BasketballMatchHandle.dart';
import 'Data_Classes/basketball/basketMatch.dart';
import 'Data_Classes/basketball/basketTeam.dart';
//import 'Firebase_Handle/BasketTeamsHandle.dart';
import 'Match_Details_Package/add_match_page.dart';
import 'Team_Display_Page_Package/addTeamScreen.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:untitled1/API/Match_Handle.dart';
import 'package:untitled1/API/top_players_handle.dart';
import 'package:untitled1/Data_Classes/Team.dart';
import 'package:untitled1/Firebase_Handle/FireBaseMessage.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';
import 'package:untitled1/Firebase_Handle/user_handle_in_base.dart';
import 'package:untitled1/championship_details/sector_chooser.dart';
import 'API/NotificationService.dart';
import 'Favorite_Page.dart';
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
List<Team> favouriteTeams = [];
List<Player> players = [];

Future<void> loadUser(User user) async {
  UserHandleBase userHandle = UserHandleBase();
  userHandle.getUser(user);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await MobileAds.instance.initialize();
  //await Hive.initFlutter();

  //Hive.registerAdapter(MatchModelAdapter());
  //Hive.registerAdapter(GoalAdapter());
  //Hive.registerAdapter(PenaltyAdapter());

  //await Hive.openBox<MatchModel>('matches');

  try {
    // 1. Αρχικοποίηση Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    //await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true); //an δουλεψουν ποτε τα αναλυτικς
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // 2. Καταγραφή σφαλμάτων που συμβαίνουν εκτός Flutter framework (Asynchronous errors)
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // 2. Ρύθμιση Remote Config (Πριν από οτιδήποτε άλλο)
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 15),
      minimumFetchInterval:
          kDebugMode ? Duration.zero : const Duration(hours: 12),
    ));

    // Ορισμός defaults
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

    // 3. Παράλληλη αρχικοποίηση Ads και Remote Config Fetch
    await Future.wait([
      remoteConfig
          .fetchAndActivate()
          .catchError((e) => print("Remote Config error: $e")),
    ]);

    //await MatchHandle.migrateMatches();
    //await MatchHandle.migrateTeams();
    //await MatchHandle().resetPlayerData("2026");
    await Future.delayed(
        const Duration(milliseconds: 100)); //να προλαβουν να γινουν ολα σωστα

    User? user = FirebaseAuth.instance.currentUser;
    await initTracking(); //προβλημα

    if (user != null) {
      loadUser(user);
    }
    print("✅ Firebase initialized successfully!");
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }

  try {
    print("✅ All good!");
    Messages().initNotification();
  } catch (e) {
    print("❌ Could not load messages $e");
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
        '/home': (context) => LoadingScreen(),
      },
      home: LoadingScreen(),
    );
  }
}

// New loading screen widget
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _isLoading = true;
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

    initia();
    //  BettingResultUpdate().recalculateAllScores();
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
      await loadYear();
      await loadTeams();

      setState(() {
        _loadingMessage = "Loading matches...";
      });
      await loadMatches();

      setState(() {
        _loadingMessage = "Setting up data...";
      });
      MatchHandle().initializeMatces(matches);
      TopPlayersHandle().initializeList(teams);

      // Add a small delay so users can see the loading completed message
      setState(() {
        _loadingMessage = "All set!";
      });
      bool hasSplashSponsor =
          FirebaseRemoteConfig.instance.getBool('has_splash_sponsor');

      int delayMilliseconds = hasSplashSponsor ? 1200 : 200;

      await Future.delayed(Duration(milliseconds: delayMilliseconds));

      // Navigate to main screen once loading is complete
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainScreen()),
        );

        if (pendingMatchId != null) {
          // Δίνουμε μισό δευτερόλεπτο να χτιστεί η MainScreen και μετά πάμε στο ματς!
          Future.delayed(const Duration(milliseconds: 500), () {
            NotificationService.navigateToMatch(pendingMatchId!);
            pendingMatchId = null; // Το καθαρίζουμε για να μην ξανανοίξει
          });
        }
      }
    } catch (e) {
      print("Error loading data: $e");
      //setState(() {
      //  _hasError = true;
      //  _errorMessage = "Failed to load data: $e";
      //  _isLoading = false;
      //});
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF121212) : const Color(0xFF97B4C3),
      body: Center(
        child: _hasError ? _buildErrorWidget() : _buildLoadingWidget(),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    // Παίρνουμε το ύψος της οθόνης για να υπολογίσουμε τη θέση
    final double screenHeight = MediaQuery.of(context).size.height;

    bool hasSplashSponsor =
        FirebaseRemoteConfig.instance.getBool('has_splash_sponsor');
    String splashLogoUrl =
        FirebaseRemoteConfig.instance.getString('splash_logo_url');

    return Stack(
      alignment: Alignment.center, // Κεντράρει τα πάντα στο Stack
      children: [
        // 1. Το "UniScore" - ΑΠΟΛΥΤΩΣ ΚΕΝΤΡΑΡΙΣΜΕΝΟ
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 29,
              ),
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
          top: screenHeight / 2 + 50, // 50 pixels κάτω από το κέντρο της οθόνης
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // To Spinner
              const CircularProgressIndicator(
                color: Colors.white,
              ),
              const SizedBox(height: 20),

              Text(
                _loadingMessage,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
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
                    color: Colors.white.withOpacity(
                        0.7), // Ελαφρώς διάφανο για να μην "φωνάζει"
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                SmartBanner(
                  hasSponsor: hasSplashSponsor,
                  height: FirebaseRemoteConfig.instance
                      .getDouble('splash_screen_sponsor_image_height'),
                  sponsorImageUrl: splashLogoUrl,
                  customBgColor: (MediaQuery.of(context).platformBrightness ==
                          Brightness.dark)
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
        Icon(
          Icons.error_outline,
          size: 70,
          color: Colors.red,
        ),
        SizedBox(height: 20),
        Text(
          "Error Loading Data",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _hasError = false;
              _isLoading = true;
              _loadingMessage = "Retrying...";
            });
            _loadData();
          },
          child: Text("Retry"),
        ),
      ],
    );
  }
}

// Original team loading function
Future<void> loadTeams() async {
  TeamsHandle teamsHandle = TeamsHandle();
  teams = await teamsHandle.getAllTeams();

/*
  TeamHandle().addTeam('ΤΕΦΑΑ ΣΕΡΡΩΝ', "TEFAA SERRES", "PHED SER");
  TeamHandle().addTeam('ΔΑΣΟΛΟΓΙΑ', "DASOLOGIA", "FOR");
  TeamHandle().addTeam('ΠΟΛΙΤΙΚΟΙ ΜΗΧΑΝΙΚΟΙ 2', "CIVIL ENGINEERS 2", "CIVIL II");
  TeamHandle().addTeam("ΕΡΑΣΜΟΥΣ", "ERASMUS", "ERASMUS");
  TeamHandle().addTeam("ΓΕΩΛΟΓΙΑ", "GEOLOGY", "GEO");
*/
  /*
  teamsHandle.addMatch("ΗΜΜΥ 2","ΟΙΚΟΝΟΜΙΚΟ",17,2, 2025, 2, true, true, 1510, "previous",0,11);
  teamsHandle.addMatch("ΤΕΦΑΑ","ΦΥΣΙΚΟ",18, 2, 2025, 2, true, true, 1510, "previous",10,0);
  teamsHandle.addMatch("ΗΜΜΥ 1","ΧΩΡΟΤΑΞΙΑ",19, 2, 2025, 2, true, true, 1510, "previous",5,0);
  teamsHandle.addMatch("ΗΜΜΥ 2","ΓΕΩΠΟΝΙΑ",20, 2, 2025, 2, true, true, 1510, "previous",1,2);

  teamsHandle.addMatch("ΠΟΛΙΤΙΚΩΝ ΕΠΙΣΤΗΜ.","ΧΗΜ.ΜΗΧΑΝΙΚΩΝ",21,2, 2025, 2, true, true, 1510, "previous",0,6);
  teamsHandle.addMatch("ΠΑΙΔΑΓΩΓΙΚΗ","ΟΔΟΝΤΙΑΤΡΙΚΗ",24, 2, 2025, 2, true, true, 1510, "previous",1,2);
  teamsHandle.addMatch("ΚΤΗΝΙΑΤΡΙΚΗ","ΝΟΜΙΚΗ",25, 2, 2025, 2, true, true, 1510, "previous",3,4);
  teamsHandle.addMatch("ΒΙΟΛΟΓΙΑ","ΣΣΑΣ",26, 2, 2025, 2, true, true, 1510, "previous",0,12);


   */
}

Future<void> loadYear() async {
  final doc =
      await FirebaseFirestore.instance.collection('ThisYear').doc('2026').get();

  final data = doc.data();
  if (data != null && data.containsKey('year')) {
    thisYearNow = data['year'] as int;
  }

  //thisYearNow=2027;
}

// Original matches loading function
Future<void> loadMatches() async {
  TeamsHandle teamsHandle = TeamsHandle();
  upcomingMatches = await teamsHandle.getMatches("upcoming");
  previousMatches = await teamsHandle.getMatches("previous");
  matches = [upcomingMatches, previousMatches];

  //teamsHandle.addMatch("ΕΜΠΟΡ.ΝΑΥΤΙΚΟ", "ΜΗΧΑΝ.ΜΗΧΑΝ.", 29, 4, 2025, 1, false, true, 1510, "upcoming", -1, -1);
}

// Original MainScreen and other classes
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
  final Function(String) onOptionSelected;
  final String selectedOption;

  const CustomAppBar({
    super.key,
    required this.onOptionSelected,
    required this.selectedOption,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (context, isDarkMode, _) {
        return AppBar(
          title: Row(
            children: const [
              Text(
                "UniScore",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          backgroundColor: isDarkMode
              ? const Color(0xFF121212)
              : const Color.fromARGB(250, 46, 90, 136),
          actions: [
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: NotificationsForAllChampionship(),
                ),

                // 1. Κουμπί Αναζήτησης
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

                // 2. Κουμπί Προσθήκης Αγώνα (Άμεση πρόσβαση για Admins)
                if (globalUser.isAdmin || globalUser.isUpperAdmin)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: IconButton(
                      icon: const Icon(Icons.add_circle_outline,
                          color: Colors.white),
                      tooltip: greek ? "Προσθήκη Αγώνα" : "Add Match",
                      onPressed: () async {
                        bool? didChange = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddMatchScreen()),
                        );

                        if (didChange == true) {
                          await loadTeams();
                          await loadMatches();
                          MatchHandle().initializeMatces(matches);
                          TopPlayersHandle().initializeList(teams);

                          if (!context.mounted) return;
                          // Ανανεώνει το UI της αρχικής σελίδας
                          onOptionSelected(selectedOption);
                        }
                      },
                    ),
                  ),

                // 3. Κουμπί Προσθήκης Ομάδας (Άμεση πρόσβαση μόνο για UpperAdmin)
                if (globalUser.isUpperAdmin)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: IconButton(
                      icon: const Icon(Icons.group_add, color: Colors.white),
                      tooltip: greek ? "Προσθήκη Ομάδας" : "Add Team",
                      onPressed: () async {
                        bool? didChange = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddTeamScreen()),
                        );

                        if (didChange == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(greek
                                  ? "Ανανέωση δεδομένων..."
                                  : "Refreshing data..."),
                              duration: const Duration(seconds: 1),
                              backgroundColor: Colors.blue,
                            ),
                          );

                          await loadTeams();
                          await loadMatches();
                          MatchHandle().initializeMatces(matches);
                          TopPlayersHandle().initializeList(teams);

                          if (!context.mounted) return;

                          onOptionSelected(selectedOption);
                        }
                      },
                    ),
                  ),

                // Μικρό κενό δεξιά για να μην κολλάνε τα εικονίδια στην άκρη της οθόνης
                const SizedBox(width: 8),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class NotificationsForAllChampionship extends StatefulWidget {
  const NotificationsForAllChampionship({super.key});

  @override
  State<NotificationsForAllChampionship> createState() =>
      _NotificationsForAllChampionshipState();
}

class _NotificationsForAllChampionshipState
    extends State<NotificationsForAllChampionship> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: loggedInNotifications,
      builder: (context, isLogged, child) {
        // 1. Αν δεν είναι συνδεδεμένος, δείχνουμε "νεκρό" εικονίδιο αμέσως!
        if (!isLogged) {
          return IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => _showLoginWarning(context),
          );
        }

        // 2. Αν ΕΙΝΑΙ συνδεδεμένος, ακούμε τον τρέχοντα χρήστη
        return ValueListenableBuilder<bool>(
          valueListenable: globalUser.notifyAllMatches,
          builder: (context, active, child) {
            return IconButton(
              tooltip: greek
                  ? "Ειδοποιήσεις για όλα τα ματς"
                  : "Notifications for all matches",
              onPressed: () {
                bool newValue = !active;

                globalUser.setNotifyAllMatches(newValue);

                if (mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(newValue
                        ? (greek
                            ? "Ενεργοποιήθηκαν οι ειδοποιήσεις!"
                            : "Enabled!")
                        : (greek
                            ? "Απενεργοποιήθηκαν οι ειδοποιήσεις."
                            : "Disabled.")),
                    duration: const Duration(milliseconds: 1300),
                    backgroundColor: newValue ? Colors.green : Colors.grey[700],
                  ));
                }
                UserHandleBase().setNotifyAllMatches(newValue);
              },
              icon: Icon(
                active ? Icons.notifications_active : Icons.notifications_none,
                color: active ? Colors.amber : Colors.white,
              ),
            );
          },
        );
      },
    );
  }

  // Βοηθητική συνάρτηση για καθαρό κώδικα
  void _showLoginWarning(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(greek
          ? "Πρέπει να συνδεθείς για να έχεις ειδοποιήσεις"
          : "Please log in"),
      duration: const Duration(milliseconds: 1300),
      backgroundColor: Colors.redAccent.withOpacity(0.9),
    ));
  }
}

// ------------------------ BOTTOM NAVIGATION ------------------------
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar(
      {super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor:
          darkModeNotifier.value ? Colors.grey[850] : Colors.black87,
      selectedFontSize: 14,
      unselectedFontSize: 12,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
            icon: const Icon(Icons.sports_soccer),
            label: greek ? "Αγώνες" : "Games"),
        BottomNavigationBarItem(
            icon: const Icon(Icons.emoji_events),
            label: greek ? "Πρωτάθλημα" : "Championship"),
        BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: greek ? "Αγαπημένα" : "Favorite"),
        BottomNavigationBarItem(
            icon: Icon(Icons.person), label: greek ? "Προφίλ" : "Profile"),
        //BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: greek? 'Φανέλες' : 'Merch')
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.white,
      onTap: onTap,
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
