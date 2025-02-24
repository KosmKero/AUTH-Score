import 'package:flutter/material.dart';
import 'package:untitled1/Team.dart';
import 'Favorite_Page.dart';
import 'HomePage.dart';
import 'Profile/Profile_Page.dart';
import 'StandingsPage.dart';
import 'Match.dart';
void main() {
  runApp(MyApp());
}
List<Team> teams = [
  Team("Ολυμπιακός", 10, 7, 2, 1, 1, [
    Player("Γιώργος", "Παπαδόπουλος", 5),
    Player("Νίκος", "Λαμπρόπουλος", 3),
  ]),
  Team("Παναθηναϊκός", 10, 6, 3, 1, 1, [
    Player("Αλέξανδρος", "Βασιλείου", 4),
    Player("Δημήτρης", "Κωνσταντίνου", 2),
  ]),
  Team("ΑΕΚ", 10, 5, 4, 1, 1, [
    Player("Στέφανος", "Αντωνίου", 6),
    Player("Μιχάλης", "Γεωργίου", 3),
  ]),
  Team("ΠΑΟΚ", 10, 4, 4, 2, 1, [
    Player("Χρήστος", "Καραμανλής", 2),
    Player("Παναγιώτης", "Σωτηρίου", 5),
  ]),

  // Group 2
  Team("Άρης", 10, 6, 2, 2, 2, [
    Player("Λευτέρης", "Διαμαντής", 4),
    Player("Θοδωρής", "Αναστασίου", 2),
  ]),
  Team("Αστέρας Τρίπολης", 10, 5, 3, 2, 2, [
    Player("Βασίλης", "Κυριακίδης", 3),
    Player("Γιάννης", "Χατζηδάκης", 2),
  ]),
  Team("ΟΦΗ", 10, 4, 5, 1, 2, [
    Player("Μανώλης", "Στρατής", 2),
    Player("Δημήτρης", "Φωτεινός", 1),
  ]),
  Team("Λαμία", 10, 3, 6, 1, 2, [
    Player("Πέτρος", "Αγγελόπουλος", 1),
    Player("Σωτήρης", "Μιχαηλίδης", 1),
  ]),

  // Group 3
  Team("Βόλος", 10, 7, 2, 1, 3, [
    Player("Γιώργος", "Δημητρίου", 5),
    Player("Χάρης", "Νικολάου", 4),
  ]),
  Team("Παναιτωλικός", 10, 5, 3, 2, 3, [
    Player("Αντώνης", "Ρουμπής", 2),
    Player("Σταύρος", "Θεοδώρου", 1),
  ]),
  Team("Ιωνικός", 10, 4, 4, 2, 3, [
    Player("Νεκτάριος", "Παπανικολάου", 3),
    Player("Άρης", "Λεμονής", 2),
  ]),
  Team("Απόλλων Σμύρνης", 10, 2, 6, 2, 3, [
    Player("Χριστόφορος", "Δούκας", 1),
    Player("Φώτης", "Σταματόπουλος", 1),
  ]),

  // Group 4
  Team("Καλαμάτα", 10, 8, 1, 1, 4, [
    Player("Στέργιος", "Κυριαζής", 6),
    Player("Διονύσης", "Μαρκόπουλος", 3),
  ]),
  Team("Χανιά", 10, 6, 3, 1, 4, [
    Player("Ευθύμης", "Ανδριανός", 5),
    Player("Νίκος", "Σφακιανάκης", 2),
  ]),
  Team("Αναγέννηση Καρδίτσας", 10, 5, 4, 1, 4, [
    Player("Λάμπρος", "Παπαγεωργίου", 2),
    Player("Μάριος", "Ξανθόπουλος", 1),
  ]),
  Team("Δόξα Δράμας", 10, 3, 6, 1, 4, [
    Player("Χρήστος", "Καλογερόπουλος", 2),
    Player("Σπύρος", "Αρβανίτης", 1),
  ]),
];
List<Team> favouriteTeams=[];

List<Match> matches = [
  Match(
      homeTeam:  Team("CSD", 10, 7, 2, 1, 1, [
        Player("PA", "PA", 5),
        Player("EW", "EWF", 3),
      ]),
      awayTeam:  Team("νομ", 10, 7, 2, 1, 1, [
        Player("Γιώργος", "Παπαδόπουλος", 5),
        Player("Νίκος", "Λαμπρόπουλος", 3),
      ]),
      hasMatchStarted: true,
      time: 1210,
      day: 10,
      month: 10,
      year: 2025),
  Match(
      homeTeam:  Team("Ολυμπιακός", 10, 7, 2, 1, 1, [
        Player("Γιώργος", "Παπαδόπουλος", 5),
        Player("Νίκος", "Λαμπρόπουλος", 3),
      ]),
      awayTeam:  Team("ψσδ", 10, 7, 2, 1, 1, [
        Player("Γιώργος", "Παπαδόπουλος", 5),
        Player("Νίκος", "Λαμπρόπουλος", 3),
      ]),
      hasMatchStarted: true,
      time: 1210,
      day: 3,
      month: 3,
      year: 2015),
  Match(
      homeTeam:  Team("Ολυμπιακός", 10, 7, 2, 1, 1, [
        Player("Γιώργος", "Παπαδόπουλος", 5),
        Player("Νίκος", "Λαμπρόπουλος", 3),
      ]),
      awayTeam:  Team("Ολυμπιακός", 10, 7, 2, 1, 1, [
        Player("Γιώργος", "Παπαδόπουλος", 5),
        Player("Νίκος", "Λαμπρόπουλος", 3),
      ]),
      hasMatchStarted: true,
      time: 1210,
      day: 3,
      month: 3,
      year: 2015),
  Match(
      homeTeam:  Team("Ολυμπιακός", 10, 7, 2, 1, 1, [
        Player("Γιώργος", "Παπαδόπουλος", 5),
        Player("Νίκος", "Λαμπρόπουλος", 3),
      ]),
      awayTeam: Team("Ολυμπιακός", 10, 7, 2, 1, 1, [
        Player("Γιώργος", "Παπαδόπουλος", 5),
        Player("Νίκος", "Λαμπρόπουλος", 3),
      ]),
      hasMatchStarted: true,
      time: 1210,
      day: 3,
      month: 3,
      year: 2015),
  Match(
      homeTeam:  Team("Ολυμπιακός", 10, 7, 2, 1, 1, [
        Player("Γιώργος", "Παπαδόπουλος", 5),
        Player("Νίκος", "Λαμπρόπουλος", 3),
      ]),
      awayTeam:  Team("Ολυμπιακός", 10, 7, 2, 1, 1, [
        Player("Γιώργος", "Παπαδόπουλος", 5),
        Player("Νίκος", "Λαμπρόπουλος", 3),
      ]),
      hasMatchStarted: true,
      time: 1210,
      day: 3,
      month: 3,
      year: 2015),
  Match(
      homeTeam:  Team("Ολυμπιακός", 10, 7, 2, 1, 1, [
        Player("Γιώργος", "Παπαδόπουλος", 5),
        Player("Νίκος", "Λαμπρόπουλος", 3),
      ]),
      awayTeam: Team("Ολυμπιακός", 10, 7, 2, 1, 1, [
        Player("Γιώργος", "Παπαδόπουλος", 5),
        Player("Νίκος", "Λαμπρόπουλος", 3),
      ]),
      hasMatchStarted: true,
      time: 1210,
      day: 3,
      month: 3,
      year: 2015),
  Match(
      homeTeam:  Team("Ολυμπιακός", 10, 7, 2, 1, 1, [
        Player("Γιώργος", "Παπαδόπουλος", 5),
        Player("Νίκος", "Λαμπρόπουλος", 3),
      ]),
      awayTeam:  Team("Ολυμπιακός", 10, 7, 2, 1, 1, [
        Player("Γιώργος", "Παπαδόπουλος", 5),
        Player("Νίκος", "Λαμπρόπουλος", 3),
      ]),
      hasMatchStarted: true,
      time: 1210,
      day: 3,
      month: 3,
      year: 2015),
  Match(
      homeTeam:  Team("Ολυμπιακός", 10, 7, 2, 1, 1, [
        Player("Γιώργος", "Παπαδόπουλος", 5),
        Player("Νίκος", "Λαμπρόπουλος", 3),
      ]),
      awayTeam:  Team("Ολυμπιακός", 10, 7, 2, 1, 1, [
        Player("Γιώργος", "Παπαδόπουλος", 5),
        Player("Νίκος", "Λαμπρόπουλος", 3),
      ]),
      hasMatchStarted: true,
      time: 1210,
      day: 3,
      month: 3,
      year: 2015),
  Match(
      homeTeam:  Team("Ολυμπιακός", 10, 7, 2, 1, 1, [
        Player("Γιώργος", "Παπαδόπουλος", 5),
        Player("Νίκος", "Λαμπρόπουλος", 3),
      ]),
      awayTeam:  Team("Ολυμπιακός", 10, 7, 2, 1, 1, [
        Player("Γιώργος", "Παπαδόπουλος", 5),
        Player("Νίκος", "Λαμπρόπουλος", 3),
      ]),
      hasMatchStarted: true,
      time: 1210,
      day: 3,
      month: 3,
      year: 2015),
  Match(
      homeTeam:  Team("Ολυμπιακός", 10, 7, 2, 1, 1, [
        Player("Γιώργος", "Παπαδόπουλος", 5),
        Player("Νίκος", "Λαμπρόπουλος", 3),
      ]),
      awayTeam:  Team("Ολυμπιακός", 10, 7, 2, 1, 1, [
        Player("Γιώργος", "Παπαδόπουλος", 5),
        Player("Νίκος", "Λαμπρόπουλος", 3),
      ]),
      hasMatchStarted: true,
      time: 1210,
      day: 3,
      month: 3,
      year: 2015),
  Match(
      homeTeam:  Team("Ολυμπιακός", 10, 7, 2, 1, 1, [
      Player("Γιώργος", "Παπαδόπουλος", 5),
  Player("Νίκος", "Λαμπρόπουλος", 3),
]),
      awayTeam:  Team("Ολυμπιακός", 10, 7, 2, 1, 1, [
        Player("Γιώργος", "Παπαδόπουλος", 5),
        Player("Νίκος", "Λαμπρόπουλος", 3),
      ]),
      hasMatchStarted: true,
      time: 1210,
      day: 3,
      month: 3,
      year: 2015),
  Match(
      homeTeam:  Team("Ολυμπιακός", 10, 7, 2, 1, 1, [
        Player("Γιώργος", "Παπαδόπουλος", 5),
        Player("Νίκος", "Λαμπρόπουλος", 3),
      ]),
      awayTeam:  Team("Ολυμπιακός", 10, 7, 2, 1, 1, [
        Player("Γιώργος", "Παπαδόπουλος", 5),
        Player("Νίκος", "Λαμπρόπουλος", 3),
      ]),
      hasMatchStarted: true,
      time: 1210,
      day: 3,
      month: 3,
      year: 2015)
];

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
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

  CustomAppBar({required this.onOptionSelected, required this.selectedOption});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("AUTH Score",style: TextStyle(fontSize: 26,fontWeight: FontWeight.bold, color:  Colors.white)),
      backgroundColor: const Color.fromARGB(255, 177, 37, 32),
      actions: [
        Padding(
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
        ),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 5),
          child: IconButton(
            icon: Icon(Icons.search, color: Colors.white,), // Μεγεθυντικός φακός
            onPressed: () {
              // Εδώ προσθέτεις τη λειτουργία αναζήτησης
              print('Πατήθηκε το κουμπί αναζήτησης');
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
      backgroundColor: const Color.fromARGB(255, 223, 87, 82),
      selectedFontSize:
      14, // Αυξάνει το μέγεθος της γραμματοσειράς του επιλεγμένου
      unselectedFontSize: 12, // Μικρότερη γραμματοσειρά για τα μη επιλεγμένα
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer), label: "Αγώνες"),
        BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_rounded), label: "Βαθμολογία"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Αγαπημένα"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Προφίλ"),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.black,
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
      return StandingsPage();
    case 2:
      return FavoritePage();
    case 3:
      return ProfilePage();
    default:
      return HomePage();
  }
}

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
//----------------------------------------------------------------------------------






