import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/globals.dart';

import '../../Firebase_Handle/update_statistics.dart';

class SchoolStatsPage extends StatefulWidget {
  const SchoolStatsPage({super.key});

  @override
  State<SchoolStatsPage> createState() => _SchoolStatsPageState();
}

class _SchoolStatsPageState extends State<SchoolStatsPage> {
  Map<String, int> schoolCounts = {};
  Map<String, int> teamCounts = {};
  Map<String, int> darkModeCounts = {};
  int totalUsers = 0;
  bool loading = true;
  bool showSchools = true;
  bool showTeams = false;
  bool showDarkMode = false;

  Future<void> fetchData() async {
    setState(() {
      loading = true;
    });

    final docId = showSchools
        ? 'schoolStats'
        : showTeams
        ? 'favoriteTeamsStat'
        : 'darkModeStats';

    final doc =
    await FirebaseFirestore.instance.collection('userStats').doc(docId).get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        totalUsers = data['totalUsers'] ?? 0;
        if (showSchools) {
          schoolCounts = Map<String, int>.from(data['schools'] ?? {});
        } else if (showTeams) {
          teamCounts = Map<String, int>.from(data['teams'] ?? {});
        } else {
          darkModeCounts = {
            'Dark Mode': data['darkMode'] ?? 0,
            'Light Mode': data['lightMode'] ?? 0,
          };
        }
        loading = false;
      });
    } else {
      setState(() { loading = false; });
    }
  }

  Future<void> updateAndFetchData() async {
    setState(() {
      loading = true;
    });

    await updateAllUserStatistics();

    // Αφού τα ενημέρωσε όλα, ξαναδιαβάζει μόνο το document του τρέχοντος Tab (1 read)
    await fetchData();
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final currentData = showSchools
        ? schoolCounts
        : showTeams
        ? teamCounts
        : darkModeCounts;

    final title = showSchools
        ? "Σχολές"
        : showTeams
        ? "Αγαπημένες Ομάδες"
        : "Θέμα Εφαρμογής";

    return loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
      children: [
        Text(
          "Σύνολο χρηστών: $totalUsers",
          style: TextStyle(
              color: darkModeNotifier.value ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          "Στατιστικά για: $title",
          style: TextStyle(
              color: darkModeNotifier.value ? Colors.white : Colors.black,
              fontSize: 16),
        ),
        const SizedBox(height: 10),
        ToggleButtons(
          isSelected: [showSchools, showTeams, showDarkMode],
          onPressed: (index) async {
            setState(() {
              showSchools = index == 0;
              showTeams = index == 1;
              showDarkMode = index == 2;
              loading = true;
            });
            await fetchData();
          },
          borderRadius: BorderRadius.circular(12),
          selectedColor: Theme.of(context).colorScheme.onPrimary,
          color: darkModeNotifier.value ? Colors.grey : Colors.grey,
          fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
          borderColor: Theme.of(context).colorScheme.primary,
          selectedBorderColor: Theme.of(context).colorScheme.primary,
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text("Σχολές"),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text("Ομάδες"),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text("Θέμα"),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox( // Το Container έγινε SizedBox (βέλτιστη πρακτική στο Flutter)
          height: 450,
          width: double.infinity,
          child: ListView(
            children: (currentData.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
                .map((entry) {
              final percentage = totalUsers == 0
                  ? 0
                  : (entry.value / totalUsers * 100).toStringAsFixed(1);
              return ListTile(
                title: Text(
                  entry.key,
                  style: TextStyle(
                      color: darkModeNotifier.value
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w500),
                ),
                trailing: Text(
                  "$percentage%",
                  style: TextStyle(
                      color: darkModeNotifier.value
                          ? Colors.white
                          : Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${entry.value} χρήστες",
                  style: TextStyle(
                      color: darkModeNotifier.value
                          ? Colors.grey[400]
                          : Colors.grey[700]),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: updateAndFetchData,
          icon: const Icon(Icons.refresh),
          label: const Text("Ανανέωση Στατιστικών"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        )
      ],
    );
  }
}