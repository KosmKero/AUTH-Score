import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Data_Classes/Team.dart';
import '../../Firebase_Handle/TeamsHandle.dart';
import '../../globals.dart';

class GroupManagementScreen extends StatefulWidget {
  const GroupManagementScreen({super.key});

  @override
  State<GroupManagementScreen> createState() => _GroupManagementScreenState();
}

class _GroupManagementScreenState extends State<GroupManagementScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  // Λίστα με τις ομάδες (Κρατάμε το ID, το όνομα και τον τρέχοντα όμιλο)
  List<Map<String, dynamic>> _teams = [];

  // Οι διαθέσιμοι όμιλοι (Μπορείς να το προσαρμόσεις ανάλογα με το τουρνουά σου)
  final List<int> _availableGroups = [1, 2, 3, 4];

  @override
  void initState() {
    super.initState();
    _fetchTeams();
  }

  Future<void> _fetchTeams() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('year')
          .doc(thisYearNow.toString())
          .collection('teams')
          .orderBy('Name') // Αλφαβητική ταξινόμηση για ευκολία
          .get();

      setState(() {
        _teams = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc.data()['Name'] ?? 'Άγνωστη Ομάδα',
            // Default στον όμιλο 1 αν για κάποιο λόγο λείπει
            'group': doc.data()['Group'] ?? 1,
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Σφάλμα φόρτωσης ομάδων: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveGroups() async {
    setState(() => _isSaving = true);
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    final teamsHandle = TeamsHandle();

    try {
      for (var team in _teams) {
        // 1. Ενημέρωση στο Firestore
        final docRef = firestore
            .collection('year')
            .doc(thisYearNow.toString())
            .collection('teams')
            .doc(team['id']);

        batch.update(docRef, {'Group': team['group']});

        Team? localTeam = teamsHandle.getTeam(team['name']);
        if (localTeam != null) {
          localTeam.setGroup(team['group']);
        }
      }

      await batch.commit(); // Στέλνει όλες τις αλλαγές στο Firebase ταυτόχρονα

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Οι όμιλοι ενημερώθηκαν επιτυχώς!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Σφάλμα: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    bool darkModeOn = darkModeNotifier.value;

    return Scaffold(
      backgroundColor: darkModeOn ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        title: const Text("Διαχείριση Ομίλων"),
        backgroundColor: darkModeOn ? const Color(0xFF1E1E1E) : Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _teams.isEmpty
          ? const Center(child: Text("Δεν βρέθηκαν ομάδες."))
          : ListView.builder(
        padding: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: 100, // Έξτρα χώρος στο κάτω μέρος για να μην κρύβεται από το FAB
        ),
        itemCount: _teams.length,
        itemBuilder: (context, index) {
          final team = _teams[index];
          return Card(
            color: darkModeOn ? Colors.grey[850] : Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                team['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: darkModeOn ? Colors.white : Colors.black87,
                ),
              ),
              trailing: DropdownButton<int>(
                value: team['group'],
                dropdownColor: darkModeOn ? Colors.grey[800] : Colors.white,
                style: TextStyle(
                  color: darkModeOn ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                underline: Container(
                  height: 2,
                  color: Colors.blue,
                ),
                items: _availableGroups.map((int groupNum) {
                  return DropdownMenuItem<int>(
                    value: groupNum,
                    child: Text("Όμιλος $groupNum"),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      team['group'] = newValue;
                    });
                  }
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: _teams.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: _isSaving ? null : _saveGroups,
        backgroundColor: Colors.green,
        icon: _isSaving
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
            : const Icon(Icons.save, color: Colors.white),
        label: Text(
          _isSaving ? "Αποθήκευση..." : "Αποθήκευση",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      )
          : null,
    );
  }
}