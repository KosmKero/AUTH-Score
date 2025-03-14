import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/Match_Details_Package/Match_Details_Page.dart';
import 'Data_Classes/Match.dart';

class matchesContainer extends StatelessWidget {
  matchesContainer({super.key, required this.matches}){
    sortMatches();
  }
  final List<Match> matches;

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
        for (int i = 0; i < matches.length; i++) ...[
          if (i == 0 ||
              matches[i].day != matches[i - 1].day ||
              matches[i].month != matches[i - 1].month ||
              matches[i].year != matches[i - 1].year)
            Text(
              " ${matches[i].day}/${matches[i].month}/${matches[i].year}",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,color: Colors.white),
            ),
          // Create Container for the match
          eachMatchContainer(matches[i]),
        ],

      ],
    );






  }

  void sortMatches(){
    matches.sort((a, b) {
      if (a.year != b.year) {
        return a.year.compareTo(b.year);
      } else if (a.month != b.month) {
        return a.month.compareTo(b.month);
      } else if (a.day!=b.day){
        return a.day.compareTo(b.day);
      }else{
        return a.time.compareTo(b.time);
      }
    });
  }
}

class eachMatchContainer extends StatelessWidget {
  final Match match;
  const eachMatchContainer(this.match, {Key? key,}): super(key: key);


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
    final match = Provider.of<Match>(context);

    return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => matchDetailsPage(match, )
            )
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Card(

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 10,
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MatchContainerTime(match: match),
            SizedBox(width: 15),
            Container(height: 50, width: 1.5, color: Colors.black26),
            SizedBox(width: 15),
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
                          child: Image.asset('fotos/teamlogo.png')
                      ),
                      Text(" ${match.homeTeam.name}",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      SizedBox(
                        height: 25,
                        width: 25,
                        child: Image.asset('fotos/csdfootball.png')
                      ),

                      Text(" ${match.awayTeam.name}",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            match.hasMatchStarted ? Column(
              children: [
                Text(
                  match.scoreHome.toString(),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: match.hasMatchFinished ? Colors.black : Colors.red),
                ),
                Text(
                  match.scoreAway.toString(),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: match.hasMatchFinished ? Colors.black : Colors.red),
                ),
              ],
            ):SizedBox.shrink() ,
            Padding(
                padding: EdgeInsetsDirectional.only(start: 5,end:0),
                child: notificationIcon(match: match,),
            )
          ],
        ),
      ),
    )
    );
  }
}

class MatchContainerTime extends StatefulWidget {


  late final Color color;
  MatchContainerTime({super.key,required this.match}){
    match.hasMatchFinished ? color =Colors.black : color=Colors.red;
  }

  final Match match;

  @override
  State<MatchContainerTime> createState() => _MatchContainerTimeState();
}

class _MatchContainerTimeState extends State<MatchContainerTime> {

  late int _secondsElapsed;
  Timer? _timer;



  @override
  void initState() {
    super.initState();

    // Ελέγχει αν το ματς έχει ξεκινήσει και αρχίζει το χρονόμετρο
    if (widget.match.hasMatchStarted) {
      _startTimer();
    } else {
      _secondsElapsed = 0;
    }

    // Listener για να ξεκινησει το χρονομετρο του αγώνα
    widget.match.addListener(() {
      if (widget.match.hasMatchStarted && _timer == null) {
        _startTimer(); // Ξεκινά το χρονόμετρο αν το ματς ξεκινήσει
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _secondsElapsed = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - widget.match.startTimeInSeconds;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if(widget.match.hasMatchStarted) Text(
            '${(_secondsElapsed ~/ 60).toString().padLeft(2, '0')}:${(_secondsElapsed % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 8, color: Colors.red),)
      ],
    );
  }
}


class notificationIcon extends StatefulWidget {
  final Match match;
  const notificationIcon({super.key, required this.match});

  @override
  State<notificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends State<notificationIcon> {
  bool isNotified = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        setState(() {
          isNotified = !isNotified;
        });
      },
      icon: Icon(
        isNotified ? Icons.notifications_active : Icons.notification_add_outlined,
        color: isNotified ? Colors.blue : Colors.black,
      ),
    );
  }
}

