import 'package:cloud_firestore/cloud_firestore.dart';

import '../globals.dart';

class TeamHandle {
  Future<void> addTeam(String name, String nameEnglish, String initials) async {
    final teamData = {
      "Coach": "",
      "Draws": 0,
      "Foundation Year": thisYearNow - 1,
      "Group": 3,
      "LastFive": [],
      "Loses": 0,
      "Matches": 0,
      "Name": name,
      "NameEnglish": nameEnglish,
      "Players": {}, // μπορείς να βάλεις map με στοιχεία παικτών
      "Titles": 0,
      "Wins": 0,
      "draws": 0,
      "goalsAgainst": 0,
      "goalsFor": 0,
      "initials": initials,
      "loses": 0,
      "matches": 0,
      "position": 0,
      "titles": 0,
      "wins": 0
    };

    try {
      await FirebaseFirestore.instance
          .collection('year')
          .doc(thisYearNow.toString())
          .collection('teams')
          .doc(name)
          .set(teamData);
      print('✅ Η ομάδα προστέθηκε επιτυχώς!');
    } catch (e) {
      print('❌ Σφάλμα κατά την προσθήκη: $e');
    }
  }
}
