import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/Data_Classes/basketball/basketMatch.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';
import 'package:untitled1/Match_Details_Package/Match_Not_Started/Match_Not_Started_Details_Page.dart';
import 'package:untitled1/Match_Details_Package/Match_Started_Details_Page.dart';
import '../Data_Classes/MatchDetails.dart';
import '../Match_Details_Package/bracketEditPage.dart';
import '../ad_manager.dart';
import '../globals.dart';
import 'basketMatchNotStarted/basketMatchNotStartedPage.dart';
import 'basketMatchNotStarted/basketMatchUpperBody.dart';
import 'basket_match_started.dart';


class basketMatchDetailsPage extends StatelessWidget {
  final BasketMatch match;
  const basketMatchDetailsPage(this.match, {Key? key,}): super(key: key);




  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: match,
      child: _matchDetailsPageView(),
    );
  }
}

class _matchDetailsPageView extends StatefulWidget {
  const _matchDetailsPageView();

  @override
  State<_matchDetailsPageView> createState() => _matchDetailsPageViewState();
}

class _matchDetailsPageViewState extends State<_matchDetailsPageView> {


  @override
  Widget build(BuildContext context) {
    final match = Provider.of<BasketMatch>(context);
    return Scaffold(
      backgroundColor: darkModeNotifier.value ? Color.fromARGB(255, 30, 30, 30) : Colors.white,
      appBar: AppBar(
        backgroundColor:darkModeNotifier.value?Colors.grey[900]: Color.fromARGB(50, 5, 150, 200),
        iconTheme: IconThemeData(color: darkModeNotifier.value?Colors.white:Colors.black),
        actions: [
          if (!match.hasMatchStarted)
            if (true)
              IconButton(onPressed: () async {
               //await Navigator.push(
               //    context,
               //    MaterialPageRoute(
               //      builder: (context) => MatchEditPage(match: match,),
               //    ));
              }, icon: Icon(Icons.edit)),

          // Απλό IF! Δεν χρειαζόμαστε πια το FutureBuilder!
          if (globalUser.isSuperUser)
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    //    await showDialog(
                    //      context: context,
                    //      builder: (context) => SlotPickerDialog(
                    //        match: match,
                    //        phase: match.game,
                    //        maxSlots: (match.game / 2).toInt(),
                    //      ),
                    //    );
                  },
                  icon: Icon(Icons.edit_road),
                ),

                IconButton(
                  onPressed: () async {
                    bool? confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Επιβεβαίωση'),
                        content: Text('Είσαι σίγουρος ότι θέλεις να διαγράψεις τον αγώνα;'),
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
                      // Εδώ είμαστε ήδη μέσα στο IF του isSuperUser, αλλά κρατάω και το isUpperAdmin όπως το είχες
                      if (globalUser.isSuperUser || globalUser.isUpperAdmin) {
                        // await TeamsHandle().deleteMatch(match);
                        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                      }
                    }
                  },
                  icon: Icon(Icons.delete),
                ),
              ],
            )
          else
            const SizedBox(), // Αν δεν είναι superuser, δεν δείχνουμε τίποτα!



        ],
      ),
      body: matchProgress(match),

    );
  }

  Widget matchProgress(BasketMatch match){
    if (!match.hasMatchStarted) {
      return BasketMatchNotStartedDetails(match: match,);
    }
    else {
      return basketMatchStartedPage(match: match,);
    }
  }
}
