import 'dart:async';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Data_Classes/Player.dart';
import 'package:untitled1/Firebase_Handle/user_handle_in_base.dart';
import 'package:untitled1/Match_Details_Package/penalty_shootout_widget.dart';
import 'package:untitled1/championship_details/StandingsPage.dart';
import 'package:untitled1/globals.dart';
import '../../Data_Classes/MatchDetails.dart';
import 'package:provider/provider.dart';
import '../API/user_handle.dart';
import '../Data_Classes/Penaltys.dart';
import '../Data_Classes/Team.dart';
import '../Data_Classes/match_facts.dart';
import '../Team_Display_Page_Package/one_group_standings.dart';
import 'Match_Not_Started/Match_Not_Started_Details_Page.dart';
import 'Starting__11_Display_Card.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
  }

  @override
  void dispose() {
    _timer?.cancel();
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
    _secondsElapsed = DateTime.now().millisecondsSinceEpoch ~/ 1000 - _startTimeInSeconds;
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
    return Container(
      //color: Colors.blueGrey,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              color:darkModeNotifier.value? Colors.grey[900]: Color.fromARGB(50, 5, 150, 200),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    Center(
                        child: Text(
                          widget.match.matchweekInfo(),
                          style: TextStyle(
                              fontSize: 13,
                              color: darkModeNotifier.value?Colors.white: Colors.grey[800]),
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
                          child: (((widget.match.hasMatchFinished && !widget.match.isExtraTimeTime) ||( widget.match.hasExtraTimeFinished && !widget.match.isPenaltyTime)) || widget.match.isShootoutOver)
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
                    const Divider(),
                    NavigationButtons(onSectionChange: _changeSection),
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

    (widget.match.homeScore+widget.match.penaltyScoreHome > widget.match.awayScore+widget.match.penaltyScoreAway) ? {homeColor = darkModeNotifier.value ? Colors.white : Colors.black, awayColor = Colors.grey}
        : (widget.match.homeScore+widget.match.penaltyScoreHome < widget.match.awayScore+widget.match.penaltyScoreAway)
            ? {homeColor = Colors.grey, awayColor = darkModeNotifier.value ? Colors.white : Colors.black}
            : {homeColor = Colors.blueGrey, awayColor = Colors.blueGrey};

    return Container(
      //color:darkModeNotifier.value? Colors.grey[900]: Color.fromARGB(50, 5, 150, 200),
      child: Column(
        children: [
          Text(
              widget.match.dateString,
            style: TextStyle(
                color: darkModeNotifier.value?Colors.white:Colors.black
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${widget.match.homeScore+widget.match.penaltyScoreHome}",
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
              Text("${widget.match.awayScore+widget.match.penaltyScoreAway}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: awayColor)),
            ],
          ),
          Text('Ολοκληρώθηκε',
              style: TextStyle(
                  fontWeight: FontWeight.w400, fontSize: 12,
                  color: darkModeNotifier.value?Colors.white: Colors.black))
        ],
      ),
    );
  }

  Widget _buildMatchTimer() {
    return Consumer<MatchDetails>(
      builder: (context, matchDetails, child) {
        // Λαμβάνουμε το χρόνο σε δευτερόλεπτα από το matchDetails
        int secondsElapsed = DateTime.now().millisecondsSinceEpoch ~/ 1000-matchDetails.startTimeInSeconds;

        int minutes = secondsElapsed ~/ 60;
        int seconds = secondsElapsed % 60;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 15),
            Text(
              "${matchDetails.homeScore+matchDetails.penaltyScoreHome}-${matchDetails.awayScore+matchDetails.penaltyScoreAway}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.red),
            ),

            (matchDetails.isPenaltyTime)?
            Text(
              'Πέναλτι',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red),
              textAlign: TextAlign.center,
            ):
            // Ελέγχουμε αν είναι το ημίχρονο ή όχι
            (!matchDetails.isHalfTime() && !matchDetails.isExtraTimeHalf() && !(matchDetails.hasMatchFinished && !matchDetails.hasExtraTimeStarted))
                ? Text(
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
            )
                : Text(
          (matchDetails.hasMatchFinished && !matchDetails.hasExtraTimeStarted)? 'Αναμονή Παράτασης': matchDetails.isHalfTime() ? 'Ημίχρονο' : 'Ημίχρονο Παράτασης',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red),
              textAlign: TextAlign.center,
            )
          ],
        );
      },
    );
  }


  Widget _buildMatchDetails() {
    return Column(
      children: [
        if (globalUser.controlTheseTeams(
            widget.match.homeTeam.name,widget.match.awayTeam.name) && widget.match.isPenaltyTime && (DateTime.now().millisecondsSinceEpoch ~/ 1000<widget.match.startTimeInSeconds + 3*3600))
          ElevatedButton(onPressed:() async {
           await widget.match.cancelPenalty();
           setState(() {

           });
          }, child: Text('Διαγραφή τελευταίου πέναλτι')),

        if (widget.match.isPenaltyTime)
          ChangeNotifierProvider(
            key: ValueKey(widget.match.matchDocId), // 👈 εξαναγκάζει ανανέωση
            create: (_) => PenaltyShootoutManager(matchDocId: widget.match.matchDocId),
            child: PenaltyShootoutPanel(
              homeTeam: widget.match.homeTeam,
              awayTeam: widget.match.awayTeam,
            ),
          ),

        if (widget.match.isExtraTimeTime && widget.match.hasSecondHalfExtraTimeStarted)
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
    int ha= (half % 2==0) ? 2 : 1;
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 1,
            width: (half>2) ? 65 : 100,
            color: (( widget.match.hasMatchFinished && !widget.match.isExtraTimeTime) || widget.match.hasExtraTimeFinished)
                ? Colors.blueGrey
                : Colors.redAccent,
          ),
          Text(
            " ${ha}ο ημίχρονο ${(half>2) ? 'παράτασης' : ""}",
            style: TextStyle(
                color:(( widget.match.hasMatchFinished && !widget.match.isExtraTimeTime) || widget.match.hasExtraTimeFinished) ?darkModeNotifier.value?Colors.white: Colors.black : Colors.redAccent),
          ),
          Container(

            height: 1,
            width: (half>2) ? 65 : 100,
            color: (( widget.match.hasMatchFinished && !widget.match.isExtraTimeTime) || widget.match.hasExtraTimeFinished)
                ? Colors.blueGrey
                : Colors.redAccent,
          ),
        ],
      ),
      ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(), // Prevents nested scrolling
        itemCount: (widget.match.matchFact[half - 1] ?? []).length,
        itemBuilder: (context, index) {
          int reversedIndex =
              (widget.match.matchFact[half - 1]!.length - 1) - index;
          return Padding(
            padding: const EdgeInsets.all(2.0),
            child: (widget.match.matchFact[half - 1]![reversedIndex] is Goal)
                ? buildGoalIndicator(
                    widget.match.matchFact[half - 1]![reversedIndex] as Goal,widget.match)
                : buildCardIndicator(
                    widget.match.matchFact[half - 1]![reversedIndex] as CardP,widget.match),
          );
        },
      ),
    ]);
  }

  Widget buildGoalIndicator(Goal goal,MatchDetails match) {
    String goalScorer;
    goal.scorerName == "Άλλος" ?  goalScorer='Γκολ' : goalScorer = goal.scorerName;

    return InkWell(
        onLongPress:() {
          ((!widget.match.hasMatchEndedFinal || widget.match.startTimeInSeconds >
              DateTime.now().millisecondsSinceEpoch ~/ 1000 - 110800) &&
              globalUser.controlTheseTeams(
                  widget.match.homeTeam.name, widget.match.awayTeam.name))
              ?
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) =>
                EditMatchFactModal(
                  fact: goal, // ή card
                  //onSave: (updatedFact) {
                  //  // πχ. setState ή ενημέρωση σε provider / db
                  //},
                  match:match,
                ),
          ) : null;
        },
        child: Row(
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
                  borderRadius: BorderRadius.circular(10),
                ),
                //border: Border.all(color: Colors.grey)),
                child: goal.isHomeTeam
                    ? Text(
                        '${goal.timeString} \u0301 ⚽ $goalScorer (${goal.homeScore}-${goal.awayScore})',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: darkModeNotifier.value?Colors.grey[300]: Colors.black
                        ),
                      )
                    : Text(
                        '(${goal.homeScore}-${goal.awayScore}) $goalScorer ⚽ ${goal.timeString} \u0301 ',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: darkModeNotifier.value?Colors.grey[300]: Colors.black
                        ),
                      ),
              ),
            ),
            if (goal.isHomeTeam)
              Spacer(), // Αν είναι η γηπεδούχος ομάδα, μετακινεί το κείμενο αριστερά
          ],
        ));
  }

  Widget buildCardIndicator(CardP card,MatchDetails match) {
    Color color;
    card.isYellow ? color = Colors.yellow : color = Colors.red;

    return InkWell(
      onLongPress: () {
        setState(() {
          _cancelCardDialog(context, card);
        });
      },
      child: Row(
        mainAxisAlignment:
            card.isHomeTeam ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (!card.isHomeTeam)
            Spacer(), // Αν είναι η εκτός έδρας ομάδα, μετακινεί το κείμενο δεξιά
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Color.fromARGB(10, 15, 35, 30),
                borderRadius: BorderRadius.circular(10),
              ),
              //border: Border.all(color: Colors.grey)),
              child: card.isHomeTeam
                  ? Row(
                      children: [
                        Text('${card.timeString} \u0301 ',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                        Container(
                          width: 13,
                          height: 20,
                          color: color,
                        ),
                        Text(
                          ' ${card.name} ',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Text(
                          ' ${card.name} ',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        Container(
                          width: 13,
                          height: 20,
                          color: color,
                        ),
                        Text(
                          ' ${card.timeString} \u0301 ',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
            ),
          ),
          if (card.isHomeTeam)
            Spacer(), // Αν είναι η γηπεδούχος ομάδα, μετακινεί το κείμενο αριστερά
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
     // case 1:
     //   return Starting11Display(
     //     match: match,
     //   );
      case 1:
        DateTime now = DateTime.now();
        int seasonYear = now.month > 8 ? now.year : now.year - 1;
        return OneGroupStandings(group: match.homeTeam.group, seasonYear: seasonYear,);
      default:
        return _buildMatchDetails();
    }
  }

  Widget _isAdminWidgetGoal(bool homeTeamScored) {
    // Check if the user is logged in

    if (globalUser.controlTheseTeams(
        widget.match.homeTeam.name, widget.match.awayTeam.name) && widget.match.hasExtraTimeFinished && !widget.match.isShootoutOver  && DateTime.now().millisecondsSinceEpoch ~/ 1000<widget.match.startTimeInSeconds + 10*3600 ) {
      return Column(
        children: [
          SizedBox(height: 15,),
          Text('Πέναλτι',style:TextStyle(color: darkModeNotifier.value?Colors.grey[300]: Colors.black)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () async {
                      await widget.match.addPenalty(isScored: false, isHomeTeam: homeTeamScored);
                    },
                    icon: Icon(Icons.cancel,color: Colors.red,size: 30),
                  ),
                  IconButton(
                    onPressed: () async {
                      await widget.match.addPenalty(isScored: true, isHomeTeam: homeTeamScored);
                    },
                    icon: Icon(Icons.check_circle,color: Colors.green,size: 30,),
                  ),
                ],
              ),
        ],
      );
      }
    else if (globalUser.controlTheseTeams(
            widget.match.homeTeam.name, widget.match.awayTeam.name) && (!widget.match.hasMatchFinished || (widget.match.isExtraTimeTime && !widget.match.hasExtraTimeFinished)) ) {
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
                SizedBox(
                  height: 10,
                  width: 50,
                ),
                Text(
                  "Γκολ",
                  style: TextStyle(
                      color:darkModeNotifier.value?Colors.grey[300]: Colors.black,
                      fontSize: 18),
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
    //3 ωρες μετα το ματς δεν μπορεις να το κανεις κανσελ
    if ((DateTime.now().millisecondsSinceEpoch ~/ 1000 > widget.match.startTimeInSeconds + 3*3600)){
      return SizedBox(
        height: 5,
      );
    }
    // Check if the user is logged in
    if (widget.match.hasMatchFinished && (!widget.match.isExtraTimeTime || widget.match.hasExtraTimeFinished) &&
        (globalUser.controlTheseTeams(
                widget.match.homeTeam.name, widget.match.awayTeam.name))) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent, // Γκρι για "Ακύρωση"
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Στρογγυλεμένες γωνίες
          ),
          padding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
          elevation: 5, // Ελαφριά σκιά
        ),
        onPressed: () {
          widget.match.matchCancelProgressed();
          setState(() {});
        },
        child: Text(
          (!widget.match.hasExtraTimeFinished) ? "Ματς δεν τελείωσε" : 'Η παράταση δεν τελείωσε',
          style: TextStyle(color: Colors.white, fontSize: 9),
        ),
      );
    } else if (globalUser.controlTheseTeams(
        widget.match.homeTeam.name, widget.match.awayTeam.name)) {
      MatchDetails match = widget.match;
      String progress = " ";
      String cancelProgress = " ";
      match.hasSecondHalfExtraTimeStarted ? (progress = "Τέλος Παράτασης", cancelProgress = "Ημίχρονο Παράτασης") :
      match.hasFirstHalfExtraTimeFinished ? (progress = "Εκκίνηση 2ου Ημιχρόνου Παράτασης", cancelProgress = "1ο Ημίχρονο παράτασης"):
      match.hasExtraTimeStarted ? (progress = "Ημίχρονο Παράτασης", cancelProgress = "Η παράταση δεν ξεκίνησε"):
      match.hasMatchFinished ? (progress = "Εκκίνηση Παράτασης", cancelProgress = "Ο αγώνας δεν τελείωσε"):
      match.hasSecondHalfStarted
          ? (progress = "Τέλος Αγώνα", cancelProgress = "Ημίχρονο")
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
              backgroundColor: Colors.redAccent, // Γκρι για "Ακύρωση"
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10), // Στρογγυλεμένες γωνίες
              ),
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
              elevation: 5, // Ελαφριά σκιά
            ),
            onPressed: () {
              match.matchCancelProgressed();
              setState(() {});
            },
            child: Text(
              cancelProgress,
              style: TextStyle(color: Colors.white, fontSize: 9),
            ),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200], // Γκρι για "Ακύρωση"
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(50), // Στρογγυλεμένες γωνίες
                ),
                padding: EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
                    style: TextStyle(color: Colors.blue, fontSize: 15),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              )),
        ],
      );
    } else {
      return SizedBox(
        height: 5,
      );
    }
  }

  TextEditingController _controller = TextEditingController();
  void _showInputDialogForGoal(
      BuildContext context, Team team, bool homeTeamScored)
  {
    String? goalScorer;
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("ΓΚΟΛ ${team.name}"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              DropdownSearch<String>(
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: "Αναζήτηση σκόρερ",
                  ),
                ),
                emptyBuilder: (_, __) => Center(child: Text("Δεν βρέθηκαν παίκτες")),
              ),
                items: [
                  ...team.players.map((player) => "${player.name.substring(0, 1)}. ${player.surname}"),
                  "Άλλος",
                ],
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  hintText: "Σκόρερ",
                ),
              ),
              selectedItem: goalScorer,
              onChanged: (String? newValue) {
                setDialogState(() {
                  goalScorer = newValue;
                });
              },
            )
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
                      if (goalScorer !='Άλλος') {
                        homeTeamScored
                          ? widget.match.homeScored(goalScorer ?? " ", true)
                          : widget.match.awayScored(goalScorer ?? " ", true);
                      }
                      else{
                        homeTeamScored
                            ? widget.match.homeScored(goalScorer ?? " ",false)
                            : widget.match.awayScored(goalScorer ?? " ",false);
                      }
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

  Widget _cardAdmin(bool homeTeamCard) {
    if (globalUser.controlTheseTeams(
            widget.match.homeTeam.name, widget.match.awayTeam.name) && (!widget.match.hasMatchFinished || (widget.match.isExtraTimeTime && !widget.match.hasExtraTimeFinished)) && !widget.match.isExtraTimeHalf()) {
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
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 10,
              child: Text(
                "Κάρτα",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15
                ),
              )));
    } else {
      return SizedBox(
        height: 5,
      );
    }
  }

  void _showInputDialogCard(
      BuildContext context, Team team, bool homeTeamCard)
  {
    String? goalScorer;
    bool isYellow = true;
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Κάρτα ${team.name}"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: isYellow
                              ? Border.all(
                                  color:
                                      Colors.black, // Χρώμα του περιγράμματος
                                  width: 1, // Πάχος του περιγράμματος
                                )
                              : null,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: InkWell(
                            onTap: () {
                              setDialogState(() {
                                // Χρήση setDialogState για να αλλάξει η τιμή
                                isYellow = true;
                              });
                            },
                            child: Column(
                              children: [
                                Container(
                                  color: Colors.yellow,
                                  width: 20,
                                  height: 30,
                                ),
                                Text("Κίτρινη Κάρτα",
                                    style: TextStyle(fontSize: 10))
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: !isYellow
                              ? Border.all(
                                  color:
                                      Colors.black, // Χρώμα του περιγράμματος
                                  width: 1, // Πάχος του περιγράμματος
                                )
                              : null,
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: InkWell(
                              onTap: () {
                                setDialogState(() {
                                  // Χρήση setDialogState για να αλλάξει η τιμή
                                  isYellow = false;
                                });
                              },
                              child: Column(
                                children: [
                                  Container(
                                    color: Colors.red,
                                    width: 20,
                                    height: 30,
                                  ),
                                  Text("Κόκκινη Κάρτα",
                                      style: TextStyle(fontSize: 10))
                                ],
                              ),
                            )),
                      )
                    ],
                  ),
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
                      "Παίχτης που πήρε την κάρτα",
                      style: TextStyle(
                          color: _getFilteredOptions(team).isNotEmpty
                              ? Colors.black
                              : Colors.grey),
                    ),
                    value: goalScorer,
                    isExpanded: true,
                    items: _getFilteredOptions(team).map((Player player) {
                      return DropdownMenuItem<String>(
                        value:
                            "${player.name.substring(0, 1)}. ${player.surname}",
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
                      homeTeamCard
                          ? widget.match.playerGotCard(
                              goalScorer ?? " ",
                              widget.match.homeTeam,
                              isYellow,
                              null,
                              homeTeamCard)
                          : widget.match.playerGotCard(
                              goalScorer ?? " ",
                              widget.match.awayTeam,
                              isYellow,
                              null,
                              homeTeamCard);
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

  void _cancelGoalDialog(BuildContext context, Goal goal) {
    String? goalScorer;
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Ακύρωση Γκολ"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Ακύρωση του γκολ του"),
                  Text("${goal.scorerName} στο ${goal.timeString} \u0301 ")
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
                    widget.match.cancelGoal(goal);

                    Navigator.of(context).pop(); // Κλείνει το διάλογο
                  },
                ),
              ],
            );
          });
        });
  }

  void _cancelCardDialog(BuildContext context, CardP card) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Ακύρωση Κάρτας"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Ακύρωση της κάρτας:"),
                  Text("${card.name} ${card.timeString} \u0301 ")
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
                    widget.match.cancelCard(card);

                    Navigator.of(context).pop(); // Κλείνει το διάλογο
                  },
                ),
              ],
            );
          });
        });
  }
}
