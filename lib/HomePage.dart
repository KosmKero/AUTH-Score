import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:untitled1/TopScorersContainer.dart';
import 'package:untitled1/matchesContainer.dart';
import 'package:untitled1/API/Match_Handle.dart';
import 'package:untitled1/Match_Details_Package/add_match_page.dart';
import 'package:untitled1/Scorer.dart';
import 'package:untitled1/ad_manager.dart';
import 'globals.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool upcomingMatches = true;

  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  List<Scorer> topScorers = [
    Scorer("paulos", 30, "c"),
    Scorer("lito", 15, "c"),
    Scorer("billy", 13, "csd"),
    Scorer("glaros", 10, "c"),
    Scorer("paulito", 10, "c"),
    Scorer("lama", 15, "csd"),
  ];

  void changeMatches() {
    setState(() {
      upcomingMatches = !upcomingMatches;
    });
  }

  @override
  void initState() {
    super.initState();

    // Create banner ad with listener
    _bannerAd = AdManager.createBannerAd(
        onStatusChanged: (status) {
          setState(() {
            _isBannerAdReady = status;
          });
        }
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // === Banner Ad ===
        if (_isBannerAdReady && _bannerAd != null)
          Container(
            color: darkModeNotifier.value ? Color(0xFF121212) : lightModeBackGround,
            width: double.infinity.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),

        // === Admin Button ===
        if (globalUser.isAdmin) Container(height: 5,color: darkModeNotifier.value ? Color(0xFF121212) : lightModeBackGround,) ,
        if (globalUser.isAdmin)
          Container(
            color: darkModeNotifier.value ? Color(0xFF121212) : lightModeBackGround,
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: darkModeNotifier.value
                    ? darkModeBackGround
                    : Color.fromARGB(250, 74, 111, 150),
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddMatchScreen()),
                );
              },
              child: Text(
                greek ? "Προσθήκη Αγώνα" : "Add new match",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold,
                  fontSize: 16.5,
                  wordSpacing: 1,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

        // === Toggle Button for Matches ===
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
