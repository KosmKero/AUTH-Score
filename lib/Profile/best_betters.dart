import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/globals.dart';

Future<List<Map<String, dynamic>>> getTopUsers() async {
  // Ερώτημα για να πάρεις τους χρήστες με την καλύτερη ακρίβεια (accuracy)
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .orderBy('predictions.accuracy', descending: true) // Ταξινόμηση κατά ακρίβεια
      .limit(20) // Περιορισμός στους πρώτους 20
      .get();

  // Δημιουργία μιας λίστας με τα δεδομένα των χρηστών
  List<Map<String, dynamic>> topUsers = [];

  for (var doc in snapshot.docs) {
    Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
    topUsers.add({
      'uid': doc.id, // Το UID του χρήστη
      'username' : userData['username'],
      'accuracy': userData['predictions']['accuracy'], // Η ακρίβεια του χρήστη
      'correctVotes': userData['predictions']['correctVotes'], // Ο αριθμός των σωστών προβλέψεων
      'totalVotes': userData['predictions']['totalVotes'], // Ο συνολικός αριθμός προβλέψεων
    });
  }

  return topUsers;
}



class TopUsersListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(  // Τοποθετούμε το TopUsersList μέσα σε ένα Scaffold
      appBar: AppBar(
        title: Text('Top 20 Users'),
        backgroundColor: Colors.blueAccent,  // Αλλαγή χρώματος AppBar
      ),
      body: TopUsersList(),  // Το widget που καλεί τη λίστα χρηστών
    );
  }
}

class TopUsersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getTopUsers(), // Αντικαταστήστε με την πραγματική συνάρτηση για την απόκτηση των χρηστών
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No top users found.'));
        }

        final topUsers = snapshot.data!;

        return ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: topUsers.length,
          itemBuilder: (context, index) {
            final user = topUsers[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  '${user['username']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Accuracy: ${user['accuracy'].toStringAsFixed(2)}%',
                      style: TextStyle(color: Colors.green),
                    ),
                    Text(
                      'Correct Votes: ${user['correctVotes']} / ${user['totalVotes']}',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
                trailing: Icon(Icons.star, color: Colors.yellow[700]),
              ),
            );
          },
        );
      },
    );
  }
}

