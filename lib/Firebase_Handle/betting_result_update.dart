import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BettingResultUpdate {


  Future<void> checkAndUpdateStats() async {
    // Λήψη όλων των αγώνων που έχουν περάσει και δεν έχουν ελεγχθεί ακόμα
    final currentDate = DateTime.now();
    final matchesSnapshot = await FirebaseFirestore.instance
        .collection('votes')
        .where('hasMatchFinished', isEqualTo: true)
        .where('statsUpdated', isEqualTo: false)  // Ματς που δεν έχουν ενημερωθεί
        .get();

    for (final matchDoc in matchesSnapshot.docs) {
      final matchKey = matchDoc.id;  // Το matchKey είναι το ID του εγγράφου
      final matchData = matchDoc.data();
      final correctChoice = matchData['correctChoice'];
      final userVotes = Map<String, dynamic>.from(matchData['userVotes']);

      // Ενημέρωση των στατιστικών των χρηστών
      for (final entry in userVotes.entries) {
        final String uid = entry.key;
        final String choice = entry.value;

        // Λήψη των δεδομένων του χρήστη
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
        final userDoc = await userDocRef.get();

        int correct = 0;
        int total = 0;

        if (userDoc.exists && userDoc.data()?['predictions'] != null) {
          final predData = userDoc.data()!['predictions'];
          correct = predData['correctVotes'] ?? 0;
          total = predData['totalVotes'] ?? 0;
        }

        // Ενημέρωση των στατιστικών
        if (choice == correctChoice) {
          correct++;
        }
        total++;

        final accuracy = total > 0 ? (correct / total) * 100 : 0;

        // Αποθήκευση των ενημερωμένων δεδομένων του χρήστη
        await userDocRef.set({
          'predictions': {
            'correctVotes': correct,
            'totalVotes': total,
            'accuracy': accuracy,
          },
          'totalVotes': total
        }, SetOptions(merge: true));
      }

      // Ενημέρωση του match ότι τα στατιστικά έχουν ανανεωθεί
      await FirebaseFirestore.instance
          .collection('votes')
          .doc(matchKey)
          .set({
        'statsUpdated': true, // Προσθήκη του πεδίου που δηλώνει ότι τα στατιστικά έχουν ανανεωθεί
        'TimeStamp': DateTime.now()
      }, SetOptions(merge: true));

      print("Stats updated for match $matchKey.");
    }
  }

}
