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
   matchKey = '${match.homeTeam.name}${match.awayTeam.name}${match.dateString}';
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
  Future<void> _checkIfUserVoted() async {
    final vote = await getUserVoteFromMatch(match: widget.match);
    if (vote != null && mounted) {
      // Φόρτωσε τα ποσοστά και όχι μόνο την επιλογή
      final loadedPercentages = await loadPercentages(
        widget.match.homeTeam.name,
        widget.match.awayTeam.name,
        vote,
      );
      setState(() {
        hasChosen = true;
        _selected = vote;
        percentages = loadedPercentages;
      });
    }
  }


  void _updateCount(String value) async {
    if (hasChosen) return; // Επιστρέφει αν ο χρήστης έχει ήδη επιλέξει.

    if (!globalUser.isLoggedIn) {
      // Εμφάνιση του snackbar αν ο χρήστης δεν είναι συνδεδεμένος.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Πρέπει να συνδεθείς για να ψηφίσεις!'),
          duration: Duration(seconds: 2),
        ),
      );
      return; // Επιστρέφει χωρίς να αποθηκεύσει την ψήφο αν ο χρήστης δεν είναι συνδεδεμένος.
    }

    await saveUserVoteToMatch(match: widget.match, choice: value);

    final loadedPercentages = await loadPercentages(
      widget.match.homeTeam.name,
      widget.match.awayTeam.name,
      value,
    );

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
      padding: EdgeInsets.only(right: 10),
      child: Column(
        children: [
          SizedBox(
            width: 320,
            child:SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: '1',
                  label: Text(
                    hasChosen && percentages.isNotEmpty ? percentages[0].toStringAsFixed(2) : "1",
                    style: TextStyle(fontSize: 15),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ButtonSegment(
                  value: 'X',
                  label: Text(
                    hasChosen && percentages.isNotEmpty ? percentages[2].toStringAsFixed(2) : 'X',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                ButtonSegment(
                  value: '2',
                  label: Text(
                    hasChosen && percentages.isNotEmpty ? percentages[1].toStringAsFixed(2) : '2',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
              style: ButtonStyle(
                fixedSize: WidgetStateProperty.all(Size(540, 50)),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                    side: BorderSide(color: Colors.black, width: 1.5),
                  ),
                ),
                backgroundColor:
                WidgetStateProperty.all(Color.fromARGB(255, 243, 246, 255)),
              ),
              showSelectedIcon: true,
              selected: _selected.isNotEmpty ? {_selected} : <String>{},
              emptySelectionAllowed: true,
              onSelectionChanged: hasChosen
                  ? null
                  : (newSelection) {
                _updateCount(newSelection.first);
              },
            )




          ),
          SizedBox(height: 10),
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
  }

  Future<String?> getUserVoteFromMatch({required MatchDetails match}) async {
    final doc = await FirebaseFirestore.instance
        .collection('votes')
        .doc(widget.matchKey)
        .get();

    print('Match key: ${widget.matchKey}');
    print('Full doc: ${doc.data()}');

    final uid = FirebaseAuth.instance.currentUser?.uid;
    print('Current UID: $uid');

    if (uid != null && doc.exists) {
      final data = doc.data();
      if (data != null && data['userVotes'] != null) {
        final votes = data['userVotes'] as Map<String, dynamic>;
        print('All userVotes: $votes');
        final vote = votes[uid] as String?;
        print('Vote for current user: $vote');
        return vote;
      }
    }

    print('problem');
    return null;
  }

}
