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
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: _buildMatches(),
    );
  }

  Column _buildMatches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        for (int i = 0; i < matches.length; i++) ...[
          if (i == 0 ||
              matches[i].day != matches[i - 1].day ||
              matches[i].month != matches[i - 1].month ||
              matches[i].year != matches[i - 1].year) ...[
            // Add extra spacing ONLY if it's a new date (not the first item)
            if (i != 0) SizedBox(height: 20), // ← Larger gap for new dates
            Text(
              " ${matches[i].day}/${matches[i].month}/${matches[i].year}",
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                fontFamily: 'Arial',
                color: darkModeNotifier.value ? Colors.white : Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 8),
          ],
          // Match container
          eachMatchContainer(matches[i]),
        ],
      ],
    );
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
                            match.scoreHome.toString(),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Arial',
                                color: match.hasMatchFinished ? match.scoreHome > match.scoreAway ?darkModeNotifier.value?Colors.white: Colors.black:Colors.grey : Colors.red),
                          ),
                          Text(
                            match.scoreAway.toString(),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: match.hasMatchFinished ?match.scoreAway>match.scoreHome?darkModeNotifier.value?Colors.white: Colors.black:Colors.grey : Colors.red),
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
  late final Color color;
  MatchContainerTime({super.key, required this.match}) {
    match.hasMatchFinished ? color = Colors.black : color = Colors.red;
  }

  final MatchDetails match;

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
    if (!widget.match.hasMatchFinished) {

      WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.match.addListener(_onMatchUpdated);
    });
    }

    if (widget.match.hasMatchStarted) {
      _startTimer();
    }
  }

  void _onMatchUpdated() {
    if (widget.match.hasMatchStarted && _timer == null && !widget.match.hasMatchFinished) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    widget.match.removeListener(_onMatchUpdated);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(MatchContainerTime oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Ελέγχουμε αν το ματς έχει ξεκινήσει και αν έχει αλλάξει κατάσταση
    if (widget.match.hasMatchStarted  && !widget.match.hasMatchFinished &&
        oldWidget.match.hasMatchStarted != widget.match.hasMatchStarted) {
      setState(() {
        _startTimer(); // Ξεκινάμε το χρονόμετρο αν το ματς ξεκινήσει
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Όταν η εφαρμογή επιστρέψει από background, ξαναρχίζει το χρονόμετρο
    if (state == AppLifecycleState.resumed) {
      if (widget.match.hasMatchStarted && !widget.match.hasMatchFinished) {
        setState(() {
          // Ενημερώνουμε την κατάσταση του widget
          _startTimer();
        });
      }
    }
  }

  void _startTimer() {
    _timer?.cancel(); // Ακύρωση του προηγούμενου timer
    _secondsElapsed = (DateTime.now().millisecondsSinceEpoch ~/ 1000) -
        widget.match.startTimeInSeconds;
    print(DateTime.now().millisecondsSinceEpoch ~/ 1000 -
        widget.match.startTimeInSeconds);

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.match.timeString,
          style: TextStyle(fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkModeNotifier.value ? Colors.white : Colors.black87,
          ),
        ),
        if (widget.match.isHalfTime())
          Text("Ημίχρονο",
              style: TextStyle(
                  color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold))
        else if (widget.match.hasMatchFinished)
          SizedBox.shrink()
        else if (widget.match.hasMatchStarted)
          Text(
            '${(_secondsElapsed ~/ 60).toString().padLeft(2, '0')}:${(_secondsElapsed % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red),
          ),
      ],
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
    final newValue = !widget.match.notify.value;

    widget.match.enableNotify(newValue);

    // Προαιρετικά ενημερωτικό μήνυμα
    if (newValue) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Reminder set for ${widget.match}'),
        duration: Duration(seconds: 2),
      ));
    }

    final isFavorite = globalUser.favoriteList.contains(widget.match.homeTeam.name) ||
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
