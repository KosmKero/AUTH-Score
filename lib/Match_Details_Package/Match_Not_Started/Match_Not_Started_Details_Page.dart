import 'package:flutter/material.dart';
import 'package:untitled1/Match_Details_Package/Match_Not_Started/DetailsMatchNotStarted.dart';
import '../../Data_Classes/Match.dart';
import '../../Data_Classes/Team.dart';
import '../../Team_Display_Page_Package/TeamDisplayPage.dart';
import '../../main.dart';
import '../Standings_Card_1Group.dart';
import '../Starting__11_Display_Card.dart';

class MatchNotStartedDetails extends StatefulWidget {
  final Match match;

  const MatchNotStartedDetails({super.key, required this.match});

  @override
  State<MatchNotStartedDetails> createState() => _MatchNotStartedDetailsState();
}

class _MatchNotStartedDetailsState extends State<MatchNotStartedDetails> {
  int selectedIndex = 0;
  void _changeSection(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      TextButton(
          onPressed: () {
            widget.match.matchStarted();
            setState(() {});
          },
          child: Text("patatohome")),
      Container(
        color: Color.fromARGB(50, 5, 150, 200),
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildHomeTeamName(
                    team: widget.match.homeTeam,
                  ),
                  _buildMatchDateTime(),
                  buildAwayTeamName(team: widget.match.awayTeam),
                ],
              ),
              SizedBox(
                height: 50,
              ),
              const Divider(),
              NavigationButtons(onSectionChange: _changeSection),
            ],
          ),
        ),
      ),
      _sectionChooser(selectedIndex, widget.match)
    ]));
  }

  Widget _buildMatchDateTime() {
    return Column(
      children: [
        Text('${widget.match.day}.${widget.match.month}.${widget.match.year}',
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13)),
        Text(
          widget.match.timeString,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ],
    );
  }
}

class NavigationButtons extends StatefulWidget {
  final Function(int) onSectionChange;

  const NavigationButtons({Key? key, required this.onSectionChange})
      : super(key: key);

  @override
  State<NavigationButtons> createState() => _NavigationButtonsState();
}

class _NavigationButtonsState extends State<NavigationButtons> {
  int selectedIndex = 0;

  void _onButtonPressed(int index) {
    setState(() {
      selectedIndex = index;
    });
    widget.onSectionChange(index); // Notify parent widget
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTextButton("Λεπτομέρειες", 0),
          _buildTextButton("Συνθέσεις", 1),
          _buildTextButton("Βαθμολογία", 2),
        ],
      ),
    );
  }

  Widget _buildTextButton(String text, int index) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        _onButtonPressed(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.blue : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          SizedBox(height: 4), // Απόσταση μεταξύ κειμένου και γραμμής
          if (isSelected)
            Container(
              width: 60, // Μήκος γραμμής
              height: 3, // Πάχος γραμμής
              color: Colors.blue, // Χρώμα γραμμής
            ),
        ],
      ),
    );
  }
}

class buildHomeTeamName extends StatefulWidget {
  const buildHomeTeamName({super.key, required this.team});
  final Team team;

  @override
  State<buildHomeTeamName> createState() => _buildHomeTeamName();
}

class _buildHomeTeamName extends State<buildHomeTeamName> {
  void _toggleFavorite() {
    setState(() {
      widget.team.changeFavourite();
      widget.team.isFavourite
          ? favouriteTeams.add(widget.team)
          : favouriteTeams.remove(widget.team);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Transform.translate(
          offset: Offset(16, 0), // Μετακινεί το εικονίδιο πιο κοντά στο κείμενο
          child: IconButton(
            padding: EdgeInsets.zero, // Αφαιρεί το default padding
            constraints: BoxConstraints(), // Αποτρέπει την επέκταση του κουμπιού
            onPressed: _toggleFavorite,
            icon: Icon(
              size: 17,
              widget.team.isFavourite ? Icons.favorite : Icons.favorite_border,
              color: widget.team.isFavourite ? Colors.red : null,
            ),
          ),
        ),
        Column(
          children: [
            TextButton(
                onPressed: () { Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TeamDisplayPage(widget.team)),
                ); },
                child: Text(widget.team.name,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,color: Colors.black),)
            ),
          ],
        ),
      ],
    );
  }
}

class buildAwayTeamName extends StatefulWidget {
  const buildAwayTeamName({super.key, required this.team});
  final Team team;

  @override
  State<buildAwayTeamName> createState() => _buildAwayTeamName();
}

class _buildAwayTeamName extends State<buildAwayTeamName> {
  void _toggleFavorite() {
    setState(() {
      widget.team.changeFavourite();
      widget.team.isFavourite
          ? favouriteTeams.add(widget.team)
          : favouriteTeams.remove(widget.team);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          children: [
            TextButton(
                onPressed: () { Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TeamDisplayPage(widget.team)),
                ); },
                child: Text(widget.team.name,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,color: Colors.black),)
            ),
          ],
        ),
        Transform.translate(
          offset: Offset(-16, 0), // Μετακινεί το εικονίδιο πιο κοντά στο κείμενο
          child: IconButton(
            padding: EdgeInsets.zero, // Αφαιρεί το default padding
            constraints: BoxConstraints(), // Αποτρέπει την επέκταση του κουμπιού
            onPressed: () => _toggleFavorite(),
            icon: Icon(
              size: 17,
              widget.team.isFavourite ? Icons.favorite : Icons.favorite_border,
              color: widget.team.isFavourite ? Colors.red : null,
            ),
          ),
        ),
      ],
    );
  }
}

Widget _sectionChooser(int selectedIndex, Match match) {
  switch (selectedIndex) {
    case 0:
      return DetailsMatchNotStarted(match: match);
    case 1:
      return Starting11Display();
    case 2:
      return StandingPageOneGroup(
        team: match.homeTeam,
      );
    default:
      return DetailsMatchNotStarted(match: match);
  }
}
