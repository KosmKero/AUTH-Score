import 'dart:async';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Data_Classes/Player.dart';
import 'package:untitled1/Firebase_Handle/user_handle_in_base.dart';
import 'package:untitled1/Match_Details_Package/penalty_shootout_widget.dart';
import 'package:untitled1/championship_details/StandingsPage.dart';
import 'package:untitled1/globals.dart';
import '../../Data_Classes/MatchDetails.dart';
import 'package:provider/provider.dart';
import '../API/pdfPreview.dart';
import '../API/preview.dart';
import '../Data_Classes/Penaltys.dart';
import '../Data_Classes/Team.dart';
import '../Data_Classes/match_facts.dart';
import '../Firebase_Handle/firebase_screen_stats_helper.dart';
import '../Team_Display_Page_Package/one_group_standings.dart';
import 'Match_Not_Started/Match_Not_Started_Details_Page.dart';
import 'Starting__11_Display_Card.dart';
import '../../ad_manager.dart';
import 'match_fact_edit.dart';

class matchStartedPage extends StatelessWidget {
  final MatchDetails match;

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
  final MatchDetails match;
  @override
  State<_MatchStartedView> createState() => _MatchStartedViewState();
}

class _MatchStartedViewState extends State<_MatchStartedView> {
  int selectedIndex = 0;
  late int _secondsElapsed;
  Timer? _timer;
  late int _startTimeInSeconds;

  @override
  void initState() {
    super.initState();
    _startTimeInSeconds = widget.match.startTimeInSeconds;
    _syncTime();
    _startTimer();

    widget.match.startListeningForUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.match.stopListening();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _MatchStartedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.match.startTimeInSeconds != widget.match.startTimeInSeconds) {
      _startTimeInSeconds = widget.match.startTimeInSeconds;
      _syncTime(); // reset με νέα βάση
    }
  }

  void _syncTime() {
    _secondsElapsed =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 - _startTimeInSeconds;
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
    if (widget.match.hasMatchEndedFinal) {
      logScreenViewSta(
          screenName: 'Match ended page', screenClass: 'Match ended page');
      FirebaseAnalytics.instance.logEvent(
        name: 'Match Ended Clicked',
        parameters: {
          'match_id':
              '${widget.match.homeTeam.nameEnglish} ${widget.match.timeString} ${widget.match.awayTeam.nameEnglish}',
          'home_team': widget.match.homeTeam.nameEnglish,
          'away_team': widget.match.awayTeam.nameEnglish,
        },
      );
    } else {
      logScreenViewSta(
          screenName: 'Match started page', screenClass: 'Match started page');
      FirebaseAnalytics.instance.logEvent(
        name: 'Match Started Clicked',
        parameters: {
          'match_id':
              '${widget.match.homeTeam.nameEnglish} ${widget.match.timeString} ${widget.match.awayTeam.nameEnglish}',
          'home_team': widget.match.homeTeam.nameEnglish,
          'away_team': widget.match.awayTeam.nameEnglish,
        },
      );
    }

    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              color: darkModeNotifier.value
                  ? Colors.grey[900]
                  : Color.fromARGB(50, 5, 150, 200),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    Center(
                        child: Text(
                      widget.match.matchweekInfo(),
                      style: TextStyle(
                          fontSize: 13,
                          color: darkModeNotifier.value
                              ? Colors.white
                              : Colors.grey[800]),
                    )),
                    SizedBox(height: 10),
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
                          child: (((widget.match.hasMatchFinished &&
                                          !widget.match.isExtraTimeTime) ||
                                      (widget.match.hasExtraTimeFinished &&
                                          !widget.match.isPenaltyTime)) ||
                                  widget.match.isShootoutOver)
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _cardAdmin(true),
                        _matchProgressAdmin(),
                        _cardAdmin(false)
                      ],
                    ),

                    _buildPdfReportButton(),
                    const Divider(),
                    NavigationButtons(onSectionChange: _changeSection, homeTeamName: widget.match.homeTeam.name, awayTeamName: widget.match.awayTeam.name, ),
                  ],
                ),
              ),
            ),
            _sectionChooser(selectedIndex, widget.match),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchFinishedScore() {
    Color homeColor, awayColor;

    (widget.match.homeScore + widget.match.penaltyScoreHome >
            widget.match.awayScore + widget.match.penaltyScoreAway)
        ? {
            homeColor = darkModeNotifier.value ? Colors.white : Colors.black,
            awayColor = Colors.grey
          }
        : (widget.match.homeScore + widget.match.penaltyScoreHome <
                widget.match.awayScore + widget.match.penaltyScoreAway)
            ? {
                homeColor = Colors.grey,
                awayColor = darkModeNotifier.value ? Colors.white : Colors.black
              }
            : {homeColor = Colors.blueGrey, awayColor = Colors.blueGrey};

    return Container(
      child: Column(
        children: [
          Text(
            widget.match.dateString,
            style: TextStyle(
                color: darkModeNotifier.value ? Colors.white : Colors.black),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${widget.match.homeScore + widget.match.penaltyScoreHome}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: homeColor)),
              Text("-",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: (widget.match.homeScore != widget.match.awayScore)
                          ? Colors.grey
                          : Colors.blueGrey)),
              Text("${widget.match.awayScore + widget.match.penaltyScoreAway}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: awayColor)),
            ],
          ),
          Text('Ολοκληρώθηκε',
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: darkModeNotifier.value ? Colors.white : Colors.black))
        ],
      ),
    );
  }

  Widget _buildMatchTimer() {
    return Consumer<MatchDetails>(
      builder: (context, matchDetails, child) {
        int secondsElapsed = DateTime.now().millisecondsSinceEpoch ~/ 1000 -
            matchDetails.startTimeInSeconds;

        int minutes = secondsElapsed ~/ 60;
        int seconds = secondsElapsed % 60;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 15),
            Text(
              "${matchDetails.homeScore + matchDetails.penaltyScoreHome}-${matchDetails.awayScore + matchDetails.penaltyScoreAway}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 25, color: Colors.red),
            ),
            (matchDetails.isPenaltyTime)
                ? Text('Πέναλτι',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.red),
                    textAlign: TextAlign.center)
                : (!matchDetails.isHalfTime() &&
                        !matchDetails.isExtraTimeHalf() &&
                        !(matchDetails.hasMatchFinished &&
                            !matchDetails.hasExtraTimeStarted))
                    ? Text(
                        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red))
                    : Text(
                        (matchDetails.hasMatchFinished &&
                                !matchDetails.hasExtraTimeStarted)
                            ? 'Αναμονή Παράτασης'
                            : matchDetails.isHalfTime()
                                ? 'Ημίχρονο'
                                : 'Ημίχρονο Παράτασης',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.red),
                        textAlign: TextAlign.center)
          ],
        );
      },
    );
  }

  Widget _buildMatchDetails() {
    return Column(
      children: [
        if (globalUser.isUpperAdmin &&
            widget.match.isPenaltyTime &&
            (DateTime.now().millisecondsSinceEpoch ~/ 1000 <
                widget.match.startTimeInSeconds + 3 * 3600))
          ElevatedButton(
              onPressed: () async {
                await widget.match.cancelPenalty();
                setState(() {});
              },
              child: Text('Διαγραφή τελευταίου πέναλτι')),
        if (widget.match.isPenaltyTime)
          PenaltyShootoutPanel(match: widget.match),
        if (widget.match.isExtraTimeTime &&
            widget.match.hasSecondHalfExtraTimeStarted)
          _halfBuilder(4),
        if (widget.match.isExtraTimeTime && widget.match.hasExtraTimeStarted)
          _halfBuilder(3),
        if (widget.match.hasSecondHalfStarted || widget.match.hasMatchFinished)
          _halfBuilder(2),
        _halfBuilder(1),
      ],
    );
  }

  Widget _halfBuilder(int half) {
    int ha = (half % 2 == 0) ? 2 : 1;

    List<MatchFact> visibleFacts = (widget.match.matchFact[half - 1] ?? [])
        .where((fact) => fact is Goal || fact is CardP)
        .toList();

    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 1,
            width: (half > 2) ? 65 : 100,
            color: ((widget.match.hasMatchFinished &&
                        !widget.match.isExtraTimeTime) ||
                    widget.match.hasExtraTimeFinished)
                ? Colors.blueGrey
                : Colors.redAccent,
          ),
          Text(
            " ${ha}ο ημίχρονο ${(half > 2) ? 'παράτασης' : ""}",
            style: TextStyle(
                color: ((widget.match.hasMatchFinished &&
                            !widget.match.isExtraTimeTime) ||
                        widget.match.hasExtraTimeFinished)
                    ? darkModeNotifier.value
                        ? Colors.white
                        : Colors.black
                    : Colors.redAccent),
          ),
          Container(
            height: 1,
            width: (half > 2) ? 65 : 100,
            color: ((widget.match.hasMatchFinished &&
                        !widget.match.isExtraTimeTime) ||
                    widget.match.hasExtraTimeFinished)
                ? Colors.blueGrey
                : Colors.redAccent,
          ),
        ],
      ),
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: visibleFacts.length,
        itemBuilder: (context, index) {
          int reversedIndex = (visibleFacts.length - 1) - index;
          var fact = visibleFacts[reversedIndex];

          return Padding(
            padding: const EdgeInsets.all(2.0),
            child: (fact is Goal)
                ? buildGoalIndicator(fact, widget.match)
                : buildCardIndicator(fact as CardP, widget.match),
          );
        },
      )
    ]);
  }

  Widget buildGoalIndicator(Goal goal, MatchDetails match) {
    String goalScorer = goal.name == "Άλλος" ? 'Γκολ' : goal.name;

    // Δυναμικά χρώματα για το Bubble
    Color bubbleColor =
        darkModeNotifier.value ? Colors.grey[800]! : Colors.white;
    Color textColor = darkModeNotifier.value ? Colors.white : Colors.black87;

    return InkWell(
        onLongPress: () {
          ((!widget.match.hasMatchEndedFinal ||
                      widget.match.startTimeInSeconds >
                          DateTime.now().millisecondsSinceEpoch ~/ 1000 -
                              110800) &&
                  globalUser.isUpperAdmin)
              ? showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => EditMatchFactModal(fact: goal, match: match),
                )
              : null;
        },
        child: Row(
          mainAxisAlignment:
              goal.isHomeTeam ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            if (!goal.isHomeTeam) const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(10),
                  // Διακριτική σκιά για να ξεκολλάει από το φόντο
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: goal.isHomeTeam
                    ? Text(
                        "${goal.timeString}'  ⚽  $goalScorer (${goal.homeScore}-${goal.awayScore})",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor),
                      )
                    : Text(
                        "(${goal.homeScore}-${goal.awayScore}) $goalScorer  ⚽  ${goal.timeString}'",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor),
                      ),
              ),
            ),
            if (goal.isHomeTeam) const Spacer(),
          ],
        ));
  }

  Widget buildCardIndicator(CardP card, MatchDetails match) {
    Color bubbleColor =
        darkModeNotifier.value ? Colors.grey[800]! : Colors.white;
    Color textColor = darkModeNotifier.value ? Colors.white : Colors.black87;

    // --- ΒΟΗΘΗΤΙΚΟ WIDGET ΓΙΑ ΝΑ ΖΩΓΡΑΦΙΖΟΥΜΕ ΤΙΣ ΚΑΡΤΕΣ ---
    Widget cardIcon;
    if (card.isSecondYellow) {
      // ΣΧΕΔΙΟ ΓΙΑ 2η ΚΙΤΡΙΝΗ (Επικάλυψη Κίτρινης με Κόκκινη)
      cardIcon = SizedBox(
        width: 18,
        height: 20,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 12,
                height: 16,
                decoration: BoxDecoration(
                    color: Colors.amberAccent,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: Colors.black26, width: 0.5)),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 16,
                decoration: BoxDecoration(
                    color: Colors.red[600],
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: Colors.black26, width: 0.5)),
              ),
            ),
          ],
        ),
      );
    } else {
      // ΑΠΛΗ ΚΙΤΡΙΝΗ Η ΑΠΕΥΘΕΙΑΣ ΚΟΚΚΙΝΗ
      cardIcon = Container(
          width: 12,
          height: 18,
          decoration: BoxDecoration(
              color: card.isYellow ? Colors.amberAccent : Colors.red[600]!,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: Colors.black26, width: 0.5)));
    }

    return InkWell(
      onLongPress: () {
        if (globalUser.isUpperAdmin) {
          _editCardDialog(context, card);
        }
      },
      child: Row(
        mainAxisAlignment:
            card.isHomeTeam ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (!card.isHomeTeam) const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ],
              ),
              child: card.isHomeTeam
                  ? Row(
                      children: [
                        Text("${card.timeString}' ",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColor)),
                        const SizedBox(width: 4),
                        cardIcon, // Εδώ μπαίνει το έξυπνο εικονίδιο
                        const SizedBox(width: 4),
                        Text(" ${card.name}",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColor)),
                      ],
                    )
                  : Row(
                      children: [
                        Text("${card.name} ",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColor)),
                        const SizedBox(width: 4),
                        cardIcon, // Εδώ μπαίνει το έξυπνο εικονίδιο
                        const SizedBox(width: 4),
                        Text(" ${card.timeString}'",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColor)),
                      ],
                    ),
            ),
          ),
          if (card.isHomeTeam) const Spacer(),
        ],
      ),
    );
  }

  void scoreChanged() {
    setState(() {});
  }

  Widget _sectionChooser(int selectedIndex, MatchDetails match) {
    switch (selectedIndex) {
      case 0:
        return _buildMatchDetails();
      case 1:
        return LineupsDisplayTab(match: match);
      case 2:
        DateTime now = DateTime.now();
        int seasonYear = now.month > 8 ? now.year : now.year - 1;
        return OneGroupStandings(
            group: match.homeTeam.group, seasonYear: seasonYear);
      default:
        return _buildMatchDetails();
    }
  }

  Widget _isAdminWidgetGoal(bool homeTeamScored) {
    if (globalUser.isUpperAdmin &&
        widget.match.hasExtraTimeFinished &&
        widget.match.isPenaltyTime &&
        !widget.match.isShootoutOver &&
        DateTime.now().millisecondsSinceEpoch ~/ 1000 <
            widget.match.startTimeInSeconds + 10 * 3600) {
      return Column(
        children: [
          SizedBox(height: 15),
          Text('Πέναλτι',
              style: TextStyle(
                  color: darkModeNotifier.value
                      ? Colors.grey[300]
                      : Colors.black)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () async {
                  await widget.match
                      .addPenalty(isScored: false, isHomeTeam: homeTeamScored);
                },
                icon: Icon(Icons.cancel, color: Colors.red, size: 30),
              ),
              IconButton(
                onPressed: () async {
                  await widget.match
                      .addPenalty(isScored: true, isHomeTeam: homeTeamScored);
                },
                icon: Icon(Icons.check_circle, color: Colors.green, size: 30),
              ),
            ],
          ),
        ],
      );
    } else if (globalUser.isUpperAdmin &&
        (!widget.match.hasMatchFinished ||
            (widget.match.isExtraTimeTime &&
                !widget.match.hasExtraTimeFinished))) {
      return GestureDetector(
        onTap: () {
          homeTeamScored
              ? _showInputDialogForGoal(
                  context, widget.match.homeTeam, homeTeamScored)
              : _showInputDialogForGoal(
                  context, widget.match.awayTeam, homeTeamScored);
        },
        child: Card(
            elevation: 10,
            color: Color.fromARGB(0, 15, 35, 30),
            child: Column(
              children: [
                SizedBox(height: 10, width: 50),
                Text("Γκολ",
                    style: TextStyle(
                        color: darkModeNotifier.value
                            ? Colors.grey[300]
                            : Colors.black,
                        fontSize: 18)),
                SizedBox(height: 10),
              ],
            )),
      );
    } else {
      return SizedBox(height: 35);
    }
  }

  Widget _matchProgressAdmin() {
    if ((DateTime.now().millisecondsSinceEpoch ~/ 1000 >
        widget.match.startTimeInSeconds + 3 * 3600)) {
      return SizedBox(height: 5);
    }
    if (widget.match.hasMatchFinished &&
        (!widget.match.isExtraTimeTime || widget.match.hasExtraTimeFinished) &&
        (globalUser.isUpperAdmin)) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
          elevation: 5,
        ),
        onPressed: () {
          widget.match.matchCancelProgressed();
          setState(() {});
        },
        child: Text(
          (!widget.match.hasExtraTimeFinished)
              ? "Ματς δεν τελείωσε"
              : 'Η παράταση δεν τελείωσε',
          style: TextStyle(color: Colors.white, fontSize: 9),
        ),
      );
    } else if (globalUser.isUpperAdmin) {
      MatchDetails match = widget.match;
      String progress = " ";
      String cancelProgress = " ";
      match.hasSecondHalfExtraTimeStarted
          ? (
              progress = "Τέλος Παράτασης",
              cancelProgress = "Ημίχρονο Παράτασης"
            )
          : match.hasFirstHalfExtraTimeFinished
              ? (
                  progress = "Εκκίνηση 2ου Ημιχρόνου Παράτασης",
                  cancelProgress = "1ο Ημίχρονο παράτασης"
                )
              : match.hasExtraTimeStarted
                  ? (
                      progress = "Ημίχρονο Παράτασης",
                      cancelProgress = "Η παράταση δεν ξεκίνησε"
                    )
                  : match.hasMatchFinished
                      ? (
                          progress = "Εκκίνηση Παράτασης",
                          cancelProgress = "Ο αγώνας δεν τελείωσε"
                        )
                      : match.hasSecondHalfStarted
                          ? (
                              progress = "Τέλος Αγώνα",
                              cancelProgress = "Ημίχρονο"
                            )
                          : match.hasFirstHalfFinished
                              ? (
                                  progress = "Εκκίννηση 2ου Ημιχρόνου",
                                  cancelProgress = "1ο ημίχρονο"
                                )
                              : (
                                  progress = "Τέλος 1ου Ημιχρόνου",
                                  cancelProgress = "Tο ματς δεν ξεκίνησε"
                                );

      return Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
              elevation: 5,
            ),
            onPressed: () {
              match.matchCancelProgressed();
              setState(() {});
            },
            child: Text(cancelProgress,
                style: TextStyle(color: Colors.white, fontSize: 9)),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                padding: EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                elevation: 5,
              ),
              onPressed: () {
                match.matchProgressed();
                setState(() {});
              },
              child: Column(
                children: [
                  SizedBox(height: 10, width: 50),
                  Text(progress,
                      style: TextStyle(color: Colors.blue, fontSize: 15)),
                  SizedBox(height: 10),
                ],
              )),
        ],
      );
    } else {
      return SizedBox(height: 5);
    }
  }


  void _showInputDialogForGoal(BuildContext context, Team team, bool homeTeamScored) {
    String? goalScorer;
    bool isOwnGoal = false;
    String? errorMessage;

    TextEditingController minuteController = TextEditingController(
        text: (widget.match.hasMatchStarted)
            ? ((DateTime.now().millisecondsSinceEpoch ~/ 1000 - widget.match.startTimeInSeconds) ~/ 60 + 1).toString()
            : "");

    Team opposingTeam = homeTeamScored ? widget.match.awayTeam : widget.match.homeTeam;

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            Team currentTeamList = isOwnGoal ? opposingTeam : team;
            List<String> currentStartersKeys = (currentTeamList.name == widget.match.homeTeam.name)
                ? widget.match.homeStarters
                : widget.match.awayStarters;

            List<Player> sortedPlayers = List.from(currentTeamList.players);
            sortedPlayers.sort((a, b) {
              bool isAActive = currentStartersKeys.contains("${a.name}${a.number}");
              bool isBActive = currentStartersKeys.contains("${b.name}${b.number}");
              if (isAActive && !isBActive) return -1;
              if (!isAActive && isBActive) return 1;
              return widget.match.getDisplayNumber(a).compareTo(widget.match.getDisplayNumber(b));
            });

            Map<String, bool> playerActiveStatus = {};

            List<String> dropdownItems = sortedPlayers.map((player) {
              String key = "${player.name}${player.number}";
              bool isActive = currentStartersKeys.contains(key);
              String itemString = "${widget.match.getDisplayNumber(player)} - ${player.name.substring(0, 1)}. ${player.surname}";
              playerActiveStatus[itemString] = isActive;
              return itemString;
            }).toList();

            dropdownItems.add("Άλλος");
            playerActiveStatus["Άλλος"] = false;

            return AlertDialog(
              backgroundColor: darkModeNotifier.value ? Colors.grey[900] : Colors.white,
              title: Text(isOwnGoal ? "ΑΥΤΟΓΚΟΛ ΥΠΕΡ ${team.name}" : "ΓΚΟΛ ${team.name}",
                  style: TextStyle(color: darkModeNotifier.value ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text("Είναι Αυτογκόλ;", style: TextStyle(color: darkModeNotifier.value ? Colors.white70 : Colors.black87)),
                    value: isOwnGoal,
                    activeColor: Colors.redAccent,
                    onChanged: (bool value) => setDialogState(() {
                      isOwnGoal = value;
                      goalScorer = null;
                      errorMessage = null;
                    }),
                  ),
                  const SizedBox(height: 10),
                  DropdownSearch<String>(
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      menuProps: MenuProps(backgroundColor: darkModeNotifier.value ? Colors.grey[850] : Colors.white),
                      itemBuilder: (context, item, isSelected) {
                        bool isOther = item == "Άλλος";
                        bool isActive = playerActiveStatus[item] ?? false;
                        String number = isOther ? "" : item.split(" - ")[0];
                        String name = isOther ? "Άλλος" : item.split(" - ")[1];

                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: isOther
                                ? Colors.grey
                                : (isOwnGoal ? Colors.red[600] : (isActive ? Colors.blue[700] : Colors.blue[200])),
                            child: isOther
                                ? const Icon(Icons.person, size: 14, color: Colors.white)
                                : Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                          title: Text(name,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: isActive
                                      ? (darkModeNotifier.value ? Colors.white : Colors.black)
                                      : (darkModeNotifier.value ? Colors.grey[400] : Colors.grey[700]),
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
                        );
                      },
                    ),
                    items: dropdownItems,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: isOwnGoal ? "Παίκτης που έβαλε το αυτογκόλ:" : "Σκόρερ:",
                        labelStyle: TextStyle(color: darkModeNotifier.value ? Colors.blue[200] : Colors.blue[800]),
                        filled: true,
                        fillColor: darkModeNotifier.value ? Colors.grey[850] : Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      baseStyle: TextStyle(color: darkModeNotifier.value ? Colors.white : Colors.black),
                    ),
                    selectedItem: goalScorer,
                    onChanged: (val) => setDialogState(() {
                      goalScorer = val;
                      errorMessage = null;
                    }),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: minuteController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: darkModeNotifier.value ? Colors.white : Colors.black),
                    onChanged: (val) => setDialogState(() => errorMessage = null),
                    decoration: InputDecoration(
                      labelText: "Λεπτό Γκολ",
                      labelStyle: TextStyle(color: darkModeNotifier.value ? Colors.blue[200] : Colors.blue[800]),
                      filled: true,
                      fillColor: darkModeNotifier.value ? Colors.grey[850] : Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      prefixIcon: Icon(Icons.timer_outlined, color: darkModeNotifier.value ? Colors.grey[400] : Colors.grey[700]),
                    ),
                  ),

                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                          const SizedBox(width: 5),
                          Expanded(child: Text(errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),

                ],
              ),
              actions: [
                TextButton(
                    child: Text("Ακύρωση", style: TextStyle(color: Colors.grey[600])),
                    onPressed: () => Navigator.pop(context)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: isOwnGoal ? Colors.red[600] : Colors.green[600]),
                  onPressed: () {
                    if (goalScorer == null) {
                      setDialogState(() => errorMessage = "Παρακαλώ επίλεξε σκόρερ!");
                      return; // Σταματάει εδώ, ΔΕΝ κλείνει το dialog
                    }

                    int? parsedMinute = int.tryParse(minuteController.text);
                    if (parsedMinute == null) {
                      setDialogState(() => errorMessage = "Παρακαλώ βάλε έγκυρο λεπτό!");
                      return; // Σταματάει εδώ
                    }

                    int finalSeconds = (parsedMinute - 1) * 60;

                    String name = goalScorer == "Άλλος" ? "Άλλος" : goalScorer!.split(" - ")[1];
                    if (isOwnGoal && goalScorer != 'Άλλος') name = "$name (ΑΥΤ.)";

                    homeTeamScored
                        ? widget.match.homeScored(name, goalScorer != 'Άλλος' && !isOwnGoal, minute: finalSeconds)
                        : widget.match.awayScored(name, goalScorer != 'Άλλος' && !isOwnGoal, minute: finalSeconds);

                    Navigator.pop(context); // Τώρα που όλα είναι τέλεια, κλείνει το dialog!
                  },
                  child: const Text("Υποβολή", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          });
        });
  }


  Widget _cardAdmin(bool homeTeamCard) {
    if (globalUser.isUpperAdmin &&
        (!widget.match.hasMatchFinished ||
            (widget.match.isExtraTimeTime &&
                !widget.match.hasExtraTimeFinished)) &&
        !widget.match.isExtraTimeHalf()) {
      return TextButton(
          onPressed: () {
            homeTeamCard
                ? _showInputDialogCard(
                    context, widget.match.homeTeam, homeTeamCard)
                : _showInputDialogCard(
                    context, widget.match.awayTeam, homeTeamCard);
            setState(() {});
          },
          child: Card(
              color: Colors.grey[200],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 10,
              child: Text("Κάρτα",
                  style: TextStyle(color: Colors.black, fontSize: 15))));
    } else {
      return SizedBox(height: 5);
    }
  }

  void _showInputDialogCard(BuildContext context, Team team, bool homeTeamCard) {
    String? selectedCardPlayer;
    bool isYellow = true;
    bool hasPreviousYellow = false;
    TextEditingController reasonController = TextEditingController();

    String? errorMessage;

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            List<String> currentStartersKeys = (team.name == widget.match.homeTeam.name)
                ? widget.match.homeStarters
                : widget.match.awayStarters;

            List<Player> sortedPlayers = List.from(team.players);
            sortedPlayers.sort((a, b) {
              bool isAActive = currentStartersKeys.contains("${a.name}${a.number}");
              bool isBActive = currentStartersKeys.contains("${b.name}${b.number}");
              if (isAActive && !isBActive) return -1;
              if (!isAActive && isBActive) return 1;
              return widget.match.getDisplayNumber(a).compareTo(widget.match.getDisplayNumber(b));
            });

            Map<String, bool> playerActiveStatus = {};

            List<String> dropdownItems = sortedPlayers.map((player) {
              String key = "${player.name}${player.number}";
              bool isActive = currentStartersKeys.contains(key);
              String itemString = "${widget.match.getDisplayNumber(player)} - ${player.name.substring(0, 1)}. ${player.surname}";
              playerActiveStatus[itemString] = isActive;
              return itemString;
            }).toList();

            return AlertDialog(
              backgroundColor: darkModeNotifier.value ? Colors.grey[900] : Colors.white,
              title: Text("ΚΑΡΤΑ - ${team.name}",
                  style: TextStyle(
                      color: darkModeNotifier.value ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownSearch<String>(
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          style: TextStyle(color: darkModeNotifier.value ? Colors.white : Colors.black),
                          decoration: InputDecoration(
                            hintText: "Αναζήτηση με όνομα ή νούμερο...",
                            hintStyle: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        emptyBuilder: (_, __) => const Center(
                            child: Text("Δεν βρέθηκαν παίκτες", style: TextStyle(color: Colors.grey))),
                        menuProps: MenuProps(
                            backgroundColor: darkModeNotifier.value ? Colors.grey[850] : Colors.white),
                        itemBuilder: (context, item, isSelected) {
                          bool isActive = playerActiveStatus[item] ?? false;
                          String number = item.split(" - ")[0];
                          String name = item.split(" - ")[1];

                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 14,
                              backgroundColor: isActive ? Colors.blue[700] : Colors.blue[200],
                              child: Text(number,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                            title: Text(name,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: isActive
                                        ? (darkModeNotifier.value ? Colors.white : Colors.black)
                                        : (darkModeNotifier.value ? Colors.grey[400] : Colors.grey[700]),
                                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
                          );
                        },
                      ),
                      items: dropdownItems,
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Επιλογή Παίκτη:",
                          labelStyle: TextStyle(color: darkModeNotifier.value ? Colors.blue[200] : Colors.blue[800]),
                          filled: true,
                          fillColor: darkModeNotifier.value ? Colors.grey[850] : Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        ),
                        baseStyle: TextStyle(color: darkModeNotifier.value ? Colors.white : Colors.black),
                      ),
                      selectedItem: selectedCardPlayer,
                      onChanged: (newValue) {
                        setDialogState(() {
                          selectedCardPlayer = newValue;
                          hasPreviousYellow = false;
                          errorMessage = null;

                          if (newValue != null) {
                            String exactName = newValue.split(" - ")[1];
                            for (var halfList in widget.match.matchFact.values) {
                              for (var fact in halfList) {
                                if (fact is CardP && fact.name == exactName && fact.isYellow) {
                                  hasPreviousYellow = true;
                                  isYellow = false;
                                }
                              }
                            }
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    if (hasPreviousYellow)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red)),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(
                                    "Ο παίκτης έχει ήδη κίτρινη! Η κάρτα μετατράπηκε αυτόματα σε 2η Κίτρινη/Κόκκινη.",
                                    style: TextStyle(color: Colors.red[900], fontSize: 12, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: hasPreviousYellow
                              ? null
                              : () {
                            setDialogState(() {
                              isYellow = true;
                              errorMessage = null;
                            });
                          },
                          child: Opacity(
                            opacity: hasPreviousYellow ? 0.3 : 1.0,
                            child: Column(
                              children: [
                                Container(
                                  width: 45,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    color: Colors.yellow[600],
                                    borderRadius: BorderRadius.circular(5),
                                    border: isYellow
                                        ? Border.all(color: darkModeNotifier.value ? Colors.white : Colors.black, width: 3)
                                        : null,
                                    boxShadow: isYellow
                                        ? [BoxShadow(color: Colors.yellowAccent.withOpacity(0.5), blurRadius: 10)]
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text("Κίτρινη",
                                    style: TextStyle(
                                        color: darkModeNotifier.value ? Colors.white : Colors.black,
                                        fontWeight: isYellow ? FontWeight.bold : FontWeight.normal))
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              isYellow = false;
                              errorMessage = null;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 45,
                                height: 65,
                                decoration: BoxDecoration(
                                  color: Colors.red[600],
                                  borderRadius: BorderRadius.circular(5),
                                  border: !isYellow
                                      ? Border.all(color: darkModeNotifier.value ? Colors.white : Colors.black, width: 3)
                                      : null,
                                  boxShadow: !isYellow
                                      ? [BoxShadow(color: Colors.redAccent.withOpacity(0.5), blurRadius: 10)]
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text("Κόκκινη",
                                  style: TextStyle(
                                      color: darkModeNotifier.value ? Colors.white : Colors.black,
                                      fontWeight: !isYellow ? FontWeight.bold : FontWeight.normal))
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: reasonController,
                      style: TextStyle(color: darkModeNotifier.value ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: "Αιτιολογία (Προαιρετικό)",
                        labelStyle: TextStyle(color: darkModeNotifier.value ? Colors.blue[200] : Colors.blue[800]),
                        filled: true,
                        fillColor: darkModeNotifier.value ? Colors.grey[850] : Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        prefixIcon: Icon(Icons.edit_document, color: darkModeNotifier.value ? Colors.grey[400] : Colors.grey[700]),
                      ),
                    ),

                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                            const SizedBox(width: 5),
                            Expanded(child: Text(errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),

                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text("Ακύρωση", style: TextStyle(color: Colors.grey[600])),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: isYellow ? Colors.yellow[700] : Colors.red[700]),
                  onPressed: () {
                    if (selectedCardPlayer == null) {
                      setDialogState(() => errorMessage = "Παρακαλώ επίλεξε παίκτη!");
                      return; // Σταματάει εδώ, ΔΕΝ κλείνει το dialog
                    }

                    String finalPlayerName = selectedCardPlayer!.split(" - ")[1];
                    String? finalReason = reasonController.text.trim().isEmpty ? null : reasonController.text.trim();

                    homeTeamCard
                        ? widget.match.playerGotCard(
                        finalPlayerName, widget.match.homeTeam, isYellow, null, homeTeamCard,
                        isSecondYellow: hasPreviousYellow, reason: finalReason)
                        : widget.match.playerGotCard(
                        finalPlayerName, widget.match.awayTeam, isYellow, null, homeTeamCard,
                        isSecondYellow: hasPreviousYellow, reason: finalReason);

                    Navigator.of(context).pop(); // Κλείνει το dialog
                  },
                  child: Text("Υποβολή", style: TextStyle(color: isYellow ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          });
        });
  }
  void _editCardDialog(BuildContext context, CardP card) {
    TextEditingController minuteController = TextEditingController(text: card.timeString);
    TextEditingController reasonController = TextEditingController(text: card.reason ?? "");

    bool isYellow = card.isYellow;
    bool isSecondYellow = card.isSecondYellow;
    String? selectedCardPlayer;
    int half = card.half;
    bool hasSubsequentSecondYellow = false;
    int? secondYellowMinuteRaw;
    bool hasPreviousFirstYellow = false;
    int? firstYellowMinuteRaw;
    String? errorMessage;

    if (card.isYellow && !card.isSecondYellow) {
      for (var halfList in widget.match.matchFact.values) {
        for (var fact in halfList) {
          if (fact is CardP && fact.name == card.name && fact.isSecondYellow) {
            hasSubsequentSecondYellow = true;
            secondYellowMinuteRaw = fact.minute;
            break;
          }
        }
      }
    }

    if (card.isSecondYellow) {
      for (var halfList in widget.match.matchFact.values) {
        for (var fact in halfList) {
          if (fact is CardP && fact.name == card.name && fact.isYellow && !fact.isSecondYellow) {
            hasPreviousFirstYellow = true;
            firstYellowMinuteRaw = fact.minute;
            break;
          }
        }
      }
    }

    bool checkHasPreviousYellow(String newPlayerName) {
      bool hasPrev = false;
      for (var halfList in widget.match.matchFact.values) {
        for (var fact in halfList) {
          if (fact is CardP && fact.name == newPlayerName && fact.isYellow && !fact.isSecondYellow && fact != card) {
            hasPrev = true;
          }
        }
      }
      return hasPrev;
    }

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            bool isDark = darkModeNotifier.value;
            Color bgColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
            Color fieldColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey[100]!;
            Color textColor = isDark ? Colors.white : Colors.black87;
            Color labelColor = isDark ? Colors.blue[200]! : Colors.blue[800]!;

            List<String> currentStartersKeys = (card.team.name == widget.match.homeTeam.name)
                ? widget.match.homeStarters
                : widget.match.awayStarters;

            List<Player> sortedPlayers = List.from(card.team.players);
            sortedPlayers.sort((a, b) {
              bool isAActive = currentStartersKeys.contains("${a.name}${a.number}");
              bool isBActive = currentStartersKeys.contains("${b.name}${b.number}");
              if (isAActive && !isBActive) return -1;
              if (!isAActive && isBActive) return 1;
              return widget.match.getDisplayNumber(a).compareTo(widget.match.getDisplayNumber(b));
            });

            Map<String, bool> playerActiveStatus = {};
            List<String> dropdownItems = sortedPlayers.map((player) {
              String key = "${player.name}${player.number}";
              bool isActive = currentStartersKeys.contains(key);
              String itemString = "${widget.match.getDisplayNumber(player)} - ${player.name.substring(0, 1)}. ${player.surname}";
              playerActiveStatus[itemString] = isActive;
              if (itemString.endsWith(card.name)) selectedCardPlayer ??= itemString;
              return itemString;
            }).toList();

            selectedCardPlayer ??= dropdownItems.firstWhere((item) => item.contains(card.name), orElse: () => dropdownItems.first);
            bool hasPreviousYellowForNewPlayer = checkHasPreviousYellow(selectedCardPlayer!.split(" - ")[1]);

            return Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(color: isDark ? Colors.grey[700] : Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                    ),

                    Text("Επεξεργασία Κάρτας", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 15),

                    if (hasSubsequentSecondYellow)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange)),
                        child: Row(
                          children: [
                            const Icon(Icons.lock, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(child: Text("Ο παίκτης έχει 2η κίτρινη. Παίκτης & χρώμα κλειδώθηκαν.", style: TextStyle(color: Colors.orange[900], fontSize: 12, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),

                    DropdownSearch<String>(
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(hintText: "Αναζήτηση...", hintStyle: const TextStyle(color: Colors.grey), border: InputBorder.none),
                        ),
                        menuProps: MenuProps(backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        itemBuilder: (context, item, isSelected) {
                          bool isActive = playerActiveStatus[item] ?? false;
                          String number = item.split(" - ")[0];
                          String name = item.split(" - ")[1];
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(radius: 14, backgroundColor: isActive ? Colors.blue[700] : Colors.blue[200], child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                            title: Text(name, style: TextStyle(fontSize: 14, color: textColor, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
                          );
                        },
                      ),
                      items: dropdownItems,
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(labelText: "Επιλογή Παίκτη:", labelStyle: TextStyle(color: labelColor), filled: true, fillColor: fieldColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                        baseStyle: TextStyle(color: textColor),
                      ),
                      selectedItem: selectedCardPlayer,
                      enabled: !hasSubsequentSecondYellow,
                      onChanged: (newValue) {
                        setDialogState(() {
                          selectedCardPlayer = newValue;
                          String newName = newValue!.split(" - ")[1];
                          if (checkHasPreviousYellow(newName)) {
                            isYellow = false;
                            isSecondYellow = true;
                          } else {
                            isYellow = true;
                            isSecondYellow = false;
                          }
                          if (errorMessage != null) errorMessage = null;
                        });
                      },
                    ),
                    const SizedBox(height: 15),

                    Opacity(
                      opacity: hasSubsequentSecondYellow ? 0.5 : 1.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: (hasSubsequentSecondYellow || hasPreviousYellowForNewPlayer)
                                ? null
                                : () => setDialogState(() { isYellow = true; isSecondYellow = false; }),
                            child: Opacity(
                              opacity: (hasPreviousYellowForNewPlayer || isSecondYellow) ? 0.3 : 1.0,
                              child: Column(
                                children: [
                                  Container(
                                    width: 40, height: 55,
                                    decoration: BoxDecoration(color: Colors.yellow[600], borderRadius: BorderRadius.circular(5), border: isYellow ? Border.all(color: textColor, width: 3) : null, boxShadow: isYellow ? [BoxShadow(color: Colors.yellowAccent.withOpacity(0.5), blurRadius: 10)] : null),
                                  ),
                                  const SizedBox(height: 5),
                                  Text("Κίτρινη", style: TextStyle(color: textColor, fontSize: 12))
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: hasSubsequentSecondYellow ? null : () => setDialogState(() { isYellow = false; if (!hasPreviousYellowForNewPlayer) isSecondYellow = false; }),
                            child: Column(
                              children: [
                                Container(
                                  width: 40, height: 55,
                                  decoration: BoxDecoration(color: Colors.red[600], borderRadius: BorderRadius.circular(5), border: !isYellow ? Border.all(color: textColor, width: 3) : null, boxShadow: !isYellow ? [BoxShadow(color: Colors.redAccent.withOpacity(0.5), blurRadius: 10)] : null),
                                ),
                                const SizedBox(height: 5),
                                Text("Κόκκινη", style: TextStyle(color: textColor, fontSize: 12))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: minuteController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                            onChanged: (val) { if (errorMessage != null) setDialogState(() => errorMessage = null); },
                            decoration: InputDecoration(labelText: "Λεπτό", labelStyle: TextStyle(color: labelColor), filled: true, fillColor: fieldColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), prefixIcon: Icon(Icons.timer_outlined, color: isDark ? Colors.grey[400] : Colors.grey[700])),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<int>(
                            value: half,
                            dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                            style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(labelText: "Ημίχρονο", labelStyle: TextStyle(color: labelColor), filled: true, fillColor: fieldColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                            items: [
                              const DropdownMenuItem(value: 0, child: Text('1ο Ημίχρονο')),
                              const DropdownMenuItem(value: 1, child: Text('2ο Ημίχρονο')),
                              if (widget.match.hasExtraTimeStarted) const DropdownMenuItem(value: 2, child: Text('1ο Ημ. Παράτασης')),
                              if (widget.match.hasSecondHalfExtraTimeStarted) const DropdownMenuItem(value: 3, child: Text('2ο Ημ. Παράτασης')),
                            ],
                            onChanged: (value) => setDialogState(() { half = value ?? 1; if (errorMessage != null) errorMessage = null; }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: reasonController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "Αιτιολογία (Προαιρετικό)",
                        labelStyle: TextStyle(color: labelColor),
                        filled: true,
                        fillColor: fieldColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        prefixIcon: Icon(Icons.edit_document, color: isDark ? Colors.grey[400] : Colors.grey[700]),
                      ),
                    ),

                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                            const SizedBox(width: 5),
                            Expanded(child: Text(errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),

                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            if (hasSubsequentSecondYellow) {
                              setDialogState(() => errorMessage = "Δεν μπορείτε να διαγράψετε την 1η κίτρινη. Διαγράψτε πρώτα την 2η (Κόκκινη)!");
                              return;
                            }

                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                title: Text('Επιβεβαίωση', style: TextStyle(color: textColor)),
                                content: Text('Είσαι σίγουρος ότι θέλεις να διαγράψεις αυτή την Κάρτα;', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Ακύρωση', style: TextStyle(color: Colors.grey))),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      Navigator.of(context).pop();
                                      widget.match.cancelCard(card);
                                    },
                                    child: const Text('Διαγραφή', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Text("Διαγραφή",
                              style: TextStyle(color: hasSubsequentSecondYellow ? Colors.grey : Colors.red[600], fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
                          onPressed: () {
                            if (minuteController.text.isNotEmpty && selectedCardPlayer != null) {
                              String finalPlayerName = selectedCardPlayer!.split(" - ")[1];
                              int? parsedNewMinute = int.tryParse(minuteController.text);
                              if (parsedNewMinute == null) {
                                setDialogState(() => errorMessage = "Παρακαλώ εισάγετε έγκυρο αριθμό!");
                                return;
                              }
                              int newRawSeconds = (parsedNewMinute - 1) * 60;

                              if (hasSubsequentSecondYellow && secondYellowMinuteRaw != null && newRawSeconds >= secondYellowMinuteRaw!) {
                                setDialogState(() => errorMessage = "Η 2η κίτρινη είναι στο ${(secondYellowMinuteRaw! ~/ 60) + 1}'. Η 1η πρέπει να είναι νωρίτερα!");
                                return;
                              }
                              if (isSecondYellow && firstYellowMinuteRaw != null && newRawSeconds <= firstYellowMinuteRaw!) {
                                setDialogState(() => errorMessage = "Η 1η κίτρινη είναι στο ${(firstYellowMinuteRaw! ~/ 60) + 1}'. Η 2η πρέπει να είναι αργότερα!");
                                return;
                              }

                              String? finalReason = reasonController.text.trim().isEmpty ? null : reasonController.text.trim();

                              Navigator.of(context).pop();
                              _saveEditedCard(card, minuteController.text, finalPlayerName, isYellow, isSecondYellow, half, finalReason);
                            }
                          },
                          child: const Text("Αποθήκευση", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  Future<void> _saveEditedCard(
      CardP oldCard,
      String newMinuteString,
      String newPlayerName,
      bool isYellow,
      bool isSecondYellow,
      int half,
      String? reason) async
  {
    int? newMinute = int.tryParse(newMinuteString);

    if (newMinute != null) {
      int seconds = (newMinute - 1) * 60;
      CardP newCard = CardP(
        name: newPlayerName,
        team: oldCard.team,
        isYellow: isYellow,
        isSecondYellow: isSecondYellow,
        reason: reason, // 🌟 Περνάμε την αιτιολογία!
        minute: seconds,
        isHomeTeam: oldCard.isHomeTeam,
        half: half,
      );
      await widget.match.editCard(oldCard, newCard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Παρακαλώ εισάγετε έναν έγκυρο αριθμό λεπτού."),
        backgroundColor: Colors.red,
      ));
    }
  }

  //Κουμπί για το Φύλλο Αγώνα
  Widget _buildPdfReportButton() {
    // Ελέγχουμε αν είναι admin ΚΑΙ αν το ματς έχει τελειώσει οριστικά!
    if (globalUser.isUpperAdmin && widget.match.hasMatchEndedFinal && !(DateTime.now().millisecondsSinceEpoch ~/ 1000 >
        widget.match.startTimeInSeconds + 3 * 3600)) {
      return Padding(
        padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[800], // Επίσημο χρώμα
            elevation: 8,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
          label: const Text(
            "Φύλλο Αγώνα & Υπογραφές",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          onPressed: () {
            // Εδώ τον στέλνουμε στην οθόνη υπογραφών που φτιάξαμε!

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MatchReportScreen(match: widget.match),
              ),
            );

            print("Πάμε για υπογραφές!");
          },
        ),
      );
    }
    // Αν το ματς παίζεται ακόμα, δεν δείχνουμε τίποτα.
    return const SizedBox.shrink();
  }
}
