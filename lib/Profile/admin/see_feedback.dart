import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled1/globals.dart';

class FeedbackViewPage extends StatefulWidget {
  @override
  _FeedbackViewPageState createState() => _FeedbackViewPageState();
}

class _FeedbackViewPageState extends State<FeedbackViewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  List<DocumentSnapshot> _feedbacks = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _fetchFeedbacks();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _fetchFeedbacks();
      }
    });
  }

  Future<void> _fetchFeedbacks() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    Query query = _firestore
        .collection('feedback')
        .where('checked', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(_limit);

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.length < _limit) {
      _hasMore = false;
    }

    if (snapshot.docs.isNotEmpty) {
      _lastDoc = snapshot.docs.last;
      _feedbacks.addAll(snapshot.docs);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = darkModeNotifier.value ? Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = darkModeNotifier.value ? Colors.white : Colors.black87;
    final Color cardColor = darkModeNotifier.value ? Color(0xFF2C2C2C) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _feedbacks.isEmpty && !_isLoading
          ? Center(
        child: Text(
          "Δεν υπάρχει feedback ακόμα.",
          style: TextStyle(color: textColor),
        ),
      )
          : ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(10),
        itemCount: _feedbacks.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _feedbacks.length) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ));
          }

          final feedback = _feedbacks[index];
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
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Checkbox(
                        value: false,
                        onChanged: (val) async {
                          if (val == true) {
                            await _firestore
                                .collection('feedback')
                                .doc(feedback.id)
                                .update({'checked': true});
                            setState(() {
                              _feedbacks.removeAt(index);
                            });
                          }
                        },
                      ),
                      Text(
                        "Το ειδα",
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
