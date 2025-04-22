import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled1/globals.dart';

class FeedbackViewPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = darkModeNotifier.value ? Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = darkModeNotifier.value ? Colors.white : Colors.black87;
    final Color cardColor = darkModeNotifier.value ? Color(0xFF2C2C2C) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('feedback')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "Δεν υπάρχει feedback ακόμα.",
                style: TextStyle(color: textColor),
              ),
            );
          }

          final feedbackList = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: feedbackList.length,
            itemBuilder: (context, index) {
              final feedback = feedbackList[index];
              final title = feedback['title'] ?? '';
              final message = feedback['message'] ?? '';
              final username = feedback['username'] ?? '';
              final timestamp = feedback['timestamp']?.toDate();

              return Card(
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        message,
                        style: TextStyle(color: textColor),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Από: $username",
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor.withOpacity(0.7),
                            ),
                          ),
                          if (timestamp != null)
                            Text(
                              "${timestamp.day}/${timestamp.month}/${timestamp.year}",
                              style: TextStyle(
                                fontSize: 12,
                                color: textColor.withOpacity(0.7),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
