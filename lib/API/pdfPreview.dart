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
      String path = "MatchReports/$thisYearNow/${match.matchKey}.pdf";
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
          .doc(match.matchKey)
          .update({
        'pdfReportUrl': downloadUrl,
        'isFinalized': true,
      });

      if (context.mounted) {
        Navigator.pop(context); // Κλείνει το Loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Το Φύλλο Αγώνα ανέβηκε επιτυχώς!'), backgroundColor: Colors.green),
        );
        // Επιστρέφουμε στην αρχική οθόνη (ή 2 οθόνες πίσω για να κλείσει και η οθόνη υπογραφών)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      print("Error uploading match PDF: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Σφάλμα κατά την υποβολή. Δοκιμάστε ξανά.'), backgroundColor: Colors.red),
      );
      print("🕵️ ΕΛΕΓΧΟΣ AUTH: ${FirebaseAuth.instance.currentUser?.uid}");
    }
  }
}