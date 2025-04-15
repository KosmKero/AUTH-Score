import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestHandlePage extends StatefulWidget {
  const RequestHandlePage({super.key});

  @override
  _RequestHandlePageState createState() => _RequestHandlePageState();
}

class _RequestHandlePageState extends State<RequestHandlePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _requests = []; // Αποθήκευση των αιτημάτων
  bool _isLoading = false; // Κατάσταση φόρτωσης

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true; // Ενεργοποιούμε την κατάσταση φόρτωσης
    });

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('requests')
          .where('status', isEqualTo: 'pending')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _requests = snapshot.docs; // Αποθήκευση των δεδομένων
      });
    } catch (e) {
      // Διαχείριση σφάλματος
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching requests: $e'),
      ));
    } finally {
      setState(() {
        _isLoading = false; // Απενεργοποιούμε την κατάσταση φόρτωσης
      });
    }
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    // Ανακτούμε το αίτημα για να πάρουμε την ομάδα
    DocumentSnapshot requestSnapshot = await _firestore.collection('requests').doc(requestId).get();

    // Βεβαιωνόμαστε ότι το αίτημα υπάρχει
    if (requestSnapshot.exists) {
      String teamName = requestSnapshot['team']; // Υποθέτουμε ότι η ομάδα αποθηκεύεται με το κλειδί 'group'

      // Ενημέρωση της κατάστασης του αιτήματος
      await _firestore.collection('requests').doc(requestId).update({'status': status});

      // Προσθήκη της ομάδας στο έγγραφο του χρήστη
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(
          {'Controlled Teams': FieldValue.arrayUnion([teamName]),
            'role':"admin"}, // Προσθέτουμε την ομάδα στο array
          SetOptions(merge: true) // Χρησιμοποιούμε merge για να κρατήσουμε τα υπάρχοντα δεδομένα
      );

      // Κλήση για ανανέωση των αιτημάτων μετά την ενημέρωση
      await _fetchRequests();
    } else {
      // Διαχείριση σφάλματος αν το αίτημα δεν βρέθηκε
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Request not found.'),
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          ElevatedButton(
            onPressed: _fetchRequests,
            child: Text('Refresh Requests'),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator()) // Εμφάνιση κύκλου φόρτωσης
                : _requests.isEmpty
                ? Center(child: Text('No pending requests available.')) // Μήνυμα αν δεν υπάρχουν αιτήματα
                : ListView.builder(
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                var request = _requests[index];
                return ListTile(
                  title: Text(request['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${request['status']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () {
                          setState(() {
                            _updateRequestStatus(request.id, 'approved');
                          });

                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () async {
                          await _firestore.collection('requests').doc(request.id).update({'status': "rejected"});
                          await _fetchRequests();
                          setState(()  {
                          });

                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
    );
  }
}
