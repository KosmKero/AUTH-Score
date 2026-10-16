import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../globals.dart' as global;

class AdminListWidget extends StatefulWidget {
  const AdminListWidget({Key? key}) : super(key: key);

  @override
  State<AdminListWidget> createState() => _AdminListWidgetState();
}

class _AdminListWidgetState extends State<AdminListWidget> {
  late Future<List<Map<String, dynamic>>> _adminUsersFuture;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String _myUid = '';
  List<String> _myControlledTeams = [];

  @override
  void initState() {
    super.initState();
    _adminUsersFuture = _fetchAdmins();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchAdmins() async {
    _myUid = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot myDoc =
    await FirebaseFirestore.instance.collection('users').doc(_myUid).get();
    Map<String, dynamic>? myData = myDoc.data() as Map<String, dynamic>?;

    _myControlledTeams = List<String>.from(myData?['Controlled Teams'] ?? []);

    Query query;

    if (global.globalUser.isSuperUser) {
      query = FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'admin');
    } else if (global.globalUser.isUpperAdmin) {
      query = FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'admin');
    } else {
      if (_myControlledTeams.isNotEmpty) {
        query = FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'admin')
            .where('Controlled Teams', arrayContainsAny: _myControlledTeams);
      } else {
        return [];
      }
    }

    final querySnapshot = await query.get();
    List<Map<String, dynamic>> admins = querySnapshot.docs
        .map((doc) => {
      ...doc.data() as Map<String, dynamic>,
      'uid': doc.id,
    })
        .toList();

    if (!global.globalUser.isSuperUser) {
      admins.removeWhere((admin) => admin['superuser'] == "super123userRR");
    }

    if (!global.globalUser.isSuperUser && !global.globalUser.isUpperAdmin) {
      admins.removeWhere((admin) => admin['moderator'] == true);
    }

    // ΒΕΛΤΙΩΣΗ 2: Αλφαβητική Ταξινόμηση βάσει ονόματος
    admins.sort((a, b) {
      final nameA = (a['captainname'] ?? a['username'] ?? '').toString().toLowerCase();
      final nameB = (b['captainname'] ?? b['username'] ?? '').toString().toLowerCase();
      return nameA.compareTo(nameB);
    });

    return admins;
  }

  Future<void> _refreshAdmins() async {
    setState(() {
      _adminUsersFuture = _fetchAdmins();
    });
    await _adminUsersFuture; // Περιμένουμε να ολοκληρωθεί για το RefreshIndicator
  }

  @override
  Widget build(BuildContext context) {
    final isDark = global.darkModeNotifier.value;
    final textColor = isDark ? Colors.white : Colors.black87;
    final tileColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) =>
                setState(() => _searchQuery = value.toLowerCase()),
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'Αναζήτηση (Όνομα, Email, Ομάδα)...',
              hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
              prefixIcon: Icon(Icons.search, color: textColor.withOpacity(0.5)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                  icon: Icon(Icons.cancel, color: textColor.withOpacity(0.5)),
                  onPressed: () {
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                    setState(() => _searchQuery = '');
                  })
                  : null,
              filled: true,
              fillColor: tileColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _adminUsersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError)
                return Center(
                    child: Text('Σφάλμα: ${snapshot.error}',
                        style: TextStyle(color: textColor)));

              final admins = snapshot.data ?? [];
              final filteredAdmins = admins.where((admin) {
                final query = _searchQuery.trim();
                if (query.isEmpty) return true;
                final name = (admin['captainname'] ?? admin['username'] ?? '').toString().toLowerCase();
                final email = (admin['email'] ?? '').toString().toLowerCase();
                final teamsList = List<String>.from(admin['Controlled Teams'] ?? []).join(' ').toLowerCase();
                return name.contains(query) || email.contains(query) || teamsList.contains(query);
              }).toList();

              if (filteredAdmins.isEmpty) {
                return Center(
                    child: Text('Δεν βρέθηκε αποτέλεσμα.', style: TextStyle(color: textColor)));
              }

              // ΒΕΛΤΙΩΣΗ 3: Pull-to-Refresh για χειροκίνητη ανανέωση
              return RefreshIndicator(
                onRefresh: _refreshAdmins,
                child: ListView.builder(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  itemCount: filteredAdmins.length,
                  itemBuilder: (context, index) {
                    return AdminCard(
                      admin: filteredAdmins[index],
                      searchQuery: _searchQuery,
                      refreshList: () => _refreshAdmins(),
                      myUid: _myUid,
                      isMeSuperUser: global.globalUser.isSuperUser,
                      isMeSecretariat: global.globalUser.isUpperAdmin,
                      myControlledTeams: _myControlledTeams,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ================= AdminCard Stateful Widget =================
class AdminCard extends StatefulWidget {
  final Map<String, dynamic> admin;
  final VoidCallback refreshList;
  final String searchQuery;

  final String myUid;
  final bool isMeSuperUser;
  final bool isMeSecretariat;
  final List<String> myControlledTeams;

  const AdminCard(
      {required this.admin,
        required this.refreshList,
        required this.myUid,
        required this.isMeSuperUser,
        required this.isMeSecretariat,
        required this.myControlledTeams,
        this.searchQuery = '',
        Key? key})
      : super(key: key);

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

  bool get _canManageSecretariat => widget.isMeSuperUser || widget.isMeSecretariat;
  bool get _canAssignNewTeam => widget.isMeSuperUser || widget.isMeSecretariat;

  bool _canRemoveTeam(String team) {
    if (widget.isMeSuperUser || widget.isMeSecretariat) return true;
    if (widget.admin['uid'] == widget.myUid) return true;
    if (widget.myControlledTeams.contains(team)) return true;
    return false;
  }

  void _toggleModerator(String uid) async {
    final newValue = !moderator;
    setState(() => moderator = newValue);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({'moderator': newValue});
    } catch (e) {
      setState(() => moderator = !newValue);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Σφάλμα: $e'), backgroundColor: Colors.red));
    }
  }

  // ΒΕΛΤΙΩΣΗ 1: Popup Επιβεβαίωσης πριν τη διαγραφή της ομάδας
  void _confirmRemoveTeam(String uid, String team) {
    final bool isLastTeam = teams.length == 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Αφαίρεση Ομάδας'),
        content: Text(isLastTeam
            ? 'Αυτή είναι η τελευταία ομάδα. Αν την αφαιρέσετε, ο χρήστης θα χάσει τα δικαιώματα Admin. Είστε σίγουροι;'
            : 'Θέλετε σίγουρα να αφαιρέσετε την ομάδα "$team";'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ΑΚΥΡΟ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
              _removeTeam(uid, team);
            },
            child: const Text('ΑΦΑΙΡΕΣΗ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _removeTeam(String uid, String team) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'Controlled Teams': FieldValue.arrayRemove([team]),
      });

      setState(() {
        teams.remove(team);
      });

      if (teams.isEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'role': 'user',
          'moderator': false,
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Ο χρήστης δεν έχει πια ομάδες και διαγράφηκε από Admin.'),
            backgroundColor: Colors.redAccent));

        widget.refreshList();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Σφάλμα: $e'), backgroundColor: Colors.red));
    }
  }

  void _addTeam(String uid, String team) async {
    if (team.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'Controlled Teams': FieldValue.arrayUnion([team]),
        'role': 'admin'
      });
      setState(() => teams.add(team));
    } catch (e) {
      // ΒΕΛΤΙΩΣΗ 4: Εμφάνιση σφάλματος αν αποτύχει η προσθήκη
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Σφάλμα προσθήκης: $e'), backgroundColor: Colors.red));
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
            textCapitalization: TextCapitalization.words, // Βοηθάει να ξεκινάει με κεφαλαίο
            decoration: const InputDecoration(hintText: 'Όνομα Ομάδας')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Άκυρο')),
          ElevatedButton(
            onPressed: () {
              final newTeam = controller.text.trim(); // Καθαρίζουμε τα κενά
              if (newTeam.isNotEmpty) {
                if (teams.contains(newTeam)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ο χρήστης διαχειρίζεται ήδη αυτή την ομάδα.')));
                } else {
                  _addTeam(uid, newTeam);
                }
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
    final isDark = global.darkModeNotifier.value;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    final uid = widget.admin['uid'];
    final name = widget.admin['captainname'] ?? widget.admin['username'] ?? 'Άγνωστος';
    final email = widget.admin['email'] ?? 'Χωρίς Email';
    final bool isMyOwnCard = uid == widget.myUid;

    List<String> displayTeams = List.from(teams);
    if (widget.searchQuery.isNotEmpty) {
      displayTeams = displayTeams
          .where((team) =>
          team.toLowerCase().contains(widget.searchQuery.toLowerCase()))
          .toList();
    }

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isMyOwnCard
            ? const BorderSide(color: Colors.blueAccent, width: 2)
            : BorderSide.none,
      ),
      elevation: isDark ? 0 : 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: moderator
                    ? Colors.purple
                    : (isMyOwnCard ? Colors.green : Colors.blue),
                child: Icon(moderator ? Icons.verified_user : Icons.person,
                    color: Colors.white),
              ),
              title: Text(isMyOwnCard ? "$name (Εσύ)" : name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 16)),
              subtitle: Text(email,
                  style: TextStyle(
                      color: textColor.withOpacity(0.7), fontSize: 13)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_canManageSecretariat && !isMyOwnCard)
                    IconButton(
                      icon: moderator
                          ? const Icon(Icons.star, color: Colors.amber)
                          : Icon(Icons.star_border,
                          color: textColor.withOpacity(0.5)),
                      tooltip: 'Γραμματεία',
                      onPressed: () => _toggleModerator(uid),
                    ),
                  if (_canAssignNewTeam)
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      tooltip: 'Ανάθεση νέας Ομάδας',
                      onPressed: () => _showAddTeamDialog(context, uid),
                    ),
                ],
              ),
            ),
            const Divider(),
            Text("Ομάδες:",
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textColor.withOpacity(0.8))),
            const SizedBox(height: 6),
            if (teams.isEmpty)
              const Text("Καμία ενεργή ομάδα",
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                      fontStyle: FontStyle.italic))
            else if (displayTeams.isEmpty && widget.searchQuery.isNotEmpty)
              Text("Δεν ταιριάζουν στην αναζήτηση",
                  style: TextStyle(
                      color: textColor.withOpacity(0.5),
                      fontSize: 13,
                      fontStyle: FontStyle.italic))
            else
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: displayTeams.map((team) {
                  bool canIRemoveThem = _canRemoveTeam(team);

                  return Chip(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    labelStyle: TextStyle(
                        color: isDark ? Colors.lightBlueAccent : Colors.blue[800]!,
                        fontWeight: FontWeight.bold),
                    label: Text(team),
                    deleteIcon: canIRemoveThem
                        ? Icon(Icons.cancel,
                        size: 18, color: Colors.red.withOpacity(0.8))
                        : null,
                    // Κλήση της επιβεβαίωσης αντί για κατευθείαν διαγραφή
                    onDeleted: canIRemoveThem ? () => _confirmRemoveTeam(uid, team) : null,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}