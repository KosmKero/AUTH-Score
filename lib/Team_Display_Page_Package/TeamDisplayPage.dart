import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';
import 'package:untitled1/Team_Display_Page_Package/Team_Details_Widget.dart';
import 'package:untitled1/Team_Display_Page_Package/Team_Matches_Widget.dart';
import 'package:untitled1/Team_Display_Page_Package/Team_Players_Display_Widget.dart';
import 'package:untitled1/championship_details/top_players_page.dart';
import 'package:untitled1/globals.dart';
import 'package:untitled1/main.dart';

import '../Data_Classes/Player.dart';
import '../Data_Classes/Team.dart';

class TeamDisplayPage extends StatefulWidget{

  const TeamDisplayPage(this.team, {super.key});
  final Team team;

  @override
  State<TeamDisplayPage> createState() => _TeamDisplayPageState();
}

class _TeamDisplayPageState extends State<TeamDisplayPage> {
  int selectedIndex = 0;

  void _changeSection(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold( //ΑΦΟΡΑ ΤΟ ΟΝΟΜΑ ΠΑΝΩ ΣΤΗΝ ΣΕΛΙΔΑ
        appBar: AppBar(
            backgroundColor: Color.fromARGB(250, 46, 90, 136),
            iconTheme: IconThemeData(color: Colors.white),
            title: Text(
            widget.team.name,
            style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
            fontStyle: FontStyle.italic,
              color: Colors.white
          ),
        ),
            actions: [
              isFavourite(team: widget.team,),
            ]
        ),
        body:Scaffold(
          backgroundColor: Colors.white,
          body: Column(
      children: [
        //Text(team.name,style: TextStyle(color: Color.fromARGB(100, 255, 10, 40),)),
        _NavigationButtons(onSectionChange: _changeSection),
        _sectionChooser(selectedIndex , widget.team,)
      ],
    )
      )
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
            SizedBox(width: 10),
            _buildTextButton("Λεπτομέρειες", 0),
            SizedBox(width: 15),
            _buildTextButton("Αγώνες", 1),
            SizedBox(width: 15),
            _buildTextButton("Παίχτες", 2),
            SizedBox(width: 15),
            _buildTextButton("Κορυφαίοι Παίχτες", 3),
            SizedBox(width: 10),
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
              color: isSelected ? Colors.blue : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              //backgroundColor: darkModeNotifier.value==true?Colors.black87: lightModeBackGround
            ),
          ),
          SizedBox(height: 3), // Απόσταση μεταξύ κειμένου και γραμμής
          if (isSelected)
            Container(
              width: 60, // Μήκος γραμμής
              height: 3, // Πάχος γραμμής
              color: Colors.blue, // Χρώμα γραμμής
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
      bool result = await teamsHandle.isFavouriteTeam(widget.team.name);
      setState(() {
        isFavourite = result;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        if (isLoggedIn) {
          if (isFavourite) {
            await teamsHandle.removeFavouriteTeam(widget.team.name);
          } else {
            await teamsHandle.addFavouriteTeam(widget.team.name);
          }

          setState(() {
            isFavourite = !isFavourite;
          });
        }
        else{
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: greek? Text('Πρέπει να συνδεθείς για να έχεις αγαπημένες ομάδες!') : Text('You have to log in to have favourite teams!'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
      icon: Icon(
        isFavourite ? Icons.favorite : Icons.favorite_border,
        color: isFavourite ? Colors.red : null,
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
      return TopPlayersPage(team.players);
    default:
      return TeamDetailsWidget(team: team);
  }
}


