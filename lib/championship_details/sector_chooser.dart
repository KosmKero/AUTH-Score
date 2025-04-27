import 'package:flutter/material.dart';
import 'package:untitled1/championship_details/StandingsPage.dart';
import 'package:untitled1/championship_details/knock_outs_page.dart';
import 'package:untitled1/championship_details/top_players_page.dart';

import '../globals.dart';



class StandingsOrKnockoutsChooserPage extends StatefulWidget {
  const StandingsOrKnockoutsChooserPage({super.key});

  @override
  State<StandingsOrKnockoutsChooserPage> createState() => _StandingsOrKnockoutsChooserPageState();
}

class _StandingsOrKnockoutsChooserPageState extends State<StandingsOrKnockoutsChooserPage> {
  int indexChoice=0;
  void _changeSection(int index) {
    setState(() {
      indexChoice = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    int seasonYear = now.month > 8 ? now.year : now.year - 1;

    return Column(
      children: [
        // Row για τα κουμπιά πλοήγησης
        _NavigationButtons(onSectionChange: _changeSection),

        // Εδώ επιλέγουμε ποιο περιεχόμενο να εμφανίσουμε ανάλογα με την επιλογή
        indexChoice == 0
              ? StandingsPage(seasonYear)
              : (indexChoice == 1)
              ? KnockOutsPage()
              : TopPlayersProvider(),
      ],
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
      return Container(
        color:darkModeNotifier.value?Color(0xFF121212): lightModeBackGround,
        height: 65,
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(width: 10),
              _buildTextButton(greek?"Βαθμολογία":"Standings", 0),
              SizedBox(width: 15),
              _buildTextButton(greek?"Νοκ Άουτς":"Knock outs", 1),
              SizedBox(width: 15),
              _buildTextButton(greek?"Κορυφαίοι Παίχτες":"Best players", 2),
            ],
          ),
        ),
      );
  }

  //ΔΗΜΙΟΥΡΓΕΙ ΤΑ 3 ΚΟΥΜΠΙΑ(ΛΕΠΤΟΜΕΡΕΙΕΣ ΑΓΩΝΕΣ ΚΑΙ ΠΑΙΧΤΕΣ)
  Widget _buildTextButton(String text, int index) {
    bool isSelected = selectedIndex == index;

    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth < 300 ? 15 : 17; // Μειώνει το μέγεθος της γραμματοσειράς για μικρότερες οθόνες


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
              fontSize: fontSize,
              color: isSelected ?darkModeNotifier.value?Colors.blue: Color.fromARGB(255, 0, 35, 150) :darkModeNotifier.value?Colors.white: Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontFamily: "Arial"
            ),
          ),
          SizedBox(height: 3), // Απόσταση μεταξύ κειμένου και γραμμής
          if (isSelected)
            Container(
              width: 70, // Μήκος γραμμής
              height: 3, // Πάχος γραμμής
              color:darkModeNotifier.value?Colors.blue: Color.fromARGB(255, 0, 35, 150), // Χρώμα γραμμής
            ),
        ],
      ),
    );
  }
}