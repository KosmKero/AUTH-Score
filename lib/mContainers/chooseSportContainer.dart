import 'package:flutter/cupertino.dart';
import '../Data_Classes/MatchDetails.dart';
import '../Data_Classes/basketball/basketMatch.dart';
import '../API/Match_Handle.dart';
import '../API/BasketballMatchHandle.dart'; // <-- Σιγουρέψου ότι αυτό είναι το σωστό import σου
import '../globals.dart';
import 'BasketballContainer.dart';
import 'matchesContainer.dart';

class ChooseSportContainer extends StatelessWidget {
  final int type; // 1 = Upcoming, 2 = Previous

  // Βγάλαμε το required this.matches
  const ChooseSportContainer({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    // Ακούμε το ValueNotifier selectedSport
    return ValueListenableBuilder<String>(
      valueListenable: selectedSport,
      builder: (context, sport, _) {
        if (sport == "football") {
          // Τραβάμε τα Ποδοσφαιρικά ματς κατευθείαν από το API
          final List<MatchDetails> fbMatches = (type == 1)
              ? MatchHandle().getUpcomingMatches()
              : MatchHandle().getPreviousMatches();

          return matchesContainer(matches: fbMatches, type: type);
        } else {
          // Τραβάμε τα Μπασκετικά ματς κατευθείαν από το API
          final List<BasketMatch> bkMatches = (type == 1)
              ? BasketballMatchHandle().getUpcomingMatches()
              : BasketballMatchHandle().getPreviousMatches();

          return BasketballContainer(matches: bkMatches, type: type);
        }
      },
    );
  }
}