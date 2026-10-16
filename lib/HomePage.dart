import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/ad_manager.dart';
import 'Firebase_Handle/firebase_screen_stats_helper.dart';
import 'Profile/bets/choosePage.dart';
import 'globals.dart';
import 'mContainers/chooseSportContainer.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool upcomingMatches = true;

  void changeMatches() {
    setState(() {
      upcomingMatches = !upcomingMatches;
    });
  }

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Home page', screenClass: 'Home class');

    return Column(
      children: [
        // === Banner Ad ===
        SmartBanner(
          hasSponsor: FirebaseRemoteConfig.instance.getBool('has_home_sponsor'),
          sponsorImageUrl:
              FirebaseRemoteConfig.instance.getString('home_sponsor_image_url'),
          sponsorName: "homepage_Sponsor",
          sponsorLink:
              FirebaseRemoteConfig.instance.getString('home_sponsor_link'),
          height: FirebaseRemoteConfig.instance
              .getDouble('home_sponsor_image_height'),
          // Αν το to20best είναι true, δώσε τη συνάρτηση. Αλλιώς, δώσε null!
          onCustomTap: FirebaseRemoteConfig.instance.getBool('to20best')
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TopUsersAndHistory()),
                  );
                }
              : null,
          customBgColor:
              darkModeNotifier.value ? Color(0xFF121212) : lightModeBackGround,
        ),

        Container(
          color: darkModeNotifier.value ? const Color(0xFF121212) : lightModeBackGround,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: CupertinoSlidingSegmentedControl<bool>(
            // Χρώμα του φόντου της μπάρας
            backgroundColor: darkModeNotifier.value ? Colors.grey[900]! : Colors.grey[300]!,
            // Χρώμα της επιλεγμένης καρτέλας (thumb)
            thumbColor: darkModeNotifier.value ? Colors.grey[700]! : Colors.white,
            // Ποιο είναι επιλεγμένο αυτή τη στιγμή
            groupValue: upcomingMatches,
            onValueChanged: (bool? value) {
              if (value != null && value != upcomingMatches) {
                setState(() {
                  upcomingMatches = value;
                });
              }
            },
            children: {
              false: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  greek ? "Προηγούμενοι" : "Previous",
                  style: TextStyle(
                    // Φωτίζουμε το κείμενο αν είναι επιλεγμένο, το κάνουμε πιο αχνό αν δεν είναι
                    color: !upcomingMatches
                        ? (darkModeNotifier.value ? Colors.white : Colors.black)
                        : Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Arial",
                  ),
                ),
              ),
              true: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  greek ? "Επερχόμενοι" : "Upcoming",
                  style: TextStyle(
                    color: upcomingMatches
                        ? (darkModeNotifier.value ? Colors.white : Colors.black)
                        : Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Arial",
                  ),
                ),
              ),
            },
          ),
        ),
        // === Main Match Container ===
        Expanded(
          child: Container(
            color: darkModeNotifier.value
                ? const Color(0xFF121212)
                : lightModeBackGround,

            child: ChooseSportContainer(
              type: upcomingMatches ? 1 : 2,
            ),
          ),
        )
      ],
    );
  }
}
