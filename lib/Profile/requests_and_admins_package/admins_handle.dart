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

  Future<void> _addTeam(String uid, String team) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({
      'Controlled Teams': FieldValue.arrayUnion([team])
    });

    setState(() {
      _adminUsersFuture = _fetchAdmins();
    });
  }

  Future<void> _removeTeam(String uid, String team) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({
      'Controlled Teams': FieldValue.arrayRemove([team])
    });

    setState(() {
      _adminUsersFuture = _fetchAdmins();
    });
  }

  void _showAddTeamDialog(BuildContext context, String uid) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Προσθήκη Ομάδας'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Όνομα Ομάδας',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Άκυρο'),
          ),
          ElevatedButton(
            onPressed: () {
              final teamName = controller.text.trim();
              if (teamName.isNotEmpty) {
                _addTeam(uid, teamName);
              }
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

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: admins.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final admin = admins[index];
            final uid = admin['uid'];
            final name = admin['username'] ?? 'Χωρίς όνομα';
            final teams = List<String>.from(admin['Controlled Teams'] ?? []);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.admin_panel_settings),
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: IconButton(
                        icon: const Icon(Icons.add),
                        tooltip: 'Προσθήκη Ομάδας',
                        onPressed: () => _showAddTeamDialog(context, uid),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text("Ομάδες που ελέγχει:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
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
                            onDeleted: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Επιβεβαίωση'),
                                  content: Text('Θέλεις σίγουρα να αφαιρέσεις την ομάδα "$team";'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Ακύρωση'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(ctx); // Κλείσιμο διαλόγου
                                        _removeTeam(uid, team); // Διαγραφή
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      child: const Text('Αφαίρεση'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
