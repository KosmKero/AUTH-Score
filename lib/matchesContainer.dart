import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/Firebase_Handle/user_handle_in_base.dart';
import 'package:untitled1/Match_Details_Package/Match_Details_Page.dart';
import 'package:untitled1/globals.dart';
import 'Data_Classes/MatchDetails.dart';
import 'API/NotificationService.dart';
import 'globals.dart';

//ΑΥΤΗ Η ΚΛΑΣΗ ΑΦΟΡΑ ΤΑ CONTAINER ΤΩΝ ΜΑΤΣ ΣΤΗΝ ΑΡΧΙΚΗ ΟΘΟΝΗ
class matchesContainer extends StatelessWidget {
  matchesContainer({super.key, required this.matches, required this.type}) {
    if (type == 1) {
      sortMatches();
    } else {
      sortMatchesDifferent();
    }
  }
  final List<MatchDetails> matches;

  int type;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      children: _buildMatchList(matches),
    );
  }

// Ένα βοηθητικό function για να μεταφράζει την ημέρα
  String getGreekWeekday(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Δευτέρα';
      case DateTime.tuesday:
        return 'Τρίτη';
      case DateTime.wednesday:
        return 'Τετάρτη';
      case DateTime.thursday:
        return 'Πέμπτη';
      case DateTime.friday:
        return 'Παρασκευή';
      case DateTime.saturday:
        return 'Σάββατο';
      case DateTime.sunday:
        return 'Κυριακή';
      default:
        return '';
    }
  }

  String getEnglishWeekday(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }


  List<Widget> _buildMatchList(List<MatchDetails> matches) {
    List<Widget> widgets = [];
    for (int i = 0; i < matches.length; i++) {
      final match = matches[i];

      final isNewDate = i == 0 ||
          match.day != matches[i - 1].day ||
          match.month != matches[i - 1].month ||
          match.year != matches[i - 1].year;

      if (isNewDate) {
        if (i != 0) widgets.add(SizedBox(height: 20));

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 8,left: 7),
            child: Text(
              "${match.day}/${match.month}/${match.year}",
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                fontFamily: 'Arial',
                color: darkModeNotifier.value ? Colors.white : Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      }



      widgets.add(eachMatchContainer(match));
    }
    return widgets;
  }

  void sortMatches() {
    matches.sort((a, b) {
      if (a.year != b.year) {
        return a.year.compareTo(b.year);
      } else if (a.month != b.month) {
        return a.month.compareTo(b.month);
      } else if (a.day != b.day) {
        return a.day.compareTo(b.day);
      } else {
        return a.time.compareTo(b.time);
      }
    });
  }

  void sortMatchesDifferent() {
    matches.sort((a, b) {
      if (a.year != b.year) {
        return b.year.compareTo(a.year);
      } else if (a.month != b.month) {
        return b.month.compareTo(a.month);
      } else if (a.day != b.day) {
        return b.day.compareTo(a.day);
      } else {
        return b.time.compareTo(a.time);
      }
    });
  }
}

class eachMatchContainer extends StatelessWidget {
  final MatchDetails match;
  const eachMatchContainer(
    this.match, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: match,
      child: eachMatchContainerView(),
    );
  }
}

class eachMatchContainerView extends StatelessWidget {
  const eachMatchContainerView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final match = Provider.of<MatchDetails>(context);

    return InkWell(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => matchDetailsPage(match)));
        },
        borderRadius: BorderRadius.circular(10),
        child: Card(
          color: darkModeNotifier.value ? Colors.grey[850] : lightModeContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
          margin: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MatchContainerTime(match: match),
                SizedBox(width: 15),
                Container(height: 50, width: 1.5, color:darkModeNotifier.value==true? Colors.white : Colors.black),
                SizedBox(width: 15),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        //ΦΤΙΑΧΝΕΙ ΤΗΝ HOME TEAM
                        children: [
                          SizedBox(
                              height: 25,
                              width: 25,
                              child: match.homeTeam.image),
                          Text(
                            " ${match.homeTeam.name}",
                            style: TextStyle(
                                fontSize: match.homeTeam.name.length < 15 ? 15 : 15,
                              fontWeight: FontWeight.w600,
                                color: darkModeNotifier.value==true ? Colors.white : lightModeText,
                                fontFamily: 'Arial',
                                letterSpacing: 0.3
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 2),
                      Row(
                        //ΦΤΙΑΧΝΕΙ ΤΗΝ AWAY TEAM
                        children: [
                          SizedBox(
                              height: 25,
                              width: 25,
                              child: match.awayTeam.image),
                          Text(
                            " ${match.awayTeam.name}",
                            style: TextStyle(
                                fontSize: match.awayTeam.name.length < 15 ? 15 : 15,
                                fontWeight: FontWeight.w600,
                                color: darkModeNotifier.value ? Colors.white : lightModeText,
                                fontFamily: 'Arial',
                                letterSpacing: 0.3
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                match.hasMatchStarted
                    ? Column(
                        children: [
                          Text(
                           ( match.homeScore+match.penaltyScoreHome).toString(),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Arial',
                                color: !(!match.hasMatchFinished || (match.isExtraTimeTime && !match.hasExtraTimeFinished)|| (match.isPenaltyTime && !match.isShootoutOver))? match.scoreHome > match.scoreAway ?darkModeNotifier.value?Colors.white: Colors.black:Colors.grey : Colors.red),
                          ),
                          Text(
                            (match.awayScore+match.penaltyScoreAway).toString(),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: !(!match.hasMatchFinished || (match.isExtraTimeTime && !match.hasExtraTimeFinished) || (match.isPenaltyTime && !match.isShootoutOver)) ?match.scoreAway>match.scoreHome?darkModeNotifier.value?Colors.white: Colors.black:Colors.grey : Colors.red),
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
                Padding(
                  padding: EdgeInsetsDirectional.only(start: 5, end: 0),
                  child: MatchNotificationIcon(
                    match: match,
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

//ΦΤΙΑΧΝΕΙ ΤΗΝ ΩΡΑ ΤΟΥ MATCH
class MatchContainerTime extends StatefulWidget {
  final MatchDetails match;

  const MatchContainerTime({super.key, required this.match});

  @override
  State<MatchContainerTime> createState() => _MatchContainerTimeState();
}

class _MatchContainerTimeState extends State<MatchContainerTime>
    with WidgetsBindingObserver {
  int _secondsElapsed = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    widget.match.addListener(_onMatchUpdated);

    if (widget.match.hasMatchStarted && (!widget.match.hasMatchFinished || (widget.match.isExtraTimeTime && !widget.match.hasExtraTimeFinished))) {
      _startTimer();
    }
  }

  void _onMatchUpdated() {
    if (widget.match.hasMatchStarted && _timer == null && (!widget.match.hasMatchFinished || (widget.match.isExtraTimeTime && !widget.match.hasExtraTimeFinished))) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.match.removeListener(_onMatchUpdated);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(MatchContainerTime oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.match != widget.match) {
      oldWidget.match.removeListener(_onMatchUpdated);
      widget.match.addListener(_onMatchUpdated);

      if (widget.match.hasMatchStarted && (!widget.match.hasMatchFinished || (widget.match.isExtraTimeTime && !widget.match.hasExtraTimeFinished))) {
        _startTimer();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed &&
        widget.match.hasMatchStarted &&
        (!widget.match.hasMatchFinished || (widget.match.isExtraTimeTime && !widget.match.hasExtraTimeFinished))) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel(); // cancel previous timer if any

    _secondsElapsed = (DateTime.now().millisecondsSinceEpoch ~/ 1000) -
        widget.match.startTimeInSeconds;

    print("object");

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  Color get _timeColor =>
      (!widget.match.hasMatchFinished || (widget.match.isExtraTimeTime && !widget.match.hasExtraTimeFinished)) ? Colors.red : Colors.black;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48.5,
      child: Column(
        children: [
          Text(
            widget.match.timeString,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkModeNotifier.value ? Colors.white : Colors.black87,
            ),
          ),
          if (widget.match.isHalfTime())
            const Text(
              "Ημίχρονο",
              style: TextStyle(
                color: Colors.red,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            )
          else if ((widget.match.hasMatchFinished && (!widget.match.isExtraTimeTime || widget.match.hasExtraTimeFinished)))
            const SizedBox.shrink()
          else if (widget.match.isExtraTimeTime && widget.match.isExtraTimeHalf())
            const Text(
              "Ημίχρονο Παράτασης",
              style: TextStyle(
                color: Colors.red,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
              textAlign: TextAlign.center,
            )
          else if (widget.match.isExtraTimeTime && widget.match.hasMatchFinished && !widget.match.hasExtraTimeStarted)
              const Text(
                "Αναμονή Παράτασης",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
                textAlign: TextAlign.center,
              )
          else if (widget.match.hasMatchStarted)
              Text(
                '${(_secondsElapsed ~/ 60).toString().padLeft(2, '0')}:${(_secondsElapsed % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: _timeColor,
                ),
              ),
        ],
      ),
    );
  }
}


//ΦΤΙΑΧΝΕΙ ΤΗΝ NOTIFICATION ICON ΤΟΥ MATCH
class MatchNotificationIcon extends StatefulWidget {
  final MatchDetails match;

  MatchNotificationIcon({
    super.key,
    required this.match,
  });

  @override
  State<MatchNotificationIcon> createState() => _MatchNotificationIconState();
}

class _MatchNotificationIconState extends State<MatchNotificationIcon> {

  @override
  void initState() {
    super.initState();
  }

  Future<void> toggleNotification() async {
    if (globalUser.isLoggedIn) {
      final newValue = !widget.match.notify.value;

      widget.match.enableNotify(newValue);

      // Προαιρετικά ενημερωτικό μήνυμα
      if (newValue) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Reminder set for ${widget.match}'),
          duration: Duration(seconds: 2),
        ));
      }

      final isFavorite =
          globalUser.favoriteList.contains(widget.match.homeTeam.name) ||
              globalUser.favoriteList.contains(widget.match.awayTeam.name);

      if (newValue) {
        if (!isFavorite) {
          await UserHandleBase().addNotifyMatch(widget.match);
        } else {
          await UserHandleBase().deleteNotifyMatch(widget.match);
        }
      } else {
        if (!isFavorite) {
          await UserHandleBase().deleteNotifyMatch(widget.match);
        } else {
          await UserHandleBase().addNotifyMatch(widget.match);
        }
      }
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(greek? "Πρέπει να συνδεθείς για να έχεις ειδοποιήσεις." : "Please log in to receive notifications."),
        duration: Duration(seconds: 2),
       // behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent.withOpacity(0.9),
      ));
    }
  }



  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.match.notify,
      builder: (context, value, _) {
        return IconButton(
          icon: Icon(
            value ? Icons.notifications_active : Icons.notifications_off,
            color: value ? (darkModeNotifier.value ? Colors.amber : Colors.blue) : Colors.grey,
          ),
          tooltip: value ? "Απενεργοποίηση ειδοποίησης" : "Ενεργοποίηση ειδοποίησης",
          onPressed: toggleNotification,
        );
      },
    );
  }

}
