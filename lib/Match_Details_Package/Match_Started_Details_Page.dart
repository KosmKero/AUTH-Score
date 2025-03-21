import 'dart:async';

import 'package:flutter/material.dart';
import 'package:untitled1/Data_Classes/Player.dart';
import '../../Data_Classes/Match.dart';
import 'package:provider/provider.dart';
import '../API/user_handle.dart';
import '../Data_Classes/Team.dart';
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
  late int _secondsElapsed;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsElapsed = (DateTime.now().millisecondsSinceEpoch ~/ 1000) -
        widget.match.startTimeInSeconds;
    _secondsElapsed = (DateTime.now().millisecondsSinceEpoch ~/ 1000) -
        widget.match.startTimeInSeconds;

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
        body: Container(
      //color: Colors.blueGrey,
      child: Column(
        children: [
          Column(children: [
            Container(
              color: Color.fromARGB(50, 5, 150, 200),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    // Row(
                    //   children: [
                    //     TextButton(onPressed:()
                    //     {widget.match.homeScored("name");
                    //     setState(() {});}, child: Text("patatohome")),
                    //     TextButton(onPressed:()
                    //     {widget.match.awayScored("name2");
                    //     setState(() {});}, child: Text("patatoaway")),
                    //     TextButton(onPressed:()
                    //     {widget.match.secondHalfStarted();
                    //     }, child: Text("2ohalf")),
                    //     TextButton(onPressed:()
                    //     {widget.match.matchFinished();
                    //     setState(() {});}, child: Text("finished")),
                    //   ],
                    // ),
                    Center(
                        child: Text(
                      widget.match.matchweekInfo(),
                      style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                    )),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Column(children: [
                            buildTeamName(team: widget.match.homeTeam),
                            _isAdminWidgetGoal(true)
                          ]),
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          child: widget.match.hasMatchFinished
                              ? _buildMatchFinishedScore()
                              : _buildMatchTimer(),
                        ),
                        Expanded(
                          child: Column(children: [
                            buildTeamName(team: widget.match.awayTeam),
                            _isAdminWidgetGoal(false)
                          ]),
                        ),
                      ],
                    ),
                    _matchProgressAdmin(),
                    const Divider(),
                    NavigationButtons(onSectionChange: _changeSection),
                  ],
                ),
              ),
            ),
          ]),
          _sectionChooser(selectedIndex, widget.match)
        ],
      ),
    ));
  }

  Widget _buildMatchFinishedScore() {
    Color homeColor, awayColor;

    (widget.match.scoreHome > widget.match.scoreAway)
        ? {homeColor = Colors.black, awayColor = Colors.grey}
        : (widget.match.scoreHome < widget.match.scoreAway)
            ? {homeColor = Colors.grey, awayColor = Colors.black}
            : {homeColor = Colors.blueGrey, awayColor = Colors.blueGrey};

    return Column(
      children: [
        Text(widget.match.dateString),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${widget.match.scoreHome}",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: homeColor)),
            Text("-",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: (widget.match.scoreHome != widget.match.scoreAway)
                        ? Colors.grey
                        : Colors.blueGrey)),
            Text("${widget.match.scoreAway}",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: awayColor)),
          ],
        ),
        Text('Ολοκληρώθηκε',
            style: const TextStyle(
                fontWeight: FontWeight.w400, fontSize: 12, color: Colors.black))
      ],
    );
  }

  Widget _buildMatchTimer() {
    int minutes = _secondsElapsed ~/ 60;
    int seconds = _secondsElapsed % 60;
    return Column(
      children: [
        SizedBox(
          height: 15,
        ),
        Text("${widget.match.scoreHome}-${widget.match.scoreAway}",
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 25, color: Colors.red)),
        (!widget.match.isHalfTime())
            ? Text(
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red),
              )
            : Text('Ημίχρονο',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.red))
      ],
    );
  }

  Widget _buildMatchdetails() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            widget.match.hasSecondHalfStarted
                ? _halfBuilder(2)
                : SizedBox.shrink(),
            _halfBuilder(1), // Always display the first half
          ],
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
            color: widget.match.hasMatchFinished? Colors.blueGrey :  Colors.redAccent,
          ),
          Text(
            " $halfο ημίχρονο ",
            style: TextStyle(color: widget.match.hasMatchFinished? Colors.black :  Colors.redAccent),
          ),
          Container(
            height: 1,
            width: 100,
            color: widget.match.hasMatchFinished? Colors.blueGrey :  Colors.redAccent,
          ),
        ],
      ),
      ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(), // Prevents nested scrolling
        itemCount: (widget.match.goalsList[half - 1] ?? []).length,
        itemBuilder: (context, index) {
          int reversedIndex =
              (widget.match.goalsList[half - 1]!.length - 1) - index;
          return Padding(
            padding: const EdgeInsets.all(2.0),
            child: buildGoalIndicator(
                widget.match.goalsList[half - 1]![reversedIndex]),
          );
        },
      ),
    ]);
  }

  Widget buildGoalIndicator(Goal goal) {
    return Row(
      mainAxisAlignment:
          goal.isHomeTeam ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (!goal.isHomeTeam)
          Spacer(), // Αν είναι η εκτός έδρας ομάδα, μετακινεί το κείμενο δεξιά
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: Color.fromARGB(10, 15, 35, 30),
                borderRadius: BorderRadius.circular(10),),
                //border: Border.all(color: Colors.grey)),
            child: goal.isHomeTeam
                ? Text(
                    '${goal.timeString} \u0301 ⚽ ${goal.scorerName} (${goal.homeScore}-${goal.awayScore})',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  )
                : Text(
                    '(${goal.homeScore}-${goal.awayScore}) ${goal.scorerName} ⚽ ${goal.timeString} \u0301 ',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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

  Widget _sectionChooser(int selectedIndex, Match match) {
    switch (selectedIndex) {
      case 0:
        return _buildMatchdetails();
      case 1:
        return Starting11Display();
      case 2:
        return StandingPageOneGroup(
          team: match.homeTeam,
        );
      default:
        return _buildMatchdetails();
    }
  }

  Widget _isAdminWidgetGoal(bool homeTeamScored) {
    // Check if the user is logged in
    if (UserHandle().getLoggedUser() == null || widget.match.hasMatchFinished) {
      return SizedBox(
        height: 50,
      );
    } else if (UserHandle().getLoggedUser()!.controlTheseTeams(
        widget.match.homeTeam.name, widget.match.awayTeam.name)) {
      return GestureDetector(
        onTap: () {
          homeTeamScored
              ? _showInputDialog(context, widget.match.homeTeam, homeTeamScored)
              : _showInputDialog(
                  context, widget.match.awayTeam, homeTeamScored);
          setState(() {});
        },
        child: Card(
            elevation: 10,
            color: Color.fromARGB(0, 15, 35, 30),
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                  width: 50,
                ),
                Text(
                  "Γκολ",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            )),
      );
    } else {
      return SizedBox(
        height: 50,
      );
    }
  }

  Widget _matchProgressAdmin() {
    // Check if the user is logged in
    if (UserHandle().getLoggedUser() == null || widget.match.hasMatchFinished) {
      return SizedBox(
        height: 10,
      );
    } else if (UserHandle().getLoggedUser()!.controlTheseTeams(
        widget.match.homeTeam.name, widget.match.awayTeam.name)) {
      Match match = widget.match;
      String progress = " ";
      match.hasSecondHalfStarted
          ? progress = "Τέλος Αγώνα"
          : match.hasFirstHalfFinished
              ? progress = "Εκκίννηση 2ου Ημιχρόνου"
              : progress = "Τέλος 1ου Ημιχρόνου";

      return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200], // Γκρι για "Ακύρωση"
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50), // Στρογγυλεμένες γωνίες
            ),
            padding: EdgeInsets.symmetric(horizontal: 9, vertical: 9),
            elevation: 5, // Ελαφριά σκιά
          ),
          onPressed: () {
            match.matchProgressed();
            setState(() {});
          },
          child: Column(
            children: [
              SizedBox(
                height: 10,
                width: 50,
              ),
              Text(
                progress,
                style: TextStyle(color: Colors.blue, fontSize: 18),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ));
    } else {
      return SizedBox(
        height: 10,
      );
    }
  }

  TextEditingController _controller = TextEditingController();
  void _showInputDialog(BuildContext context, Team team, bool homeTeamScored) {
    String? goalScorer;
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Γκολ ${team.name}"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _controller,
                    decoration:
                        InputDecoration(hintText: "Γράψτε για αναζήτηση"),
                    onChanged: (value) {
                      setDialogState(() {
                        goalScorer = null;
                        // Ενημέρωση της κατάστασης με βάση την είσοδο
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  DropdownButton<String>(
                    hint: Text(
                      "Σκόρερ",
                      style: TextStyle(
                          color: _getFilteredOptions(team).isNotEmpty
                              ? Colors.black
                              : Colors.grey),
                    ),
                    value: goalScorer,
                    isExpanded: true,
                    items: _getFilteredOptions(team).map((Player player) {
                      return DropdownMenuItem<String>(
                        value: "${player.name.substring(0,1)}. ${player.surname}",
                        child: Text("${player.name} ${player.surname}"),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setDialogState(() {
                        goalScorer = newValue;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text("Ακύρωση"),
                  onPressed: () {
                    _controller.clear();
                    Navigator.of(context).pop(); // Κλείνει το διάλογο
                  },
                ),
                TextButton(
                  child: Text("Υποβολή"),
                  onPressed: () {
                    //εδω πρεπει να μπει λεπτο
                    if (goalScorer != null) {
                      homeTeamScored
                          ? widget.match.homeScored(goalScorer ?? " ")
                          : widget.match.awayScored(goalScorer ?? " ");
                    }
                    _controller.clear();
                    Navigator.of(context).pop(); // Κλείνει το διάλογο
                  },
                ),
              ],
            );
          });
        });
  }

  List<Player> _getFilteredOptions(Team team) {
    // Create a Set to filter unique player names
    Set<String> uniquePlayerNames = {};
    List<Player> filteredPlayers = [];

    for (var player in team.players) {
      if (uniquePlayerNames.add(player.name.toLowerCase()) &&
          (player.name.toLowerCase().contains(_controller.text.toLowerCase()) ||
              _controller.text.isEmpty)) {
        filteredPlayers.add(player);
      }
    }

    return filteredPlayers;
  }
}
