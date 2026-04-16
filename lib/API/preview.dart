import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:untitled1/API/pdfPreview.dart';

import '../Data_Classes/MatchDetails.dart';
import 'matchPDF.dart';


class MatchReportScreen extends StatefulWidget {
  final MatchDetails match; // 🌟 Τώρα παίρνει ΟΛΟ το ματς!

  const MatchReportScreen({Key? key, required this.match}) : super(key: key);

  @override
  State<MatchReportScreen> createState() => _MatchReportScreenState();
}

class _MatchReportScreenState extends State<MatchReportScreen> {
  final TextEditingController _remarksController = TextEditingController();

  Uint8List? refSignature;
  Uint8List? homeSignature;
  Uint8List? awaySignature;

  bool _isGeneratingPDF = false;


  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _previousText = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // --- ΣΥΝΑΡΤΗΣΗ: Ανοίγει τον Καμβά Υπογραφής ---
  Future<void> _collectSignature(String title,
      Function(Uint8List) onSave) async {
    final SignatureController controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    await showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text(title, textAlign: TextAlign.center),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue)),
                    child: Signature(
                      controller: controller,
                      height: 150,
                      backgroundColor: Colors.grey[200]!,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => controller.clear(),
                    icon: const Icon(Icons.clear, color: Colors.red),
                    label: const Text(
                        'Καθαρισμός', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context),
                  child: const Text('Άκυρο')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  if (controller.isNotEmpty) {
                    final bytes = await controller.toPngBytes();
                    if (bytes != null) onSave(bytes);
                    Navigator.pop(context);
                  } else {
                    // Αν πατήσει αποθήκευση χωρίς να έχει υπογράψει
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Παρακαλώ βάλτε μια υπογραφή πρώτα!'))
                    );
                  }
                },
                child: const Text(
                    'Αποθήκευση', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
    controller.dispose();
  }

  // --- ΣΥΝΑΡΤΗΣΗ: Χτίζει το PDF και πάει στην Προεπισκόπηση! ---
  Future<void> _goToPreview() async {
    if (refSignature == null || homeSignature == null ||
        awaySignature == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(
          'Λείπουν υπογραφές!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red));
      return;
    }

    setState(() => _isGeneratingPDF = true);

    try {
      // 1. Καλούμε τη Γεννήτρια (από το pdf_generator.dart) και της δίνουμε το MatchDetails!
      final Uint8List pdfBytes = await MatchReportGenerator
          .generateModernReport(
        match: widget.match,
        remarks: _remarksController.text,
        refSignature: refSignature!,
        homeSignature: homeSignature!,
        awaySignature: awaySignature!,
      );

      // 2. Στέλνουμε τα έτοιμα bytes στην οθόνη Προεπισκόπησης!
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MatchPdfPreviewScreen(
                match: widget.match,
                pdfBytes: pdfBytes,
              ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Σφάλμα: $e')));
    } finally {
      setState(() => _isGeneratingPDF = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Φύλλο Αγώνα")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Δείχνουμε το σκορ απευθείας από το αντικείμενο match!
            Text("${widget.match.homeTeam.name} ${widget.match
                .homeScore} - ${widget.match.awayScore} ${widget.match.awayTeam
                .name}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            TextField(
              controller: _remarksController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Παρατηρήσεις Διαιτητή (Προαιρετικό)",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                  ),
                  color: _isListening ? Colors.red : Colors.grey,
                  onPressed: _listen,
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text("Απαραίτητες Υπογραφές:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ListTile(
              tileColor: refSignature == null
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              title: const Text("Υπογραφή Διαιτητή"),
              trailing: refSignature == null
                  ? const Icon(Icons.edit)
                  : const Icon(Icons.check_circle, color: Colors.green),
              onTap: () =>
                  _collectSignature("Διαιτητής", (bytes) =>
                      setState(() => refSignature = bytes)),
            ),
            ListTile(
              tileColor: homeSignature == null
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              title: Text("Αρχηγός ${widget.match.homeTeam.name}"),
              trailing: homeSignature == null
                  ? const Icon(Icons.edit)
                  : const Icon(Icons.check_circle, color: Colors.green),
              onTap: () =>
                  _collectSignature(
                      "Αρχηγός ${widget.match.homeTeam.name}", (bytes) =>
                      setState(() => homeSignature = bytes)),
            ),
            ListTile(
              tileColor: awaySignature == null
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              title: Text("Αρχηγός ${widget.match.awayTeam.name}"),
              trailing: awaySignature == null
                  ? const Icon(Icons.edit)
                  : const Icon(Icons.check_circle, color: Colors.green),
              onTap: () =>
                  _collectSignature(
                      "Αρχηγός ${widget.match.awayTeam.name}", (bytes) =>
                      setState(() => awaySignature = bytes)),
            ),

            const SizedBox(height: 40),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blueAccent,
              ),
              icon: _isGeneratingPDF ? const CircularProgressIndicator(
                  color: Colors.white) : const Icon(
                  Icons.picture_as_pdf, color: Colors.white),
              label: Text(_isGeneratingPDF
                  ? "Δημιουργία..."
                  : "Δημιουργία PDF & Προεπισκόπηση",
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: _isGeneratingPDF ? null : _goToPreview,
            )
          ],
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      // Το initialize() αναλαμβάνει να ζητήσει την άδεια από το λειτουργικό
      bool available = await _speech.initialize(
        // Προαιρετικό: Χρήσιμο για να βλέπεις στην κονσόλα αν κόπηκε ο ήχος
        onError: (val) => print('onError: $val'),
      );

      if (available) {
        _previousText = _remarksController.text;

        if (_previousText.isNotEmpty && !_previousText.endsWith(" ")) {
          _previousText += " ";
        }

        setState(() => _isListening = true);

        _speech.listen(
          localeId: 'el_GR',
          onResult: (val) =>
              setState(() {
                _remarksController.text = _previousText + val.recognizedWords;
              }),
        );
      } else {
        // Αν δεν υπάρχει άδεια ή αν το μικρόφωνο έχει πρόβλημα!
        setState(() => _isListening = false);
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Δεν δόθηκε άδεια μικροφώνου ή δεν υποστηρίζεται.'),
              backgroundColor: Colors.orange,
              duration: Duration(milliseconds: 1500),
            ),
          );
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

}