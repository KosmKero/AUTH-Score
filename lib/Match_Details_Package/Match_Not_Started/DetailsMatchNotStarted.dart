import 'package:flutter/material.dart';
import '../../Data_Classes/Match.dart';
import '../../Data_Classes/Team.dart';
import '../../Team_Display_Page_Package/TeamDisplayPage.dart';

class DetailsMatchNotStarted extends StatelessWidget {
  const DetailsMatchNotStarted({super.key, required this.match});
  final Match match;
  @override
  Widget build(BuildContext context) {
    return Container(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Center(child: BettingChooser())]),
            SizedBox(
              height: 20,
            ),
            Text(
              'Φόρμα',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(
              height: 10,
            ),
            TeamFormWidget(
                team: match.homeTeam,
                results: match.homeTeam.last5Results),
            SizedBox(height: 10),
            TeamFormWidget(
                team: match.awayTeam,
                results: match.awayTeam.last5Results),
            SizedBox(
              height: 20,
            )
          ],
        ));
  }
}

class BettingChooser extends StatefulWidget {
  const BettingChooser({super.key});

  @override
  State<BettingChooser> createState() => _BettingChooserState();
}

class _BettingChooserState extends State<BettingChooser> {
  String _selected = '1';

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: '1', label: Text('1')),
        ButtonSegment(value: 'X', label: Text('X')),
        ButtonSegment(value: '2', label: Text('2')),
      ],
      selected: {_selected},
      onSelectionChanged: (newSelection) {
        setState(() {
          _selected = newSelection.first;
        });
      },
    );
  }
}

class TeamFormWidget extends StatelessWidget {
  final Team team;
  final List<String> results; // "W" for Win, "D" for Draw, "L" for Loss

  const TeamFormWidget(
      {super.key, required this.team, required this.results});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
                onPressed: () { Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TeamDisplayPage(team)),
                ); },
                child: Text(team.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: Colors.black),)
            ),
            SizedBox(width: 10),
            ...results.map((result) => _buildResultIcon(result))
          ],
        ),
      ],
    );
  }

  Widget _buildResultIcon(String result) {
    IconData icon;
    Color color;

    switch (result) {
      case "W":
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case "D":
        icon = Icons.remove_circle;
        color = Colors.grey;
        break;
      case "L":
        icon = Icons.cancel;
        color = Colors.red;
        break;
      default:
        icon = Icons.circle;
        color = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Icon(icon, color: color, size: 30),
    );
  }
}
