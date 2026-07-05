import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/Firebase_Handle/user_handle_in_base.dart';
import 'package:untitled1/Match_Details_Package/Match_Details_Page.dart';
import 'package:untitled1/basketMatches/basket_match_details.dart';
import 'package:untitled1/globals.dart';
import '../Data_Classes/basketball/basketMatch.dart';

//ΑΥΤΗ Η ΚΛΑΣΗ ΑΦΟΡΑ ΤΑ CONTAINER ΤΩΝ ΜΑΤΣ ΣΤΗΝ ΑΡΧΙΚΗ ΟΘΟΝΗ
class BasketballContainer extends StatelessWidget {
  BasketballContainer({super.key, required this.matches, required this.type}) {
    if (type == 1) {
      sortMatches();
    } else {
      sortMatchesDifferent();
    }
  }
  final List<BasketMatch> matches;

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

  List<Widget> _buildMatchList(List<BasketMatch> matches) {
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
            padding: const EdgeInsets.only(top: 10, bottom: 8, left: 7),
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
  final BasketMatch match;
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
    final match = Provider.of<BasketMatch>(context);

    return InkWell(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => basketMatchDetailsPage(match)));
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
                BasketContainerTime(match: match),
                SizedBox(width: 15),
                Container(
                    height: 50,
                    width: 1.5,
                    color: darkModeNotifier.value == true
                        ? Colors.white
                        : Colors.black),
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
                          Expanded(
                              child: Text(
                                " ${match.homeTeam.name}",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: darkModeNotifier.value == true
                                      ? Colors.white
                                      : lightModeText,
                                  fontFamily: 'Arial',
                                  letterSpacing: 0.3,
                                ),
                              ))
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
                          Expanded(
                              child: Text(
                                " ${match.awayTeam.name}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: darkModeNotifier.value
                                        ? Colors.white
                                        : lightModeText,
                                    fontFamily: 'Arial',
                                    letterSpacing: 0.3),
                              )),
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
                      (match.homeScore).toString(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Arial',
                          color: match.hasMatchFinished
                              ? match.homeScore > match.awayScore
                              ? darkModeNotifier.value
                              ? Colors.white  //ματς τελειωσε και νταρκ μοουντ και νικη
                              : Colors.black  //ματς τελειωσε και λαιτ μοοουντ καςι νικη
                              : Colors.grey   //χασαμε
                              : Colors.red),  //ματς δεν τελειωσε
                    ),
                    Text(
                      (match.awayScore).toString(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: match.hasMatchFinished
                              ? match.awayScore > match.homeScore
                              ? darkModeNotifier.value
                              ? Colors.white   //ματς τελειωσε και νταρκ μοουντ και νικη
                              : Colors.black   //ματς τελειωσε και λαιτ μοοουντ καςι νικη
                              : Colors.grey    //χασαμε
                              : Colors.red),   //ματς δεν τελειωσε
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
class BasketContainerTime extends StatefulWidget {
  final BasketMatch match;
  const BasketContainerTime({super.key, required this.match});
  @override
  State<BasketContainerTime> createState() => _BasketContainerTimeState();
}

class _BasketContainerTimeState extends State<BasketContainerTime>
    with WidgetsBindingObserver {
  int _secondsElapsed = 0;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.match.addListener(_onMatchUpdated);
    if (widget.match.hasMatchStarted &&
        (!widget.match.hasMatchFinished ))

      _startTimer();

  }

  void _onMatchUpdated() {
    if (widget.match.hasMatchStarted &&
        (!widget.match.hasMatchFinished))
             {
      _startTimer(); // πάντα ξαναξεκινάει με βάση το νέο startTimeInSeconds
    } else {
      _timer?.cancel();
      _timer = null;
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
  void didUpdateWidget(BasketContainerTime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.match != widget.match) {
      oldWidget.match.removeListener(_onMatchUpdated);
      widget.match.addListener(_onMatchUpdated);
      if (widget.match.hasMatchStarted &&
          (!widget.match.hasMatchFinished)) {
        _startTimer();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed &&
        widget.match.hasMatchStarted &&
        (!widget.match.hasMatchFinished )) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel(); // cancel previous timer if any
    _secondsElapsed = ((DateTime.now().millisecondsSinceEpoch ~/ 1000) -
        widget.match.startTimeInSeconds);
    //print("object");
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

  Color get _timeColor => (!widget.match.hasMatchFinished )
      ? Colors.red
      : Colors.black;
  @override
  Widget build(BuildContext context) {   //εδω θελει να πουμε σε ποια περιοδο ειμαστε
    return SizedBox(
      width: 48.5,
      child: Column(
        children: [
          (!widget.match.hasMatchStarted || widget.match.hasMatchFinished)
              ? Text(
            widget.match.timeString,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color:
              darkModeNotifier.value ? Colors.white : Colors.black87,
            ),
          )
              : SizedBox.shrink(),
          if (widget.match.isHalftime)
            const Text(
              "Ημίχρονο",
              style: TextStyle(
                color: Colors.red,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            )
          else if (widget.match.hasMatchFinished)
            const SizedBox.shrink()
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
  final BasketMatch match;

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

     //  widget.match.enableNotify(newValue);  θελει τετοια συναρτηση και στο μπασκετ

      // Προαιρετικά ενημερωτικό μήνυμα
      if (newValue) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: (!greek)
              ? Text(
              'Reminder set for ${widget.match.homeTeam.nameEnglish}-${widget.match.awayTeam.nameEnglish}')
              : Text(
              'Θα λάβετε ειδοποίηση για το ματς ${widget.match.homeTeam.name}-${widget.match.awayTeam.name}'),
          duration: Duration(seconds: 2),
        ));
      }

      final isFavorite =
          globalUser.favoriteList.contains(widget.match.homeTeam.name) ||
              globalUser.favoriteList.contains(widget.match.awayTeam.name);

      if (newValue) {
      //    if (!isFavorite) {
      //      await UserHandleBase().addNotifyMatch(widget.match);    //λογικη για ειδοποιησεις
      //    } else {
      //      await UserHandleBase().deleteNotifyMatch(widget.match);
      //    }
      //  } else {
      //    if (!isFavorite) {
      //      await UserHandleBase().deleteNotifyMatch(widget.match);
      //    } else {
      //      await UserHandleBase().addNotifyMatch(widget.match);
      //    }
        }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(greek
            ? "Πρέπει να συνδεθείς για να έχεις ειδοποιήσεις."
            : "Please log in to receive notifications."),
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
            color: value
                ? (darkModeNotifier.value ? Colors.amber : Colors.blue)
                : Colors.grey,
          ),
          tooltip:
          value ? "Απενεργοποίηση ειδοποίησης" : "Ενεργοποίηση ειδοποίησης",
          onPressed: toggleNotification,
        );
      },
    );
  }
}
