import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/globals.dart';
import '../../Data_Classes/MatchDetails.dart';
import '../../Firebase_Handle/TeamsHandle.dart';
import 'DetailsMatchNotStarted.dart';

class BettingChooser extends StatefulWidget {
  final MatchDetails match;
  late final matchKey;
  BettingChooser({
    super.key,
    required this.match,
  }){
    matchKey = '${match.homeTeam.nameEnglish}${match.awayTeam.nameEnglish}${match.dateString}';
  }

  @override
  State<BettingChooser> createState() => _BettingChooserState();
}

class _BettingChooserState extends State<BettingChooser> {
  TeamsHandle teamsHandle = TeamsHandle();
  String _selected = '';
  bool hasChosen = false;
  List<num> percentages = [];

  @override
  void initState() {
    super.initState();
    _checkIfUserVoted();
  }

  bool _isVotingOpen() {
    int nowInSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int lockTime = widget.match.matchDateTime2.millisecondsSinceEpoch ~/ 1000;  //15 λεπτα μετα την ωρα του ματς
    return nowInSeconds < lockTime && !widget.match.hasMatchStarted;
  }

  Future<void> _checkIfUserVoted() async {
    final vote = await getUserVoteFromMatch(match: widget.match);
    bool votingOpen = _isVotingOpen();

    if (vote != null && mounted) {
      final loadedPercentages = await loadPercentages(widget.match);
      setState(() {
        hasChosen = true;
        _selected = vote;
        percentages = loadedPercentages;
      });
    } else if (!votingOpen && mounted) {
      final loadedPercentages = await loadPercentages(widget.match);
      setState(() {
        percentages = loadedPercentages;
      });
    }
  }

  void _updateCount(String value) async {
    // Αν έχει ψηφίσει ή έχουν κλείσει οι προβλέψεις, αγνόησε το πάτημα
    if (hasChosen || !_isVotingOpen()) return;

    if (!globalUser.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Πρέπει να συνδεθείς για να ψηφίσεις!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _selected = value;
      hasChosen = true;
    });

    try {
      // Στέλνουμε τα δεδομένα στο Firebase
      await saveUserVoteToMatch(match: widget.match, choice: value);

      // Φορτώνουμε τα νέα ποσοστά
      final loadedPercentages = await loadPercentages(widget.match);

      if (mounted) {
        setState(() {
          percentages = loadedPercentages;
        });
      }
    } on FirebaseException catch (e) {
      // GRACEFUL ERROR HANDLING: Πιάνουμε το Rule του Firebase
      if (e.code == 'permission-denied') {
        if (mounted) {
          setState(() {
            _selected = ''; // Αναιρούμε την επιλογή στο UI
            hasChosen = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Οι προβλέψεις για αυτόν τον αγώνα έχουν κλείσει 🔒'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      // Αν πέσει το ίντερνετ
      if (mounted) {
        setState(() {
          _selected = '';
          hasChosen = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Σφάλμα σύνδεσης. Η ψήφος δεν αποθηκεύτηκε.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool votingOpen = _isVotingOpen();

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
                      (hasChosen || !votingOpen) && percentages.isNotEmpty ? "${percentages[0].toStringAsFixed(0)}%" : "1",
                      style: const TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ButtonSegment(
                    value: 'X',
                    label: Text(
                      (hasChosen || !votingOpen) && percentages.isNotEmpty ? "${percentages[2].toStringAsFixed(0)}%" : 'X',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  ButtonSegment(
                    value: '2',
                    label: Text(
                      (hasChosen || !votingOpen) && percentages.isNotEmpty ? "${percentages[1].toStringAsFixed(0)}%" : '2',
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
                  backgroundColor:
                  WidgetStateProperty.all(const Color.fromARGB(255, 243, 246, 255)),
                  elevation: WidgetStateProperty.all(3),
                  shadowColor: WidgetStateProperty.all(Colors.black.withOpacity(0.3)),
                ),
                showSelectedIcon: true,
                selected: _selected.isNotEmpty ? {_selected} : <String>{},
                emptySelectionAllowed: true,
                // Απενεργοποίηση του κουμπιού αν έχει ψηφίσει ή αν έκλεισαν οι προβλέψεις
                onSelectionChanged: (hasChosen || !votingOpen)
                    ? null
                    : (newSelection) {
                  _updateCount(newSelection.first);
                },
              )
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Future<void> saveUserVoteToMatch({
    required MatchDetails match,
    required String choice,
  }) async {
    final docRef = FirebaseFirestore.instance.collection('votes').doc(widget.matchKey);

    await docRef.set({
      'userVotes': {
        FirebaseAuth.instance.currentUser!.uid: choice,
      }
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection('bets').doc('${FirebaseAuth.instance.currentUser!.uid}_${widget.matchKey}').set({
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'matchId': widget.matchKey,
      'choice': choice,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'matchInfo': {
        'Hometeam': match.homeTeam.name,
        'Awayteam': match.awayTeam.name,
        'homeTeamEnglish': match.homeTeam.nameEnglish,
        'awayTeamEnglish': match.awayTeam.nameEnglish,
        'startTime': match.matchDateTime2
      }
    });
  }

  Future<String?> getUserVoteFromMatch({required MatchDetails match}) async {
    final doc = await FirebaseFirestore.instance
        .collection('votes')
        .doc(widget.matchKey)
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