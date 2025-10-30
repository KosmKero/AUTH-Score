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
        totalUsers = data['totalUsers'];
        if (showSchools) {
          schoolCounts = Map<String, int>.from(data['schools']);
        } else if (showTeams) {
          teamCounts = Map<String, int>.from(data['teams']);
        } else {
          darkModeCounts = {
            'Dark Mode': data['darkMode'],
            'Light Mode': data['lightMode'],
          };
        }
        loading = false;
      });
    }
  }

  Future<void> updateAndFetchData() async {
    setState(() {
      loading = true;
    });

    if (showSchools) {
      await updateSchoolStatistics();
    } else if (showTeams) {
      await updateFavoriteTeamsStatistics();
    } else {
      await updateDarkModeStatistics(); // needs to be implemented in Firebase_Handle
    }

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
              fontSize: 18),
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
        Container(
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
                          : Colors.black),
                ),
                trailing: Text(
                  "$percentage%",
                  style: TextStyle(
                      color: darkModeNotifier.value
                          ? Colors.white
                          : Colors.black,
                      fontSize: 15),
                ),
                subtitle: Text(
                  "${entry.value} χρήστες",
                  style: TextStyle(
                      color: darkModeNotifier.value
                          ? Colors.white
                          : Colors.black),
                ),
              );
            }).toList(),
          ),
        ),
        ElevatedButton(
          onPressed: updateAndFetchData,
          child: const Text("Ανανέωση Στατιστικών"),
        )
      ],
    );
  }
}
