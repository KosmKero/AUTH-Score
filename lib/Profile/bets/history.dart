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
    final status = (bet['status'] ?? 'pending') as String;


    String choice = bet['choice'] == '1'
        ? matchInfo['Hometeam'] ?? ""
        : bet['choice'] == '2'
        ? matchInfo['Awayteam'] ?? ""
        : 'Ισοπαλία';

    // 🎨 Χρώματα status
    Color statusColor;
    String statusText;

    // COLORS
    const Color wonLight = Color(0xFF2E7D32);
    const Color wonDark  = Color(0xFF66BB6A);

    const Color lostLight = Color(0xFFC62828);
    const Color lostDark  = Color(0xFFEF5350);

    const Color cancelledLight = Color(0xFF616161); // grey 700
    const Color cancelledDark  = Color(0xFFBDBDBD); // grey 400




    const Color pendingLight = Color(0xFFF57C00);
    const Color pendingDark  = Color(0xFFFFB74D);

// LOGIC
    final isDark = darkModeNotifier.value;

    switch (status) {
      case 'won':
        statusColor = isDark ? wonDark : wonLight;
        statusText = "ΚΕΡΔΙΣΜΕΝΟ 🎉";
        break;

      case 'lost':
        statusColor = isDark ? lostDark : lostLight;
        statusText = "ΧΑΜΕΝΟ ❌";
        break;

      case 'cancelled':
        statusColor = isDark ? cancelledDark : cancelledLight;
        statusText = "ΑΚΥΡΩΘΗΚΕ 🚫";
        break;

      default:
        statusColor = isDark ? pendingDark : pendingLight;
        statusText = "ΕΚΚΡΕΜΕΙ ⏳";
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
                Flexible(
                  child: Text(
                    homeTeam,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                Text("vs", style: TextStyle(fontSize: 16, color: textColor)),
                Flexible(
                  child: Text(
                    awayTeam,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
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
              Expanded(
                child: RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Η επιλογή σου: ",
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                      TextSpan(
                        text: choice,
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),


              if (homeScore != null &&
                  awayScore != null &&
                  (status == "won" || status == "lost"))
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 6),
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: darkModeNotifier.value
                        ? Colors.black38
                        : const Color.fromARGB(60, 40, 90, 95),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "Σκορ $homeScore - $awayScore",
                    style: TextStyle(
                      fontSize: 14,
                      color: darkModeNotifier.value ? Colors.white : Colors.black,
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
