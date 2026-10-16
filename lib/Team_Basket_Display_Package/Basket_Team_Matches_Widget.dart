import 'package:flutter/cupertino.dart';
import '../../Data_Classes/basketball/basketTeam.dart';
import '../../Data_Classes/basketball/basketMatch.dart';
import '../../API/BasketballMatchHandle.dart';

import '../../Firebase_Handle/firebase_screen_stats_helper.dart';
import '../mContainers/BasketballContainer.dart';

class BasketballTeamMatchesWidget extends StatefulWidget {
  const BasketballTeamMatchesWidget({super.key, required this.team});

  final basketTeam team;

  @override
  State<BasketballTeamMatchesWidget> createState() => _BasketballTeamMatchesWidgetState();
}

class _BasketballTeamMatchesWidgetState extends State<BasketballTeamMatchesWidget> {
  List<BasketMatch> matchList = [];

  @override
  void initState() {
    super.initState();
    refreshList();
  }

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Basket Team matches', screenClass: 'Basket Team matches page');

    return Expanded(
        child: BasketballContainer(
            matches: matchList,
            type: 2
        )
    );
  }

  void refreshList() {
    matchList.clear();

    // Φέρνουμε όλα τα ματς του μπάσκετ και φιλτράρουμε
    for (BasketMatch match in BasketballMatchHandle().getAllMatches()) {
      if (match.homeTeam.name == widget.team.name ||
          match.awayTeam.name == widget.team.name) {
        matchList.add(match);
      }
    }
  }
}