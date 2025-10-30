import 'package:cloud_firestore/cloud_firestore.dart';

List<String> allItems = [
  'Αγγλικής Γλώσσας και Φιλολογίας',
  'Αγροτικής Ανάπτυξης',
  'Αρχιτεκτόνων Μηχανικών',
  'Βιολογίας',
  'Γαλλικής Γλώσσας και Φιλολογίας',
  'Γεωλογίας',
  'Γεωπονίας',
  'Δημοσιογραφίας και ΜΜΕ',
  'Δημόσιας Διοίκησης',
  'Διοίκησης Επιχειρήσεων',
  'Εικαστικών και Εφαρμοσμένων Τεχνών',
  'Επιστήμης Φυσικής Αγωγής και Αθλητισμού',
  'Ηλεκτρολόγων Μηχανικών και Μηχανικών Υπολογιστών',
  'Ιατρικής',
  'Ιστορίας και Αρχαιολογίας',
  'Ιταλικής Γλώσσας και Φιλολογίας',
  'Κτηνιατρικής',
  'Μαθηματικού',
  'Μηχανικών Χωροταξίας και Ανάπτυξης',
  'Μηχανολόγων Μηχανικών',
  'Μουσικών Σπουδών',
  'Νομικής',
  'Νοσηλευτικής',
  'Ξένων Γλωσσών, Μετάφρασης και Διερμηνείας',
  'Οικονομικών Επιστημών',
  'Παιδαγωγικό Δημοτικής Εκπαίδευσης',
  'Παιδαγωγικό Ειδικής Αγωγής',
  'Παιδαγωγικό Νηπιαγωγών',
  'Πολιτικών Επιστημών',
  'Πολιτικών Μηχανικών',
  'Πολιτισμού και Δημιουργικών Μέσων',
  'Πληροφορικής',
  'Προγραμμάτων Σπουδών Πολιτισμού',
  'Προγραμμάτων Σπουδών Τουρισμού',
  'Στατιστικής και Αναλογιστικών-Χρηματοοικονομικών Μαθηματικών',
  'Σπουδών Νοτιοανατολικής Ευρώπης',
  'Σπουδών Σλαβικών Γλωσσών και Φιλολογιών',
  'Σχολή Θεολογίας',
  'Σχολή Καλών Τεχνών',
  'Τεχνολογίας Τροφίμων',
  'Φαρμακευτικής',
  'Φιλολογίας',
  'Φιλοσοφίας και Παιδαγωγικής',
  'Φυσικής',
  'Χημείας',
  'Ψυχολογίας'

];

Future<void> updateSchoolStatistics() async {
  final firestore = FirebaseFirestore.instance;

  // Αρχικοποίηση map με 0 για κάθε σχολή
  Map<String, int> counts = { for (var item in allItems) item: 0 };
  counts['Άλλο'] = 0; // Προσθήκη της κατηγορίας "Άλλο"
  int totalUsers = 0;

  // Λήψη όλων των χρηστών από τη συλλογή users
  final snapshot = await firestore.collection('users').get();

  for (var doc in snapshot.docs) {
    final university = doc['University'];

    if (university != null) {
      if (counts.containsKey(university)) {
        counts[university] = counts[university]! + 1;
      } else {
        counts['Άλλο'] = counts['Άλλο']! + 1;
      }

    }
    totalUsers++;
  }

  // Αφαίρεση σχολών με 0 αν δεν τις θέλεις στο τελικό document
  counts.removeWhere((key, value) => value == 0);

  // Αποθήκευση στο Firestore
  await firestore.collection('userStats').doc('schoolStats').set({
    'totalUsers': totalUsers,
    'schools': counts,
  });
}

Future<void> updateFavoriteTeamsStatistics() async {
  final firestore = FirebaseFirestore.instance;

  Map<String, int> teamCounts = {};
  int totalUsers = 0;

  final snapshot = await firestore.collection('users').get();

  for (var doc in snapshot.docs) {
    final data = doc.data();
    final favTeams = data['Favourite Teams'];

    if (favTeams != null && favTeams is List && favTeams.isNotEmpty) {
      for (var team in favTeams) {
        if (team is String && team.trim().isNotEmpty) {
          teamCounts[team] = (teamCounts[team] ?? 0) + 1;
        }
      }
      totalUsers++; // Αν θεωρείς ότι μετράμε χρήστες που έχουν έστω 1 ομάδα
    }
  }

  // Αφαίρεση ομάδων με 0 εμφανίσεις αν χρειάζεται (σπάνιο εδώ)
  teamCounts.removeWhere((key, value) => value == 0);

  await firestore.collection('userStats').doc('favoriteTeamsStat').set({
    'totalUsers': totalUsers,
    'teams': teamCounts,
  });
}

Future<void> updateDarkModeStatistics() async {
  final usersCollection = FirebaseFirestore.instance.collection('users');
  final snapshot = await usersCollection.get();

  int darkCount = 0;
  int lightCount = 0;

  for (var doc in snapshot.docs) {
    final data = doc.data();
    if (data.containsKey('darkMode')) {
      final isDark = data['darkMode'] == true;
      if (isDark) {
        darkCount++;
      } else {
        lightCount++;
      }
    }
  }

  final totalUsers = darkCount + lightCount;

  await FirebaseFirestore.instance.collection('userStats').doc('darkModeStats').set({
    'totalUsers': totalUsers,
    'darkMode': darkCount,
    'lightMode': lightCount,
  });
}

