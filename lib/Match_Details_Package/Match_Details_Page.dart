import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';
import 'package:untitled1/Match_Details_Package/Match_Not_Started/Match_Not_Started_Details_Page.dart';
import 'package:untitled1/Match_Details_Package/Match_Started_Details_Page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Data_Classes/MatchDetails.dart';
import '../ad_manager.dart';
import '../globals.dart';
import 'bracketEditPage.dart';
import 'match_edit_page.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

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

  @override
  void initState() {
    super.initState();

    final match = Provider.of<MatchDetails>(context, listen: false);

    if (match.hasMatchStarted && !match.hasMatchEndedFinal) {
      WakelockPlus.enable();
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
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
            if (globalUser.controlTheseTeamsFootball(match.homeTeam.name, match.awayTeam.name) || globalUser.isUpperAdmin)
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

          // Ελέγχουμε αν υπάρχει αποθηκευμένο link για αυτό το ματς (έχει τη μεταβλητή pdfReportUrl το MatchDetails σου;)
          if (match.pdfReportUrl != null && match.pdfReportUrl!.isNotEmpty && globalUser.isAdmin)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.picture_as_pdf),
              label: Text(greek ? "Προβολή Φύλλου Αγώνα" : "View Match Report"),
              onPressed: () async {
                final Uri url = Uri.parse(match.pdfReportUrl!);

                // Ανοίγει το PDF στον Browser του κινητού!
                if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(greek ? "Δεν ήταν δυνατό το άνοιγμα του PDF" : "Could not open PDF")),
                  );
                }
              },
            ),

          if ((globalUser.isSuperUser || globalUser.isUpperAdmin ) && !match.hasMatchStarted)
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Για να είναι κεντραρισμένα
              children: [
                // 1. ΚΟΥΜΠΙ 3-0
                IconButton(
                  onPressed: () async {
                    // ΒΗΜΑ 1: Παράθυρο επιλογής νικητή
                    String? winner = await showDialog<String>(
                      context: context,
                      builder: (BuildContext context) {
                        return SimpleDialog(
                          title: const Text('3-0 Άνευ αγώνα', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                          children: <Widget>[
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Ποια ομάδα κέρδισε το ματς στα χαρτιά:', textAlign: TextAlign.center),
                            ),
                            const Divider(),
                            Row(
                              children: [
                                // Γηπεδούχος
                                Expanded(
                                  child: SimpleDialogOption(
                                    onPressed: () => Navigator.pop(context, match.homeTeam.name),
                                    padding: EdgeInsets.zero,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(height: 60, width: 100, child: match.homeTeam.image),
                                        const SizedBox(height: 12),
                                        Text(match.homeTeam.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, height: 1.1)),
                                      ],
                                    ),
                                  ),
                                ),
                                // Φιλοξενούμενος
                                Expanded(
                                  child: SimpleDialogOption(
                                    onPressed: () => Navigator.pop(context, match.awayTeam.name),
                                    padding: EdgeInsets.zero,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(height: 60, width: 100, child: match.awayTeam.image),
                                        const SizedBox(height: 12),
                                        Text(match.awayTeam.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, height: 1.1)),
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

                    if (winner == null) return;

                    // ΒΗΜΑ 2: Επιβεβαίωση
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Επιβεβαίωση'),
                        content: Text('Είσαι σίγουρος ότι θέλεις να κατοχυρώσεις τον αγώνα με 3-0 υπέρ της ομάδας "$winner";'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ακύρωση')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ναι, σίγουρα')),
                        ],
                      ),
                    );

                    // ΒΗΜΑ 3: Εκτέλεση
                    if (confirm == true) {
                      match.noMatch30(winner == match.homeTeam.name);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Το ματς κατοχυρώθηκε στην ομάδα $winner με 3-0!')));
                    }
                  },
                  icon: const Icon(Icons.gavel),
                  tooltip: '3-0 Άνευ αγώνος',
                ),

                // 2. ΚΟΥΜΠΙ SLOT PICKER
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
                  icon: const Icon(Icons.edit_road),
                ),

                // 3. ΚΟΥΜΠΙ ΔΙΑΓΡΑΦΗΣ
                IconButton(
                  onPressed: () async {
                    bool? confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Επιβεβαίωση'),
                        content: const Text('Είσαι σίγουρος ότι θέλεις να διαγράψεις τον αγώνα;'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ακύρωση')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ναι')),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await TeamsHandle().deleteMatch(match);
                      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                    }
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            )
          else
            const SizedBox()



        ],
      ),
      body: matchProgress(match),
      bottomNavigationBar: SmartBanner(
        hasSponsor: FirebaseRemoteConfig.instance.getBool('has_match_sponsor'),
        sponsorImageUrl: FirebaseRemoteConfig.instance.getString('match_sponsor_image_url'),
        sponsorLink: FirebaseRemoteConfig.instance.getString('match_sponsor_link'),

        sponsorName: "Match_Screen_Sponsor",
        height: FirebaseRemoteConfig.instance.getDouble('match_screen_sponsor_image_height'),
        customBgColor: darkModeNotifier.value ? Color.fromARGB(255, 30, 30, 30) : Colors.white,

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
