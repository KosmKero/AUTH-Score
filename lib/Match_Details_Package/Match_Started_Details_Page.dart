import 'dart:async';

import 'package:flutter/material.dart';
import '../../Data_Classes/Match.dart';
import 'package:provider/provider.dart';
import 'Match_Not_Started/Match_Not_Started_Details_Page.dart';
import 'Standings_Card_1Group.dart';
import 'Starting__11_Display_Card.dart';

class matchStartedPage extends StatelessWidget {
  final Match match;

  const matchStartedPage({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: match,
      child: _MatchStartedView(match),
    );
  }
}


class _MatchStartedView extends StatefulWidget {
  const _MatchStartedView(this.match);
  final Match match;
  @override
  State<_MatchStartedView> createState() => _MatchStartedViewState();
}

class _MatchStartedViewState extends State<_MatchStartedView> {
  int selectedIndex = 0;
  int _secondsElapsed = 0;
  Timer? _timer;



  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  void _changeSection(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            Column(children: [
              Container(
                color: Color.fromARGB(50, 5, 150, 200),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          TextButton(onPressed:()
                          {widget.match.homeScored("name");
                          setState(() {});}, child: Text("patatohome")),
                          TextButton(onPressed:()
                          {widget.match.awayScored("name2");
                          setState(() {});}, child: Text("patatoaway")),
                          TextButton(onPressed:()
                          {widget.match.secondHalfStarted();
                          }, child: Text("2ohalf")),
                          TextButton(onPressed:()
                          {widget.match.matchFinished();
                          setState(() {});}, child: Text("finished")),
                        ],
                      )
                      ,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildHomeTeamName(
                            team: widget.match.homeTeam,
                          ),
                          _buildMatchTimer(),
                          buildAwayTeamName(team: widget.match.awayTeam),
                        ],
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      const Divider(),
                      NavigationButtons(onSectionChange: _changeSection),

                    ],
                  ),
                ),
              ),
            ]),
            _sectionChooser(selectedIndex, widget.match)


          ],
        ));
  }

  Widget _buildMatchTimer() {
    int minutes = _secondsElapsed ~/ 60;
    int seconds = _secondsElapsed % 60;
    return Column(
      children: [
        Text("${widget.match.scoreHome}-${widget.match.scoreAway}",
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 25, color: Colors.red)),
        Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
        ),
      ],
    );
  }

  Widget _buildMatchdetails() {
    return Container(

      child: Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              widget.match.hasSecondhalfStarted ? _halfBuilder(2) : SizedBox.shrink(),
              _halfBuilder(1), // Always display the first half
            ],
          ),
        ),
      ),

    );
  }

  Widget _halfBuilder(int half) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 1,
            width: 100,
            color: Colors.redAccent,
          ),
          Text(
            " $halfο ημίχρονο ",
            style: TextStyle(color: Colors.redAccent),
          ),
          Container(
            height: 1,
            width: 100,
            color: Colors.redAccent,
          ),
        ],
      ),
      ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(), // Prevents nested scrolling
        itemCount: (widget.match.goalsList[half - 1] ?? []).length,
        itemBuilder: (context, index) {
          int reversedIndex = (widget.match.goalsList[half - 1]!.length - 1) - index;
          return buildGoalIndicator(widget.match.goalsList[half - 1]![reversedIndex]);
        },
      ),

    ]);
  }

  List<Widget> _halfGoalsBuild(int i) {
    List<Widget> list = [buildGoalIndicator(Goal("_scorerName", 2, 1, 20,null ,true))];
    for (Goal goal in widget.match.goalsList[i] ?? []) {
      list.add(buildGoalIndicator(goal));
    }
    return list;
  }

  Widget buildGoalIndicator(Goal goal) {
    return Row(
      mainAxisAlignment:
      goal.isHomeTeam ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (!goal.isHomeTeam)
          Spacer(), // Αν είναι η εκτός έδρας ομάδα, μετακινεί το κείμενο δεξιά
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 2),
          child: Container(

            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Color.fromARGB(10, 15, 35, 30),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey)

            ),
            child: goal.isHomeTeam
                ? Text(
              '${goal.timeString} \u0301⚽${goal.scorerName} ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )
                : Text(
              '${goal.scorerName} ⚽${goal.timeString} \u0301 ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        if (goal.isHomeTeam)
          Spacer(), // Αν είναι η γηπεδούχος ομάδα, μετακινεί το κείμενο αριστερά
      ],
    );
  }

  void scoreChanged() {
    setState(() {});
  }



  Widget _sectionChooser(int selectedIndex,Match match) {
    switch (selectedIndex) {
      case 0:
        return _buildMatchdetails();
      case 1:
        return Starting11Display();
      case 2:
        return StandingPageOneGroup(team: match.homeTeam,);
      default:
        return _buildMatchdetails();
    }
  }
}