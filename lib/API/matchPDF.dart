import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Πρόσθεσε εδώ τα δικά σου imports ανάλογα με το πού βρίσκονται τα αρχεία σου
import '../Data_Classes/MatchDetails.dart';
import '../Data_Classes/Team.dart';
import '../Data_Classes/match_facts.dart';

class MatchReportGenerator {
  static Future<Uint8List> generateModernReport({
    required MatchDetails match,
    required String remarks,
    required Uint8List refSignature,
    required Uint8List homeSignature,
    required Uint8List awaySignature,
  }) async {
    final pdf = pw.Document();

    // Φορτώνουμε ελληνικές γραμματοσειρές on the fly (απαραίτητο για τα Ελληνικά)
    // Φορτώνουμε ελληνικές γραμματοσειρές on the fly (απαραίτητο για τα Ελληνικά)
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();
    final italicFont = await PdfGoogleFonts.robotoItalic();

    final formattedHomeStarters =
        _formatPlayerList(match.homeStarters, match.homeTeam, match);
    final formattedHomeSubs =
        _formatPlayerList(match.homeSubsIn, match.homeTeam, match);
    final formattedAwayStarters =
        _formatPlayerList(match.awayStarters, match.awayTeam, match);
    final formattedAwaySubs =
        _formatPlayerList(match.awaySubsIn, match.awayTeam, match);

    // Χρησιμοποιούμε MultiPage ώστε αν γεμίσει η σελίδα, να αλλάξει σελίδα αυτόματα
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // --- 1. HEADER (ΒΙΤΡΙΝΑ) ---
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 15),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.blue900, width: 2)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("ΦΥΛΛΟ ΑΓΩΝΑ",
                          style: pw.TextStyle(
                              font: boldFont,
                              fontSize: 22,
                              color: PdfColors.blue900)),
                      pw.SizedBox(height: 4),
                      pw.Text("Διοργάνωση: Πρωτάθλημα ΑΠΘ",
                          style: pw.TextStyle(
                              font: font,
                              fontSize: 12,
                              color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("Ημερομηνία: ${match.dateString}",
                          style: pw.TextStyle(font: font, fontSize: 12)),
                      pw.Text("Ώρα Έναρξης: ${match.timeString}",
                          style: pw.TextStyle(font: font, fontSize: 12)),
                      pw.Text("Φάση: ${match.matchweekInfo()}",
                          style: pw.TextStyle(font: font, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // --- 2. ΣΚΟΡ & ΟΜΑΔΕΣ (ΚΕΝΤΡΟ) ---
            pw.Center(
              child: pw.Text(
                "${match.homeTeam.name}   ${match.homeScore} - ${match.awayScore}   ${match.awayTeam.name}",
                style: pw.TextStyle(font: boldFont, fontSize: 24),
              ),
            ),
            if (match.isPenaltyTime)
              pw.Center(
                child: pw.Text(
                  "(Πέναλτι: ${match.penaltyScoreHome} - ${match.penaltyScoreAway})",
                  style: pw.TextStyle(
                      font: font, fontSize: 14, color: PdfColors.red800),
                ),
              ),

            pw.SizedBox(height: 30),

            // --- 3. ΡΟΣΤΕΡ (ΤΟ ΔΙΣΤΗΛΟ) ---
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Αριστερή Στήλη: Γηπεδούχος
                pw.Expanded(
                  child: _buildTeamColumn(
                    teamName: match.homeTeam.name,
                    captain: match.awayCaptain,
                    starters: formattedHomeStarters,
                    subs: formattedHomeSubs,
                    font: font,
                    boldFont: boldFont,
                  ),
                ),
                pw.SizedBox(width: 20), // Κενό ανάμεσα στις ομάδες
                // Δεξιά Στήλη: Φιλοξενούμενος
                pw.Expanded(
                  child: _buildTeamColumn(
                    teamName: match.awayTeam.name,
                    captain: match.awayCaptain,
                    starters: formattedAwayStarters,
                    subs: formattedAwaySubs,
                    font: font,
                    boldFont: boldFont,
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 30),

            // --- 4. ΓΕΓΟΝΟΤΑ ΑΓΩΝΑ (TIMELINE) ---
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 5),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey400, width: 1)),
              ),
              child: pw.Text("Γεγονότα Αγώνα:",
                  style: pw.TextStyle(font: boldFont, fontSize: 14)),
            ),
            pw.SizedBox(height: 10),
            _buildEventsTimeline(match, font, boldFont, italicFont),

            pw.SizedBox(height: 30),

            // --- 5. ΠΑΡΑΤΗΡΗΣΕΙΣ ΔΙΑΙΤΗΤΗ ---
            pw.Text("Παρατηρήσεις:",
                style: pw.TextStyle(font: boldFont, fontSize: 14)),
            pw.SizedBox(height: 5),
            pw.Container(
              width: double.infinity,
              constraints: const pw.BoxConstraints(minHeight: 80),
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Text(
                remarks.isEmpty ? "" : remarks,
                style: pw.TextStyle(font: font, fontSize: 11),
              ),
            ),

            pw.SizedBox(height: 40),

            // --- 6. ΥΠΟΓΡΑΦΕΣ ---
            // Χρησιμοποιούμε Wrap ή απλό Row ανάλογα με το χώρο
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                _buildSignatureBlock("Υπογραφή Διαιτητή", refSignature, font),
                _buildSignatureBlock(
                    "Αρχηγός (${match.homeTeam.name})", homeSignature, font),
                _buildSignatureBlock(
                    "Αρχηγός (${match.awayTeam.name})", awaySignature, font),
              ],
            ),
          ];
        },
      ),
    );

    return await pdf.save(); // Επιστρέφει το τελικό αρχείο ως Bytes
  }

  // ============================================================================
  // ΒΟΗΘΗΤΙΚΑ WIDGETS

  // 1. Στήλη Ομάδας (Ρόστερ)
  static pw.Widget _buildTeamColumn({
    required String teamName,
    required String? captain,
    required List<String> starters,
    required List<String> subs,
    required pw.Font font,
    required pw.Font boldFont,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          color: PdfColors.grey200,
          width: double.infinity,
          child: pw.Text(teamName,
              style: pw.TextStyle(font: boldFont, fontSize: 14)),
        ),
        if (captain != null && captain.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 4, bottom: 8),
            child: pw.Text("Αρχηγός: $captain",
                style: pw.TextStyle(
                    font: font, fontSize: 10, color: PdfColors.grey700)),
          ),
        pw.Text("Βασική Ενδεκάδα:",
            style: pw.TextStyle(font: boldFont, fontSize: 11)),
        ...starters.map((p) =>
            pw.Text("• $p", style: pw.TextStyle(font: font, fontSize: 10))),
        pw.SizedBox(height: 10),
        pw.Text("Αλλαγές (Μπήκαν):",
            style: pw.TextStyle(font: boldFont, fontSize: 11)),
        if (subs.isEmpty)
          pw.Text("Καμία",
              style: pw.TextStyle(
                  font: font, fontSize: 10, color: PdfColors.grey600)),
        ...subs.map((p) =>
            pw.Text("• $p", style: pw.TextStyle(font: font, fontSize: 10))),
      ],
    );
  }

  // 2. Χρονολόγιο Γεγονότων (Timeline)
  static pw.Widget _buildEventsTimeline(
      MatchDetails match, pw.Font font, pw.Font boldFont, pw.Font italicFont) {
    List<pw.Widget> eventWidgets = [];

    // Διασχίζουμε όλα τα ημίχρονα (0: 1ο, 1: 2ο, 2: 1ο Παράτασης, 3: 2ο Παράτασης)
    for (int half = 0; half < 4; half++) {
      if (match.matchFact.containsKey(half) &&
          match.matchFact[half]!.isNotEmpty) {
        // Επικεφαλίδα Ημιχρόνου
        String halfName = "";
        if (half == 0) halfName = "1ο Ημίχρονο";
        if (half == 1) halfName = "2ο Ημίχρονο";
        if (half == 2) halfName = "1ο Ημίχρονο Παράτασης";
        if (half == 3) halfName = "2ο Ημίχρονο Παράτασης";

        eventWidgets.add(pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8, bottom: 4),
          child: pw.Text(halfName,
              style: pw.TextStyle(
                  font: boldFont, fontSize: 12, color: PdfColors.blueGrey800)),
        ));

        // Για κάθε γεγονός σε αυτό το ημίχρονο
        for (var fact in match.matchFact[half]!) {
          String timePrefix = "[${fact.timeString}']";
          String description = "";

          // Βρίσκουμε το όνομα της ομάδας
          String teamName =
              fact.isHomeTeam ? match.homeTeam.name : match.awayTeam.name;

          // Ελέγχουμε τον τύπο του MatchFact
          if (fact is Goal) {
            description =
                "ΓΚΟΛ ($teamName) - ${fact.name} | Σκορ: ${fact.homeScore}-${fact.awayScore}";
          } else if (fact is CardP) {
            String cardType = fact.isYellow ? "ΚΙΤΡΙΝΗ ΚΑΡΤΑ" : "ΚΟΚΚΙΝΗ ΚΑΡΤΑ";
            description = "$cardType ($teamName) - ${fact.name}";
          } else if (fact is Substitution) {
            description =
                "ΑΛΛΑΓΗ ($teamName) - Μπήκε: ${fact.playerInName}, Βγήκε: ${fact.playerOutName}";
          }

          eventWidgets.add(pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(
                        width: 35,
                        child: pw.Text(timePrefix,
                            style: pw.TextStyle(font: boldFont, fontSize: 10))),
                    pw.Expanded(
                        child: pw.Text(description,
                            style: pw.TextStyle(font: font, fontSize: 10))),
                  ])));
        }
      }
    }

    if (eventWidgets.isEmpty) {
      return pw.Text("Δεν καταγράφηκαν σημαντικά γεγονότα στον αγώνα.",
          style: pw.TextStyle(
              font: italicFont, fontSize: 11, color: PdfColors.grey600));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: eventWidgets,
    );
  }

  // 3. Κουτάκι Υπογραφής
  static pw.Widget _buildSignatureBlock(
      String title, Uint8List signatureBytes, pw.Font font) {
    return pw.Column(
      children: [
        pw.Container(
          height: 60,
          width: 120,
          decoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.black, width: 1))),
          child:
              pw.Image(pw.MemoryImage(signatureBytes), fit: pw.BoxFit.contain),
        ),
        pw.SizedBox(height: 5),
        pw.Text(title, style: pw.TextStyle(font: font, fontSize: 10)),
      ],
    );
  }

  //Βοηθητική συνάρτηση που μετατρέπει τα keys σε κανονικά ονόματα ---
  static List<String> _formatPlayerList(
      List<String> keys, Team team, MatchDetails match) {
    return keys.map((key) {
      try {
        final player =
            team.players.firstWhere((p) => p.uniqueKey == key);

        return "${match.getDisplayNumber(player)} - ${player.name} ${player.surname}";
      } catch (e) {
        // Αν για κάποιο λόγο δεν βρεθεί ο παίκτης (π.χ. διαγράφηκε), επιστρέφουμε το κλειδί ως έχει
        return key;
      }
    }).toList();
  }
}
