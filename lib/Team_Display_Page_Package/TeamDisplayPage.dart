import 'package:flutter/material.dart';
import 'package:untitled1/Team_Display_Page_Package/Team_Details_Widget.dart';
import 'package:untitled1/Team_Display_Page_Package/Team_Matches_Widget.dart';
import 'package:untitled1/Team_Display_Page_Package/Team_Players_Display_Widget.dart';
import 'package:untitled1/main.dart';

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
            title: Text(
            widget.team.name,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            fontStyle: FontStyle.italic,
          ),
        ),
            actions: [isFavourite(team: widget.team,)]
        ),
        body:Column(
      children: [
        //Text(team.name,style: TextStyle(color: Color.fromARGB(100, 255, 10, 40),)),
        _NavigationButtons(onSectionChange: _changeSection),
        _sectionChooser(selectedIndex , widget.team,)

      ],

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTextButton("Λεπτομέρειες", 0),
          _buildTextButton("Αγώνες", 1),
          _buildTextButton("Παίχτες", 2),
        ],
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
class isFavourite extends StatefulWidget{
    final Team team;
   const isFavourite({super.key, required this.team});
  @override
  State<isFavourite> createState() => _isFavouriteState();
}

class _isFavouriteState extends State<isFavourite> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        setState(() {
          widget.team.changeFavourite(); // Toggle the favorite state
        });
        widget.team.isFavourite ? favouriteTeams.add(widget.team) : favouriteTeams.remove(widget.team);
      },
      icon: Icon(
        widget.team.isFavourite ?  Icons.favorite:  Icons.favorite_border, // Change icon based on state
        color: widget.team.isFavourite ? Colors.red : null , // Change color based on state
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
    default:
      return TeamDetailsWidget(team: team);
  }
}