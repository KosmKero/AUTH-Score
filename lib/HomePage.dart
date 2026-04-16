import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/matchesContainer.dart';
import 'package:untitled1/API/Match_Handle.dart';
import 'package:untitled1/ad_manager.dart';
import 'Firebase_Handle/firebase_screen_stats_helper.dart';
import 'Profile/bets/choosePage.dart';
import 'globals.dart';

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
    logScreenViewSta(screenName: 'Home page',screenClass: 'Home class');

    return Column(
      children: [
        // === Banner Ad ===
        SmartBanner(
          hasSponsor: FirebaseRemoteConfig.instance.getBool('has_home_sponsor'),
          sponsorImageUrl: FirebaseRemoteConfig.instance.getString('home_sponsor_image_url'),
          sponsorName: "homepage_Sponsor",
          sponsorLink: FirebaseRemoteConfig.instance.getString('home_sponsor_link'),
          height: FirebaseRemoteConfig.instance.getDouble('home_sponsor_image_height'),
          // Αν το to20best είναι true, δώσε τη συνάρτηση. Αλλιώς, δώσε null!
          onCustomTap: FirebaseRemoteConfig.instance.getBool('to20best')
              ? () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TopUsersAndHistory()),
            );
          }
              : null,
          customBgColor: darkModeNotifier.value ? Color(0xFF121212) : lightModeBackGround,
        ),

        Container(
          color: darkModeNotifier.value ? Color(0xFF121212) : lightModeBackGround,
          width: double.infinity,
          height: 60,
          child: TextButton(
            onPressed: changeMatches,
            child: upcomingMatches
                ? Row(
              children: [
                Icon(CupertinoIcons.back, color: Colors.white, size: 19),
                Text(
                  greek ? "Προηγούμενοι αγώνες" : "Previous matches",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Arial",
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  greek ? "Επερχόμενοι αγώνες" : "Upcoming matches",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Arial",
                    letterSpacing: 0.5,
                  ),
                ),
                Icon(CupertinoIcons.right_chevron,
                    color: Colors.white, size: 19),
              ],
            ),
          ),
        ),

        // === Main Match Container ===
        Expanded(
          child: Container(
            color: darkModeNotifier.value ? Color(0xFF121212) : lightModeBackGround,
            child: upcomingMatches
                ? matchesContainer(
              matches: MatchHandle().getUpcomingMatches(),
              type: 1,
            )
                : matchesContainer(
              matches: MatchHandle().getPreviousMatches(),
              type: 2,
            ),
          ),
        ),
      ],
    );
  }
}
