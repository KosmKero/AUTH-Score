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

Future<void> updateAllUserStatistics() async {
  final firestore = FirebaseFirestore.instance;

  // 1. Προετοιμασία των μετρητών (Counters)
  Map<String, int> schoolCounts = { for (var item in allItems) item: 0 };
  schoolCounts['Άλλο'] = 0;

  Map<String, int> teamCounts = {};

  int darkCount = 0;
  int lightCount = 0;
  int totalUsers = 0;

  // 2. Η ΜΟΝΑΔΙΚΗ ανάγνωση από τη βάση! (Εδώ γλιτώνεις το 66% των Reads)
  final snapshot = await firestore.collection('users').get();

  // 3. Επεξεργασία δεδομένων
  for (var doc in snapshot.docs) {
    final data = doc.data();
    totalUsers++;

    // --- Στατιστικά Σχολών ---
    final university = data['University'];
    if (university != null) {
      if (schoolCounts.containsKey(university)) {
        schoolCounts[university] = schoolCounts[university]! + 1;
      } else {
        schoolCounts['Άλλο'] = schoolCounts['Άλλο']! + 1;
      }
    }

    // --- Στατιστικά Ομάδων ---
    final favTeams = data['Favourite Teams'];
    if (favTeams != null && favTeams is List && favTeams.isNotEmpty) {
      for (var team in favTeams) {
        if (team is String && team.trim().isNotEmpty) {
          teamCounts[team] = (teamCounts[team] ?? 0) + 1;
        }
      }
    }

    // --- Στατιστικά Dark Mode ---
    if (data.containsKey('darkMode')) {
      if (data['darkMode'] == true) {
        darkCount++;
      } else {
        lightCount++;
      }
    }
  }

  // 4. Καθάρισμα άδειων δεδομένων
  schoolCounts.removeWhere((key, value) => value == 0);
  teamCounts.removeWhere((key, value) => value == 0);

  // 5. Μαζική αποθήκευση στο Firestore (Batched Write για ασφάλεια & οικονομία)
  final batch = firestore.batch();

  batch.set(firestore.collection('userStats').doc('schoolStats'), {
    'totalUsers': totalUsers,
    'schools': schoolCounts,
  });

  batch.set(firestore.collection('userStats').doc('favoriteTeamsStat'), {
    'totalUsers': totalUsers, // Ίσως θες να βάλεις άλλον μετρητή αν μετράς μόνο αυτούς με 1+ ομάδα
    'teams': teamCounts,
  });

  batch.set(firestore.collection('userStats').doc('darkModeStats'), {
    'totalUsers': darkCount + lightCount,
    'darkMode': darkCount,
    'lightMode': lightCount,
  });

  // Εκτέλεση όλων των εγγραφών ταυτόχρονα
  await batch.commit();

  print("✅ Όλα τα στατιστικά ενημερώθηκαν επιτυχώς με 1 μόνο Read Batch!");
}
