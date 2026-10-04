import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class BettingResultUpdate {
  // Μαθηματικός τύπος υπολογισμού σκορ
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

    Set<String> updatedYears = {};
    Set<String> updatedMonths = {};
    bool needsAllTimeUpdate = false;

    for (final matchDoc in matchesSnapshot.docs) {
      final matchKey = matchDoc.id;
      final matchData = matchDoc.data();
      final bool isCancelled = matchData['cancelled'] == true;
      final String? correctChoice = isCancelled ? null : matchData['correctChoice'] as String?;

      // --- Υπολογισμός Ημερομηνίας Ματς ---
      DateTime date = (matchData['startTime'] as Timestamp).toDate();
      String yearKey = date.year.toString();
      String monthKey = "${date.year}_${date.month.toString().padLeft(2, '0')}";

      if (!isCancelled) {
        updatedYears.add(yearKey);
        updatedMonths.add(monthKey);
        needsAllTimeUpdate = true;
      }

      final userVotes = Map<String, dynamic>.from(matchData['userVotes'] ?? {});
      final entries = userVotes.entries.toList();
      final int chunkSize = 200; // Ασφαλές όριο για τα Batches του Firestore (Max 500)

      for (int i = 0; i < entries.length; i += chunkSize) {
        final chunk = entries.skip(i).take(chunkSize).toList();
        WriteBatch batch = FirebaseFirestore.instance.batch();

        final userFutures = chunk.map((entry) =>
            FirebaseFirestore.instance.collection('users').doc(entry.key).get()).toList();
        final userDocs = await Future.wait(userFutures);

        for (int j = 0; j < chunk.length; j++) {
          final entry = chunk[j];
          final userDoc = userDocs[j];
          final String uid = entry.key;
          final String choice = entry.value;

          final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
          final betRef = FirebaseFirestore.instance.collection('bets').doc('${uid}_$matchKey');

          if (isCancelled) {
            batch.set(betRef, {
              'status': 'cancelled',
              'matchInfo': {
                'GoalHome': matchData['GoalHome'],
                'GoalAway': matchData['GoalAway'],
              }
            }, SetOptions(merge: true));
            continue;
          }

          final userData = userDoc.exists ? (userDoc.data() ?? {}) : {};

          // --- 1. All Time Στατιστικά ---
          int correct = userData['predictions']?['correctVotes'] ?? 0;
          int total = userData['predictions']?['totalVotes'] ?? 0;

          // --- 2. Ετήσια Στατιστικά ---
          int yearCorrect = userData['yearlyStats']?[yearKey]?['correctVotes'] ?? 0;
          int yearTotal = userData['yearlyStats']?[yearKey]?['totalVotes'] ?? 0;

          // --- 3. Μηνιαία Στατιστικά ---
          int monthCorrect = userData['monthlyStats']?[monthKey]?['correctVotes'] ?? 0;
          int monthTotal = userData['monthlyStats']?[monthKey]?['totalVotes'] ?? 0;

          // --- Ενημέρωση ---
          if (choice == correctChoice) {
            correct++; yearCorrect++; monthCorrect++;
          }
          total++; yearTotal++; monthTotal++;

          // --- Αποθήκευση στο Batch ---
          batch.set(userRef, {
            'predictions': {
              'correctVotes': correct,
              'totalVotes': total,
              'accuracy': total > 0 ? (correct / total) * 100 : 0.0,
              'score': _calculateScore(correct, total),
            },
            'totalVotes': total,
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
          }, SetOptions(merge: true));

          // Ενημέρωση Στοιχήματος
          batch.set(betRef, {
            'status': choice == correctChoice ? 'won' : 'lost',
            'matchInfo': {
              'GoalHome': matchData['GoalHome'],
              'GoalAway': matchData['GoalAway'],
            }
          }, SetOptions(merge: true));
        }

        await batch.commit();
      }

      await FirebaseFirestore.instance.collection('votes').doc(matchKey).set({
        'statsUpdated': true,
        'TimeStamp': DateTime.now(),
      }, SetOptions(merge: true));

      print("✅ Stats updated for match $matchKey.");
    }

    // --- Ενημέρωση ΟΛΩΝ των Leaderboards (Με Local Sort για να αποφύγουμε Index Errors) ---
    if (needsAllTimeUpdate) {
      await _buildLeaderboardLocal('top20', null, null);
    }
    for (String year in updatedYears) {
      await _buildLeaderboardLocal('top20_$year', year, null);
    }
    for (String month in updatedMonths) {
      await _buildLeaderboardLocal('top20_$month', null, month);
    }
  }

  // Χτίζει τα Leaderboards ΤΟΠΙΚΑ για να μην κρασάρει το Firebase λόγω απουσίας Indexes!
  Future<void> _buildLeaderboardLocal(String docId, String? yearKey, String? monthKey) async {
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
    List<Map<String, dynamic>> allUsersList = [];

    for (var doc in usersSnapshot.docs) {
      final data = doc.data();
      Map<String, dynamic> stats = {};

      if (yearKey != null) {
        stats = data['yearlyStats']?[yearKey] ?? {};
      } else if (monthKey != null) {
        stats = data['monthlyStats']?[monthKey] ?? {};
      } else {
        stats = data['predictions'] ?? {};
      }

      int total = stats['totalVotes'] ?? 0;
      if (total == 0) continue; // Αν δεν έχει παίξει σε αυτό το διάστημα, τον αγνοούμε

      int correct = stats['correctVotes'] ?? 0;
      double score = (stats['score'] ?? 0.0).toDouble();
      double accuracy = total > 0 ? (correct / total) * 100 : 0.0;

      allUsersList.add({
        'uid': doc.id,
        'username': data['username'] ?? 'Unknown',
        'accuracy': accuracy,
        'correctVotes': correct,
        'totalVotes': total,
        'score': score,
      });
    }

    // Ταξινόμηση στη μνήμη (Αστραπιαίο)
    allUsersList.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    final top20 = allUsersList.take(20).toList();

    await FirebaseFirestore.instance.collection('leaderboard').doc(docId).set({
      'updatedAt': DateTime.now(),
      'users': top20,
    });

    print("🏆 Leaderboard [$docId] updated!");
  }
}





class EmergencyRescue {
  double _calculateScore(int correct, int total) {
    if (total == 0) return 0.0;
    final accuracy = correct / total;
    final cappedTotal = total.clamp(0, 50);
    final confidence = 1 - exp(-0.1 * cappedTotal);
    return accuracy * confidence * 100;
  }

  // Διασώζει ΚΑΙ All-Time, ΚΑΙ Ετήσια, ΚΑΙ Μηνιαία!
  Future<void> restoreAllPredictions() async {
    print("🚑 Ξεκινάει η ολική ανάκτηση δεδομένων...");
    final firestore = FirebaseFirestore.instance;

    final usersSnapshot = await firestore.collection('users').get();
    Map<String, Map<String, dynamic>> userMemoryStats = {};

    for (var doc in usersSnapshot.docs) {
      userMemoryStats[doc.id] = {
        'username': doc.data()['username'] ?? 'Unknown',
        'allTime': {'correct': 0, 'total': 0},
        'yearly': <String, Map<String, int>>{},
        'monthly': <String, Map<String, int>>{},
      };
    }

    final matchesSnapshot = await firestore.collection('votes').where('hasMatchFinished', isEqualTo: true).get();

    for (var matchDoc in matchesSnapshot.docs) {
      final data = matchDoc.data();
      final String? correctChoice = data['correctChoice'] as String?;
      if (correctChoice == null || correctChoice.isEmpty) continue;

      DateTime date = (data['startTime'] as Timestamp).toDate();
      String yearKey = date.year.toString();
      String monthKey = "${date.year}_${date.month.toString().padLeft(2, '0')}";

      final userVotes = Map<String, dynamic>.from(data['userVotes'] ?? {});

      for (final entry in userVotes.entries) {
        final uid = entry.key;
        final choice = entry.value.toString();
        if (!userMemoryStats.containsKey(uid)) continue;

        bool isCorrect = (choice == correctChoice);
        var stats = userMemoryStats[uid]!;

        // Update All-Time
        stats['allTime']['total'] += 1;
        if (isCorrect) stats['allTime']['correct'] += 1;

        // Update Yearly
        stats['yearly'].putIfAbsent(yearKey, () => {'correct': 0, 'total': 0});
        stats['yearly'][yearKey]!['total'] = stats['yearly'][yearKey]!['total']! + 1;
        if (isCorrect) stats['yearly'][yearKey]!['correct'] = stats['yearly'][yearKey]!['correct']! + 1;

        // Update Monthly
        stats['monthly'].putIfAbsent(monthKey, () => {'correct': 0, 'total': 0});
        stats['monthly'][monthKey]!['total'] = stats['monthly'][monthKey]!['total']! + 1;
        if (isCorrect) stats['monthly'][monthKey]!['correct'] = stats['monthly'][monthKey]!['correct']! + 1;
      }
    }

    List<WriteBatch> batches = [firestore.batch()];
    int operationCount = 0;

    void addToBatch(DocumentReference ref, Map<String, dynamic> data) {
      batches.last.set(ref, data, SetOptions(merge: true));
      operationCount++;
      if (operationCount >= 400) {
        batches.add(firestore.batch());
        operationCount = 0;
      }
    }

    for (final entry in userMemoryStats.entries) {
      final uid = entry.key;
      final stats = entry.value;

      int allCorrect = stats['allTime']['correct'];
      int allTotal = stats['allTime']['total'];

      Map<String, dynamic> payload = {
        'predictions': {
          'correctVotes': allCorrect,
          'totalVotes': allTotal,
          'accuracy': allTotal > 0 ? (allCorrect / allTotal) * 100 : 0.0,
          'score': _calculateScore(allCorrect, allTotal),
        },
        'totalVotes': allTotal,
        'yearlyStats': {},
        'monthlyStats': {},
      };

      // Χτίσιμο Yearly
      (stats['yearly'] as Map<String, Map<String, int>>).forEach((year, data) {
        payload['yearlyStats'][year] = {
          'correctVotes': data['correct'],
          'totalVotes': data['total'],
          'score': _calculateScore(data['correct']!, data['total']!),
        };
      });

      // Χτίσιμο Monthly
      (stats['monthly'] as Map<String, Map<String, int>>).forEach((month, data) {
        payload['monthlyStats'][month] = {
          'correctVotes': data['correct'],
          'totalVotes': data['total'],
          'score': _calculateScore(data['correct']!, data['total']!),
        };
      });

      addToBatch(firestore.collection('users').doc(uid), payload);
    }

    for (var batch in batches) {
      await batch.commit();
    }

    // Αναδημιουργούμε και όλα τα Leaderboards
    await BettingResultUpdate()._buildLeaderboardLocal('top20', null, null);
    print("✅ Η ΔΙΑΣΩΣΗ (Ολική) ΟΛΟΚΛΗΡΩΘΗΚΕ ΕΠΙΤΥΧΩΣ! 🚑");
  }
}