import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled1/globals.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitFeedback() async {
    String title = _titleController.text.trim();
    String message = _messageController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Συμπλήρωσε και τον τίτλο και το μήνυμα.')),
      );
      return;
    } else if (message.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Παρακαλώ γράψε τουλάχιστον 5 χαρακτήρες.')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final docId =
          '${globalUser.username}_${DateTime.now().millisecondsSinceEpoch}';

      await _firestore.collection('feedback').doc(docId).set({
        'title': title,
        'message': message,
        'username': globalUser.username,
        'timestamp': FieldValue.serverTimestamp(),
        'checked': false
      });

      _titleController.clear();
      _messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ευχαριστούμε για το feedback σου!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Σφάλμα κατά την αποστολή')),
      );
    }

    setState(() {
      _isSending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final inputBorderColor = darkModeNotifier.value ? Colors.white70 : Colors.grey;

    final textColor = darkModeNotifier.value ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: Text("Αποστολή Feedback"),
        backgroundColor: darkModeNotifier.value ? Colors.black : null,
        foregroundColor: darkModeNotifier.value ? Colors.white : null,
      ),
      backgroundColor: darkModeNotifier.value ? Color(0xFF121212) : Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: "Τίτλος",
                labelStyle: TextStyle(color: textColor),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: inputBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: inputBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _messageController,
              maxLines: 5,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: "Μήνυμα",
                labelStyle: TextStyle(color: textColor),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: inputBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: inputBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isSending ? null : submitFeedback,
              icon: Icon(Icons.send),
              label: Text("Αποστολή"),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkModeNotifier.value ? Colors.blue[800] : Colors.blueGrey,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
