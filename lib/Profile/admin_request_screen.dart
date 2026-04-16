import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled1/globals.dart';
import 'package:untitled1/Firebase_Handle/user_handle_in_base.dart';
import '../Firebase_Handle/firebase_screen_stats_helper.dart';

// Συνάρτηση παραγωγής τυχαίου PIN (5 χαρακτήρες, εύκολοι στην ανάγνωση)
String generateNewPin() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  Random rnd = Random();
  return String.fromCharCodes(Iterable.generate(
      5, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
}

class AdminRequestScreen extends StatefulWidget {
  const AdminRequestScreen({super.key});

  @override
  _AdminRequestScreenState createState() => _AdminRequestScreenState();
}

class _AdminRequestScreenState extends State<AdminRequestScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers για τα πεδία
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _submitRequest() async {
    String userName = _nameController.text.trim();
    String enteredPin = _pinController.text.trim().toUpperCase();

    if (userName.isNotEmpty && enteredPin.isNotEmpty) {
      // 1. Δείχνουμε το Loading Spinner
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // 2. ΤΟ ΜΑΓΙΚΟ QUERY: Ψάχνουμε αν υπάρχει κάποια ομάδα με αυτό το PIN
        QuerySnapshot teamQuery = await _firestore
            .collection("year")
            .doc(thisYearNow.toString())
            .collection("teams")
            .where('secret_pin', isEqualTo: enteredPin)
            .limit(1) // Φέρε μόνο μία, αφού το PIN είναι μοναδικό!
            .get();

        // Αποθηκεύουμε τα εργαλεία περιήγησης πριν τα ασύγχρονα κενά
        if (!mounted) return;
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);

        if (teamQuery.docs.isNotEmpty) {
          // ==== ΒΡΗΚΑΜΕ ΤΗΝ ΟΜΑΔΑ! ====
          DocumentSnapshot teamDoc = teamQuery.docs.first;
          String teamId = teamDoc.id; // Το όνομα της ομάδας

          String uid = FirebaseAuth.instance.currentUser!.uid;
          String newPin = generateNewPin(); // Φτιάχνουμε νέο PIN για ασφάλεια

          // 3. Ενημερώνουμε την ομάδα
          await teamDoc.reference.update({
            'secret_pin': newPin,
            'captains': FieldValue.arrayUnion([uid]),
          });

          // 4. Ενημερώνουμε το προφίλ του χρήστη
          await _firestore.collection('users').doc(uid).set({
            'role': 'admin',
            'Controlled Teams': FieldValue.arrayUnion([teamId]),
            'CaptainName': userName,
          }, SetOptions(merge: true));

          await UserHandleBase().refreshGlobalUserData();

          // Κλείνουμε το Loading
          navigator.pop();
          // Κλείνουμε την οθόνη
          navigator.pop();

          // Μήνυμα Επιτυχίας
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(greek
                  ? 'Συγχαρητήρια! Είσαι πλέον αρχηγός στην ομάδα: $teamId.'
                  : 'Success! You are now admin for: $teamId.'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );

        } else {
          // ==== ΛΑΘΟΣ PIN ====
          navigator.pop(); // Κλείνουμε μόνο το Loading

          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(greek ? 'Λάθος PIN! Προσπαθήστε ξανά.' : 'Invalid PIN! Please try again.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context); // Κλείνουμε το Loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Σφάλμα: $e'), backgroundColor: Colors.red),
        );
      }
    } else {
      // Μήνυμα λάθους αν ξέχασε κάτι
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(greek ? 'Παρακαλώ συμπληρώστε όλα τα πεδία' : 'Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Admin request page', screenClass: 'Admin request page');

    final bool isDark = darkModeNotifier.value;

    // Μεταβλητές χρωμάτων για το Dark Mode
    final Color bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color hintColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final Color inputFillColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color borderColor = isDark ? Colors.grey[700]! : Colors.grey[400]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          greek ? 'Αίτημα Αρχηγού' : 'Team Admin Request',
          style: TextStyle(color: textColor),
        ),
        backgroundColor: isDark ? Colors.black : Colors.blue,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- ΕΝΗΜΕΡΩΤΙΚΟ ΚΕΙΜΕΝΟ ----
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: isDark ? Colors.blue.withOpacity(0.15) : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? Colors.blueAccent.withOpacity(0.5) : Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_person, color: Colors.blueAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      greek
                          ? 'Εισάγετε το 5ψήφιο PIN της ομάδας σας για να αποκτήσετε δικαιώματα διαχείρισης.'
                          : 'Enter your team\'s 5-digit PIN to instantly gain admin rights.',
                      style: TextStyle(fontSize: 14, color: textColor),
                    ),
                  ),
                ],
              ),
            ),

            // ---- ΠΕΔΙΟ ΟΝΟΜΑΤΟΣ ----
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: greek ? 'Ονοματεπώνυμο' : 'Full Name',
                labelStyle: TextStyle(color: hintColor),
                prefixIcon: Icon(Icons.person, color: hintColor),
                filled: true,
                fillColor: inputFillColor,
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: borderColor)),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent, width: 2)),
              ),
            ),
            const SizedBox(height: 20),

            // ---- ΠΕΔΙΟ PIN ----
            TextField(
              controller: _pinController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 5, // Κλειδώνει στους 5 χαρακτήρες
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, letterSpacing: 3, fontSize: 18),
              decoration: InputDecoration(
                labelText: greek ? 'PIN Ομάδας' : 'Team\'s PIN',
                labelStyle: TextStyle(color: hintColor),
                hintText: 'π.χ. K8X2P',
                hintStyle: TextStyle(color: hintColor.withOpacity(0.5)),
                prefixIcon: Icon(Icons.key, color: hintColor),
                filled: true,
                fillColor: inputFillColor,
                counterText: "", // Κρύβει το "0/5" κάτω δεξιά αν δεν το θες
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: borderColor)),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent, width: 2)),
              ),
            ),
            const SizedBox(height: 30),

            // ---- ΚΟΥΜΠΙ ΥΠΟΒΟΛΗΣ ----
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: _submitRequest,
              child: Text(greek ? 'Ενεργοποίηση Δικαιωμάτων' : 'Activate Rights'),
            ),
          ],
        ),
      ),
    );
  }
}