import 'package:flutter/material.dart';
import 'package:untitled1/Match_Details_Page.dart';
import 'Match.dart';

class matchesContainer extends StatefulWidget {
  matchesContainer({super.key, required this.matches});
  final List<Match> matches;

  @override
  State<matchesContainer> createState() => _matchesContainerState();
}

class _matchesContainerState extends State<matchesContainer> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(children: _buildMatches()),
    );
  }

  List<Widget> _buildMatches() {
    List<Widget> widgets = [];
    for (int i = 0; i < widget.matches.length; i++) {
      widgets.add(eachMatchContainer(widget.matches[i]));
    }
    return widgets;
  }
}

class eachMatchContainer extends StatefulWidget {
  const eachMatchContainer(this.match, {super.key});
  final Match match;

  @override
  State<eachMatchContainer> createState() => _eachMatchContainerState();
}

class _eachMatchContainerState extends State<eachMatchContainer> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MatchDetailsPage(match: widget.match, )
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
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              ("${widget.match.time % 100}:${(widget.match.time / 100).toInt()}"),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 20),
            Container(height: 50, width: 1.5, color: Colors.black26),
            SizedBox(width: 20),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.match.homeTeam.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    widget.match.awayTeam.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Spacer(),
            Column(
              children: [
                Text(
                  widget.match.scoreHome.toString(),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Text(
                  widget.match.scoreAway.toString(),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
            Padding(
                padding: EdgeInsetsDirectional.only(start: 5,end:0),
                child: notificationIcon(),
            )
          ],
        ),
      ),
    )
    );
  }

}
class notificationIcon extends StatefulWidget {
  const notificationIcon({super.key});

  @override
  State<notificationIcon> createState() => _notificationIconState();
}

class _notificationIconState extends State<notificationIcon> {
  late bool notifonoroff;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {},
        icon: Icon(Icons.notification_add_outlined));
  }
}

