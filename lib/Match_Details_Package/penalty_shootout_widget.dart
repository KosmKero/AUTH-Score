import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/Data_Classes/MatchDetails.dart';

import '../Data_Classes/Penaltys.dart';
import '../Data_Classes/Team.dart';
import '../globals.dart';

class PenaltyShootoutManager extends ChangeNotifier {
  final String matchDocId;
  PenaltyShootout _shootout = PenaltyShootout([]);
  late final StreamSubscription _subscription;

  PenaltyShootoutManager({required this.matchDocId}) {
    _startListeningForUpdates();
  }

  PenaltyShootout get shootout => _shootout;

  void _startListeningForUpdates() {
    _subscription = FirebaseFirestore.instance
        .collection('matches')
        .doc(matchDocId)
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.data();
      final penalties = (data?['penalties'] as List<dynamic>?)
          ?.map((p) => Penalty.fromMap(Map<String, dynamic>.from(p)))
          .toList() ?? [];

      _shootout = PenaltyShootout(penalties);
      notifyListeners();
    });
  }

    @override
  void dispose() {
    _subscription.cancel(); // Cancel the Firestore listener
    super.dispose();
  }
}





class PenaltyShootoutPanel extends StatelessWidget {
  final Team homeTeam;
  final Team awayTeam;
  const PenaltyShootoutPanel({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
  });

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<PenaltyShootoutManager>();
    final shootout = manager.shootout;

    return Container(

      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Text(
              "Διαδικασία Πέναλτι",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: darkModeNotifier.value?Colors.white:Colors.black ),  // Μικρότερο μέγεθος γραμματων
            ),
            const SizedBox(height: 16),

            // Γηπεδούχος ομάδα
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    homeTeam.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,color: darkModeNotifier.value?Colors.white:Colors.black),  // Μικρότερο μέγεθος
                  ),
                ),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: shootout.penalties
                        .where((p) => p.isHomeTeam)
                        .map((p) => _PenaltyDot(isScored: p.isScored))
                        .toList(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Φιλοξενούμενη ομάδα
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    awayTeam.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,color: darkModeNotifier.value?Colors.white:Colors.black),  // Μικρότερο μέγεθος
                  ),
                ),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: shootout.penalties
                        .where((p) => !p.isHomeTeam)
                        .map((p) => _PenaltyDot(isScored: p.isScored))
                        .toList(),
                  ),
                ),
              ],
            ),
           // SizedBox(height: 10,),
           // Divider()
          ],
        ),
      ),
    );
  }
}

class _PenaltyDot extends StatelessWidget {
  final bool isScored;

  const _PenaltyDot({required this.isScored});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,  // Μικρότερο μέγεθος κουκκίδων
      height: 15, // Μικρότερο μέγεθος κουκκίδων
      decoration: BoxDecoration(
        color: isScored ? Colors.green : Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}
