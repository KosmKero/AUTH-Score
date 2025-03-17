import 'package:flutter/material.dart';
import 'package:untitled1/API/Match_Handle.dart';
import 'package:untitled1/Data_Classes/Team.dart';
import 'package:untitled1/standings_or_knockouts_package/knock_outs_page.dart';
import 'package:untitled1/standings_or_knockouts_package/standings_or_knockouts_chooser_page.dart';
import 'Data_Classes/User.dart';
import 'Favorite_Page.dart';
import 'HomePage.dart';
import 'Data_Classes/Player.dart';
import 'Profile/Profile_Page.dart';
import 'Search_Page.dart';
import 'standings_or_knockouts_package/StandingsPage.dart';
import 'Data_Classes/Match.dart';



void main() {
  runApp(MyApp());
}
List<Team> teams = [
  Team("Ολυμπιακός", 10, 7, 2, 1, 1,2000, 0,[
    Player("Γιώργος", "Παπαδόπουλος",2, 5),
    Player("Γιώργος", "Παπαδόπουλος",2, 5),
    Player("Γιώργος", "Παπαδόπουλος",2, 5),
    Player("Γιώργος", "Παπαδόπουλος",2, 5),
    Player("Γιώργος", "Παπαδόπουλος",0, 5),
    Player("Γιώργος", "Παπαδόπουλος",0, 5),
    Player("Γιώργος", "Παπαδόπουλος",1, 5),
    Player("Νίκος", "Λαμπρόπουλος",2, 3),
  ]),
  Team("Παναθηναϊκός", 10, 6, 3, 1, 1,2010,0, [
    Player("Αλέξανδρος", "Βασιλείου",2, 4),
    Player("Δημήτρης", "Κωνσταντίνου",2, 2),
  ]),
  Team("ΑΕΚ", 10, 5, 4, 1, 1, 2015,0,[
    Player("Στέφανος", "Αντωνίου",2, 6),
    Player("Μιχάλης", "Γεωργίου",2, 3),
  ]),
  Team("ΠΑΟΚ", 10, 4, 4, 2, 1,2000,0, [
    Player("Χρήστος", "Καραμανλής", 2,2),
    Player("Παναγιώτης", "Σωτηρίου",2, 5),
  ]),

  // Group 2
  Team("Άρης", 10, 6, 2, 2, 2, 2000,0,[
    Player("Λευτέρης", "Διαμαντής", 2,4),
    Player("Θοδωρής", "Αναστασίου", 2,2),
  ]),
  Team("Αστέρας Τρίπολης", 10, 5, 3, 2, 2, 2000,0,[
    Player("Βασίλης", "Κυριακίδης",2, 3),
    Player("Γιάννης", "Χατζηδάκης",2, 2),
  ]),
  Team("ΟΦΗ", 10, 4, 5, 1, 2, 2000,0,[
    Player("Μανώλης", "Στρατής",2, 2),
    Player("Δημήτρης", "Φωτεινός",2, 1),
  ]),
  Team("Λαμία", 10, 3, 6, 1, 2,2000,0, [
    Player("Πέτρος", "Αγγελόπουλος",2, 1),
    Player("Σωτήρης", "Μιχαηλίδης",2, 1),
  ]),

  // Group 3
  Team("Βόλος", 10, 7, 2, 1, 3,2000,0, [
    Player("Γιώργος", "Δημητρίου",2, 5),
    Player("Χάρης", "Νικολάου",2, 4),
  ]),
  Team("Παναιτωλικός", 10, 5, 3, 2, 3,2000,0, [
    Player("Αντώνης", "Ρουμπής",2, 2),
    Player("Σταύρος", "Θεοδώρου",2, 1),
  ]),
  Team("Ιωνικός", 10, 4, 4, 2, 3, 2000,0,[
    Player("Νεκτάριος", "Παπανικολάου",2, 3),
    Player("Άρης", "Λεμονής",2, 2),
  ]),
  Team("Απόλλων Σμύρνης", 10, 2, 6, 2, 3,2000,0, [
    Player("Χριστόφορος", "Δούκας",2, 1),
    Player("Φώτης", "Σταματόπουλος",2, 1),
  ]),

  // Group 4
  Team("Καλαμάτα", 10, 8, 1, 1, 4,2000,0, [
    Player("Στέργιος", "Κυριαζής",2, 6),
    Player("Διονύσης", "Μαρκόπουλος",2, 3),
  ]),
  Team("Χανιά", 10, 6, 3, 1, 4,2000, 0,[
    Player("Ευθύμης", "Ανδριανός",2, 5),
    Player("Νίκος", "Σφακιανάκης",2, 2),
  ]),
  Team("Αναγέννηση Καρδίτσας", 10, 5, 4, 1, 4, 2000,0,[
    Player("Λάμπρος", "Παπαγεωργίου",2, 2),
    Player("Μάριος", "Ξανθόπουλος",2, 1),
  ]),
  Team("Δόξα Δράμας", 10, 3, 6, 1, 4, 2000,0,[
    Player("Χρήστος", "Καλογερόπουλος",2, 2),
    Player("Σπύρος", "Αρβανίτης",2, 1),
  ]),
];
List<Team> favouriteTeams=[];
List<Player> players=[];
List<Match> upcomingMatches = [
  Match(
      homeTeam: Team("Ολυμπιακός", 10, 7, 2, 1, 1,2000,0, [
        Player("Γιώργος", "Παπαδόπουλος",2, 5),
        Player("Νίκος", "Λαμπρόπουλος",2, 3),
      ]),
      awayTeam: Team("Παναθηναϊκός", 10, 6, 3, 1, 1,2000, 0,[
        Player("Αλέξανδρος", "Βασιλείου",2, 4),
        Player("Δημήτρης", "Κωνσταντίνου",2, 2),
      ]),
      hasMatchStarted: false,
      time: 1500,
      day: 5,
      month: 3,
      year: 2025),

  Match(
      homeTeam: Team("ΑΕΚ", 10, 5, 4, 1, 1,2000, 0,[
        Player("Στέφανος", "Αντωνίου",1, 6),
        Player("Μιχάλης", "Γεωργίου",2, 3),
      ]),
      awayTeam: Team("ΠΑΟΚ", 10, 4, 4, 2, 1, 2000,0,[
        Player("Χρήστος", "Καραμανλής",1, 2),
        Player("Παναγιώτης", "Σωτηρίου",2, 5),
      ]),
      hasMatchStarted: false,
      time: 1700,
      day: 5,
      month: 3,
      year: 2025),

  Match(
      homeTeam: Team("Άρης", 10, 6, 2, 2, 2, 2000,0,[
        Player("Λευτέρης", "Διαμαντής",1, 4),
        Player("Θοδωρής", "Αναστασίου", 2,2),
      ]),
      awayTeam: Team("ΟΦΗ", 10, 4, 5, 1, 2,2000,0, [
        Player("Μανώλης", "Στρατής",2, 2),
        Player("Δημήτρης", "Φωτεινός",1, 1),
        Player("Λευτέρης", "Διαμαντής",3, 4),
      ]),
      hasMatchStarted: false,
      time: 1600,
      day: 7,
      month: 3,
      year: 2025),

  Match(
      homeTeam: Team("Βόλος", 10, 7, 2, 1, 3,2015,0, [
        Player("Γιώργος", "Δημητρίου",1, 5),
        Player("Χάρης", "Νικολάου",2, 4),
      ]),
      awayTeam: Team("Ιωνικός", 10, 4, 4, 2, 3,2000,0, [
        Player("Νεκτάριος", "Παπανικολάου", 2,3),
        Player("Άρης", "Λεμονής",1, 2),
      ]),
      hasMatchStarted: false,
      time: 1800,
      day: 8,
      month: 3,
      year: 2025),

  Match(
      homeTeam: Team("Καλαμάτα", 10, 8, 1, 1, 4,2000,0, [
        Player("Στέργιος", "Κυριαζής",2, 6),
        Player("Διονύσης", "Μαρκόπουλος",2, 3),
      ]),
      awayTeam: Team("Χανιά", 10, 6, 3, 1, 4,2000,0, [
        Player("Ευθύμης", "Ανδριανός",2, 5),
        Player("Νίκος", "Σφακιανάκης",2, 2),
      ]),
      hasMatchStarted: false,
      time: 1900,
      day: 9,
      month: 3,
      year: 2025),
  Match(
      homeTeam: Team("Ολυμπιακός", 10, 7, 2, 1, 1,2000, 0,[
        Player("Γιώργος", "Παπαδόπουλος",2, 5),
        Player("Νίκος", "Λαμπρόπουλος",2, 3),
      ]),
      awayTeam: Team("Παναθηναϊκός", 10, 6, 3, 1, 1,2000,0, [
        Player("Αλέξανδρος", "Βασιλείου",2, 4),
        Player("Δημήτρης", "Κωνσταντίνου",2, 2),
      ]),
      hasMatchStarted: true,
      time: 1500,
      day: 12,
      month: 3,
      year: 2025),

  Match(
      homeTeam: Team("ΑΕΚ", 10, 5, 4, 1, 1,2000,0, [
        Player("Στέφανος", "Αντωνίου",2, 6),
        Player("Μιχάλης", "Γεωργίου",2, 3),
      ]),
      awayTeam: Team("ΠΑΟΚ", 10, 4, 4, 2, 1,2000, 0,[
        Player("Χρήστος", "Καραμανλής",2, 2),
        Player("Παναγιώτης", "Σωτηρίου",2, 5),
      ]),
      hasMatchStarted: false,
      time: 1700,
      day: 15,
      month: 3,
      year: 2025),

  Match(
      homeTeam: Team("Άρης", 10, 6, 2, 2, 2,2000, 0,[
        Player("Λευτέρης", "Διαμαντής",2, 4),
        Player("Θοδωρής", "Αναστασίου",2, 2),
      ]),
      awayTeam: Team("Αστέρας Τρίπολης", 10, 5, 3, 2, 2,2000, 0,[
        Player("Βασίλης", "Κυριακίδης",2, 3),
        Player("Γιάννης", "Χατζηδάκης",2, 2),
      ]),
      hasMatchStarted: false,
      time: 1600,
      day: 20,
      month: 3,
      year: 2025),

  Match(
      homeTeam: Team("ΟΦΗ", 10, 4, 5, 1, 2,2000,0, [
        Player("Μανώλης", "Στρατής",2, 2),
        Player("Δημήτρης", "Φωτεινός",2, 1),
      ]),
      awayTeam: Team("Λαμία", 10, 3, 6, 1, 2,2000, 0,[
        Player("Πέτρος", "Αγγελόπουλος",2, 1),
        Player("Σωτήρης", "Μιχαηλίδης",2, 1),
      ]),
      hasMatchStarted: true,
      time: 1800,
      day: 25,
      month: 3,
      year: 2025),

  Match(
      homeTeam: Team("Βόλος", 10, 7, 2, 1, 3,2000, 0,[
        Player("Γιώργος", "Δημητρίου",2, 5),
        Player("Χάρης", "Νικολάου",2, 4),
      ]),
      awayTeam: Team("Παναιτωλικός", 10, 5, 3, 2, 3,2000,0, [
        Player("Αντώνης", "Ρουμπής",2, 2),
        Player("Σταύρος", "Θεοδώρου",2, 1),
      ]),
      hasMatchStarted: false,
      time: 1900,
      day: 28,
      month: 3,
      year: 2025)
];
List<Match> previousMatches = [
  Match(
      homeTeam: Team("Ολυμπιακός", 10, 7, 2, 1, 1,2000,0, [
        Player("Γιώργος", "Παπαδόπουλος",2, 5),
        Player("Νίκος", "Λαμπρόπουλος",2, 3),
      ]),
      awayTeam: Team("Παναθηναϊκός", 10, 6, 3, 1, 1,2000, 0,[
        Player("Αλέξανδρος", "Βασιλείου",2, 4),
        Player("Δημήτρης", "Κωνσταντίνου",2, 2),
      ]),
      hasMatchStarted: false,
      time: 1500,
      day: 5,
      month: 3,
      year: 2025),

  Match(
      homeTeam: Team("ΑΕΚ", 10, 5, 4, 1, 1,2000, 0,[
        Player("Στέφανος", "Αντωνίου",1, 6),
        Player("Μιχάλης", "Γεωργίου",2, 3),
      ]),
      awayTeam: Team("ΠΑΟΚ", 10, 4, 4, 2, 1, 2000,0,[
        Player("Χρήστος", "Καραμανλής",1, 2),
        Player("Παναγιώτης", "Σωτηρίου",2, 5),
      ]),
      hasMatchStarted: false,
      time: 1700,
      day: 5,
      month: 3,
      year: 2025),

  Match(
      homeTeam: Team("Άρης", 10, 6, 2, 2, 2, 2000,0,[
        Player("Λευτέρης", "Διαμαντής",1, 4),
        Player("Θοδωρής", "Αναστασίου", 2,2),
      ]),
      awayTeam: Team("ΟΦΗ", 10, 4, 5, 1, 2,2000,0, [
        Player("Μανώλης", "Στρατής",2, 2),
        Player("Δημήτρης", "Φωτεινός",1, 1),
        Player("Λευτέρης", "Διαμαντής",3, 4),
      ]),
      hasMatchStarted: false,
      time: 1600,
      day: 7,
      month: 3,
      year: 2025),

  Match(
      homeTeam: Team("Βόλος", 10, 7, 2, 1, 3,2015,0, [
        Player("Γιώργος", "Δημητρίου",1, 5),
        Player("Χάρης", "Νικολάου",2, 4),
      ]),
      awayTeam: Team("Ιωνικός", 10, 4, 4, 2, 3,2000,0, [
        Player("Νεκτάριος", "Παπανικολάου", 2,3),
        Player("Άρης", "Λεμονής",1, 2),
      ]),
      hasMatchStarted: false,
      time: 1800,
      day: 8,
      month: 3,
      year: 2025),

  Match(
      homeTeam: Team("Καλαμάτα", 10, 8, 1, 1, 4,2000,0, [
        Player("Στέργιος", "Κυριαζής",2, 6),
        Player("Διονύσης", "Μαρκόπουλος",2, 3),
      ]),
      awayTeam: Team("Χανιά", 10, 6, 3, 1, 4,2000,0, [
        Player("Ευθύμης", "Ανδριανός",2, 5),
        Player("Νίκος", "Σφακιανάκης",2, 2),
      ]),
      hasMatchStarted: false,
      time: 1900,
      day: 9,
      month: 3,
      year: 2025),
  Match(
      homeTeam: Team("Ολυμπιακός", 10, 7, 2, 1, 1,2000, 0,[
        Player("Γιώργος", "Παπαδόπουλος",2, 5),
        Player("Νίκος", "Λαμπρόπουλος",2, 3),
      ]),
      awayTeam: Team("Παναθηναϊκός", 10, 6, 3, 1, 1,2000,0, [
        Player("Αλέξανδρος", "Βασιλείου",2, 4),
        Player("Δημήτρης", "Κωνσταντίνου",2, 2),
      ]),
      hasMatchStarted: true,
      time: 1500,
      day: 12,
      month: 3,
      year: 2025),

  Match(
      homeTeam: Team("ΑΕΚ", 10, 5, 4, 1, 1,2000,0, [
        Player("Στέφανος", "Αντωνίου",2, 6),
        Player("Μιχάλης", "Γεωργίου",2, 3),
      ]),
      awayTeam: Team("ΠΑΟΚ", 10, 4, 4, 2, 1,2000, 0,[
        Player("Χρήστος", "Καραμανλής",2, 2),
        Player("Παναγιώτης", "Σωτηρίου",2, 5),
      ]),
      hasMatchStarted: false,
      time: 1700,
      day: 15,
      month: 3,
      year: 2025),

  Match(
      homeTeam: Team("Άρης", 10, 6, 2, 2, 2,2000, 0,[
        Player("Λευτέρης", "Διαμαντής",2, 4),
        Player("Θοδωρής", "Αναστασίου",2, 2),
      ]),
      awayTeam: Team("Αστέρας Τρίπολης", 10, 5, 3, 2, 2,2000, 0,[
        Player("Βασίλης", "Κυριακίδης",2, 3),
        Player("Γιάννης", "Χατζηδάκης",2, 2),
      ]),
      hasMatchStarted: false,
      time: 1600,
      day: 20,
      month: 3,
      year: 2025),

  Match(
      homeTeam: Team("ΟΦΗ", 10, 4, 5, 1, 2,2000,0, [
        Player("Μανώλης", "Στρατής",2, 2),
        Player("Δημήτρης", "Φωτεινός",2, 1),
      ]),
      awayTeam: Team("Λαμία", 10, 3, 6, 1, 2,2000, 0,[
        Player("Πέτρος", "Αγγελόπουλος",2, 1),
        Player("Σωτήρης", "Μιχαηλίδης",2, 1),
      ]),
      hasMatchStarted: true,
      time: 1800,
      day: 25,
      month: 3,
      year: 2025),

  Match(
      homeTeam: Team("Βόλος", 10, 7, 2, 1, 3,2000, 0,[
        Player("Γιώργος", "Δημητρίου",2, 5),
        Player("Χάρης", "Νικολάου",2, 4),
      ]),
      awayTeam: Team("Παναιτωλικός", 10, 5, 3, 2, 3,2000,0, [
        Player("Αντώνης", "Ρουμπής",2, 2),
        Player("Σταύρος", "Θεοδώρου",2, 1),
      ]),
      hasMatchStarted: false,
      time: 1900,
      day: 28,
      month: 3,
      year: 2025)
];
List<List<Match>> matches=[upcomingMatches,previousMatches];


class MyApp extends StatelessWidget {
  MyApp({super.key}){
    MatchHandle().initializeMatces(matches);
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
            icon: Icon(Icons.leaderboard_rounded), label: "Βαθμολογία"),
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
      return ProfilePage(user: User("Kosm","Kero","Kosmkero","pass"),);
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






