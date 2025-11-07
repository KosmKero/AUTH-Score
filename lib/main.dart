import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:untitled1/API/Match_Handle.dart';
import 'package:untitled1/API/top_players_handle.dart';
import 'package:untitled1/Data_Classes/Team.dart';
import 'package:untitled1/Firebase_Handle/FireBaseMessage.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';
import 'package:untitled1/Firebase_Handle/user_handle_in_base.dart';
import 'package:untitled1/championship_details/sector_chooser.dart';
import 'API/NotificationService.dart';
import 'API/TeamHandle.dart';
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


Future<void> loadUser(User user) async{
  UserHandleBase userHandle = UserHandleBase();
   userHandle.getUser(user);
}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  //await Hive.initFlutter();

 //Hive.registerAdapter(MatchModelAdapter());
 //Hive.registerAdapter(GoalAdapter());
 //Hive.registerAdapter(PenaltyAdapter());

 //await Hive.openBox<MatchModel>('matches');



  try {

    await Firebase.initializeApp();
    //await MatchHandle.migrateMatches();
    //await MatchHandle.migrateTeams();
    //await MatchHandle().resetPlayerData("2026");
    User? user = FirebaseAuth.instance.currentUser;

    await initTracking();

    if(user!=null) {
      loadUser(user);
    }
    print("✅ Firebase initialized successfully!");
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }

  try {
    print("✅ All good!");
    await Messages().initNotification();
  } catch(e) {
    print("❌ Could not load messages $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Opened',screenClass: 'Opened');


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
    if(isLoggedIn) {
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
      await Future.delayed(Duration(milliseconds: 500));

      // Navigate to main screen once loading is complete
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
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

    return Scaffold(
      backgroundColor: lightModeBackGround,
      body: Center(
        child: _hasError
            ? _buildErrorWidget()
            : _buildLoadingWidget(),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "AUTH Score",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 40),
        CircularProgressIndicator(
          color: Colors.white,
        ),
        SizedBox(height: 20),
        Text(
          _loadingMessage,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
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
  final doc = await FirebaseFirestore.instance
      .collection('ThisYear')
      .doc('2026')
      .get();

  final data = doc.data();
  if (data != null && data.containsKey('year')) {
    thisYearNow = data['year'] as int;
  }
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
            children: [
              Text(
                "AUTH Score",
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
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
                //NotificationsForAllChampionship()

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
  State<NotificationsForAllChampionship> createState() => _NotificationsForAllChampionshipState();
}

class _NotificationsForAllChampionshipState extends State<NotificationsForAllChampionship> {
  bool active= false;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        setState(() {
          active = !active;
        });
        // εδώ μπορείς να βάλεις και FirebaseMessaging.subscribeToTopic / unsubscribe
      },
      icon: Icon(
        active
            ? Icons.notifications_active
            : Icons.notifications_none,
        color: Colors.white,
      ),
    );
  }
}




// ------------------------ BOTTOM NAVIGATION ------------------------
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor:  darkModeNotifier.value?Colors.grey[850]: Colors.black87,
      selectedFontSize: 14,
      unselectedFontSize: 12,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.sports_soccer), label: greek ? "Αγώνες" : "Games"),
        BottomNavigationBarItem(icon: const Icon(Icons.emoji_events), label: greek ? "Πρωτάθλημα" : "Championship"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: greek ? "Αγαπημένα" : "Favorite"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: greek ? "Προφίλ" : "Profile"),
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