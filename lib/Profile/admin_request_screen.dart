import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled1/globals.dart';

class AdminRequestScreen extends StatefulWidget {
  @override
  _AdminRequestScreenState createState() => _AdminRequestScreenState();
}

class _AdminRequestScreenState extends State<AdminRequestScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController(); // Controller για το όνομα
  List<String> _teams = []; // Οι διαθέσιμες ομάδες
  String? _selectedGroup; // Αποθήκευση της επιλεγμένης ομάδας

  @override
  void initState() {
    super.initState();
    _fetchGroups(); // Κλήση της μεθόδου για ανάκτηση ομάδων
  }

  Future<void> _fetchGroups() async {
    // Ανάκτηση ομάδων από το Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Ανάκτηση όλων των εγγράφων από τη συλλογή "teams"
    QuerySnapshot querySnapshot = await firestore.collection("teams").get();



    setState(() {
      // Λήψη των ονομάτων των ομάδων από τα έγγραφα
      _teams = querySnapshot.docs.map((doc) => doc.id).toList();
    });
  }

  void _submitRequest() async{
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).get();

    String userName = _nameController.text.trim(); // Λήψη του ονόματος από το TextField
    if (_selectedGroup != null && userName.isNotEmpty) {
      _firestore.collection('requests').add({
        'name': userName, // Χρήση του ονόματος που εισήγαγε ο χρήστης
        'username': userDoc.get("username"),
        'team': _selectedGroup,
        'status': 'pending',
        'uid': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Κλείσιμο της οθόνης ή καθαρισμός της επιλογής
      Navigator.pop(context);
    } else {
      // Μηνύματα λάθους αν δεν έχει επιλεγεί ομάδα ή αν το όνομα είναι κενό
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a group and enter your name')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Request Admin Role')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController, // Συνδέουμε το controller με το TextField
              decoration: InputDecoration(labelText: greek?'Γράψε ονοματεπώνυμο':'Enter your name'), // Ετικέτα του TextField
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              hint: Text('Select a group'),
              value: _selectedGroup,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGroup = newValue;
                });
              },
              items: _teams.map<DropdownMenuItem<String>>((String group) {
                return DropdownMenuItem<String>(
                  value: group,
                  child: Text(group),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitRequest,
              child: Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }
}
