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
    return Column(
      children: [
        _NavigationButtons(onSectionChange: _changeSection),
        (indexChoice==0)? StandingsPage() : (indexChoice==1)? KnockOutsPage():TopPlayersProvider()
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
      color: Color.fromARGB(70, 60, 80, 150),
      height: 65,
      width: double.infinity,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTextButton(greek?"Βαθμολογία":"Standings", 0),
            SizedBox(width: 15),
            _buildTextButton(greek?"Νοκ Άουτς":"Knock outs", 1),
            SizedBox(width: 15),
            _buildTextButton(greek?"Κορυφαίοι Παίχτες":"Best players", 2),
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
              color: isSelected ? Colors.blue : Colors.black87,
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
