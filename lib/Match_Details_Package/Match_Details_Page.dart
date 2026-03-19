import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';
import 'package:untitled1/Match_Details_Package/Match_Not_Started/Match_Not_Started_Details_Page.dart';
import 'package:untitled1/Match_Details_Package/Match_Started_Details_Page.dart';
import '../Data_Classes/MatchDetails.dart';
import '../ad_manager.dart';
import '../globals.dart';
import 'bracketEditPage.dart';
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
    final match = Provider.of<MatchDetails>(context);
    return Scaffold(
      backgroundColor: darkModeNotifier.value ? Color.fromARGB(255, 30, 30, 30) : Colors.white,
      appBar: AppBar(
        backgroundColor:darkModeNotifier.value?Colors.grey[900]: Color.fromARGB(50, 5, 150, 200),
        iconTheme: IconThemeData(color: darkModeNotifier.value?Colors.white:Colors.black),
        actions: [
          if (!match.hasMatchStarted)
            if (globalUser.controlTheseTeamsFootball(match.homeTeam.name, match.awayTeam.name))
              Row(
                children: [
                  IconButton(onPressed: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MatchEditPage(match: match,),
                        ));
                  }, icon: Icon(Icons.edit)),
                ],
              ),

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
                        // ΒΗΜΑ 1: Παράθυρο επιλογής νικητή
                        String? winner = await showDialog<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              title: const Text('3-0 Άνευ αγώνα',textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Text(
                                    'Ποια ομάδα κέρδισε το ματς στα χαρτιά:',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const Divider(),
                                Row(
                                  children: [
                                    // Χρησιμοποιούμε Expanded για να μοιραστεί η οθόνη ακριβώς στη μέση (50/50)
                                    Expanded(
                                      child: SimpleDialogOption(
                                        onPressed: () => Navigator.pop(context, match.homeTeam.name),
                                        padding: EdgeInsets.zero, // Μηδενίζουμε το εσωτερικό padding του option για περισσότερο χώρο
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                                height: 60,
                                                width: 100,
                                                child: match.homeTeam.image
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              match.homeTeam.name,
                                              textAlign: TextAlign.center, // Κεντράρισμα κειμένου
                                              maxLines: 2, // Επιτρέπει μέχρι 2 γραμμές αν είναι μεγάλο το όνομα
                                              overflow: TextOverflow.ellipsis, // Αν είναι ακόμα μεγαλύτερο, βάζει αποσιωπητικά (...)
                                              style: const TextStyle(
                                                fontSize: 12,
                                                height: 1.1, // Μικραίνει το κενό μεταξύ των γραμμών αν πάει από κάτω
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Δεύτερη ομάδα
                                    Expanded(
                                      child: SimpleDialogOption(
                                        onPressed: () => Navigator.pop(context, match.awayTeam.name),
                                        padding: EdgeInsets.zero,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                                height: 60,
                                                width: 100,
                                                child: match.awayTeam.image
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              match.awayTeam.name,
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                height: 1.1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            );
                          },
                        );

                        // Αν ο χρήστης πάτησε έξω από το παράθυρο και δεν επέλεξε τίποτα, σταματάμε
                        if (winner == null) return;

                        // ΒΗΜΑ 2: Παράθυρο Επιβεβαίωσης ("Είσαι σίγουρος;")
                        bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Επιβεβαίωση'),
                            content: Text('Είσαι σίγουρος ότι θέλεις να κατοχυρώσεις τον αγώνα με 3-0 υπέρ της ομάδας "$winner";'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Ακύρωση'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Ναι, σίγουρα'),
                              ),
                            ],
                          ),
                        );

                        // ΒΗΜΑ 3: Εκτέλεση (Αν πάτησε "Ναι")
                        if (confirm == true) {
                          // Υπολογίζουμε ποιος πήρε τα 3 γκολ και ποιος τα 0
                          int homeGoals = (winner == match.homeTeam.name) ? 3 : 0;
                          int awayGoals = (winner == match.awayTeam.name) ? 3 : 0;

                          match.noMatch30(winner == match.homeTeam.name);
                          print("✅ Ο αγώνας έληξε $homeGoals - $awayGoals υπέρ της ομάδας $winner");

                          // Προαιρετικά: Εμφάνισε ένα snackbar επιτυχίας
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Το ματς κατοχυρώθηκε στην ομάδα $winner με 3-0!')),
                          );
                        }

                      },
                      icon: Icon(Icons.gavel, ),
                      tooltip: '3-0 Άνευ αγώνος', // Εμφανίζεται αν το κρατήσεις πατημένο!
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(12), // Για να μην είναι πολύ μικρό
                      ),
                    ),

                    IconButton(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) => SlotPickerDialog(
                            match: match,
                            phase: match.game,
                            maxSlots: (match.game / 2).toInt(),
                          ),
                        );
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
                            await TeamsHandle().deleteMatch(match);


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

  Widget matchProgress(MatchDetails match){
    if (!match.hasMatchStarted) {
      return MatchNotStartedDetails(match: match,);
    }
    else {
      return matchStartedPage(match: match,);
    }
  }
}
