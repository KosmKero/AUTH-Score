import 'package:flutter/material.dart';
import 'package:untitled1/API/user_handle.dart';
import 'package:untitled1/Firebase_Handle/user_handle_in_base.dart';
import 'package:untitled1/Match_Details_Package/Match_Not_Started/DetailsMatchNotStarted.dart';
import '../../Data_Classes/MatchDetails.dart';
import '../../Data_Classes/Team.dart';
import '../../Team_Display_Page_Package/TeamDisplayPage.dart';
import '../../Team_Display_Page_Package/one_group_standings.dart';
import '../../championship_details/StandingsPage.dart';
import '../../globals.dart';
import '../../main.dart';
import '../Starting__11_Display_Card.dart';

//ΟΛΟ ΕΔΩ ΑΦΟΡΑ ΤΟ ΕΠΑΝΩ ΚΟΜΜΑΤΙ ΤΗΣ ΣΕΛΙΔΑΣ. ΓΙΑ ΤΗΝ ΩΡΑ =,ΜΕΡΑ ΚΙΑ ΤΙς ΟΜΑΔΕΣ. ΤΟ ΜΠΛΕ ΠΛΑΙΣΙΟ ΣΤΗΝ ΑΡΧΗ ΑΡΧΗ ΠΑΝΩ
class MatchNotStartedDetails extends StatefulWidget {
  final MatchDetails match;

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
      backgroundColor: darkModeNotifier.value?Colors.grey[900]:Colors.white,
        //Button to begin the match countdown
        body: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(children: [
        Container(
          color:darkModeNotifier.value?Colors.grey[900]: Color.fromARGB(50, 5, 150, 200),
          child: Padding(
            padding: const EdgeInsets.all(0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: Text(
                  widget.match.matchweekInfo(),
                  style: TextStyle(
                      fontSize: 13,
                      color:darkModeNotifier.value?Colors.white: Colors.grey[800]),
                )),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: buildTeamName(team: widget.match.homeTeam)),
                    Flexible(fit: FlexFit.tight, child: _buildMatchDateTime()),
                    Expanded(child: buildTeamName(team: widget.match.awayTeam)),
                  ],
                ),
                Center(child: _isAdminWidget()),
                const Divider(),
                NavigationButtons(onSectionChange: _changeSection),
              ],
            ),
          ),
        ),
        _sectionChooser(selectedIndex, widget.match)
      ]),
    ));
  }

  Widget _isAdminWidget() {
    // Check if the user is logged in
    if (globalUser.controlTheseTeams(
        widget.match.homeTeam.name, widget.match.awayTeam.name)) {
      return TextButton(
        child: Text(
            "Εκκινηση Αγώνα",
            style: TextStyle(
              fontFamily: "Arial",
              fontSize: 15,

            ),
        ),
        onPressed: () {
          widget.match.matchStarted();
          setState(() {});
        },
      );
    } else {
      return SizedBox(
        height: 50,
      );
    }
  }

  Widget _buildMatchDateTime() {
    return Column(
      children: [
        //Sets the text for the date of the match
        Text('${widget.match.day}.${widget.match.month}.${widget.match.year}',
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              color: darkModeNotifier.value?Colors.white:Colors.black
            )
        ),
        Text(
          widget.match.timeString,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: darkModeNotifier.value?Colors.white:Colors.black
          ),
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
    //
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTextButton(greek ? "Λεπτομέρειες" : "Details", 0),
          // _buildTextButton(greek?"Συνθέσεις":"Teams", 1),
          _buildTextButton(greek ? "Βαθμολογία" : "Standing", 1),
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
              fontFamily: '"Arial"',
              color: isSelected ? Colors.blue :darkModeNotifier.value?Colors.white: Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          SizedBox(height: 3), // Απόσταση μεταξύ κειμένου και γραμμής
          if (isSelected)
            Container(
              width: 80, // Μήκος γραμμής
              height: 3, // Πάχος γραμμής
              color: Colors.blue, // Χρώμα γραμμής
            ),
        ],
      ),
    );
  }
}

//ΦΤΙΑΧΝΕΙ ΤΟ ΠΤΑΜΠΛΟ ΓΙΑ ΤΗΝ ΟΜΑΔΑ ΕΔΡΑΣ ΣΤΟ ΜΠΛΕ ΠΛΑΙΣΙΟ
class buildTeamName extends StatefulWidget {
  const buildTeamName({super.key, required this.team});
  final Team team;

  @override
  State<buildTeamName> createState() => _buildTeamName();
}

class _buildTeamName extends State<buildTeamName> {
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Transform.translate(
        //   //ΑΦΟΡΑ ΤΟ ΕΙΚΟΝΙΔΙΟ ΤΗΣ ΚΑΡΔΙΑΣ
        //   offset: Offset(16, 0), // Μετακινεί το εικονίδιο πιο κοντά στο κείμενο
        // ),
        GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TeamDisplayPage(widget.team)),
              );
            },
            child: Container(
              child: Column(
                children: [
                  SizedBox(
                    child: SizedBox(
                        height: 60, width: 100, child: widget.team.image),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Text(
                    widget.team.name,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color:darkModeNotifier.value?Colors.white: Colors.black),
                  ),
                ],
              ),
            ))
      ],
    );
  }
}

//ΦΤΙΑΧΝΕΙ ΤΟ ΠΕΔΙΟ ΓΙΑ ΤΗΝ ΟΜΑΔΑ ΕΚΤΟΣ ΣΤΟ ΜΠΛΕ ΠΛΑΙΣΙΟ !!!
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TeamDisplayPage(widget.team)),
                  );
                },
                child: Text(
                  widget.team.name,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color:darkModeNotifier.value?Colors.white: Colors.black),
                )),
          ],
        ),
        Transform.translate(
          offset:
              Offset(-16, 0), // Μετακινεί το εικονίδιο πιο κοντά στο κείμενο
        ),
      ],
    );
  }
}

Widget _sectionChooser(int selectedIndex, MatchDetails match) {
  switch (selectedIndex) {
    case 0:
      return DetailsMatchNotStarted(match: match);
    //case 1:
    //  return Starting11Display(match: match,);
    case 1:
      return OneGroupStandings(group: match.homeTeam.group);
    default:
      return DetailsMatchNotStarted(match: match);
  }
}
