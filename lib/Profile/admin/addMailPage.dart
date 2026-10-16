import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../globals.dart' as global;

class MatchSheetEmailsPage extends StatefulWidget {
  const MatchSheetEmailsPage({Key? key}) : super(key: key);

  @override
  State<MatchSheetEmailsPage> createState() => _MatchSheetEmailsPageState();
}

class _MatchSheetEmailsPageState extends State<MatchSheetEmailsPage> {
  final TextEditingController _emailController = TextEditingController();
  List<String> _recipients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEmails();
  }

  Future<void> _fetchEmails() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('match_sheet')
          .get();

      if (doc.exists) {
        setState(() {
          _recipients = List<String>.from(doc['recipients'] ?? []);
        });
      }
    } catch (e) {
      print("Error fetching emails: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addEmail() async {
    String newEmail = _emailController.text.trim().toLowerCase();
    if (newEmail.isEmpty || !newEmail.contains('@')) return;

    if (!_recipients.contains(newEmail)) {
      setState(() => _isLoading = true);
      _recipients.add(newEmail);

      await FirebaseFirestore.instance.collection('settings').doc('match_sheet').set({
        'recipients': _recipients
      }, SetOptions(merge: true));

      _emailController.clear();
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Το Email προστέθηκε επιτυχώς!'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _removeEmail(String email) async {
    setState(() => _isLoading = true);
    _recipients.remove(email);

    await FirebaseFirestore.instance.collection('settings').doc('match_sheet').set({
      'recipients': _recipients
    }, SetOptions(merge: true));

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = global.darkModeNotifier.value;
    final textColor = isDark ? Colors.white : Colors.black87;

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Παραλήπτες Φύλλου Αγώνα",
            style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Αυτά τα emails θα χρησιμοποιούνται αυτόματα ως παραλήπτες του φύλλου αγώνα.",
            style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: "Νέο Email (π.χ. ref@auth.gr)",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _addEmail,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Προσθήκη"),
              )
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _recipients.length,
              itemBuilder: (context, index) {
                String email = _recipients[index];
                return Card(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[200],
                  child: ListTile(
                    leading: const Icon(Icons.email, color: Colors.blueAccent),
                    title: Text(email, style: TextStyle(color: textColor)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _removeEmail(email),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}