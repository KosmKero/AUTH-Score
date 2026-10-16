import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/Firebase_Handle/user_handle_in_base.dart';
import 'package:untitled1/Match_Details_Package/Match_Details_Page.dart';
import 'package:untitled1/globals.dart';
import '../Data_Classes/MatchDetails.dart';

// ΑΥΤΗ Η ΚΛΑΣΗ ΑΦΟΡΑ ΤΑ CONTAINER ΤΩΝ ΜΑΤΣ ΣΤΗΝ ΑΡΧΙΚΗ ΟΘΟΝΗ
class matchesContainer extends StatelessWidget {
  final List<MatchDetails> originalMatches;
  final int type;

  // Βάζουμε το originalMatches στο constructor
  const matchesContainer({
    super.key,
    required List<MatchDetails> matches,
    required this.type,
  }) : originalMatches = matches;

  @override
  Widget build(BuildContext context) {
    // 1. Δημιουργούμε ένα αντίγραφο της λίστας για να μην καταστρέφουμε την αρχική (Fix Mutability Bug)
    final sortedMatches = List<MatchDetails>.from(originalMatches);

    // 2. Ταξινομούμε το αντίγραφο
    if (type == 1) {
      sortedMatches.sort((a, b) {
        if (a.year != b.year) return a.year.compareTo(b.year);
        if (a.month != b.month) return a.month.compareTo(b.month);
        if (a.day != b.day) return a.day.compareTo(b.day);
        return a.time.compareTo(b.time);
      });
    } else {
      sortedMatches.sort((a, b) {
        if (a.year != b.year) return b.year.compareTo(a.year);
        if (a.month != b.month) return b.month.compareTo(a.month);
        if (a.day != b.day) return b.day.compareTo(a.day);
        return b.time.compareTo(a.time);
      });
    }

    // 3. Φτιάχνουμε μια "επίπεδη" (flat) λίστα που θα έχει String (Ημερομηνίες) και MatchDetails (Αγώνες)
    final List<dynamic> listItems = [];

    for (int i = 0; i < sortedMatches.length; i++) {
      final match = sortedMatches[i];

      final isNewDate = i == 0 ||
          match.day != sortedMatches[i - 1].day ||
          match.month != sortedMatches[i - 1].month ||
          match.year != sortedMatches[i - 1].year;

      if (isNewDate) {
        // Αν αλλάξει η μέρα, βάζουμε στη λίστα ένα String με την ημερομηνία
        listItems.add("${match.day}/${match.month}/${match.year}");
      }

      // Μετά προσθέτουμε τον ίδιο τον αγώνα
      listItems.add(match);
    }

    // 4. Επιστρέφουμε ListView.builder (Φορτώνει ΜΟΝΟ ό,τι βλέπει ο χρήστης)
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: listItems.length,
      itemBuilder: (context, index) {
        final item = listItems[index];

        // Αν το item είναι String, φτιάχνουμε τον τίτλο της ημερομηνίας
        if (item is String) {
          return Padding(
            // Βάζουμε μεγαλύτερο κενό πάνω αν δεν είναι η πρώτη ημερομηνία
            padding: EdgeInsets.only(top: index == 0 ? 10 : 30, bottom: 8, left: 7),
            child: Text(
              item,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                fontFamily: 'Arial',
                color: darkModeNotifier.value ? Colors.white : Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          );
        }
        // Αν το item είναι MatchDetails, φτιάχνουμε την κάρτα του αγώνα
        else if (item is MatchDetails) {
          return eachMatchContainer(item);
        }

        // Ασφαλής επιστροφή σε περίπτωση άγνωστου τύπου
        return const SizedBox.shrink();
      },
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
                                " ${match.homeTeam.displayName}",
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
                                " ${match.awayTeam.displayName}",
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
                          color: !(!match.hasMatchFinished ||
                              (match.isExtraTimeTime &&
                                  !match.hasExtraTimeFinished) ||
                              (match.isPenaltyTime &&
                                  !match.isShootoutOver))
                              ? match.homeScore > match.awayScore
                              ? darkModeNotifier.value
                              ? Colors.white
                              : Colors.black
                              : Colors.grey
                              : Colors.red),
                    ),
                    Text(
                      (match.awayScore).toString(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: !(!match.hasMatchFinished ||
                              (match.isExtraTimeTime &&
                                  !match.hasExtraTimeFinished) ||
                              (match.isPenaltyTime &&
                                  !match.isShootoutOver))
                              ? match.awayScore > match.homeScore
                              ? darkModeNotifier.value
                              ? Colors.white
                              : Colors.black
                              : Colors.grey
                              : Colors.red),
                    ),
                  ],
                )
                    : SizedBox.shrink(),
                (match.isPenaltyTime)
                    ? Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Column(
                    children: [
                      Text(
                        ('(${match.penaltyScoreHome})').toString(),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Arial',
                            color: (match.hasMatchEndedFinal)
                                ? match.penaltyScoreHome >
                                match.penaltyScoreAway
                                ? darkModeNotifier.value
                                ? Colors.white
                                : Colors.black
                                : Colors.grey
                                : Colors.red),
                      ),
                      Text(
                        ('(${match.penaltyScoreAway})').toString(),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: (match.hasMatchEndedFinal)
                                ? match.penaltyScoreAway >
                                match.penaltyScoreHome
                                ? darkModeNotifier.value
                                ? Colors.white
                                : Colors.black
                                : Colors.grey
                                : Colors.red),
                      ),
                    ],
                  ),
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
    if (widget.match.hasMatchStarted &&
        (!widget.match.hasMatchFinished ||
            (widget.match.isExtraTimeTime &&
                !widget.match.hasExtraTimeFinished))) {
      _startTimer();
    }
  }

  void _onMatchUpdated() {
    if (widget.match.hasMatchStarted &&
        (!widget.match.hasMatchFinished ||
            (widget.match.isExtraTimeTime &&
                !widget.match.hasExtraTimeFinished))) {
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
  void didUpdateWidget(MatchContainerTime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.match != widget.match) {
      oldWidget.match.removeListener(_onMatchUpdated);
      widget.match.addListener(_onMatchUpdated);
      if (widget.match.hasMatchStarted &&
          (!widget.match.hasMatchFinished ||
              (widget.match.isExtraTimeTime &&
                  !widget.match.hasExtraTimeFinished))) {
        _startTimer();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed &&
        widget.match.hasMatchStarted &&
        (!widget.match.hasMatchFinished ||
            (widget.match.isExtraTimeTime &&
                !widget.match.hasExtraTimeFinished))) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel(); // cancel previous timer if any
    _secondsElapsed = (DateTime.now().millisecondsSinceEpoch ~/ 1000) -
        widget.match.startTimeInSeconds;
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

  Color get _timeColor => ((!widget.match.hasMatchFinished ||
      (widget.match.isExtraTimeTime && !widget.match.hasExtraTimeFinished)))
      ? Colors.red
      : Colors.black;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48.5,
      child: Column(
        children: [
          (!widget.match.hasMatchStarted || widget.match.hasMatchEndedFinal)
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
          if (widget.match.isHalfTime())
            Text(
              greek ?  "Ημίχρονο" : 'HalfTime',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            )
          else if ((widget.match.hasMatchFinished &&
              (!widget.match.isExtraTimeTime ||
                  widget.match.hasExtraTimeFinished)))
            const SizedBox.shrink()
          else if (widget.match.isExtraTimeTime &&
                widget.match.isExtraTimeHalf())
              Text(
                greek ? "Ημίχρονο Παράτασης" : 'ET half',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
                textAlign: TextAlign.center,
              )
            else if (widget.match.isExtraTimeTime &&
                  widget.match.hasMatchFinished &&
                  !widget.match.hasExtraTimeStarted)
                Text(
                  greek ? "Αναμονή Παράτασης" : "ET Break",
                  style: const TextStyle(
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
  // Ένας τοπικός notifier που αλλάζει τιμή απλώς για να κάνει rebuild το συγκεκριμένο IconButton
  final ValueNotifier<int> _rebuildTrigger = ValueNotifier<int>(0);

  Future<void> toggleNotification() async {
    if (globalUser.isLoggedIn) {
      bool isFavorite = globalUser.favoriteList.contains(widget.match.homeTeam.name) ||
          globalUser.favoriteList.contains(widget.match.awayTeam.name);

      bool isGlobalFootball = globalUser.notifyAllMatches.value;

      await UserHandleBase().smartToggleMatchNotification(
          widget.match.matchDocId, isFavorite, isGlobalFootball);

      // ΜΟΛΙΣ ΤΕΛΕΙΩΣΕΙ Η ΑΛΛΑΓΗ, αυξάνουμε το trigger για να γίνει ακαριαίο rebuild το εικονίδιο!
      _rebuildTrigger.value++;

      bool newState = globalUser.matchKeys.containsKey(widget.match.matchDocId)
          ? globalUser.matchKeys[widget.match.matchDocId]!
          : (isFavorite || isGlobalFootball);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(newState
              ? (greek
              ? 'Θα λάβετε ειδοποίηση για το ${widget.match.homeTeam.name} - ${widget.match.awayTeam.name}'
              : 'Reminder set for ${widget.match.homeTeam.nameEnglish} - ${widget.match.awayTeam.nameEnglish}')
              : (greek
              ? 'Απενεργοποιήθηκε η ειδοποίηση'
              : 'Notification disabled')),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.blue,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(greek
            ? "Πρέπει να συνδεθείς για να έχεις ειδοποιήσεις."
            : "Please log in to receive notifications."),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.redAccent.withOpacity(0.9),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Ακούμε το γενικό καμπανάκι (αν αλλάξει από πάνω, αλλάζουν όλα)
    return ValueListenableBuilder<bool>(
      valueListenable: globalUser.notifyAllMatches,
      builder: (context, notifyAllFootball, _) {

        // 2. Ακούμε το τοπικό trigger του πατήματος
        return ValueListenableBuilder<int>(
          valueListenable: _rebuildTrigger,
          builder: (context, _, child) {

            // Καθαρός υπολογισμός χωρίς καμία παρεμβολή από εξωτερικά ValueNotifiers του Match
            bool isExplicitlySet = globalUser.matchKeys.containsKey(widget.match.matchDocId);
            bool isFavorite = globalUser.favoriteList.contains(widget.match.homeTeam.name) ||
                globalUser.favoriteList.contains(widget.match.awayTeam.name);

            bool isActive = isExplicitlySet
                ? globalUser.matchKeys[widget.match.matchDocId]!
                : (isFavorite || notifyAllFootball);

            return IconButton(
              icon: Icon(
                isActive ? Icons.notifications_active : Icons.notifications_off,
                color: isActive
                    ? (darkModeNotifier.value ? Colors.amber : Colors.blue)
                    : Colors.grey,
              ),
              tooltip: isActive
                  ? (greek ? "Απενεργοποίηση ειδοποίησης" : "Disable notification")
                  : (greek ? "Ενεργοποίηση ειδοποίησης" : "Enable notification"),
              onPressed: toggleNotification,
            );
          },
        );
      },
    );
  }
}