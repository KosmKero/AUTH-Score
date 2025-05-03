import 'package:cloud_firestore/cloud_firestore.dart';

import '../Data_Classes/MatchDetails.dart';

class MatchHandle {
  static final MatchHandle _instance = MatchHandle._internal();
  static List<List<MatchDetails>> matchesList = [];

  // Ιδιωτικός constructor
  MatchHandle._internal();

  // Μέθοδος για επιστροφή του ίδιου instance
  factory MatchHandle() {
    return _instance;
  }

  void initializeMatces(List<List<MatchDetails>> matchList){
    matchesList=matchList;
  }
  Future<void> matchFinished(MatchDetails match) async {
    matchesList[0].remove(match);
    matchesList[1].add(match);

    await FirebaseFirestore.instance
        .collection('matches')
        .doc(match.matchDocId)
        .set({'hasMatchFinished': true, 'Type': 'previous'},
        SetOptions(merge: true)); // ώστε να μη διαγράψει άλλα πεδία

  }
  Future<void> matchNotFinished(MatchDetails match) async {
    matchesList[1].remove(match);
    matchesList[0].add(match);

    await FirebaseFirestore.instance
        .collection('matches')
        .doc(match.matchDocId)
        .set({'hasMatchFinished': true, 'Type': "upcoming"},
        SetOptions(merge: true)); // ώστε να μη διαγράψει άλλα πεδία

  }

  // Μέθοδοι για πρόσβαση στα δεδομένα
  List<MatchDetails> getUpcomingMatches() => matchesList[0];
  List<MatchDetails> getPreviousMatches() => matchesList[1];
  List<MatchDetails> getAllMatches() => matchesList.expand((i) => i).toList();
}
