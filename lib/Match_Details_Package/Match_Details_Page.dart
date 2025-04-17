import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';
import 'package:untitled1/Match_Details_Package/Match_Not_Started/Match_Not_Started_Details_Page.dart';
import 'package:untitled1/Match_Details_Package/Match_Started_Details_Page.dart';
import '../Data_Classes/MatchDetails.dart';
import '../globals.dart';
import 'match_edit_page.dart';

class matchDetailsPage extends StatelessWidget {
  final MatchDetails match;
  const matchDetailsPage(this.match, {Key? key,}): super(key: key);


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
        backgroundColor:darkModeNotifier.value?Colors.grey[900]: Color.fromARGB(50, 5, 150, 200),
        iconTheme: IconThemeData(color: darkModeNotifier.value?Colors.white:Colors.black),
        actions: [
          if (!match.hasMatchStarted)
            if (globalUser.controlTheseTeams(match.homeTeam.name, match.awayTeam.name))
              IconButton(onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MatchEditPage(match: match,),
                    ));
              }, icon: Icon(Icons.edit)),

          FutureBuilder<bool>(
            future: globalUser.isSuperUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(); // ή CircularProgressIndicator()
              }
              if (snapshot.hasData && snapshot.data == true) {
                return IconButton(
                  onPressed: () async {
                    bool? confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Επιβεβαίωση'),
                        content: Text('Είσαι σίγουρος ότι θέλεις να επεξεργαστείς τον αγώνα;'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Ακύρωση'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Ναι'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      TeamsHandle().deleteMatch(match);
                    }
                  },
                  icon: Icon(Icons.delete),
                );
              } else {
                return SizedBox(); // δεν δείχνει τίποτα αν δεν είναι super user
              }
            },
          ),



        ],
      ),
      body: matchProgress(match),


    );
  }

  Widget matchProgress(MatchDetails match){
    if (!match.hasMatchStarted) {
      return MatchNotStartedDetails(match: match,);
    }
    else {
      return matchStartedPage(match: match,);
    }
  }
}
