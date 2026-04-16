import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

import '../../ad_manager.dart';
import '../../globals.dart';
import 'betLeaderboard.dart';
import 'history.dart';

class TopUsersAndHistory extends StatefulWidget {
  @override
  State<TopUsersAndHistory> createState() => _TopUsersAndHistoryState();
}

class _TopUsersAndHistoryState extends State<TopUsersAndHistory>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double sponsorHeight =
        FirebaseRemoteConfig.instance.getDouble('top20_sponsor_height');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          greek ? "Προβλέψεις" : 'Predictions',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: darkModeNotifier.value
            ? const Color(0xFF1E1E1E)
            : const Color(0xFF2E5A88),
        iconTheme: IconThemeData(
            color: darkModeNotifier.value ? Colors.white : Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor:
              darkModeNotifier.value ? const Color(0xFFBB86FC) : Colors.white,
          labelColor:
              darkModeNotifier.value ? const Color(0xFFBB86FC) : Colors.white,
          unselectedLabelColor:
              darkModeNotifier.value ? Colors.grey[400] : Colors.grey[300],
          tabs: [
            Tab(
                icon: Icon(Icons.emoji_events),
                text: greek ? 'Βαθμολογία' : "Leaderboard"),
            Tab(
                icon: Icon(Icons.history),
                text: greek ? 'Ιστορικό' : "History"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TopUsersList(),
          UserBetHistory(),
        ],
      ),
      bottomNavigationBar: SmartBanner(
        hasSponsor: FirebaseRemoteConfig.instance.getBool('has_top20_sponsor'),
        sponsorImageUrl:
            FirebaseRemoteConfig.instance.getString('top20_sponsor_image_url'),
        sponsorName: "top20_Sponsor",
        sponsorLink:
            FirebaseRemoteConfig.instance.getString('top20_sponsor_link'),
        height: sponsorHeight > 0 ? sponsorHeight : 60.0,
        customBgColor: darkModeNotifier.value
            ? const Color(0xFF1E1E1E)
            : const Color(0xFF2E5A88),
      ),
    );
  }
}
