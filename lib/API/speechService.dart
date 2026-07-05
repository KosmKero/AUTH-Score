import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;

  // Αρχικοποίηση - Ζητάει άδεια από τον χρήστη την πρώτη φορά
  Future<bool> initSpeech() async {
    _isAvailable = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error)   => print('Speech error: $error')  ,
    );
    return _isAvailable;
  }

  // Ξεκινάει να ακούει και επιστρέφει το κείμενο live!
  void startListening(Function(String) onResult) {
    if (_isAvailable) {
      _speech.listen(
        onResult: (result) => onResult(result.recognizedWords),
        localeId: 'el_GR', // Κλειδώνουμε τα Ελληνικά για μέγιστη ακρίβεια
      );
    }
  }

  // Σταματάει να ακούει
  void stopListening() {
    _speech.stop();
  }
}