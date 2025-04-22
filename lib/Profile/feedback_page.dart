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

    if (title.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Συμπλήρωσε και τον τίτλο και το μήνυμα.')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await _firestore.collection('feedback').add({
        'title': title,
        'message': message,
        'username': globalUser.username,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _titleController.clear();
      _messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ευχαριστούμε για το feedback σου!')),
      );
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
    return Scaffold(
      appBar: AppBar(title: Text("Αποστολή Feedback")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Τίτλος",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Μήνυμα",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isSending ? null : submitFeedback,
              icon: Icon(Icons.send),
              label: Text("Αποστολή"),
            ),
          ],
        ),
      ),
    );
  }
}
