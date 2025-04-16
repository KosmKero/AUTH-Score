import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';
import 'package:untitled1/Match_Details_Package/Match_Not_Started/Match_Not_Started_Details_Page.dart';
import 'package:untitled1/Match_Details_Package/Match_Started_Details_Page.dart';
import '../Data_Classes/MatchDetails.dart';
import '../globals.dart';
import '../main.dart';
import 'match_edit_page.dart';

class matchDetailsPage extends StatelessWidget {
  final MatchDetails match;
  const matchDetailsPage(
    this.match, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: match,
      child: _matchDetailsPageView(),
    );
  }
}

class _matchDetailsPageView extends StatelessWidget {
  const _matchDetailsPageView();

  //const MatchDetailsPage({super.key,required this.match});
  //final Match match;

  @override
  Widget build(BuildContext context) {
    final match = Provider.of<MatchDetails>(context);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: darkModeNotifier.value
              ? Color(0xFF121212)
              : Color.fromARGB(50, 5, 150, 200),
          iconTheme: IconThemeData(color: Colors.black87),
          actions: [
            if (!match.hasMatchStarted)
              if (globalUser.controlTheseTeams(
                  match.homeTeam.name, match.awayTeam.name))
                IconButton(
                    onPressed: () {
                      if (!match.hasMatchStarted) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MatchEditPage(
                                      match: match,
                                    )));
                      }
                    },
                    icon: Icon(Icons.edit)),


    // Ελέγχει αν ο χρήστης είναι superuser
            FutureBuilder<bool>(
              future: globalUser.isSuperUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(); // ή δείξε loader
                }

                if (snapshot.hasData && snapshot.data == true) {
                  return IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Επιβεβαίωση διαγραφής'),
                            content: Text(
                              'Είσαι σίγουρος ότι θέλεις να διαγράψεις αυτό το έγγραφο;',
                            ),
                            actions: [
                              TextButton(
                                child: Text('Άκυρο'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('Διαγραφή'),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await TeamsHandle().deleteMatch(match);

                                  navigatorKey.currentState?.pushReplacementNamed('/home');




                                },
                              ),
                            ],
                          );
                        },
                      );


                    },
                  );
                }

                return SizedBox(); // Αν δεν είναι superuser, δεν δείχνει τίποτα
              },
            )

          ]),
      body: matchProgress(match),
    );
  }

  Widget matchProgress(MatchDetails match) {
    if (!match.hasMatchStarted) {
      return MatchNotStartedDetails(
        match: match,
      );
    } else {
      return matchStartedPage(
        match: match,
      );
    }
  }



}
