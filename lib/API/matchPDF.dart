import 'dart:typed_data';
import 'package:flutter/services.dart'; // 💡 ΠΡΟΣΤΕΘΗΚΕ: Για το rootBundle (Τοπικά αρχεία)
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

    // ΑΛΛΑΓΗ: Φορτώνουμε τις γραμματοσειρές ΤΟΠΙΚΑ, όχι από το ίντερνετ!
    final regularFontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final boldFontData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');

    final italicFontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');

    final font = pw.Font.ttf(regularFontData);
    final boldFont = pw.Font.ttf(boldFontData);
    final italicFont = pw.Font.ttf(italicFontData);

    // Βρίσκουμε τον πάγκο αφαιρώντας τους βασικούς από το συνολικό ρόστερ του αγώνα
    final List<String> homeBenchKeys = match.homeSquad.where((key) => !match.homeStarters.contains(key)).toList();
    final List<String> awayBenchKeys = match.awaySquad.where((key) => !match.awayStarters.contains(key)).toList();

    // Φορμάρουμε τις λίστες με τα ονόματα (και το (C) για τους αρχηγούς)
    final formattedHomeStarters = _formatPlayerList(match.homeStarters, match.homeTeam, match, match.homeCaptain);
    final formattedHomeBench = _formatPlayerList(homeBenchKeys, match.homeTeam, match, match.homeCaptain);
    final formattedAwayStarters = _formatPlayerList(match.awayStarters, match.awayTeam, match, match.awayCaptain);
    final formattedAwayBench = _formatPlayerList(awayBenchKeys, match.awayTeam, match, match.awayCaptain);


    // Χρησιμοποιούμε MultiPage ώστε αν γεμίσει η σελίδα, να αλλάξει σελίδα αυτόματα
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        // 💡 Βάζουμε το Theme για ασφάλεια
        theme: pw.ThemeData.withFont(
          base: font,
          bold: boldFont,
          italic: italicFont,
        ),
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
            pw.Partitions(
              children: [
                // Αριστερή Στήλη: Γηπεδούχος
                pw.Partition(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.only(right: 10),
                    child: _buildTeamColumn(
                      teamName: match.homeTeam.name,
                      captain: match.homeCaptain,
                      starters: formattedHomeStarters,
                      subs: formattedHomeBench,
                      font: font,
                      boldFont: boldFont,
                    ),
                  ),
                ),
                // Δεξιά Στήλη: Φιλοξενούμενος
                pw.Partition(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.only(left: 10),
                    child: _buildTeamColumn(
                      teamName: match.awayTeam.name,
                      captain: match.awayCaptain,
                      starters: formattedAwayStarters,
                      subs: formattedAwayBench,
                      font: font,
                      boldFont: boldFont,
                    ),
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
        pw.Text("Βασική Ενδεκάδα:",
            style: pw.TextStyle(font: boldFont, fontSize: 11)),
        ...starters.map((p) =>
            pw.Text("• $p", style: pw.TextStyle(font: font, fontSize: 10))),
        // ... (προηγούμενος κώδικας βασικής ενδεκάδας) ...
        pw.SizedBox(height: 10),

        pw.Text("Αναπληρωματικοί:",
            style: pw.TextStyle(font: boldFont, fontSize: 11)),
        if (subs.isEmpty)
          pw.Text("Κανείς",
              style: pw.TextStyle(
                  font: font, fontSize: 10, color: PdfColors.grey600)),
        ...subs.map((p) =>
            pw.Text("• $p", style: pw.TextStyle(font: font, fontSize: 10))),
      ],
    );
  }

  static pw.Widget _buildEventsTimeline(
      MatchDetails match, pw.Font font, pw.Font boldFont, pw.Font italicFont) {
    List<pw.Widget> eventWidgets = [];

    for (int half = 0; half < 4; half++) {
      if (match.matchFact.containsKey(half) &&
          match.matchFact[half]!.isNotEmpty) {

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

        for (var fact in match.matchFact[half]!) {
          String timePrefix = "[${fact.timeString}']";
          String description = "";

          String teamName =
          fact.isHomeTeam ? match.homeTeam.name : match.awayTeam.name;

          if (fact is Goal) {
            description =
            "ΓΚΟΛ ($teamName) - ${fact.name} | Σκορ: ${fact.homeScore}-${fact.awayScore}";
          } else if (fact is CardP) {
            String cardType = fact.isYellow
                ? (fact.isSecondYellow ? "2η Κίτρινη (Κόκκινη)" : "Κίτρινη")
                : "Απευθείας Κόκκινη";
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

  static List<String> _formatPlayerList(
      List<String> keys, Team team, MatchDetails match, String? captainKey) {
    return keys.map((key) {
      try {
        final player = team.players.firstWhere((p) => p.uniqueKey == key);
        String playerText = "${match.getDisplayNumber(player)} - ${player.surname} ${player.name}";

        if (key == captainKey) {
          playerText += " (C)";
        }

        return playerText;
      } catch (e) {
        return key; // Fallback αν δεν βρεθεί ο παίκτης
      }
    }).toList();
  }
}