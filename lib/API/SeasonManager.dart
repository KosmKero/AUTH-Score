import 'package:cloud_firestore/cloud_firestore.dart';

class SeasonManager {
  static Future<void> createNewSeason(int currentYear) async {
    final firestore = FirebaseFirestore.instance;
    final int newYear = currentYear + 1;

    print("🔄 Ξεκινάει η δημιουργία της σεζόν $newYear...");

    try {
      // 1. Τραβάμε τις ομάδες από την τρέχουσα σεζόν
      final teamsSnapshot = await firestore
          .collection('year')
          .doc(currentYear.toString())
          .collection('teams')
          .get();

      if (teamsSnapshot.docs.isEmpty) {
        throw Exception("Δεν βρέθηκαν ομάδες για το $currentYear.");
      }

      final WriteBatch batch = firestore.batch();

      // 2. Επεξεργασία της κάθε ομάδας
      for (var teamDoc in teamsSnapshot.docs) {
        Map<String, dynamic> oldData = teamDoc.data();

        // --- ΝΕΑ ΛΟΓΙΚΗ: Διαβάζουμε το PIN από το private subcollection ---
        String? secretPin;
        final oldSecretSnap = await teamDoc.reference.collection('private').doc('secrets').get();

        secretPin = oldSecretSnap.data()!['secret_pin'];


        // 3. Επεξεργασία Παικτών (Map): Διατήρηση στοιχείων, μηδενισμός στατιστικών
        Map<String, dynamic> oldPlayers = oldData['Players'] ?? {};
        Map<String, dynamic> newPlayers = {};

        oldPlayers.forEach((playerId, playerData) {
          if (playerData is Map) {
            Map<String, dynamic> newPlayerData = Map<String, dynamic>.from(playerData);

            // Μηδενισμός ατομικών στατιστικών
            newPlayerData['Appearances'] = 0;
            newPlayerData['Goals'] = 0;
            newPlayerData['numOfRedCards'] = 0;
            newPlayerData['numOfYellowCards'] = 0;

            newPlayers[playerId] = newPlayerData;
          }
        });

        // 4. Χτίσιμο της Νέας Ομάδας (ΧΩΡΙΣ το secret_pin)
        Map<String, dynamic> newData = {
          // --- ΣΤΟΙΧΕΙΑ ΠΟΥ ΔΙΑΤΗΡΟΥΝΤΑΙ ---
          'Name': oldData['Name'],
          'NameEnglish': oldData['NameEnglish'] ?? "",
          'initials': oldData['initials'] ?? "",
          'Coach': oldData['Coach'] ?? "",
          'Foundation Year': oldData['Foundation Year'],
          'Group': oldData['Group'],
          'captains': oldData['captains'] ?? [],
          'Titles': oldData['Titles'] ?? 0,
          'titles': oldData['titles'] ?? 0,
          'Players': newPlayers, // Το νέο καθαρό ρόστερ

          // --- ΣΤΑΤΙΣΤΙΚΑ ΠΟΥ ΜΗΔΕΝΙΖΟΝΤΑΙ ---
          'Matches': 0, 'matches': 0,
          'Wins': 0, 'wins': 0,
          'Draws': 0, 'draws': 0,
          'Loses': 0, 'loses': 0,
          'goalsFor': 0,
          'goalsAgainst': 0,
          'LastFive': [], 'lastFive': [],
          'position': 1, // Επαναφορά στην 1η θέση προσωρινά
        };

        // 5. Αποθήκευση της κεντρικής ομάδας (στο year/2027/teams/...)
        final newTeamRef = firestore
            .collection('year')
            .doc(newYear.toString())
            .collection('teams')
            .doc(teamDoc.id);

        batch.set(newTeamRef, newData);

        // 6. --- ΝΕΑ ΛΟΓΙΚΗ: Αποθήκευση του PIN στο κλειδωμένο subcollection ---
        if (secretPin != null) {
          final newSecretRef = newTeamRef.collection('private').doc('secrets');
          batch.set(newSecretRef, {'secret_pin': secretPin});
        }
      }

      // 7. Εκτέλεση του Batch
      await batch.commit();
      print("✅ Η σεζόν $newYear δημιουργήθηκε επιτυχώς!");

    } catch (e) {
      print("❌ Σφάλμα κατά τη δημιουργία νέας σεζόν: $e");
      rethrow;
    }
  }
}