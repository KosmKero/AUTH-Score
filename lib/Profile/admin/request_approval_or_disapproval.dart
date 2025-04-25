import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled1/globals.dart';

class RequestHandlePage extends StatefulWidget {
  const RequestHandlePage({super.key});

  @override
  _RequestHandlePageState createState() => _RequestHandlePageState();
}

class _RequestHandlePageState extends State<RequestHandlePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _requests = [];
  bool _isLoading = false;

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('requests')
          .where('status', isEqualTo: 'pending')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() => _requests = snapshot.docs);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching requests: $e'),
      ));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    DocumentSnapshot requestSnapshot = await _firestore.collection('requests').doc(requestId).get();

    if (requestSnapshot.exists) {
      String teamName = requestSnapshot['team'];

      await _firestore.collection('requests').doc(requestId).update({'status': status});

      await _firestore
          .collection('users')
          .doc(requestSnapshot['uid'])
          .set({
        'Controlled Teams': FieldValue.arrayUnion([teamName]),
        'role': "admin",
      }, SetOptions(merge: true));

      await _fetchRequests();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Request not found.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = darkModeNotifier.value ? Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = darkModeNotifier.value ? Colors.white : Colors.black87;
    final Color tileColor = darkModeNotifier.value ? Color(0xFF2C2C2C) : Colors.grey[200]!;

    return Container(
      color: backgroundColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ElevatedButton(
              onPressed: _fetchRequests,
              child: Text('Refresh Requests'),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _requests.isEmpty
                ? Center(
              child: Text(
                'No pending requests available.',
                style: TextStyle(color: textColor),
              ),
            )
                : ListView.builder(
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                var request = _requests[index];
                return Card(
                  color: tileColor,
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                      request['name'],
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Username: ${request['username']}', style: TextStyle(color: textColor)),
                        Text('Ομάδα: ${request['team']}', style: TextStyle(color: textColor)),
                        Text('Status: ${request['status']}', style: TextStyle(color: textColor)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            _updateRequestStatus(request.id, 'approved');
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            await _firestore.collection('requests').doc(request.id).update({'status': "rejected"});
                            await _fetchRequests();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
