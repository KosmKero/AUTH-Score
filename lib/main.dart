import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/API/Match_Handle.dart';
import 'package:untitled1/API/top_players_handle.dart';
import 'package:untitled1/Data_Classes/Team.dart';
import 'package:untitled1/Data_Classes/User.dart';
import 'package:untitled1/championship_details/knock_outs_page.dart';
import 'package:untitled1/championship_details/sector_chooser.dart';
import 'Data_Classes/User.dart';
import 'Favorite_Page.dart';
import 'HomePage.dart';
import 'Data_Classes/Player.dart';
import 'Profile/Profile_Page.dart';
import 'Search_Page.dart';
import 'championship_details/StandingsPage.dart';
import 'Data_Classes/Match.dart';

import 'package:cloud_firestore/cloud_firestore.dart';



void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print("✅ Firebase initialized successfully!");
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }

  //ΒΑΖΟΥΜΕ ΧΡΗΣΤΗ ΣΤΗΝ ΒΑΣΗ ΔΕΔΟΜΕΝΩΝ
  /*
  User User1 = new User("alex", "damos", "adamo", "aD");

  CollectionReference users = FirebaseFirestore.instance.collection('UserDocument');
  await users.doc(User1.username).set({
    'LastName': User1.lastName,
    'Name': User1.name,
    'Role': 'No role', // Αν υπάρχει ρόλος, προσθέστε τον εδώ
    'UserName': User1.username,
    'password': User1.password,
  });

   */





  runApp(MyApp());
}

//0 τερμας, 1 αμυντικος, 2 μεσος, 3 επιθετικος
List<Team> teams = [
  Team("Ολυμπιακός", 10, 7, 2, 1, 1, 2000, 0, [
    Player("Γιώργαρας", "Παπαδόπgουλος", 2, 5, 10, 22,"Olympiacos"),
    Player("Πετsρος", "Ππgα", 2, 5, 5, 21, "Olympiacos"),
    Player("Φανηsς", "Κωfνστα", 2, 5, 5, 20, "Olympiacos"),
    Player("Ποαaλ", "Ποjλο", 2, 5, 5, 19, "Olympiacos"),
    Player("Γιώργaος", "Παπαδόπουgλος", 0, 5, 5, 25, "Olympiacos"),
    Player("Γιώργοdς", "Παπαδόπgουλος", 0, 5, 5, 24, "Olympiacos"),
    Player("Γιώργοdς", "Παπαδgόπουλος", 1, 5, 5, 23, "Olympiacos"),
    Player("Νίκοςd", "Λαμπρόπουλοwς", 2, 3 ,3  , 22, "Olympiacos"),
    Player("Γιώργaαρας", "Παπαδόπgουλος", 2, 5, 10, 22,"Olympiacos"),
    Player("Πετροgς", "Ππα", 2, 5, 5, 21, "Olympiacos"),
    Player("Φανης", "sdΚωνστα", 2, 5, 5, 20, "Olympiacos"),
    Player("Ποαλ", "Πολfο", 2, 5, 5, 19, "Olympiacos"),
    Player("Γιώργος", "Πfdαπαδόπουλος", 0, 5, 5, 25, "Olympiacos"),
    Player("Γιώργος", "Παπfαδόπουλος", 0, 5, 5, 24, "Olympiacos"),
    Player("Γιώργος", "Παπαfgδόπουλος", 1, 5, 5, 23, "Olympiacos"),
    Player("Νίκος", "Λαμπρόποhυλος", 2, 3 ,3  , 22, "Olympiacos"),
  ]),

  Team("Παναθηναϊκός", 10, 6, 3, 1, 1, 2010, 0, [
    Player("Αλέξανδρος", "Βασιλείου", 2, 4,  7, 23, "Panathinaikos"),
    Player("Δημήτρης", "Κωνσταντίνου", 2, 2, 2, 24, "Panathinaikos"),
  ]),

  Team("ΑΕΚ", 10, 5, 4, 1, 1, 2015, 0, [
    Player("Στέφανος", "Αντωνίου", 2, 6, 8, 22, "AEK"),
    Player("Μιχάλης", "Γεωργίου", 2, 3,  3, 25, "AEK"),
  ]),

  Team("ΠΑΟΚ", 10, 4, 4, 2, 1, 2000, 0, [
    Player("Χρήστος", "Καραμανλής", 2, 2,  4, 28, "PAOK"),
    Player("Παναγιώτης", "Σωτηρίου", 2, 5, 5, 26, "PAOK"),
  ]),

  Team("Άρης", 10, 6, 2, 2, 2, 2000, 0, [
    Player("Felipe", "Bakas",   2,   4,   6, 29, "Aris"),
    Player("Θοδωρής", "Αναστασίου", 2, 2, 3, 30, "Aris"),
  ]),

  Team("Αστέρας Τρίπολης", 10, 5, 3, 2, 2, 2000, 0, [
    Player("Βασίλης", "Κυριακίδης", 2, 3,  4, 31, "Asteras Tripolis"),
    Player("Γιάννης", "Χατζηδάκης", 2, 2,  2, 32, "Asteras Tripolis"),
  ]),

  Team("ΟΦΗ", 10, 4, 5, 1, 2, 2000, 0, [
    Player("Μανώλης", "Στρατής", 2, 2,   3,   33, "OFI"),
    Player("Δημήτρης", "Φωτεινός", 2, 1, 1, 34,   "OFI"),
  ]),

  Team("Λαμία", 10, 3, 6, 1, 2, 2000, 0, [
    Player("Πέτρος", "Αγγελόπουλος", 2, 1, 2, 35, "Λαμία"),
    Player("Σωτήρης", "Μιχαηλίδης", 2, 1,  1, 36, "Λαμία"),
  ]),

  Team("Βόλος", 10, 7, 2, 1, 3, 2000, 0, [
    Player("Γιώργος", "Δημητρίου", 2, 5,5, 37, "Βόλος"),
    Player("Χάρης", "Νικολάου", 2, 4,    4, 38, "Βόλος"),
  ]),

  Team("Παναιτωλικός", 10, 5, 3, 2, 3, 2000, 0, [
    Player("Αντώνης", "Ρουμπής", 2, 2,   2, 39, "Παναιτωλικός"),
    Player("Σταύρος", "Θεοδώρου", 2, 1,  1, 40, "Παναιτωλικός"),
  ]),

  Team("Ιωνικός", 10, 4, 4, 2, 3, 2000, 0, [
    Player("Νεκτάριος", "Παπανικολάου", 2, 3,3, 41, "Ιωνικός"),
    Player("Άρης", "Λεμονής",           2, 2,2, 42, "Ιωνικός"),
  ]),

  Team("Απόλλων Σμύρνης", 10, 2, 6, 2, 3, 2000, 0, [
    Player("Χριστόφορος", "Δούκας", 2, 1, 1, 43, "Απόλλων Σμύρνης"),
    Player("Φώτης", "Σταματόπουλος", 2, 1, 1, 44, "Απόλλων Σμύρνης"),
  ]),

  Team("Καλαμάτα", 10, 8, 1, 1, 4, 2000, 0, [
    Player("Στέργιος", "Κυριαζής", 2, 6,    8, 45, "Καλαμάτα"),
    Player("Διονύσης", "Μαρκόπουλος", 2, 3, 3, 46, "Καλαμάτα"),
  ]),

  Team("Χανιά", 10, 6, 3, 1, 4, 2000, 0, [
    Player("Ευθύμης", "Ανδριανός", 2, 5, 5, 47, "Χανιά"),
    Player("Νίκος", "Σφακιανάκης", 2, 2, 2, 48, "Χανιά"),
  ]),

  Team("Αναγέννηση Καρδίτσας", 10, 5, 4, 1, 4, 2000, 0, [
    Player("Λάμπρος", "Παπαγεωργίου", 2, 2, 2, 49, "Αναγέννηση Καρδίτσας"),
    Player("Μάριος", "Ξανθόπουλος",    2, 1,1, 50, "Αναγέννηση Καρδίτσας"),
  ]),

  Team("Δόξα Δράμας", 10, 3, 6, 1, 4, 2000, 0, [
    Player("Χρήστος", "Καλογερόπουλος", 2, 2,  2, 51, "Δόξα Δράμας"),
    Player("Σπύρος", "Αρβανίτης",       2, 1,  1, 52, "Δόξα Δράμας"),
  ]),
];
List<Team> favouriteTeams=[];
List<Player> players=[];
List<Match> upcomingMatches = [
  Match(
    homeTeam: teams[0],
    awayTeam: teams[1],
    hasMatchStarted: false,
    time: 1500,
    day: 5,
    month: 3,
    year: 2025,
    isGroupPhase: true,
    game: 8,
  ),
  Match(
    homeTeam: teams[2],
    awayTeam: teams[3],
    hasMatchStarted: false,
    time: 1700,
    day: 5,
    month: 3,
    year: 2025,
    isGroupPhase: true,
    game: 1,
  ),
  Match(
    homeTeam: teams[4],
    awayTeam: teams[6],
    hasMatchStarted: false,
    time: 1600,
    day: 7,
    month: 3,
    year: 2025,
    isGroupPhase: true,
    game: 2,
  ),
  Match(
    homeTeam: teams[8],
    awayTeam: teams[10],
    hasMatchStarted: false,
    time: 1800,
    day: 8,
    month: 3,
    year: 2025,
    isGroupPhase: true,
    game: 3,
  ),
  Match(
    homeTeam: teams[11],
    awayTeam: teams[12],
    hasMatchStarted: false,
    time: 1900,
    day: 9,
    month: 3,
    year: 2025,
    isGroupPhase: true,
    game: 4,
  ),
  Match(
    homeTeam: teams[0],
    awayTeam: teams[1],
    hasMatchStarted: true,
    time: 1500,
    day: 12,
    month: 3,
    year: 2025,
    isGroupPhase: true,
    game: 5,
  ),
  Match(
    homeTeam: teams[2],
    awayTeam:teams[3],
    hasMatchStarted: false,
    time: 1700,
    day: 15,
    month: 3,
    year: 2025,
    isGroupPhase: true,
    game: 6,
  ),
  Match(
    homeTeam: teams[4],
    awayTeam: teams[5],
    hasMatchStarted: false,
    time: 1600,
    day: 20,
    month: 3,
    year: 2025,
    isGroupPhase: true,
    game: 7,
  ),
  Match(
    homeTeam: teams[6],
    awayTeam: teams[7],
    hasMatchStarted: true,
    time: 1800,
    day: 25,
    month: 3,
    year: 2025,
    isGroupPhase: true,
    game: 8,
  ),
  Match(
    homeTeam: teams[8],
    awayTeam: teams[9],
    hasMatchStarted: false,
    time: 1900,
    day: 28,
    month: 3,
    year: 2025,
    isGroupPhase: true,
    game: 9,
  ),
];

List<Match> previousMatches = [
  Match(
    homeTeam: teams[0],
    awayTeam: teams[1],
    hasMatchStarted: false,
    time: 1500,
    day: 5,
    month: 3,
    year: 2025,
    isGroupPhase: false,
    game: 10,
  ),
  Match(
    homeTeam: teams[2],
    awayTeam: teams[3],
    hasMatchStarted: false,
    time: 1700,
    day: 5,
    month: 3,
    year: 2025,
    isGroupPhase: false,
    game: 11,
  ),
  Match(
    homeTeam: teams[4],
    awayTeam: teams[6],
    hasMatchStarted: false,
    time: 1600,
    day: 7,
    month: 3,
    year: 2025,
    isGroupPhase: false,
    game: 12,
  ),
  Match(
    homeTeam:teams[8],
    awayTeam: teams[9],
    hasMatchStarted: false,
    time: 1800,
    day: 8,
    month: 3,
    year: 2025,
    isGroupPhase: false,
    game: 13,
  ),
  Match(
    homeTeam: teams[11],
    awayTeam: teams[12],
    hasMatchStarted: false,
    time: 1900,
    day: 9,
    month: 3,
    year: 2025,
    isGroupPhase: false,
    game: 14,
  ),
  Match(
    homeTeam: teams[0],
    awayTeam: teams[1],
    hasMatchStarted: true,
    time: 1500,
    day: 12,
    month: 3,
    year: 2025,
    isGroupPhase: false,
    game: 15,
  ),
  Match(
    homeTeam: teams[2],
    awayTeam: teams[3],
    hasMatchStarted: false,
    time: 1700,
    day: 15,
    month: 3,
    year: 2025,
    isGroupPhase: false,
    game: 16,
  ),
  Match(
    homeTeam: teams[4],
    awayTeam: teams[5],
    hasMatchStarted: false,
    time: 1600,
    day: 20,
    month: 3,
    year: 2025,
    isGroupPhase: false,
    game: 17,
  ),
  Match(
    homeTeam: teams[6],
    awayTeam: teams[7],
    hasMatchStarted: true,
    time: 1800,
    day: 25,
    month: 3,
    year: 2025,
    isGroupPhase: false,
    game: 18,
  ),
  Match(
    homeTeam: teams[8],
    awayTeam: teams[9],
    hasMatchStarted: false,
    time: 1900,
    day: 28,
    month: 3,
    year: 2025,
    isGroupPhase: false,
    game: 19,
  ),
];

List<List<Match>> matches=[upcomingMatches,previousMatches];


class MyApp extends StatelessWidget {
  MyApp({super.key}){
    MatchHandle().initializeMatces(matches);
    TopPlayersHandle().initializeList(teams);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(),
    );
  }
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
  final Function(String) onOptionSelected;
  final String selectedOption;

  const CustomAppBar({super.key, required this.onOptionSelected, required this.selectedOption});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("AUTH Score",style: TextStyle(fontSize: 26,fontWeight: FontWeight.bold, color:  Colors.white)),
      backgroundColor: const Color.fromARGB(250, 50, 120, 90),
      actions: [
        /* Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: PopupMenuButton<String>(
            onSelected: onOptionSelected,
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: "Ποδόσφαιρο",
                child: Row(
                  children: [
                    Icon(Icons.sports_soccer, color: Colors.black),
                    SizedBox(width: 10),
                    Text("Ποδόσφαιρο"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "Μπάσκετ",
                child: Row(
                  children: [
                    Icon(Icons.sports_basketball, color: Colors.black),
                    SizedBox(width: 10),
                    Text("Μπάσκετ"),
                  ],
                ),
              ),
            ],
            child: Row(
              children: [
                Text(
                  selectedOption,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
          ),
        ),*/
        Padding(padding: const EdgeInsets.symmetric(horizontal: 5),
          child: IconButton(
            icon: Icon(Icons.search, color: Colors.white,), // Μεγεθυντικός φακός
            onPressed: () {
              // Εδώ προσθέτεις τη λειτουργία αναζήτησης
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SearchPage()));
            },
          ),
        )
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

// ------------------------ BOTTOM NAVIGATION ------------------------
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color.fromARGB(255, 10, 28, 21),
      selectedFontSize:
      14, // Αυξάνει το μέγεθος της γραμματοσειράς του επιλεγμένου
      unselectedFontSize: 12, // Μικρότερη γραμματοσειρά για τα μη επιλεγμένα
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer), label: "Αγώνες"),
        BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events), label: "Πρωτάθλημα"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Αγαπημένα"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Προφίλ"),
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
      //return KnockOutsPage();
      //return StandingsPage();
    case 2:
      return FavoritePage();
    case 3:
      return ProfilePage(user: User("Kosm","Kero","Kosmkero","pass","auth"),);
    default:
      return HomePage();
  }
}
/*
class profilePage extends StatelessWidget {
  const profilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "profile",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
*/
//----------------------------------------------------------------------------------






