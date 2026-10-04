import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled1/globals.dart';
import '../../Firebase_Handle/firebase_screen_stats_helper.dart';
// import '../../ad_manager.dart'; // Αν το χρειάζεσαι

// Helper για να φτιάξουμε ένα όμορφο όνομα από το docId
String formatDocIdToDisplay(String docId, bool isGreek) {
  if (docId == 'top20') return isGreek ? 'Γενική' : 'All-Time';
  final parts = docId.replaceFirst('top20_', '').split('_');

  if (parts.length == 1) {
    return isGreek ? 'Έτος ${parts[0]}' : 'Year ${parts[0]}';
  } else if (parts.length == 2) {
    final year = parts[0];
    final month = int.tryParse(parts[1]) ?? 1;

    Map<int, String> greekMonths = {
      1: "Ιαν", 2: "Φεβ", 3: "Μαρ", 4: "Απρ",
      5: "Μαϊ", 6: "Ιουν", 7: "Ιουλ", 8: "Αυγ",
      9: "Σεπ", 10: "Οκτ", 11: "Νοε", 12: "Δεκ"
    };
    Map<int, String> englishMonths = {
      1: "Jan", 2: "Feb", 3: "Mar", 4: "Apr",
      5: "May", 6: "Jun", 7: "Jul", 8: "Aug",
      9: "Sep", 10: "Oct", 11: "Nov", 12: "Dec"
    };

    String monthName = isGreek ? greekMonths[month]! : englishMonths[month]!;
    return "$monthName '${year.substring(2)}"; // π.χ. Σεπ '24
  }
  return docId;
}

Future<List<Map<String, dynamic>>> getTopUsers(String docId) async {
  DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('leaderboard')
      .doc(docId)
      .get();

  if (!snapshot.exists || snapshot.data() == null) return [];

  final data = snapshot.data() as Map<String, dynamic>;
  final List<dynamic> users = data['users'] ?? [];

  return users.map<Map<String, dynamic>>((user) => {
    'uid': user['uid'],
    'username': user['username'] ?? 'Unknown',
    'accuracy': (user['accuracy'] ?? 0.0).toDouble(),
    'correctVotes': user['correctVotes'] ?? 0,
    'totalVotes': user['totalVotes'] ?? 0,
    'score': (user['score'] ?? 0.0).toDouble(),
  }).toList();
}

class TopUsersList extends StatefulWidget {
  @override
  State<TopUsersList> createState() => _TopUsersListState();
}

class _TopUsersListState extends State<TopUsersList> {
  // Κατηγορίες: 0 = Γενική, 1 = Ετήσια, 2 = Μηνιαία
  int selectedCategory = 0;

  List<String> yearlyDocs = [];
  List<String> monthlyDocs = [];

  String selectedYearlyDoc = '';
  String selectedMonthlyDoc = '';

  bool isLoadingDocs = true;

  @override
  void initState() {
    super.initState();
    _fetchAvailableLeaderboards();
  }

  Future<void> _fetchAvailableLeaderboards() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('leaderboard').get();

      List<String> yDocs = [];
      List<String> mDocs = [];

      for (var doc in snapshot.docs) {
        String id = doc.id;
        if (id == 'top20') continue; // Γενική, το ξέρουμε

        final parts = id.replaceFirst('top20_', '').split('_');
        if (parts.length == 1) {
          yDocs.add(id);
        } else if (parts.length == 2) {
          mDocs.add(id);
        }
      }

      // Ταξινόμηση Φθίνουσα (Τα πιο πρόσφατα πρώτα)
      yDocs.sort((a, b) => b.compareTo(a));
      mDocs.sort((a, b) => b.compareTo(a));

      if (mounted) {
        setState(() {
          yearlyDocs = yDocs;
          monthlyDocs = mDocs;
          if (yearlyDocs.isNotEmpty) selectedYearlyDoc = yearlyDocs.first;
          if (monthlyDocs.isNotEmpty) selectedMonthlyDoc = monthlyDocs.first;
          isLoadingDocs = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingDocs = false);
    }
  }

  // Υπολογίζει ποιο έγγραφο πρέπει να διαβαστεί από τη βάση
  String get activeDocId {
    if (selectedCategory == 0) return 'top20';
    if (selectedCategory == 1 && yearlyDocs.isNotEmpty) return selectedYearlyDoc;
    if (selectedCategory == 2 && monthlyDocs.isNotEmpty) return selectedMonthlyDoc;
    return 'top20'; // Fallback
  }

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Top 20 betters', screenClass: 'Top 20 betters');

    final isDark = darkModeNotifier.value;
    final backgroundColor = isDark ? darkModeBackGround : lightModeBackGround;
    final cardColor = isDark ? darkModeWidgets : lightModeContainer;
    final textColor = isDark ? Colors.grey[200]! : lightModeText;
    final secondaryTextColor = isDark ? darkModeText : Colors.grey[700]!;

    final selectedChipBg = isDark ? const Color(0xFFBB86FC) : const Color(0xFF2E5A88);
    final selectedChipText = Colors.white;
    final unselectedChipBg = isDark ? Colors.grey[800] : Colors.grey[300];
    final unselectedChipText = isDark ? Colors.grey[400] : Colors.grey[800];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          const SizedBox(height: 10),

          if (isLoadingDocs)
            const Center(child: CircularProgressIndicator())
          else ...[
            // === ΕΠΙΠΕΔΟ 1: Βασικές Κατηγορίες ===
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCategoryChip(0, greek ? 'Γενική' : 'All-Time', selectedChipBg, selectedChipText, unselectedChipBg!, unselectedChipText!),
                if (monthlyDocs.isNotEmpty)
                  _buildCategoryChip(2, greek ? 'Μηνιαία' : 'Monthly', selectedChipBg, selectedChipText, unselectedChipBg, unselectedChipText),
              ],
            ),

            // === ΕΠΙΠΕΔΟ 2: Υποκατηγορίες (Μόνο αν επιλεχθεί Ετήσια ή Μηνιαία) ===
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: selectedCategory == 0 ? 0 : 50, // Κρύβεται στη "Γενική"
              child: selectedCategory == 1 && yearlyDocs.isNotEmpty
                  ? _buildSubCategoryList(yearlyDocs, selectedYearlyDoc, (val) => setState(() => selectedYearlyDoc = val), selectedChipBg, selectedChipText, unselectedChipBg, unselectedChipText)
                  : selectedCategory == 2 && monthlyDocs.isNotEmpty
                  ? _buildSubCategoryList(monthlyDocs, selectedMonthlyDoc, (val) => setState(() => selectedMonthlyDoc = val), selectedChipBg, selectedChipText, unselectedChipBg, unselectedChipText)
                  : const SizedBox.shrink(),
            ),
          ],

          const SizedBox(height: 5),

          // User Stats Card
          if (FirebaseAuth.instance.currentUser != null)
            _buildUserStatsCard(activeDocId, cardColor, textColor, secondaryTextColor),

          if (FirebaseAuth.instance.currentUser != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Divider(color: isDark ? Colors.grey : lightModeContainer),
            ),

          // Top Users List
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              // Φορτώνει ΔΥΝΑΜΙΚΑ με βάση την επιλογή
              future: getTopUsers(activeDocId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(greek ? "Δεν υπάρχουν δεδομένα." : "No data available.", style: TextStyle(color: textColor)));
                }

                final topUsers = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  itemCount: topUsers.length,
                  itemBuilder: (context, index) {
                    final user = topUsers[index];

                  // // Ειδικό χρωματάκι για τους Top 3
                   Color avatarColor = Colors.blueAccent;
                   if (index == 0) avatarColor = Colors.amber;
                   if (index == 1) avatarColor = Colors.grey[400]!;
                   if (index == 2) avatarColor = Colors.brown[300]!;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: cardColor,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: avatarColor,
                          child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        title: Text('${user['username']}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Score: ${(user['score']).round()}', style: TextStyle(color: textColor, fontSize: 15)),
                            Text('Accuracy: ${user['accuracy'].toStringAsFixed(2)}%', style: const TextStyle(color: Colors.green)),
                            Text('Correct Votes: ${user['correctVotes']} / ${user['totalVotes']}', style: TextStyle(color: secondaryTextColor)),
                          ],
                        ),
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

  // --- Widgets Helpers ---

  Widget _buildCategoryChip(int index, String title, Color activeBg, Color activeText, Color inactiveBg, Color inactiveText) {
    bool isSelected = selectedCategory == index;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? activeText : inactiveText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategoryList(List<String> docs, String selectedDoc, Function(String) onSelect, Color activeBg, Color activeText, Color inactiveBg, Color inactiveText) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final docId = docs[index];
        final isSelected = docId == selectedDoc;

        return GestureDetector(
          onTap: () => onSelect(docId),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? activeBg.withOpacity(0.8) : Colors.transparent,
              border: Border.all(color: isSelected ? activeBg : inactiveBg),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                formatDocIdToDisplay(docId, greek),
                style: TextStyle(
                  color: isSelected ? activeText : inactiveText,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserStatsCard(String docId, Color cardColor, Color textColor, Color secondaryTextColor) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) return const SizedBox.shrink();

        final data = userSnapshot.data!.data() as Map<String, dynamic>;
        double accuracy = 0.0;
        int correct = 0, total = 0;
        double rawScore = 0.0;

        if (docId == 'top20') {
          final predictions = data['predictions'] ?? {};
          accuracy = (predictions['accuracy'] ?? 0.0).toDouble();
          correct = predictions['correctVotes'] ?? 0;
          total = predictions['totalVotes'] ?? 0;
          rawScore = (predictions['score'] ?? 0).toDouble();
        } else {
          String periodKey = docId.replaceFirst('top20_', '');
          if (periodKey.contains('_')) { // Μηνιαία
            final monthlyStats = data['monthlyStats'] ?? {};
            final currentStats = monthlyStats[periodKey] ?? {};
            correct = currentStats['correctVotes'] ?? 0;
            total = currentStats['totalVotes'] ?? 0;
            rawScore = (currentStats['score'] ?? 0).toDouble();
          } else { // Ετήσια
            final yearlyStats = data['yearlyStats'] ?? {};
            final currentStats = yearlyStats[periodKey] ?? {};
            correct = currentStats['correctVotes'] ?? 0;
            total = currentStats['totalVotes'] ?? 0;
            rawScore = (currentStats['score'] ?? 0).toDouble();
          }
          accuracy = total > 0 ? (correct / total) * 100 : 0.0;
        }

        final displayTitle = formatDocIdToDisplay(docId, greek);
        final titleText = greek ? 'Τα στατιστικά σου ($displayTitle)' : 'Your Stats ($displayTitle)';

        return Card(
          margin: const EdgeInsets.all(10),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          color: cardColor,
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.person, color: Colors.white)),
            title: Text(titleText, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Score: ${rawScore.round()}', style: TextStyle(color: textColor, fontSize: 15)),
                Text('Accuracy: ${accuracy.toStringAsFixed(2)}%', style: const TextStyle(color: Colors.green)),
                Text('Correct Votes: $correct / $total', style: TextStyle(color: secondaryTextColor)),
              ],
            ),
          ),
        );
      },
    );
  }
}