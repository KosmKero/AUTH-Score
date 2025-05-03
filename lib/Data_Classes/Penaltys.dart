import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Penalty {
  final bool isScored;
  final bool isHomeTeam;

  Penalty({required this.isScored, required this.isHomeTeam});

  Map<String, dynamic> toMap() => {
    'isScored': isScored,
    'isHomeTeam': isHomeTeam,
    'timestamp': DateTime.now().toIso8601String(),
  };

  factory Penalty.fromMap(Map<String, dynamic> map) => Penalty(
    isScored: map['isScored'] ?? false,
    isHomeTeam: map['isHomeTeam'] ?? true,
  );

}

class PenaltyShootout extends ChangeNotifier{
  PenaltyShootout(this.penalties);

  List<Penalty> penalties;

  Future<void> addPenalty(Penalty penalty, String matchDocId) async {
    penalties.add(penalty);
    await savePenalty(matchDocId, penalty);
    notifyListeners();
  }


  Future<void> savePenalty(String matchDocId, Penalty penalty) async {
    final matchDoc = FirebaseFirestore.instance.collection('matches').doc(matchDocId);

    await matchDoc.update({
      'penalties': FieldValue.arrayUnion([penalty.toMap()])
    });
  }

  static Future<PenaltyShootout> loadFromFirestore(String matchDocId) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('matches')
        .doc(matchDocId)
        .get();

    final data = docSnapshot.data();
    if (data == null) return PenaltyShootout([]);

    final List<dynamic> rawPenalties = data['penalties'] ?? [];

    final penalties = rawPenalties.map((p) {
      return Penalty.fromMap(Map<String, dynamic>.from(p));
    }).toList();

    return PenaltyShootout(penalties);
  }

  Future<void> removeLastPenalty(String matchDocId) async {
    final docRef = FirebaseFirestore.instance.collection('matches').doc(matchDocId);
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
      return Penalty.fromMap(Map<String, dynamic>.from(p));
    }).toList();

    notifyListeners();
  }


  int get homeScore =>
      penalties.where((p) => p.isScored && p.isHomeTeam).length;


  int get awayScore =>
      penalties.where((p) => p.isScored && !p.isHomeTeam).length;
}
