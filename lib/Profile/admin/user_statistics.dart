import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../Firebase_Handle/update_statistics.dart';

class SchoolStatsPage extends StatefulWidget {
  const SchoolStatsPage({super.key});

  @override
  State<SchoolStatsPage> createState() => _SchoolStatsPageState();
}

class _SchoolStatsPageState extends State<SchoolStatsPage> {
  Map<String, int> schoolCounts = {};
  int totalUsers = 0;
  bool loading = true;

  Future<void> fetchData() async {
    setState(() {
      loading = true;
    });
    final doc = await FirebaseFirestore.instance
        .collection('schoolStats')
        .doc('summary')
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        totalUsers = data['totalUsers'];
        schoolCounts = Map<String, int>.from(data['schools']);
        loading = false;
      });
    }
  }

  Future<void> updateAndFetchData() async {


    setState(() {
      loading = true;
    });

    await updateStatistics();

    final doc = await FirebaseFirestore.instance
        .collection('schoolStats')
        .doc('summary')
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        totalUsers = data['totalUsers'];
        schoolCounts = Map<String, int>.from(data['schools']);
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Text(
                "Σύνολο χρηστών: $totalUsers",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 20),
              // ✅ Τώρα είναι σωστά
              Container(
                height: 550,
                width: double.infinity,
                child: ListView(
                  children: (schoolCounts.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value)))
                      .map((entry) {
                    final percentage = totalUsers == 0
                        ? 0
                        : (entry.value / totalUsers * 100).toStringAsFixed(1);
                    return ListTile(
                      title: Text(
                        entry.key,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Text(
                        "$percentage%",
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      subtitle: Text(
                        "${entry.value} χρήστες",
                        style: const TextStyle(color: Colors.white),
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
