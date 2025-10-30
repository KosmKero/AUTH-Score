import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';

import '../../ad_manager.dart';
import '../../globals.dart';

class UserBetHistory extends StatefulWidget {
  @override
  State<UserBetHistory> createState() => _UserBetHistoryState();
}

class _UserBetHistoryState extends State<UserBetHistory> {
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
  final backgroundColor = darkModeNotifier.value ? darkModeBackGround : lightModeBackGround;
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Container(
        color: darkModeNotifier.value ? darkModeBackGround : lightModeBackGround ,
        child: Center(
          child: Text(
            "Πρέπει να συνδεθείς για να δεις το ιστορικό σου",
            style: TextStyle(
              color: darkModeNotifier.value ? Colors.white : lightModeText,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: ValueListenableBuilder<bool>(
        valueListenable: darkModeNotifier,
        builder: (context, isDark, _) {
          final backgroundColor =
          isDark ? darkModeBackGround : lightModeBackGround;
          final cardColor = isDark ? darkModeWidgets : lightModeContainer;
          final textColor = isDark ? Colors.white : lightModeText;
          final dateColor = isDark ? Colors.grey[400]! : Colors.grey[700]!;

          return Container(
            color: backgroundColor,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bets')
                  .where('userId', isEqualTo: uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final bets = snapshot.data!.docs;

                if (bets.isEmpty) {
                  return Center(
                    child: Text(
                      "Δεν έχεις ακόμα στοιχήματα",
                      style: TextStyle(color: textColor),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: bets.length,
                  itemBuilder: (context, index) {
                    final bet = bets[index].data() as Map<String, dynamic>;
                    return BetCard(
                      bet: bet,
                      cardColor: cardColor,
                      textColor: textColor,
                      dateColor: dateColor,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
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

class BetCard extends StatelessWidget {
  final Map<String, dynamic> bet;
  final Color cardColor;
  final Color textColor;
  final Color dateColor;

  const BetCard({
    super.key,
    required this.bet,
    required this.cardColor,
    required this.textColor,
    required this.dateColor,
  });

  @override
  Widget build(BuildContext context) {
    final matchInfo = bet['matchInfo'] as Map<String, dynamic>;
    final DateTime startTime = (matchInfo['startTime'] as Timestamp).toDate();
    final status = bet['status'] as String;

    String choice = bet['choice'] == '1'
        ? matchInfo['Hometeam'] ?? ""
        : bet['choice'] == '2'
        ? matchInfo['Awayteam'] ?? ""
        : 'Ισοπαλία';

    // 🎨 Χρώματα status
    Color statusColor;
    String statusText;

    switch (status) {
      case 'won':
        statusColor = Colors.green;
        statusText = "ΚΕΡΔΙΣΜΕΝΟ 🎉";
        break;
      case 'lost':
        statusColor = Colors.red;
        statusText = "ΧΑΜΕΝΟ ❌";
        break;
      default:
        statusColor = Colors.orange;
        statusText = "Εκκρεμεί ⏳";
    }

    final homeTeam = matchInfo['Hometeam'] ?? "";
    final awayTeam = matchInfo['Awayteam'] ?? "";
    final homeScore = matchInfo['GoalHome'];
    final awayScore = matchInfo['GoalAway'];

    return Card(
      color: cardColor,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ομάδες
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  homeTeam,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text("vs", style: TextStyle(fontSize: 16, color: textColor)),
                Text(
                  awayTeam,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Ημερομηνία
            Text(
              "Ημερομηνία: ${DateFormat('dd/MM/yyyy – HH:mm').format(startTime)}",
              style: TextStyle(color: dateColor),
            ),

            // Επιλογή χρήστη + σκορ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Η επιλογή σου: $choice",
                  style: TextStyle(fontSize: 16, color: textColor),
                ),

                if (homeScore != null &&
                    awayScore != null &&
                    (status == "won" || status == "lost"))
                  Container(
                    margin: const EdgeInsets.only(top: 6.0),
                    padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: darkModeNotifier.value
                          ? Colors.black38
                          : Color.fromARGB(60, 40, 90, 95),


                        borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "Σκορ $homeScore - $awayScore",
                      style: TextStyle(
                        fontSize: 14,
                        color: darkModeNotifier.value
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Κατάσταση
            Container(
              padding:
              const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
