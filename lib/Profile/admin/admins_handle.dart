import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Απαραίτητο για το myUid

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

  // ΝΕΟ: Εδώ αποθηκεύουμε ποιος είμαστε εμείς (για να τα περάσουμε στις κάρτες)
  String _myUid = '';
  List<String> _myMainTeams = [];

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
    // 1. Βρίσκουμε ποιοι είμαστε
    _myUid = FirebaseAuth.instance.currentUser!.uid;

    // Διαβάζουμε τα ΔΙΚΑ ΜΑΣ δικαιώματα από τη βάση
    DocumentSnapshot myDoc = await FirebaseFirestore.instance.collection('users').doc(_myUid).get();
    Map<String, dynamic>? myData = myDoc.data() as Map<String, dynamic>?;

    _myMainTeams = List<String>.from(myData?['Main Teams'] ?? []);
    List<String> myControlledTeams = List<String>.from(myData?['Controlled Teams'] ?? []);

    // 2. Χτίζουμε το Query για τους άλλους
    Query query = FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'admin');

    if (!global.globalUser.isSuperUser && ! global.globalUser.isUpperAdmin) {
      // Αν είμαι απλός/βασικός αρχηγός, φέρε ΜΟΝΟ όσους έχουν κοινές ομάδες με εμένα
      if (myControlledTeams.isNotEmpty) {
        query = query.where('Controlled Teams', arrayContainsAny: myControlledTeams);
      } else {
        return []; // Δεν έχω καμία ομάδα, άρα δεν βλέπω κανέναν
      }
    }

    final querySnapshot = await query.get();
    List<Map<String, dynamic>> admins = querySnapshot.docs.map((doc) => {
      ...doc.data() as Map<String, dynamic>,
      'uid': doc.id,
    }).toList();

    // 3. Φίλτρο Ασφαλείας: Κρύβουμε τον Superuser από ΟΛΟΥΣ τους άλλους!
    if (!global.globalUser.isSuperUser) {
      admins.removeWhere((admin) => admin['superuser'] == "super123userRR");
    }

    return admins;
  }

  void _refreshAdmins() {
    setState(() {
      _adminUsersFuture = _fetchAdmins();
    });
  }

  // ... [Ο κώδικας του _updateYear και του _buildYearSelector ΠΑΡΑΜΕΝΕΙ Ο ΙΔΙΟΣ] ...

  @override
  Widget build(BuildContext context) {
    final isDark = global.darkModeNotifier.value;
    final textColor = isDark ? Colors.white : Colors.black87;
    final tileColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return Column(
      children: [
        //_buildYearSelector(), // Υποθέτω τον έχεις κρατήσει ίδιο

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'Αναζήτηση (Όνομα, Email, Ομάδα)',
              labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
              prefixIcon: Icon(Icons.search, color: textColor.withOpacity(0.7)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: Icon(Icons.clear, color: textColor.withOpacity(0.7)),
                onPressed: () {
                  _searchController.clear();
                  FocusScope.of(context).unfocus();
                  setState(() => _searchQuery = '');
                },
              )
                  : null,
              filled: true,
              fillColor: tileColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),

        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _adminUsersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return Center(child: Text('Σφάλμα: ${snapshot.error}', style: TextStyle(color: textColor)));

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
                return Center(child: Text('Δεν βρέθηκε αποτέλεσμα.', style: TextStyle(color: textColor)));
              }

              return ListView.builder(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                itemCount: filteredAdmins.length,
                itemBuilder: (context, index) {
                  return AdminCard(
                    admin: filteredAdmins[index],
                    searchQuery: _searchQuery,
                    refreshList: _refreshAdmins,
                    // ΝΕΟ: Περνάμε στην κάρτα ποιοι είμαστε!
                    myUid: _myUid,
                    isMeSuperUser: global.globalUser.isSuperUser,
                    isMeSecretariat:  global.globalUser.isUpperAdmin,
                    myMainTeams: _myMainTeams,
                  );
                },
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

  // Δεχόμαστε τα στοιχεία του χρήστη που κρατάει το κινητό
  final String myUid;
  final bool isMeSuperUser;
  final bool isMeSecretariat;
  final List<String> myMainTeams;

  const AdminCard({
    required this.admin,
    required this.refreshList,
    required this.myUid,
    required this.isMeSuperUser,
    required this.isMeSecretariat,
    required this.myMainTeams,
    this.searchQuery = '',
    Key? key
  }) : super(key: key);

  @override
  State<AdminCard> createState() => _AdminCardState();
}

class _AdminCardState extends State<AdminCard> {
  late bool moderator;
  late List<String> teams;
  late List<String> targetMainTeams;

  @override
  void initState() {
    super.initState();
    moderator = widget.admin['moderator'] ?? false;
    teams = List<String>.from(widget.admin['Controlled Teams'] ?? []);
    targetMainTeams = List<String>.from(widget.admin['Main Teams'] ?? []);
  }

  // Δικαιώματα (Rules)
  bool get _canManageSecretariat => widget.isMeSuperUser || widget.isMeSecretariat;
  bool get _canAssignNewTeam => widget.isMeSuperUser || widget.isMeSecretariat;

  bool _canRemoveTeam(String team) {
    if (widget.isMeSuperUser || widget.isMeSecretariat) return true;
    if (widget.admin['uid'] == widget.myUid) return true; // Αποχώρηση (Ο εαυτός μου)
    if (widget.myMainTeams.contains(team)) return true; // Είμαι Βασικός Αρχηγός
    return false;
  }

  bool _canPromoteToMain(String team) {
    if (widget.isMeSuperUser) return true; // ΝΕΟ: Ο Superuser μπορεί πάντα να προάγει/υποβιβάζει
    return _canRemoveTeam(team);
  }

  void _toggleModerator(String uid) async {
    final newValue = !moderator;
    setState(() => moderator = newValue);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({'moderator': newValue});
    } catch (e) {
      setState(() => moderator = !newValue);
    }
  }

  // --- ΣΥΝΑΡΤΗΣΗ ΠΡΟΑΓΩΓΗΣ ---
  void _promoteToMainCaptain(String uid, String team) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'Main Teams': FieldValue.arrayUnion([team])
      });
      setState(() => targetMainTeams.add(team));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Προήχθη σε Βασικό Αρχηγό!'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Σφάλμα: $e'), backgroundColor: Colors.red));
    }
  }

  // --- ΣΥΝΑΡΤΗΣΗ ΥΠΟΒΙΒΑΣΜΟΥ (ΝΕΟ) ---
  void _demoteFromMainCaptain(String uid, String team) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'Main Teams': FieldValue.arrayRemove([team])
      });
      setState(() => targetMainTeams.remove(team));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Έγινε ξανά απλός αρχηγός.'), backgroundColor: Colors.orange));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Σφάλμα: $e'), backgroundColor: Colors.red));
    }
  }

  // --- ΣΥΝΑΡΤΗΣΗ ΑΦΑΙΡΕΣΗΣ ΟΜΑΔΑΣ (Και ολικής διαγραφής Admin) ---
  void _removeTeam(String uid, String team) async {
    try {
      // 1. Τον βγάζουμε από την ομάδα (και ως απλό και ως βασικό)
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'Controlled Teams': FieldValue.arrayRemove([team]),
        'Main Teams': FieldValue.arrayRemove([team])
      });

      setState(() {
        teams.remove(team);
        targetMainTeams.remove(team);
      });

      // 2. ΝΕΟ: Αν δεν του έμεινε ΚΑΜΙΑ ομάδα, τον κάνουμε απλό χρήστη!
      if (teams.isEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'role': 'user',
          'moderator': false, // Του παίρνουμε και τη γραμματεία για ασφάλεια
        });

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ο χρήστης δεν έχει πια ομάδες και διαγράφηκε από Admin.'), backgroundColor: Colors.redAccent)
        );

        // Ανανεώνουμε τη λίστα για να εξαφανιστεί η κάρτα του!
        widget.refreshList();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Σφάλμα: $e'), backgroundColor: Colors.red));
    }
  }

  void _addTeam(String uid, String team) async {
    if (team.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'Controlled Teams': FieldValue.arrayUnion([team]),
        'role': 'admin' // Σιγουρευόμαστε ότι είναι admin!
      });
      setState(() => teams.add(team));
    } catch (e) {}
  }

  void _showAddTeamDialog(BuildContext context, String uid) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Προσθήκη Ομάδας'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Όνομα Ομάδας')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Άκυρο')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) _addTeam(uid, controller.text.trim());
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
      displayTeams = displayTeams.where((team) => team.toLowerCase().contains(widget.searchQuery.toLowerCase())).toList();
    }

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isMyOwnCard ? const BorderSide(color: Colors.blueAccent, width: 2) : BorderSide.none,
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
                backgroundColor: moderator ? Colors.purple : (isMyOwnCard ? Colors.green : Colors.blue),
                child: Icon(moderator ? Icons.verified_user : Icons.person, color: Colors.white),
              ),
              title: Text(isMyOwnCard ? "$name (Εσύ)" : name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16)),
              subtitle: Text(email, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 13)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_canManageSecretariat && !isMyOwnCard)
                    IconButton(
                      icon: moderator ? const Icon(Icons.star, color: Colors.amber) : Icon(Icons.star_border, color: textColor.withOpacity(0.5)),
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

            Text("Ομάδες:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor.withOpacity(0.8))),
            const SizedBox(height: 6),

            if (teams.isEmpty)
              const Text("Καμία ενεργή ομάδα", style: TextStyle(color: Colors.redAccent, fontSize: 13, fontStyle: FontStyle.italic))
            else if (displayTeams.isEmpty && widget.searchQuery.isNotEmpty)
              Text("Δεν ταιριάζουν στην αναζήτηση", style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 13, fontStyle: FontStyle.italic))
            else
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: displayTeams.map((team) {
                  bool isMainCapt = targetMainTeams.contains(team);
                  bool canIRemoveThem = _canRemoveTeam(team);

                  return GestureDetector(
                    // Η Λογική Προαγωγής / Υποβιβασμού!
                    onTap: () {
                      if (_canPromoteToMain(team)) {
                        if (!isMainCapt) {
                          // Είναι απλός, τον κάνουμε βασικό
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Προαγωγή'),
                              content: Text('Θέλετε να κάνετε αυτόν τον χρήστη Βασικό Αρχηγό για την ομάδα "$team";'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Άκυρο')),
                                ElevatedButton(
                                  onPressed: () {
                                    _promoteToMainCaptain(uid, team);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Ναι, Προαγωγή'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          // Είναι ΗΔΗ βασικός, τον κάνουμε απλό (Υποβιβασμός)
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Αφαίρεση Δικαιωμάτων'),
                              content: Text('Θέλετε να αφαιρέσετε τα δικαιώματα Βασικού Αρχηγού για την ομάδα "$team"; (Θα παραμείνει απλός αρχηγός)'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Άκυρο')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                  onPressed: () {
                                    _demoteFromMainCaptain(uid, team);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Ναι, Αφαίρεση'),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    },
                    child: Chip(
                      avatar: isMainCapt ? const Icon(Icons.workspace_premium, color: Colors.amber, size: 20) : null,
                      backgroundColor: isMainCapt ? Colors.amber.withOpacity(0.15) : Colors.blue.withOpacity(0.1),
                      labelStyle: TextStyle(
                          color: isDark ? Colors.lightBlueAccent : Colors.blue[800]!,
                          fontWeight: isMainCapt ? FontWeight.w900 : FontWeight.bold
                      ),
                      label: Text(team),
                      deleteIcon: canIRemoveThem ? Icon(Icons.cancel, size: 18, color: Colors.red.withOpacity(0.8)) : null,
                      onDeleted: canIRemoveThem ? () => _removeTeam(uid, team) : null,
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}