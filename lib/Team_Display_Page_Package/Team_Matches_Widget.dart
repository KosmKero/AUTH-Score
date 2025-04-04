import 'package:flutter/cupertino.dart';
import 'package:untitled1/Data_Classes/Team.dart';
import 'package:untitled1/Data_Classes/MatchDetails.dart';
import 'package:untitled1/API/Match_Handle.dart';


import '../matchesContainer.dart';


class TeamMatchesWidget extends StatefulWidget {
  const TeamMatchesWidget({super.key, required this.team});
  final Team team;

  @override
  State<TeamMatchesWidget> createState() => _TeamMatchesWidgetState();
}

class _TeamMatchesWidgetState extends State<TeamMatchesWidget> {
  @override
  void initState() {
    super.initState();
    refreshList();
  }

  List<MatchDetails> matchList=[];
  @override
  Widget build(BuildContext context) {
    return Expanded(child: matchesContainer(
      matches: matchList ,
    ));
  }

  void refreshList() {
    matchList.clear();
      for (MatchDetails match in MatchHandle().getAllMatches()) {
        if (match.homeTeam.name == widget.team.name ||
            match.awayTeam.name == widget.team.name) {
          matchList.add(match);
        }
    }
  }


}

