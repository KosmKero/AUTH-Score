import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
  final basketMatch match;
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

  @override
  Widget build(BuildContext context) {
    final match = Provider.of<basketMatch>(context);
    return Scaffold(
      backgroundColor: darkModeNotifier.value ? Color.fromARGB(255, 30, 30, 30) : Colors.white,
      appBar: AppBar(
        backgroundColor:darkModeNotifier.value?Colors.grey[900]: Color.fromARGB(50, 5, 150, 200),
        iconTheme: IconThemeData(color: darkModeNotifier.value?Colors.white:Colors.black),
        actions: [
          if (!match.matchStarted)
            if (globalUser.controlTheseTeams(match.homeTeam.name, match.awayTeam.name))
              IconButton(onPressed: () async {
               //await Navigator.push(
               //    context,
               //    MaterialPageRoute(
               //      builder: (context) => MatchEditPage(match: match,),
               //    ));
              }, icon: Icon(Icons.edit)),

          FutureBuilder<bool>(
            future: globalUser.isSuperUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Σφάλμα: ${snapshot.error}');
              }
              if (snapshot.hasData && snapshot.data == true) {
                return Row(
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
                          if (await globalUser.isSuperUser()) {
                           // await TeamsHandle().deleteMatch(match);


                            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);

                          }
                        }
                      },
                      icon: Icon(Icons.delete),
                    ),
                  ],
                );
              } else {
                return SizedBox(); // Αν δεν είναι super user
              }
            },
          ),



        ],
      ),
      body: matchProgress(match),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min, // Για να μην γεμίζει όλη την οθόνη
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

  Widget matchProgress(basketMatch match){
    if (!match.matchStarted) {
      return BasketMatchNotStartedDetails(match: match,);
    }
    else {
      return basketMatchStartedPage(match: match,);
    }
  }
}
