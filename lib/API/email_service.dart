import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';

import '../Data_Classes/MatchDetails.dart';
import 'matchPDF.dart';

Future<void> sendMatchReportToEmails(MatchDetails match, String remarks, Uint8List refSig, Uint8List homeSig, Uint8List awaySig) async {
  try {
    // 1. Δημιουργία του PDF
    Uint8List pdfBytes = await MatchReportGenerator.generateModernReport(
      match: match,
      remarks: remarks,
      refSignature: refSig,
      homeSignature: homeSig,
      awaySignature: awaySig,
    );

    // 2. Ανέβασμα του PDF στο Firebase Storage
    // Χρησιμοποιούμε το match id και το timestamp για μοναδικό όνομα
    String fileName = 'MatchReports/${match.matchId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

    // Ορίζουμε το contentType ώστε να αναγνωρίζεται ως PDF
    await storageRef.putData(pdfBytes, SettableMetadata(contentType: 'application/pdf'));
    String pdfDownloadUrl = await storageRef.getDownloadURL();

    // 3. Άντληση των ημιμόνιμων emails της Γραμματείας
    DocumentSnapshot settingsDoc = await FirebaseFirestore.instance
        .collection('settings')
        .doc('match_sheet')
        .get();

    List<String> recipients = [];
    if (settingsDoc.exists) {
      recipients = List<String>.from(settingsDoc['recipients'] ?? []);
    }

    if (recipients.isEmpty) {
      print("Δεν βρέθηκαν παραλήπτες. Το email ακυρώθηκε.");
      return;
    }

    // 4. Εγγραφή στο collection 'mail' για να πυροδοτηθεί το Cloud Function
    await FirebaseFirestore.instance.collection('mail').add({
      'to': recipients,
      'message': {
        'subject': 'Φύλλο Αγώνα: ${match.homeTeam.name} vs ${match.awayTeam.name}',
        'html': '''
          <h3>Επίσημο Φύλλο Αγώνα</h3>
          <p>Διοργάνωση: Πρωτάθλημα ΑΠΘ<br>
          Αναμέτρηση: <b>${match.homeTeam.name} - ${match.awayTeam.name}</b><br>
          Τελικό Σκορ: ${match.homeScore} - ${match.awayScore}</p>
          <p>Βρείτε επισυναπτόμενο το πλήρες φύλλο αγώνα σε μορφή PDF.</p>
        ''',
        'attachments': [
          {
            'filename': 'MatchReport_${match.homeTeam.name}_${match.awayTeam.name}.pdf',
            // Το Nodemailer δέχεται το 'path' ως link και κατεβάζει το αρχείο
            // απευθείας για να το βάλει ως πραγματικό attachment στο email!
            'path': pdfDownloadUrl
          }
        ]
      }
    });

    print("Η εντολή αποστολής email καταχωρήθηκε επιτυχώς!");

  } catch (e) {
    print("Σφάλμα κατά την αποστολή του email: $e");
    // Εδώ μπορείς να εμφανίσεις ένα SnackBar με το σφάλμα
  }
}