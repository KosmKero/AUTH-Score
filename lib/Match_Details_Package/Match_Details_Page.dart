import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';
import 'package:untitled1/Match_Details_Package/Match_Not_Started/Match_Not_Started_Details_Page.dart';
import 'package:untitled1/Match_Details_Package/Match_Started_Details_Page.dart';
import 'package:untitled1/Match_Details_Package/preview_match.dart';
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
            if (globalUser.isUpperAdmin)
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
                          title: Text(
                            greek ? '3-0 Άνευ αγώνα' : '3-0 Walkover',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                greek ? 'Ποια ομάδα κέρδισε το ματς στα χαρτιά:' : 'Which team won by forfeit:',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Divider(),
                            Row(
                              children: [
                                // Γηπεδούχος
                                Expanded(
                                  child: SimpleDialogOption(
                                    // Στέλνουμε το σταθερό ID στο backend
                                    onPressed: () => Navigator.pop(context, match.homeTeam.name),
                                    padding: EdgeInsets.zero,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(height: 60, width: 100, child: match.homeTeam.image),
                                        const SizedBox(height: 12),
                                        Text(
                                          match.homeTeam.displayName,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12, height: 1.1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Φιλοξενούμενος
                                Expanded(
                                  child: SimpleDialogOption(
                                    // Στέλνουμε το σταθερό ID στο backend
                                    onPressed: () => Navigator.pop(context, match.awayTeam.name),
                                    padding: EdgeInsets.zero,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(height: 60, width: 100, child: match.awayTeam.image),
                                        const SizedBox(height: 12),
                                        Text(
                                          match.awayTeam.displayName,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12, height: 1.1),
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

                    if (winner == null) return;

                    // 💡 Βρίσκουμε το Display Name του νικητή για τα μηνύματα επιβεβαίωσης
                    String winnerDisplayName = winner == match.homeTeam.name
                        ? match.homeTeam.displayName
                        : match.awayTeam.displayName;

                    // ΒΗΜΑ 2: Επιβεβαίωση
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(greek ? 'Επιβεβαίωση' : 'Confirmation'),
                        content: Text(greek
                            ? 'Είσαι σίγουρος ότι θέλεις να κατοχυρώσεις τον αγώνα με 3-0 υπέρ της ομάδας "$winnerDisplayName";'
                            : 'Are you sure you want to award a 3-0 win to "$winnerDisplayName"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(greek ? 'Ακύρωση' : 'Cancel', style: const TextStyle(color: Colors.grey)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(greek ? 'Ναι, σίγουρα' : 'Yes, I am sure', style: const TextStyle(color: Colors.blue)),
                          ),
                        ],
                      ),
                    );

                    // ΒΗΜΑ 3: Εκτέλεση
                    if (confirm == true) {
                      match.noMatch30(winner == match.homeTeam.name); // Χρησιμοποιούμε το ID για το logic
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(greek
                                ? 'Το ματς κατοχυρώθηκε στην ομάδα $winnerDisplayName με 3-0!'
                                : 'Match awarded to $winnerDisplayName with 3-0!'),
                            backgroundColor: Colors.green,
                          )
                      );
                    }
                  },
                  icon: const Icon(Icons.gavel),
                  tooltip: greek ? '3-0 Άνευ αγώνος' : '3-0 Walkover',
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
                  tooltip: greek ? 'Διαχείριση θέσης' : 'Manage Bracket Slot',
                ),

                // 3. ΚΟΥΜΠΙ ΔΙΑΓΡΑΦΗΣ
                IconButton(
                  onPressed: () async {
                    bool? confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(greek ? 'Επιβεβαίωση' : 'Confirmation'),
                        content: Text(greek
                            ? 'Είσαι σίγουρος ότι θέλεις να διαγράψεις τον αγώνα;'
                            : 'Are you sure you want to delete this match?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(greek ? 'Ακύρωση' : 'Cancel', style: const TextStyle(color: Colors.grey)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(greek ? 'Ναι' : 'Yes', style: const TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await TeamsHandle().deleteMatch(match);
                      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                    }
                  },
                  icon: const Icon(Icons.delete),
                  tooltip: greek ? 'Διαγραφή αγώνα' : 'Delete Match',
                ),
              ],
            )
          else
            const SizedBox(),
          /*
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink[600], // Χρώμα που θυμίζει Instagram
              elevation: 8,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            label: Text(
              greek ? "Δημιουργία IG Story" : "Create IG Story",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoryPreviewScreen(match: match),
                ),
              );
            },
          ),
           */

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
