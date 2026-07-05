import 'dart:async';

import 'package:dropdown_search/dropdown_search.dart';
//mport 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Data_Classes/Player.dart';
import 'package:untitled1/Data_Classes/basketball/basketMatch.dart';
import 'package:untitled1/Firebase_Handle/user_handle_in_base.dart';
import 'package:untitled1/Match_Details_Package/penalty_shootout_widget.dart';
import 'package:untitled1/championship_details/StandingsPage.dart';
import 'package:untitled1/globals.dart';
import '../../Data_Classes/MatchDetails.dart';
import 'package:provider/provider.dart';
import '../API/user_handle.dart';
import '../Data_Classes/Penaltys.dart';
import '../Data_Classes/Team.dart';
import '../Data_Classes/basketball/basketMatch.dart';
import '../Data_Classes/match_facts.dart';
import '../Firebase_Handle/firebase_screen_stats_helper.dart';
import '../Team_Display_Page_Package/one_group_standings.dart';
import 'basketMatchNotStarted/basketMatchNotStartedPage.dart';
import 'basketMatchNotStarted/basketMatchUpperBody.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../ad_manager.dart';

import 'basketMatchNotStarted/basketMatchUpperBody.dart';

class basketMatchStartedPage extends StatelessWidget {
  final BasketMatch match;

  const basketMatchStartedPage({Key? key, required this.match})
      : super(key: key);

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
  final BasketMatch match;
  @override
  State<_MatchStartedView> createState() => _MatchStartedViewState();
}

class _MatchStartedViewState extends State<_MatchStartedView> {
  int selectedIndex = 0;

  void _changeSection(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.match.hasMatchFinished) {
      logScreenViewSta(
          screenName: 'Match ended page', screenClass: 'Match ended page');
/*
      FirebaseAnalytics.instance.logEvent(
        name: 'Match Ended Clicked',
        parameters: {
          'match_id': '${widget.match.homeTeam.nameEnglish} ${widget.match.dateString} ${widget.match.awayTeam.nameEnglish}',
          'home_team': widget.match.homeTeam.nameEnglish,
          'away_team': widget.match.awayTeam.nameEnglish,
        },

      );


 */
    } else {
      logScreenViewSta(
          screenName: 'Match started page', screenClass: 'Match started page');
/*
      FirebaseAnalytics.instance.logEvent(
        name: 'Match Started Clicked',
        parameters: {
          'match_id': '${widget.match.homeTeam.nameEnglish} ${widget.match.dateString} ${widget.match.awayTeam.nameEnglish}',
          'home_team': widget.match.homeTeam.nameEnglish,
          'away_team': widget.match.awayTeam.nameEnglish,
        },
      );
 */
    }

    return Container(
      //color: Colors.blueGrey,
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
                          ]),
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          child: (widget.match.hasMatchFinished)
                              ? _buildMatchFinishedScore()
                              : _buildMatchScoreLive(),
                        ),
                        Expanded(
                          child: Column(children: [
                            buildTeamName(team: widget.match.awayTeam),
                          ]),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [],
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

    (widget.match.homeScore > widget.match.awayScore)
        ? {
            homeColor = darkModeNotifier.value ? Colors.white : Colors.black,
            awayColor = Colors.grey
          }
        : (widget.match.homeScore < widget.match.awayScore)
            ? {
                homeColor = Colors.grey,
                awayColor = darkModeNotifier.value ? Colors.white : Colors.black
              }
            : {homeColor = Colors.blueGrey, awayColor = Colors.blueGrey};

    return Container(
      //color:darkModeNotifier.value? Colors.grey[900]: Color.fromARGB(50, 5, 150, 200),
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
              Text("${widget.match.homeScore}",
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
              Text("${widget.match.awayScore}",
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

  Widget _buildMatchScoreLive() {
    return Consumer<BasketMatch>(
      builder: (context, match, child) {

        // Λογική για το κείμενο της περιόδου
        String periodText = "";
        if (match.currentPeriod <= 4) {
          periodText = "${match.currentPeriod}η περίοδος";
        } else {
          periodText = "Παράταση";
        }

        // Αν είναι τέλος περιόδου (αλλά όχι τέλος αγώνα)
        if (match.hasPeriodEnded) {
          periodText = "Τέλος ${match.currentPeriod}ου Δεκ.";
        }

        return Column(
          children: [
            const SizedBox(height: 10),
            Text(
                periodText,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color:  Colors.red ),
              ),
            const SizedBox(height: 4),
            // ΤΟ ΣΚΟΡ
            Text(
              "${match.homeScore} - ${match.awayScore}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 25, color: Colors.red),
            ),

            // ΧΡΟΝΟΣ (Αν τον υπολογίζεις)
            // Text("07:42", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
          ],
        );
      },
    );
  }
  Widget _buildBasketMatchDetails() {
    return Consumer<BasketMatch>(
      builder: (context, match, child) {
        // 1. Υπολογισμός στηλών (τουλάχιστον 4 για τα δεκάλεπτα)
        int maxPeriodInData = match.periodScores.keys.fold(0, (max, key) => key > max ? key : max);
        int totalPeriods = maxPeriodInData > 4 ? maxPeriodInData : 4;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: darkModeNotifier.value ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // --- ΔΥΝΑΜΙΚΕΣ ΣΤΗΛΕΣ ΠΕΡΙΟΔΩΝ ---
                ...List.generate(totalPeriods, (index) {
                  int periodKey = index + 1;
                  String label = periodKey <= 4 ? "Π$periodKey" : "ΠΑΡ${periodKey - 4}";

                  // Παίρνουμε τα σκορ ή παύλα αν δεν υπάρχει ακόμα data
                  String hScore = match.periodScores[periodKey]?['home']?.toString() ?? "";
                  String aScore = match.periodScores[periodKey]?['away']?.toString() ?? "";

                  return Container(
                    width: 55,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        Text(label, style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(hScore, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        Text(aScore, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _halfBuilder(int half) {
    int ha = (half % 2 == 0) ? 2 : 1;
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 1,
            width: (half > 2) ? 65 : 100,
            color: (widget.match.hasMatchFinished)
                ? Colors.blueGrey
                : Colors.redAccent,
          ),
          Text(
            " ${ha}ο ημίχρονο ${(half > 2) ? 'παράτασης' : ""}",
            style: TextStyle(
                color: (widget.match.hasMatchFinished)
                    ? darkModeNotifier.value
                        ? Colors.white
                        : Colors.black
                    : Colors.redAccent),
          ),
          Container(
            height: 1,
            width: (half > 2) ? 65 : 100,
            color: (widget.match.hasMatchFinished)
                ? Colors.blueGrey
                : Colors.redAccent,
          ),
        ],
      ),
      //   ListView.builder(
      //     shrinkWrap: true,
      //     physics: NeverScrollableScrollPhysics(), // Prevents nested scrolling
      //     itemCount: (widget.match.matchFact[half - 1] ?? []).length,
      //     itemBuilder: (context, index) {
      //       int reversedIndex =
      //           (widget.match.matchFact[half - 1]!.length - 1) - index;
      //       return Padding(
      //         padding: const EdgeInsets.all(2.0),
      //         child: (widget.match.matchFact[half - 1]![reversedIndex] is Goal)
      //             ? buildGoalIndicator(
      //             widget.match.matchFact[half - 1]![reversedIndex] as Goal,widget.match)
      //             : buildCardIndicator(
      //             widget.match.matchFact[half - 1]![reversedIndex] as CardP,widget.match),
      //       );
      //     },
      //   ),
    ]);
  }

  void scoreChanged() {
    setState(() {});
  }

  Widget _sectionChooser(int selectedIndex, BasketMatch match) {
    switch (selectedIndex) {
      case 0:
        return _buildBasketMatchDetails();
      // case 1:
      //   return Starting11Display(
      //     match: match,
      //   );
      case 1:
        DateTime now = DateTime.now();
        int seasonYear = now.month > 8 ? now.year : now.year - 1;
        return OneGroupStandings(
          group: match.homeTeam.group,
          seasonYear: seasonYear,
        );
      default:
        return _buildBasketMatchDetails();
    }
  }

  /*
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


   */
}
