
import 'package:flutter/cupertino.dart';

class matchesContainer extends StatefulWidget {
  const matchesContainer({super.key});
  @override
  State<matchesContainer> createState()=> _matchesContainerState();

  }

class _matchesContainerState extends State<matchesContainer> {

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
        ]
    );
  }
}

// 🔹 Custom Container για κάθε Scorer
class eachMatchContainer extends StatefulWidget{
  final String homeTeam, awayTeam;
  bool hasMatchStarted;
  int scoreHome, scoreAway;
  eachMatchContainer({super.key, required this.homeTeam, required this.awayTeam, required this.scoreHome, required this.scoreAway,required this.hasMatchStarted });

  @override
  Widget build(BuildContext context) {
    return Container(
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}