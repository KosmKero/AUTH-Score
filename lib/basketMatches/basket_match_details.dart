import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/Data_Classes/basketball/basketMatch.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';
import 'package:untitled1/Match_Details_Package/Match_Not_Started/Match_Not_Started_Details_Page.dart';
import 'package:untitled1/Match_Details_Package/Match_Started_Details_Page.dart';
import '../Data_Classes/MatchDetails.dart';
import '../Firebase_Handle/BasketTeamsHandle.dart';
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
            if (globalUser.controlTheseTeamsFootball(match.homeTeam.name, match.awayTeam.name))
              IconButton(onPressed: () async {
               //await Navigator.push(
               //    context,
               //    MaterialPageRoute(
               //      builder: (context) => MatchEditPage(match: match,),
               //    ));
              }, icon: Icon(Icons.edit)),

          if (globalUser.isUpperAdmin)
            Row(
              mainAxisSize: MainAxisSize.min, // Καλό είναι να το βάλεις για να μην πιάσει όλο το πλάτος
              children: [
                IconButton(
                  onPressed: () async {
                    // TODO: Υλοποίηση SlotPickerDialog
                  },
                  icon: const Icon(Icons.edit_road),
                ),
                IconButton(
                  onPressed: () async {
                    bool? confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Επιβεβαίωση'),
                        content: const Text('Είσαι σίγουρος ότι θέλεις να διαγράψεις τον αγώνα;'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Ακύρωση'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Ναι'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await BasketTeamsHandle().deleteMatch(match);
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                      }
                    }
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            )
          else
            const SizedBox.shrink(), // Καλύτερο από το SizedBox() για performance


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
