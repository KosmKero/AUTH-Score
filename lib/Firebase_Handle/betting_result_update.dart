import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class BettingResultUpdate {

  Future<void> checkAndUpdateStats() async {
    final matchesSnapshot = await FirebaseFirestore.instance
        .collection('votes')
        .where('hasMatchFinished', isEqualTo: true)
        .where('statsUpdated', isEqualTo: false)
        .get();

    for (final matchDoc in matchesSnapshot.docs) {
      final matchKey = matchDoc.id;
      final matchData = matchDoc.data();
      final correctChoice = matchData['correctChoice'];
      final userVotes = Map<String, dynamic>.from(matchData['userVotes'] ?? {});

      // Batch για users
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (final entry in userVotes.entries) {
        final String uid = entry.key;
        final String choice = entry.value;

        final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

        // Παίρνουμε προηγούμενα στατιστικά
        final userDoc = await userRef.get();
        int correct = 0, total = 0;
        if (userDoc.exists && userDoc.data()?['predictions'] != null) {
          final pred = userDoc.data()!['predictions'];
          correct = pred['correctVotes'] ?? 0;
          total = pred['totalVotes'] ?? 0;
        }

        // Ενημέρωση στατιστικών
        if (choice == correctChoice) correct++;
        total++;

        final accuracy = total > 0 ? (correct / total) * 100 : 0.0;
        final normalizedAccuracy = accuracy / 100;
        final cappedTotal = total.clamp(0, 50);
        final confidence = 1 - exp(-0.1 * cappedTotal);
        final score = normalizedAccuracy * confidence * 100;

        // Batch update στο user
        batch.set(userRef, {
          'predictions': {
            'correctVotes': correct,
            'totalVotes': total,
            'accuracy': accuracy,
            'score': score,
          },
          'totalVotes': total,
        }, SetOptions(merge: true));

        // Δημιουργία / ενημέρωση bet
        final betRef = FirebaseFirestore.instance
            .collection('bets')
            .doc('${uid}_$matchKey');

        batch.set(betRef, {
          'status': choice == correctChoice ? 'won' : 'lost',
          'matchInfo': {
            'GoalHome': matchData['GoalHome'],
            'GoalAway': matchData['GoalAway'],
          }
        }, SetOptions(merge: true));


      }

      // Commit batch
      await batch.commit();

      // Ενημέρωση match ότι έχει ενημερωθεί
      await FirebaseFirestore.instance.collection('votes').doc(matchKey).set({
        'statsUpdated': true,
        'TimeStamp': DateTime.now(),
      }, SetOptions(merge: true));

      print("Stats and bets updated for match $matchKey.");
    }

    // Ενημέρωση leaderboard
    await updateLeaderboard();
  }

  Future<void> updateLeaderboard() async {
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('predictions.score', descending: true)
        .limit(20)
        .get();

    final topUsers = usersSnapshot.docs.map((doc) {
      final data = doc.data();
      final pred = data['predictions'] ?? {};
      return {
        'uid': doc.id,
        'username': data['username'] ?? 'Unknown',
        'accuracy': pred['accuracy'] ?? 0,
        'correctVotes': pred['correctVotes'] ?? 0,
        'totalVotes': pred['totalVotes'] ?? 0,
        'score': pred['score'] ?? 0,
      };
    }).toList();

    await FirebaseFirestore.instance.collection('leaderboard').doc('top20').set({
      'updatedAt': DateTime.now(),
      'users': topUsers,
    });
  }
}
