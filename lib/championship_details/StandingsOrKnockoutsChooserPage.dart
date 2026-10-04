import 'package:flutter/material.dart';
import 'package:untitled1/championship_details/football/football_sector_chooser.dart';
import '../globals.dart';
import 'basket/basketball_championship_details_page.dart';

class StandingsOrKnockoutsChooserPage extends StatelessWidget {
  const StandingsOrKnockoutsChooserPage({super.key});

  @override
  Widget build(BuildContext context) {
    //ακούει το Global ValueNotifier
    return ValueListenableBuilder<String>(
      valueListenable: selectedSport,
      builder: (context, sport, _) {
        if (sport == 'football') {
          // Δείχνει ΟΛΗ τη σελίδα του Ποδοσφαίρου
          return const FootballStandingsOrKnockoutsChooserPage();
        } else {
           return const BasketballStandingsOrKnockoutsChooserPage();
        }
      },
    );
  }
}