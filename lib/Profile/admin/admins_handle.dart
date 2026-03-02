import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminListWidget extends StatefulWidget {
  const AdminListWidget({Key? key}) : super(key: key);

  @override
  State<AdminListWidget> createState() => _AdminListWidgetState();
}

class _AdminListWidgetState extends State<AdminListWidget> {
  late Future<List<Map<String, dynamic>>> _adminUsersFuture;

  @override
  void initState() {
    super.initState();
    _adminUsersFuture = _fetchAdmins();
  }

  Future<List<Map<String, dynamic>>> _fetchAdmins() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .get();

    return querySnapshot.docs.map((doc) => {
      ...doc.data(),
      'uid': doc.id,
    }).toList();
  }

  // Ανανεώνει τη λίστα των admins
  void _refreshAdmins() {
    setState(() {
      _adminUsersFuture = _fetchAdmins();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _adminUsersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Σφάλμα: ${snapshot.error}'));
        }

        final admins = snapshot.data ?? [];

        if (admins.isEmpty) {
          return const Center(child: Text('Δεν υπάρχουν admins.'));
        }

        return Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: admins.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return AdminCard(
                admin: admins[index],
                refreshList: _refreshAdmins,
              );
            },
          ),
        );
      },
    );
  }
}

// ================= AdminCard Stateful Widget =================
class AdminCard extends StatefulWidget {
  final Map<String, dynamic> admin;
  final VoidCallback refreshList;

  const AdminCard({required this.admin, required this.refreshList, Key? key}) : super(key: key);

  @override
  State<AdminCard> createState() => _AdminCardState();
}

class _AdminCardState extends State<AdminCard> {
  late bool moderator;
  late List<String> teams;

  @override
  void initState() {
    super.initState();
    moderator = widget.admin['moderator'] ?? false;
    teams = List<String>.from(widget.admin['Controlled Teams'] ?? []);
  }

  void _toggleModerator(String uid) async {
    final newValue = !moderator;
    setState(() => moderator = newValue);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'moderator': newValue});
    } catch (e) {
      setState(() => moderator = !newValue); // Αν αποτύχει, επαναφορά
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Σφάλμα κατά την αλλαγή moderator')),
      );
    }
  }

  void _addTeam(String uid, String team) async {
    if (team.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'Controlled Teams': FieldValue.arrayUnion([team])});

      setState(() => teams.add(team));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Σφάλμα κατά την προσθήκη ομάδας')),
      );
    }
  }

  void _removeTeam(String uid, String team) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'Controlled Teams': FieldValue.arrayRemove([team])});

      setState(() => teams.remove(team));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Σφάλμα κατά τη διαγραφή ομάδας')),
      );
    }
  }

  void _showAddTeamDialog(BuildContext context, String uid) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Προσθήκη Ομάδας'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Όνομα Ομάδας'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Άκυρο')),
          ElevatedButton(
            onPressed: () {
              final teamName = controller.text.trim();
              if (teamName.isNotEmpty) _addTeam(uid, teamName);
              Navigator.pop(context);
            },
            child: const Text('Προσθήκη'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = widget.admin['uid'];
    final name = widget.admin['username'] ?? 'Χωρίς όνομα';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Header =====
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Toggle Moderator
                  IconButton(
                    icon: moderator
                        ? const Icon(Icons.verified_user)
                        : const Icon(Icons.verified_user_outlined),
                    tooltip: 'Moderator',
                    onPressed: () => _toggleModerator(uid),
                  ),
                  // Add Team
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Προσθήκη Ομάδας',
                    onPressed: () => _showAddTeamDialog(context, uid),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text("Ομάδες που ελέγχει:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            // Teams
            if (teams.isEmpty)
              const Text("Καμία", style: TextStyle(color: Colors.grey))
            else
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: teams.map((team) {
                  return Chip(
                    label: Text(team),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () => _removeTeam(uid, team),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}