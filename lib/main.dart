import 'package:flutter/material.dart';
import 'HomePage.dart';

void main() {
  runApp(MyApp());
}

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
      title: Text("AUTH Score"),
      backgroundColor: const Color.fromARGB(255, 177, 37, 32),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
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

  CustomBottomNavigationBar({required this.currentIndex, required this.onTap});

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
Widget _buildBody(int _selectedIndex) {
  switch (_selectedIndex) {
    case 0:
      return HomePage();
    case 1:
      return StandingsPage();
    case 2:
      return FavoritePage();
    case 3:
      return profilePage();
    default:
      return HomePage();
  }
}


class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "agahmena",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class profilePage extends StatelessWidget {
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

class StandingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "vathmologia",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
//----------------------------------------------------------------------------------






