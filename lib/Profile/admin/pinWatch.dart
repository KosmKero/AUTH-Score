import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled1/globals.dart' as global;

// Συνάρτηση παραγωγής τυχαίου PIN
String generateNewPin() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  Random rnd = Random();
  return String.fromCharCodes(Iterable.generate(
      5, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
}

class TeamPinsDashboard extends StatefulWidget {
  const TeamPinsDashboard({super.key});

  @override
  State<TeamPinsDashboard> createState() => _TeamPinsDashboardState();
}

class _TeamPinsDashboardState extends State<TeamPinsDashboard> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Συνάρτηση για Δημιουργία Νέου PIN
  Future<void> _resetPin(BuildContext context, String teamId) async {
    String newPin = generateNewPin();

    //  Αποθήκευση στο private/secrets
    await FirebaseFirestore.instance
        .collection('year')
        .doc(global.thisYearNow.toString())
        .collection('teams')
        .doc(teamId)
        .collection('private')
        .doc('secrets')
        .set({'secret_pin': newPin}, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Το PIN για την ομάδα $teamId ανανεώθηκε!'),
      backgroundColor: Colors.green,
    ));
  }

  // Συνάρτηση για Αντιγραφή στο Πρόχειρο (Copy)
  void _copyToClipboard(String pin, String teamName) {
    Clipboard.setData(ClipboardData(text: pin)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Το PIN ($pin) αντιγράφηκε επιτυχώς!'),
        backgroundColor: Colors.blueAccent,
        duration: const Duration(seconds: 2),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = global.darkModeNotifier.value ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = global.darkModeNotifier.value ? Colors.white : Colors.black87;
    final Color tileColor = global.darkModeNotifier.value ? const Color(0xFF2C2C2C) : Colors.grey[200]!;

    return Container(
      color: backgroundColor,
      child: Column(
        children: [
          // ---- ΜΠΑΡΑ ΑΝΑΖΗΤΗΣΗΣ ----
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Αναζήτηση Ομάδας',
                labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                prefixIcon: Icon(Icons.search, color: textColor.withOpacity(0.7)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: textColor.withOpacity(0.7)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
                    : null,
                filled: true,
                fillColor: tileColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ---- ΛΙΣΤΑ ΟΜΑΔΩΝ ----
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('year')
                  .doc(global.thisYearNow.toString())
                  .collection('teams')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Σφάλμα: ${snapshot.error}', style: TextStyle(color: textColor)));
                }

                final allTeams = snapshot.data?.docs ?? [];

                final filteredTeams = allTeams.where((teamDoc) {
                  return teamDoc.id.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredTeams.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty ? 'Δεν βρέθηκαν ομάδες.' : 'Δεν βρέθηκε ομάδα με αυτό το όνομα.',
                      style: TextStyle(color: textColor),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  itemCount: filteredTeams.length,
                  itemBuilder: (context, index) {
                    var team = filteredTeams[index];
                    var teamData = team.data() as Map<String, dynamic>;

                    // --- ΝΕΟ: Δεύτερο StreamBuilder για να διαβάζει live το PIN από το private subcollection ---
                    return StreamBuilder<DocumentSnapshot>(
                        stream: team.reference.collection('private').doc('secrets').snapshots(),
                        builder: (context, secretSnapshot) {

                          String? currentPin;

                          // Ψάχνουμε πρώτα στο νέο κρυφό έγγραφο
                          if (secretSnapshot.hasData && secretSnapshot.data!.exists) {
                            var secretData = secretSnapshot.data!.data() as Map<String, dynamic>?;
                            if (secretData != null && secretData.containsKey('secret_pin')) {
                              currentPin = secretData['secret_pin'];
                            }
                          }
                          // Fallback: Αν δεν υπάρχει στο κρυφό, κοιτάμε μήπως ξέμεινε στο κεντρικό έγγραφο
                          if (currentPin == null && teamData.containsKey('secret_pin')) {
                            currentPin = teamData['secret_pin'];
                          }

                          return Card(
                            color: tileColor,
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Icon(Icons.shield, color: Colors.white),
                              ),
                              title: Text(
                                team.id,
                                style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text(
                                currentPin != null ? 'PIN: $currentPin' : 'Χωρίς PIN',
                                style: TextStyle(
                                  color: currentPin != null ? Colors.green : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (currentPin != null)
                                    IconButton(
                                      icon: const Icon(Icons.copy, color: Colors.blue),
                                      tooltip: 'Αντιγραφή PIN',
                                      onPressed: () => _copyToClipboard(currentPin!, team.id),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.refresh, color: Colors.orange),
                                    tooltip: 'Δημιουργία νέου PIN',
                                    onPressed: () => _resetPin(context, team.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}