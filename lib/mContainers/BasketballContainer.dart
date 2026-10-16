import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/Firebase_Handle/user_handle_in_base.dart';
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

  String getGreekWeekday(int weekday) {
    switch (weekday) {
      case DateTime.monday: return 'Δευτέρα';
      case DateTime.tuesday: return 'Τρίτη';
      case DateTime.wednesday: return 'Τετάρτη';
      case DateTime.thursday: return 'Πέμπτη';
      case DateTime.friday: return 'Παρασκευή';
      case DateTime.saturday: return 'Σάββατο';
      case DateTime.sunday: return 'Κυριακή';
      default: return '';
    }
  }

  String getEnglishWeekday(int weekday) {
    switch (weekday) {
      case DateTime.monday: return 'Monday';
      case DateTime.tuesday: return 'Tuesday';
      case DateTime.wednesday: return 'Wednesday';
      case DateTime.thursday: return 'Thursday';
      case DateTime.friday: return 'Friday';
      case DateTime.saturday: return 'Saturday';
      case DateTime.sunday: return 'Sunday';
      default: return '';
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
        if (i != 0) widgets.add(const SizedBox(height: 20));

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 8, left: 7),
            child: Text(
              "${match.day}/${match.month}/${match.year}",
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                fontFamily: 'Arial',
                color: darkModeNotifier.value ? Colors.white : Colors.black, // ΔΙΟΡΘΩΣΗ: Σε light mode να είναι μαύρο
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      }

      widgets.add(eachMatchContainerBasket(match));
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

class eachMatchContainerBasket extends StatelessWidget {
  final BasketMatch match;
  const eachMatchContainerBasket(
      this.match, {
        Key? key,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: match,
      child: const eachMatchContainerView(),
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
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BasketContainerTime(match: match),
                const SizedBox(width: 15),
                Container(
                    height: 50,
                    width: 1.5,
                    color: darkModeNotifier.value ? Colors.white : Colors.black),
                const SizedBox(width: 15),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                                  color: darkModeNotifier.value ? Colors.white : lightModeText,
                                  fontFamily: 'Arial',
                                  letterSpacing: 0.3,
                                ),
                              ))
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
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
                                    color: darkModeNotifier.value ? Colors.white : lightModeText,
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
                              ? (match.homeScore > match.awayScore
                              ? (darkModeNotifier.value ? Colors.white : Colors.black)
                              : Colors.grey)
                              : Colors.red),
                    ),
                    Text(
                      (match.awayScore).toString(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: match.hasMatchFinished
                              ? (match.awayScore > match.homeScore
                              ? (darkModeNotifier.value ? Colors.white : Colors.black)
                              : Colors.grey)
                              : Colors.red),
                    ),
                  ],
                )
                    : const SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 5, end: 0),
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

//ΦΤΙΑΧΝΕΙ ΤΗΝ ΩΡΑ/ΠΕΡΙΟΔΟ ΤΟΥ MATCH (ΒΕΛΤΙΩΜΕΝΟ ΓΙΑ ΜΠΑΣΚΕΤ)
class BasketContainerTime extends StatelessWidget {
  final BasketMatch match;
  const BasketContainerTime({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    // 1. Δεν έχει ξεκινήσει ή Τελείωσε: Δείχνουμε απλά την ώρα έναρξης
    if (!match.hasMatchStarted || match.hasMatchFinished) {
      return SizedBox(
        width: 48.5,
        child: Center(
          child: Text(
            match.timeString,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkModeNotifier.value ? Colors.white : Colors.black87,
            ),
          ),
        ),
      );
    }

    // 2. Είναι Ημίχρονο
    if (match.isHalftime) {
      return const SizedBox(
        width: 48.5,
        child: Center(
          child: Text(
            "Ημίχρονο",
            style: TextStyle(
              color: Colors.red,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // 3. Βρίσκεται σε Διακοπή ανάμεσα σε περιόδους (1η->2η ή 3η->4η)
    if (match.hasPeriodEnded && !match.isHalftime) {
      return SizedBox(
        width: 48.5,
        child: Center(
          child: Text(
            greek ? "Τέλος\n${match.currentPeriod}ης περ." : "End of\nQ${match.currentPeriod}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // 4. Το ματς Παίζεται! (Δείχνουμε Live Q1, Q2 κλπ.)
    String periodText = "Q${match.currentPeriod}";
    if (match.currentPeriod > 4) {
      periodText = "OT"; // Overtime (Παράταση)
    }

    return SizedBox(
      width: 48.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            match.timeString,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: darkModeNotifier.value ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            periodText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.red, // Κόκκινο για να δείχνει ότι είναι LIVE
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

  const MatchNotificationIcon({
    super.key,
    required this.match,
  });

  @override
  State<MatchNotificationIcon> createState() => _MatchNotificationIconState();
}

class _MatchNotificationIconState extends State<MatchNotificationIcon> {

  Future<void> toggleNotification() async {
    if (globalUser.isLoggedIn) {

      // Υπολογίζουμε τα "defaults" τη στιγμή του κλικ
      bool isFavorite = globalUser.favoriteListBasket.contains(widget.match.homeTeam.name) ||
          globalUser.favoriteListBasket.contains(widget.match.awayTeam.name);
      bool isGlobalBasket = globalUser.notifyAllBasketMatches.value;

      // 1. Καλούμε την έξυπνη συνάρτηση
      await UserHandleBase().smartToggleMatchNotification(
          widget.match.matchKey, isFavorite, isGlobalBasket);

      // 2. Βρίσκουμε τη ΝΕΑ κατάσταση για να την περάσουμε στο UI (αφού ενημερώθηκε το globalUser.matchKeys)
      bool newState = globalUser.matchKeys.containsKey(widget.match.matchKey)
          ? globalUser.matchKeys[widget.match.matchKey]!
          : (isFavorite || isGlobalBasket);

      widget.match.enableNotify(newState);

      // Ενημερωτικό μήνυμα
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(newState
              ? (greek ? 'Ενεργοποιήθηκε η ειδοποίηση για το ματς' : 'Notification enabled for this match')
              : (greek ? 'Απενεργοποιήθηκε η ειδοποίηση για το ματς' : 'Notification disabled for this match')),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ));
      }

    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(greek
            ? "Πρέπει να συνδεθείς για να έχεις ειδοποιήσεις."
            : "Please log in to receive notifications."),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.redAccent.withOpacity(0.9),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ακούμε το γενικό καμπανάκι του πρωταθλήματος
    return ValueListenableBuilder<bool>(
      valueListenable: globalUser.notifyAllBasketMatches,
      builder: (context, notifyAllBasket, _) {

        // Ακούμε το καμπανάκι του συγκεκριμένου ματς
        return ValueListenableBuilder<bool>(
          valueListenable: widget.match.notify,
          builder: (context, value, _) {

            // Υπολογισμός αν πρέπει να εμφανίζεται ενεργό
            bool isExplicitlySet = globalUser.matchKeys.containsKey(widget.match.matchKey);
            bool isFavorite = globalUser.favoriteListBasket.contains(widget.match.homeTeam.name) ||
                globalUser.favoriteListBasket.contains(widget.match.awayTeam.name);

            // Αν ο χρήστης το άλλαξε χειροκίνητα, κρατάμε την τιμή του (value)
            // Αλλιώς, αν δεν το έχει πειράξει, εξαρτάται από το αν είναι favorite ή αν είναι ενεργό το "όλο το πρωτάθλημα"
            bool isActive = isExplicitlySet ? value : (isFavorite || notifyAllBasket);

            return IconButton(
              icon: Icon(
                isActive ? Icons.notifications_active : Icons.notifications_off,
                color: isActive ? Colors.orange : Colors.grey,
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