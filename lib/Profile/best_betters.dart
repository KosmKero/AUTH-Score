import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/globals.dart';

Future<List<Map<String, dynamic>>> getTopUsers() async {
  // Query to get the top users ordered by accuracy
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .orderBy('predictions.accuracy', descending: true) // Sort by accuracy
      .limit(20) // Limit to the top 20
      .get();

  List<Map<String, dynamic>> topUsers = [];

  for (var doc in snapshot.docs) {
    Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
    topUsers.add({
      'uid': doc.id, // User's UID
      'username': userData['username'],
      'accuracy': userData['predictions']['accuracy'], // User's accuracy
      'correctVotes': userData['predictions']
          ['correctVotes'], // Correct votes count
      'totalVotes': userData['predictions']['totalVotes'], // Total votes count
    });
  }

  return topUsers;
}

class TopUsersList extends StatelessWidget {
  const TopUsersList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          darkModeNotifier.value ? Color(0xFF121212) : lightModeBackGround,
      appBar: AppBar(
          title: Text("Top 20 tipsters", style: TextStyle(color: Colors.white)),
          backgroundColor: darkModeNotifier.value
              ? const Color(0xFF121212)
              : const Color.fromARGB(250, 46, 90, 136),
          iconTheme: IconThemeData(
            color: Colors.white,
          )),
      body: Column(
        children: [
          // FutureBuilder για τον current user (αν είναι συνδεδεμένος)
          if (FirebaseAuth.instance.currentUser != null)
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError) {
                  return Center(child: Text('Error fetching user data'));
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return Center(child: Text('User data not found'));
                }

                final data = userSnapshot.data!.data() as Map<String, dynamic>;
                final predictions = data['predictions'] ?? {};
                final accuracy = predictions['accuracy'] ?? 0.0;
                final correct = predictions['correctVotes'] ?? 0;
                final total = predictions['totalVotes'] ?? 0;

                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: darkModeNotifier.value ? Color(0xFF1E1E1E ) : Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text('Your Stats',
                        style: TextStyle(color: darkModeNotifier.value ? Colors.white: Color(0xFF1E1E1E ) ,fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Accuracy: ${accuracy.toStringAsFixed(2)}%',
                            style: TextStyle(color: Colors.green)),
                        Text('Correct Votes: $correct / $total',
                            style: TextStyle(color: darkModeNotifier.value ? Colors.white: Color(0xFF1E1E1E ) )),
                      ],
                    ),
                    trailing: Icon(Icons.star, color: Colors.yellow[700]),
                  ),
                );
              },
            ),

          if (FirebaseAuth.instance.currentUser != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Divider(
                color: !darkModeNotifier.value ? Color(0xFF1E1E1E ) : Colors.grey,
              ),
            ),
          // FutureBuilder για τη λίστα με τους top users
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: getTopUsers(),
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
                final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

                return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  itemCount: topUsers.length,
                  itemBuilder: (context, index) {
                    final user = topUsers[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: darkModeNotifier.value ? Color(0xFF1E1E1E ) : Colors.white,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Text('${index + 1}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        title: Text('${user['username']}',
                            style: TextStyle(color: darkModeNotifier.value ? Colors.white: Color(0xFF1E1E1E ) ,fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Accuracy: ${user['accuracy'].toStringAsFixed(2)}%',
                                style: TextStyle(color: Colors.green)),
                            Text(
                                'Correct Votes: ${user['correctVotes']} / ${user['totalVotes']}',
                                style: TextStyle(color: darkModeNotifier.value ? Colors.white: Color(0xFF1E1E1E ) ,)),
                          ],
                        ),
                        trailing: Icon(Icons.star, color: Colors.yellow[700]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
