import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:untitled1/globals.dart';

import '../Firebase_Handle/firebase_screen_stats_helper.dart';
import '../ad_manager.dart';

Future<List<Map<String, dynamic>>> getTopUsers() async {
  // Λήψη του leaderboard από το συγκεκριμένο έγγραφο
  DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('leaderboard')
      .doc('top20')
      .get();

  if (!snapshot.exists || snapshot.data() == null) {
    return [];
  }

  final data = snapshot.data() as Map<String, dynamic>;
  final List<dynamic> users = data['users'] ?? [];

  // Μετατροπή σε σωστό format
  return users.map<Map<String, dynamic>>((user) => {
    'uid': user['uid'],
    'username': user['username'] ?? 'Unknown',
    'accuracy': user['accuracy'],
    'correctVotes': user['correctVotes'],
    'totalVotes': user['totalVotes'],
    'score': user['score'],
  }).toList();
}


class TopUsersList extends StatefulWidget {

  @override
  State<TopUsersList> createState() => _TopUsersListState();
}

class _TopUsersListState extends State<TopUsersList> {
  BannerAd? _bannerAd;

  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = AdManager.createBannerAd(
      onStatusChanged: (status) {
        setState(() {
          _isBannerAdReady = status;
        });
      },
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Top 20 betters',screenClass: 'Top 20 betters');
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
                final score1 = predictions['score'] ?? 0;
                final score = score1.round();

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
                        style: TextStyle(color: darkModeNotifier.value ? Colors.white: Color(0xFF1E1E1E ) ,fontWeight: FontWeight.bold,fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Score: $score',
                            style: TextStyle(color: darkModeNotifier.value ? Colors.white: Color(0xFF1E1E1E ),fontSize: 15 ,)),
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
                            style: TextStyle(color: darkModeNotifier.value ? Colors.white: Color(0xFF1E1E1E ) ,fontWeight: FontWeight.bold,fontSize: 16)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Score: ${(user['score']).round()}',
                                style: TextStyle(color: darkModeNotifier.value ? Colors.white: Color(0xFF1E1E1E ), fontSize: 15)),
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
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min, // Για να μην γεμίζει όλη την οθόνη
        children: [
          if (_isBannerAdReady && _bannerAd != null)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}
