import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../Data_Classes/MatchDetails.dart';
import '../globals.dart';


class MatchPdfPreviewScreen extends StatelessWidget {
  final MatchDetails match;
  final Uint8List pdfBytes;

  const MatchPdfPreviewScreen({
    super.key,
    required this.match,
    required this.pdfBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Προεπισκόπηση & Υποβολή'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: PdfPreview(
        build: (format) => pdfBytes,
        allowSharing: true,
        allowPrinting: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        actions: [
          PdfPreviewAction(
            icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white),
            onPressed: (context, build, pageFormat) async {

              await _finalizeMatchAndUpload(context, pdfBytes);
            },
          )
        ],
      ),
    );
  }

  Future<void> _finalizeMatchAndUpload(BuildContext context, Uint8List finalBytes) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. ΑΝΕΒΑΣΜΑ ΣΤΟ FIREBASE STORAGE
      String path = "MatchReports/$thisYearNow/${match.matchDocId}.pdf";
      Reference storageRef = FirebaseStorage.instance.ref().child(path);

      UploadTask uploadTask = storageRef.putData(
          finalBytes,
          SettableMetadata(contentType: 'application/pdf')
      );
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // 2. ΕΝΗΜΕΡΩΣΗ ΣΤΟ FIRESTORE
      await FirebaseFirestore.instance
          .collection("year")
          .doc(thisYearNow.toString())
          .collection("matches")
          .doc(match.matchDocId)
          .update({
        'pdfReportUrl': downloadUrl,
        'isFinalized': true,
      });

      // =================================================================
      // 3. ΑΝΑΚΤΗΣΗ ΔΥΝΑΜΙΚΩΝ ΠΑΡΑΛΗΠΤΩΝ (Γραμματεία + Αρχηγοί)
      // =================================================================
      List<String> recipients = [];

      // Α. Άντληση emails Γραμματείας από τα settings
      DocumentSnapshot settingsDoc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('match_sheet')
          .get();
      if (settingsDoc.exists) {
        recipients.addAll(List<String>.from(settingsDoc['recipients'] ?? []));
      }

      // Β. Άντληση email Αρχηγού Γηπεδούχου (αν υπάρχει το uid του)
      if (match.homeCaptain != null && match.homeCaptain!.isNotEmpty) {
        DocumentSnapshot hCapDoc = await FirebaseFirestore.instance.collection('users').doc(match.homeCaptain).get();
        if (hCapDoc.exists && hCapDoc.data().toString().contains('email')) {
          recipients.add(hCapDoc.get('email'));
        }
      }

      // Γ. Άντληση email Αρχηγού Φιλοξενούμενου (αν υπάρχει το uid του)
      if (match.awayCaptain != null && match.awayCaptain!.isNotEmpty) {
        DocumentSnapshot aCapDoc = await FirebaseFirestore.instance.collection('users').doc(match.awayCaptain).get();
        if (aCapDoc.exists && aCapDoc.data().toString().contains('email')) {
          recipients.add(aCapDoc.get('email'));
        }
      }

      // Αφαίρεση διπλότυπων (π.χ. αν ο αρχηγός είναι και διαχειριστής)
      recipients = recipients.toSet().toList();

      // Ασφάλεια: Αν για κάποιο λόγο δεν βρεθεί κανένα email, βάλε fallback
      if (recipients.isEmpty) {
        recipients.add('oksder1234@gmail.com');
      }

      // =================================================================
      // 4. ✉️ ΔΗΜΙΟΥΡΓΙΑ ΤΟΥ MAIL COLLECTION ΓΙΑ ΤΗΝ ΑΠΟΣΤΟΛΗ PDF
      // =================================================================
      await FirebaseFirestore.instance.collection("mail").add({
        'to': recipients, // <-- Μπαίνει η δυναμική λίστα!
        'message': {
          'subject': 'Φύλλο Αγώνα: ${match.homeTeam.displayName} - ${match.awayTeam.displayName}',
          'html': '''
          <h3>Επίσημο Φύλλο Αγώνα</h3>
          <p>Σας αποστέλλουμε το υπογεγραμμένο φύλλο αγώνα για την αναμέτρηση <b>${match.homeTeam.displayName} - ${match.awayTeam.displayName}</b>.</p>
          <p><b>Τελικό Σκορ:</b> ${match.homeScore} - ${match.awayScore}</p>
          <p>Παρακαλούμε βρείτε το PDF του αγώνα επισυναπτόμενο σε αυτό το μήνυμα.</p>
        ''',
          'attachments': [
            {
              'filename': 'Match_Report_${match.homeTeam.name}_${match.awayTeam.name}.pdf',
              'path': downloadUrl
            }
          ]
        }
      });
      // =================================================================

      if (context.mounted) {
        Navigator.pop(context); // Κλείνει το Loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Το Φύλλο Αγώνα ανέβηκε και στάλθηκε επιτυχώς!'), backgroundColor: Colors.green),
        );
        // Επιστρέφουμε στην αρχική οθόνη
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      print("Error uploading match PDF or sending email: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Σφάλμα κατά την υποβολή. Δοκιμάστε ξανά.'), backgroundColor: Colors.red),
      );
    }
  }


}