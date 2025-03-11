import 'package:flutter/material.dart';
import 'Data_Classes/Match.dart';

class KnockOutsPage extends StatelessWidget {
  const KnockOutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  Widget knockOutMatch(Match match) {
    return Card(
      child: Row(
        children: [
          Column(
            children: [
              Image.asset('fotos/teamlogo.png'),
              Text(match.homeTeam.name),
              if (match.hasMatchStarted) Text(match.scoreHome.toString())
            ],
          ),
          Column(children: [
            Image.asset('fotos/teamlogo.png'),
            Text(match.awayTeam.name),
            if (match.hasMatchStarted) Text(match.awayTeam.toString())
          ])
        ],
      ),
    );
  }
}
