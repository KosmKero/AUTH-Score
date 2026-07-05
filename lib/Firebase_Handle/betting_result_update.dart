import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class BettingResultUpdate {
  // Βοηθητική συνάρτηση για να μην γράφουμε τον ίδιο τύπο 3 φορές
  double _calculateScore(int correct, int total) {
    if (total == 0) return 0.0;
    final accuracy = correct / total;
    final cappedTotal = total.clamp(0, 50);
    final confidence = 1 - exp(-0.1 * cappedTotal);
    return accuracy * confidence * 100;
  }

  Future<void> checkAndUpdateStats() async {
    final matchesSnapshot = await FirebaseFirestore.instance
        .collection('votes')
        .where('hasMatchFinished', isEqualTo: true)
        .where('statsUpdated', isEqualTo: false)
        .get();

    // Κρατάμε τα έτη και τους μήνες που άλλαξαν, για να ανανεώσουμε μόνο αυτά τα leaderboards στο τέλος
    Set<String> updatedYears = {};
    Set<String> updatedMonths = {};
    bool needsAllTimeUpdate = false;

    for (final matchDoc in matchesSnapshot.docs) {
      final matchKey = matchDoc.id;
      final matchData = matchDoc.data();
      final bool isCancelled = matchData['cancelled'] == true;

      final String? correctChoice =
          isCancelled ? null : matchData['correctChoice'] as String?;

      // --- Υπολογισμός Ημερομηνίας Ματς ---
      DateTime date = (matchData['startTime'] as Timestamp).toDate();

      String yearKey = date.year.toString();
      String monthKey = "${date.year}_${date.month.toString().padLeft(2, '0')}";

      if (!isCancelled) {
        updatedYears.add(yearKey);
        updatedMonths.add(monthKey);
        needsAllTimeUpdate = true;
      }
      // -------------------------------------

      final userVotes = Map<String, dynamic>.from(matchData['userVotes'] ?? {});
      final entries = userVotes.entries.toList();
      final int chunkSize = 200;

      for (int i = 0; i < entries.length; i += chunkSize) {
        final chunk = entries.skip(i).take(chunkSize).toList();
        WriteBatch batch = FirebaseFirestore.instance.batch();

        final userFutures = chunk
            .map((entry) => FirebaseFirestore.instance
                .collection('users')
                .doc(entry.key)
                .get())
            .toList();
        final userDocs = await Future.wait(userFutures);

        for (int j = 0; j < chunk.length; j++) {
          final entry = chunk[j];
          final userDoc = userDocs[j];

          final String uid = entry.key;
          final String choice = entry.value;

          final userRef =
              FirebaseFirestore.instance.collection('users').doc(uid);
          final betRef = FirebaseFirestore.instance
              .collection('bets')
              .doc('${uid}_$matchKey');

          if (isCancelled) {
            batch.set(
                betRef,
                {
                  'status': 'cancelled',
                  'matchInfo': {
                    'GoalHome': matchData['GoalHome'],
                    'GoalAway': matchData['GoalAway'],
                  }
                },
                SetOptions(merge: true));
            continue;
          }

          final userData = userDoc.exists ? (userDoc.data() ?? {}) : {};

          // --- 1. All Time Στατιστικά (Για να δουλεύουν τα παλιά app) ---
          int correct = 0, total = 0;
          if (userData['predictions'] != null) {
            correct = userData['predictions']['correctVotes'] ?? 0;
            total = userData['predictions']['totalVotes'] ?? 0;
          }

          // --- 2. Ετήσια Στατιστικά ---
          int yearCorrect = 0, yearTotal = 0;
          if (userData['yearlyStats'] != null &&
              userData['yearlyStats'][yearKey] != null) {
            yearCorrect = userData['yearlyStats'][yearKey]['correctVotes'] ?? 0;
            yearTotal = userData['yearlyStats'][yearKey]['totalVotes'] ?? 0;
          }

          // --- 3. Μηνιαία Στατιστικά ---
          int monthCorrect = 0, monthTotal = 0;
          if (userData['monthlyStats'] != null &&
              userData['monthlyStats'][monthKey] != null) {
            monthCorrect =
                userData['monthlyStats'][monthKey]['correctVotes'] ?? 0;
            monthTotal = userData['monthlyStats'][monthKey]['totalVotes'] ?? 0;
          }

          // --- Ενημέρωση (Increment) ---
          if (choice == correctChoice) {
            correct++;
            yearCorrect++;
            monthCorrect++;
          }
          total++;
          yearTotal++;
          monthTotal++;

          // --- Αποθήκευση στο Batch με Merge ---
          batch.set(
              userRef,
              {
                // ΠΑΛΙΟ ΣΥΣΤΗΜΑ (Διατηρείται για παλιούς χρήστες)
                'predictions': {
                  'correctVotes': correct,
                  'totalVotes': total,
                  'accuracy': total > 0 ? (correct / total) * 100 : 0.0,
                  'score': _calculateScore(correct, total),
                },
                'totalVotes': total,

                // ΝΕΟ ΣΥΣΤΗΜΑ (Χρονιές & Μήνες)
                'yearlyStats': {
                  yearKey: {
                    'correctVotes': yearCorrect,
                    'totalVotes': yearTotal,
                    'score': _calculateScore(yearCorrect, yearTotal),
                  }
                },
                'monthlyStats': {
                  monthKey: {
                    'correctVotes': monthCorrect,
                    'totalVotes': monthTotal,
                    'score': _calculateScore(monthCorrect, monthTotal),
                  }
                }
              },
              SetOptions(merge: true));

          // Ενημέρωση Στοιχήματος
          batch.set(
              betRef,
              {
                'status': choice == correctChoice ? 'won' : 'lost',
                'matchInfo': {
                  'GoalHome': matchData['GoalHome'],
                  'GoalAway': matchData['GoalAway'],
                }
              },
              SetOptions(merge: true));
        }

        await batch.commit();
      }

      await FirebaseFirestore.instance.collection('votes').doc(matchKey).set({
        'statsUpdated': true,
        'TimeStamp': DateTime.now(),
      }, SetOptions(merge: true));

      print("✅ Stats and bets updated for match $matchKey.");
    }

    // --- Ενημέρωση ΟΛΩΝ των Leaderboards που επηρεάστηκαν ---
    if (needsAllTimeUpdate) {
      await updateLeaderboard(); // Το κλασικό All-Time
    }

    for (String year in updatedYears) {
      await _updateDynamicLeaderboard('yearlyStats.$year.score', 'top20_$year');
    }

    for (String month in updatedMonths) {
      await _updateDynamicLeaderboard(
          'monthlyStats.$month.score', 'top20_$month');
    }
  }

  // Το κλασικό Leaderboard (Για το παλιό UI)
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

    await FirebaseFirestore.instance
        .collection('leaderboard')
        .doc('top20')
        .set({
      'updatedAt': DateTime.now(),
      'users': topUsers,
    });
  }

  // ΝΕΑ ΣΥΝΑΡΤΗΣΗ: Δυναμική ενημέρωση για Μήνες και Έτη
  Future<void> _updateDynamicLeaderboard(
      String orderByField, String targetDoc) async {
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy(orderByField, descending: true)
        .limit(20)
        .get();

    final topUsers = usersSnapshot.docs.map((doc) {
      final data = doc.data();

      // Βρίσκουμε τον σωστό "φάκελο" με βάση το πεδίο που ταξινομήσαμε
      Map<String, dynamic> statsFolder = {};
      if (orderByField.startsWith('yearlyStats')) {
        String year = orderByField.split('.')[1];
        statsFolder = data['yearlyStats']?[year] ?? {};
      } else if (orderByField.startsWith('monthlyStats')) {
        String month = orderByField.split('.')[1];
        statsFolder = data['monthlyStats']?[month] ?? {};
      }

      return {
        'uid': doc.id,
        'username': data['username'] ?? 'Unknown',
        'correctVotes': statsFolder['correctVotes'] ?? 0,
        'totalVotes': statsFolder['totalVotes'] ?? 0,
        'score': statsFolder['score'] ?? 0,
      };
    }).toList();

    await FirebaseFirestore.instance
        .collection('leaderboard')
        .doc(targetDoc)
        .set({
      'updatedAt': DateTime.now(),
      'users': topUsers,
    });
  }
}



class EmergencyRescue {

  // Ο μαθηματικός σου τύπος παραμένει ίδιος
  double _calculateScore(int correct, int total) {
    if (total == 0) return 0.0;
    final accuracy = correct / total;
    final cappedTotal = total.clamp(0, 50);
    final confidence = 1 - exp(-0.1 * cappedTotal);
    return accuracy * confidence * 100;
  }

  Future<void> restoreAllTimePredictions() async {
    print("🚑 Ξεκινάει η ανάκτηση των All-Time σκορ...");
    final firestore = FirebaseFirestore.instance;

    // 1. Φέρνουμε όλους τους χρήστες (για να ξέρουμε ποιοι υπάρχουν)
    final usersSnapshot = await firestore.collection('users').get();
    Map<String, Map<String, dynamic>> userMemoryStats = {};

    for (var doc in usersSnapshot.docs) {
      userMemoryStats[doc.id] = {
        'username': doc.data()['username'] ?? 'Unknown',
        'correct': 0,
        'total': 0,
      };
    }

    // 2. Φέρνουμε ΟΛΑ τα ματς από το 'votes' που έχουν ολοκληρωθεί
    final matchesSnapshot = await firestore
        .collection('votes')
        .where('hasMatchFinished', isEqualTo: true)
        .get();

    // 3. Διαβάζουμε ποιος ψήφισε τι και ανακατασκευάζουμε τα σκορ
    for (var matchDoc in matchesSnapshot.docs) {
      final data = matchDoc.data();

      final String? correctChoice = data['correctChoice'] as String?;
      // Αν δεν έχει μπει το τελικό αποτέλεσμα σε κάποιο ματς, το αγνοούμε
      if (correctChoice == null || correctChoice.isEmpty) continue;

      final userVotes = Map<String, dynamic>.from(data['userVotes'] ?? {});

      // Σαρώνουμε το map με τις ψήφους
      for (final entry in userVotes.entries) {
        final uid = entry.key;
        final choice = entry.value.toString();

        if (!userMemoryStats.containsKey(uid)) continue;

        // Δίνουμε +1 στο σύνολο
        userMemoryStats[uid]!['total'] += 1;

        // Αν βρήκε το σωστό, του δίνουμε +1 στα σωστά
        if (choice == correctChoice) {
          userMemoryStats[uid]!['correct'] += 1;
        }
      }
    }

    // 4. Ετοιμάζουμε τα Batches για την αποθήκευση
    List<Map<String, dynamic>> allTimeLeaderboard = [];
    List<WriteBatch> batches = [firestore.batch()];
    int operationCount = 0;

    void addToBatch(DocumentReference ref, Map<String, dynamic> data) {
      batches.last.set(ref, data, SetOptions(merge: true));
      operationCount++;
      if (operationCount >= 450) {
        batches.add(firestore.batch());
        operationCount = 0;
      }
    }

    // 5. Φτιάχνουμε τα τελικά δεδομένα και το Leaderboard
    for (final entry in userMemoryStats.entries) {
      final uid = entry.key;
      final stats = entry.value;

      final String username = stats['username'];
      final int correct = stats['correct'];
      final int total = stats['total'];

      final double accuracy = total > 0 ? (correct / total) * 100 : 0.0;
      final double score = _calculateScore(correct, total);

      // --- Η ΚΡΙΣΙΜΗ ΕΓΓΡΑΦΗ: Επαναφέρει αποκλειστικά το predictions ---
      addToBatch(firestore.collection('users').doc(uid), {
        'predictions': {
          'correctVotes': correct,
          'totalVotes': total,
          'accuracy': accuracy,
          'score': score,
        },
        'totalVotes': total // (Αν το χρησιμοποιείς στο root του εγγράφου)
      });

      // Προσθήκη για το Leaderboard
      allTimeLeaderboard.add({
        'uid': uid,
        'username': username,
        'correctVotes': correct,
        'totalVotes': total,
        'accuracy': accuracy,
        'score': score
      });
    }

    // 6. Αποθήκευση του Top 20 All-Time Leaderboard
    allTimeLeaderboard.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    final top20 = allTimeLeaderboard.take(20).toList();

    addToBatch(firestore.collection('leaderboard').doc('top20'), {
      'updatedAt': DateTime.now(),
      'users': top20
    });

    // 7. Εκτέλεση των Batches
    for (var batch in batches) {
      await batch.commit();
    }

    print("✅ Η διάσωση ολοκληρώθηκε! Τα All-Time σκορ των χρηστών είναι πάλι 100% σωστά!");
  }
}
