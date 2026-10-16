import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Data_Classes/basketball/basketMatch.dart';
import 'package:untitled1/globals.dart';
import '../../Firebase_Handle/TeamsHandle.dart';
import 'basketMatchNotStartedPage.dart';

class BettingChooserBasket extends StatefulWidget {
  final BasketMatch match;

  // 💡 ΣΒΗΣΑΜΕ το matchKey! Χρησιμοποιούμε απευθείας το match.matchDocId
  const BettingChooserBasket({
    super.key,
    required this.match,
  });

  @override
  State<BettingChooserBasket> createState() => _BettingChooserBasketState();
}

class _BettingChooserBasketState extends State<BettingChooserBasket> {
  TeamsHandle teamsHandle = TeamsHandle();
  String _selected = '';
  bool hasChosen = false;
  List<num> percentages = [];

  @override
  void initState() {
    super.initState();
    _checkIfUserVoted();
  }

  Future<void> _checkIfUserVoted() async {
    final vote = await getUserVoteFromMatch(match: widget.match);
    if (vote != null && mounted) {
      final loadedPercentages = await teamsHandle.getPercentages(widget.match.matchDocId);

      setState(() {
        hasChosen = true;
        _selected = vote;
        percentages = loadedPercentages;
      });
    }
  }

  void _updateCount(String value) async {
    if (hasChosen) return;

    if (!globalUser.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(greek ? 'Πρέπει να συνδεθείς για να ψηφίσεις!' : 'You must log in to vote!'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    await saveUserVoteToMatch(match: widget.match, choice: value);

    final loadedPercentages = await teamsHandle.getPercentages(widget.match.matchDocId);

    if (mounted) {
      setState(() {
        hasChosen = true;
        _selected = value;
        percentages = loadedPercentages;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          SizedBox(
              width: 320,
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: '1',
                    label: Text(
                      hasChosen && percentages.isNotEmpty ? "${percentages[0].toStringAsFixed(1)}%" : "1",
                      style: const TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ButtonSegment(
                    value: '2',
                    label: Text(
                      hasChosen && percentages.length > 1 ? "${percentages[1].toStringAsFixed(1)}%" : '2',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
                style: ButtonStyle(
                  fixedSize: WidgetStateProperty.all(const Size(540, 50)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                      side: const BorderSide(color: Colors.black, width: 1.5),
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 243, 246, 255)),
                  elevation: WidgetStateProperty.all(3),
                  shadowColor: WidgetStateProperty.all(Colors.black.withOpacity(0.3)),
                ),
                showSelectedIcon: true,
                selected: _selected.isNotEmpty ? {_selected} : <String>{},
                emptySelectionAllowed: true,
                onSelectionChanged: hasChosen
                    ? null
                    : (newSelection) {
                  _updateCount(newSelection.first);
                },
              )),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Future<void> saveUserVoteToMatch({
    required BasketMatch match,
    required String choice,
  }) async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    final docRef = FirebaseFirestore.instance.collection('votes').doc(match.matchDocId);

    await docRef.set({
      'userVotes': {
        currentUserUid: choice,
      }
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance
        .collection('bets')
        .doc('${currentUserUid}_${match.matchDocId}')
        .set({
      'userId': currentUserUid,
      'matchId': match.matchDocId, // ✅ Ασφαλές ID
      'choice': choice,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'matchInfo': {
        'Hometeam': match.homeTeam.name,
        'Awayteam': match.awayTeam.name,
        'homeTeamEnglish': match.homeTeam.nameEnglish,
        'awayTeamEnglish': match.awayTeam.nameEnglish,
        'startTime': match.matchDateTime
      }
    });
  }

  Future<String?> getUserVoteFromMatch({required BasketMatch match}) async {
    final doc = await FirebaseFirestore.instance
        .collection('votes')
        .doc(match.matchDocId) // 💡 Ανάγνωση με το ΑΣΦΑΛΕΣ ID
        .get();

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null && doc.exists) {
      final data = doc.data();
      if (data != null && data['userVotes'] != null) {
        final votes = data['userVotes'] as Map<String, dynamic>;
        final vote = votes[uid] as String?;
        return vote;
      }
    }
    return null;
  }
}