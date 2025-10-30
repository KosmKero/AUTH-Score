import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../globals.dart';

class PenaltyShoot {
  final bool isScored;
  final bool isHomeTeam;

  PenaltyShoot({required this.isScored, required this.isHomeTeam});

  Map<String, dynamic> toMap() => {
    'isScored': isScored,
    'isHomeTeam': isHomeTeam,
    'timestamp': DateTime.now().toIso8601String(),
  };

  factory PenaltyShoot.fromMap(Map<String, dynamic> map) => PenaltyShoot(
    isScored: map['isScored'] ?? false,
    isHomeTeam: map['isHomeTeam'] ?? true,
  );

}

class PenaltyShootout extends ChangeNotifier{
  PenaltyShootout(this.penalties);

  List<PenaltyShoot> penalties;

  Future<void> addPenalty(PenaltyShoot penalty, String matchDocId) async {
    penalties.add(penalty);
    await savePenalty(matchDocId, penalty);
    notifyListeners();
  }


  Future<void> savePenalty(String matchDocId, PenaltyShoot penalty) async {
    final matchDoc = FirebaseFirestore.instance.collection('year').doc(thisYearNow.toString()).collection("matches").doc(matchDocId);

    await matchDoc.update({
      'penalties': FieldValue.arrayUnion([penalty.toMap()])
    });
  }

  static Future<PenaltyShootout> loadFromFirestore(String matchDocId, int year, int month) async {
    int yuse =year;
    if (month>9 ){
      yuse = year+1;
    }

    final docSnapshot = await FirebaseFirestore.instance
        .collection('year').doc(yuse.toString()).collection("matches")
        .doc(matchDocId)
        .get();

    final data = docSnapshot.data();
    if (data == null) return PenaltyShootout([]);

    final List<dynamic> rawPenalties = data['penalties'] ?? [];

    final penalties = rawPenalties.map((p) {
      return PenaltyShoot.fromMap(Map<String, dynamic>.from(p));
    }).toList();

    return PenaltyShootout(penalties);
  }

  Future<void> removeLastPenalty(String matchDocId) async {
    final docRef = FirebaseFirestore.instance.collection('year').doc(thisYearNow.toString()).collection("matches").doc(matchDocId);
    final snapshot = await docRef.get();

    final data = snapshot.data();
    if (data == null || data['penalties'] is! List) return;

    final List<dynamic> rawPenalties = List.from(data['penalties']);
    if (rawPenalties.isEmpty) return;

    rawPenalties.removeLast();

    // 🔁 Ενημέρωση στο Firestore
    await docRef.update({'penalties': rawPenalties});

    // 🔁 Ενημέρωση και της τοπικής λίστας
    penalties = rawPenalties.map((p) {
      return PenaltyShoot.fromMap(Map<String, dynamic>.from(p));
    }).toList();

    notifyListeners();
  }


  int get homeScore {
    if (penalties.isEmpty) return 0;
    return penalties.fold<int>(0, (sum, p) => sum + ((p.isScored && p.isHomeTeam) ? 1 : 0));
  }

  int get awayScore {
    if (penalties.isEmpty) return 0;
    return penalties.fold<int>(0, (sum, p) => sum + ((p.isScored && !p.isHomeTeam) ? 1 : 0));
  }

}
