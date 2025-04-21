import 'package:flutter/material.dart';
import 'package:untitled1/API/Match_Handle.dart';
import 'Data_Classes/MatchDetails.dart';
import 'Data_Classes/Player.dart';
import 'Data_Classes/Team.dart';
import 'Team_Display_Page_Package/TeamDisplayPage.dart';
import 'globals.dart';
import 'main.dart';
import 'matchesContainer.dart';
import 'dart:async';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  int selectedIndex = 0;
  void onSectionChange(index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkModeNotifier.value? Color(0xFF121212):  lightModeBackGround,
      appBar: AppBar(
        backgroundColor: darkModeNotifier.value? Color(0xFF121212):  lightModeBackGround,
        iconTheme: IconThemeData(
          color: darkModeNotifier.value? Colors.white: Colors.black,
        ),
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: greek?"Αναζήτηση...":'Search...',
            border: InputBorder.none,
            hintStyle: TextStyle(
                color:darkModeNotifier.value?Colors.white: Colors.black,
            ),
          ),
          style: TextStyle(color: darkModeNotifier.value? Colors.white: Colors.black),
          onChanged: (text) {
            setState(() {}); // Rerender to pass updated text
          },
        ),
      ),
      body: Column(

        children: [
          SizedBox(
            height: 60,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTextButton(greek?"Ομάδα":"Team", 0),
                _buildTextButton(greek?"Αγώνας":"Match", 1),
                _buildTextButton(greek?"Παίχτης":"Player", 2),
              ],
            ),
          ),
          searchDetails(selectedIndex, _searchController.text)
        ],
      ),
    );
  }

  void _onButtonPressed(int index) {
    setState(() {
      selectedIndex = index;
    });
    onSectionChange(index); // Notify parent widget
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
          SizedBox(
            height: 10,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.blue :darkModeNotifier.value? Colors.white: Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontFamily: "Arial"
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

class searchDetails extends StatefulWidget {
  const searchDetails(this.selectedIndex, this.name, {super.key});
  final int selectedIndex;
  final String name;

  @override
  State<searchDetails> createState() => _searchDetailsState();
}

/* class _searchDetailsState extends State<searchDetails> {




  void searchPressed(String name) {
    switch (widget.selectedIndex) {
      case 0:
        teamSearch(name);
        break;
      case 1:
        matchSearch(name);
        break;
      case 2:
        playerSearch(name);
        break;
    }
  }

  List<Team> teamSearch(String name) {
    teamSearchList.clear();
    for (Team team in teams) {
      if (team.name.toLowerCase().contains(name.toLowerCase())) {
        teamSearchList.add(team);
      }
    }
    return teamSearchList;
  }

  List<Match> matchSearch(String name) {
    matchSearchList.clear();
    for (Match match in matches) {
      if (match.homeTeam.name.toLowerCase().contains(name.toLowerCase()) ||
          match.awayTeam.name.toLowerCase().contains(name.toLowerCase())) {
        matchSearchList.add(match);
      }
    }
    return matchSearchList;
  }

  List<Player> playerSearch(String name) {
    playerSearchList.clear();
    for (Player player in players) {
      if (player.name.toLowerCase().contains(name.toLowerCase())) {
        playerSearchList.add(player);
      }
    }
    return playerSearchList;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: buildSearchColumn(widget.selectedIndex))));
  }



    List<Widget> buildSearchColumn(int selectedIndex) {
      if (selectedIndex == 0) {
        return buildTeamSearch();
      } else if (selectedIndex == 1) {
        return buildMatchSearch();
      } else if (selectedIndex == 2) {
        return buildPlayerSearch();
      }
      return [];
    }



  List<Container> buildTeamSearch() {
    List<Container> list = [];
    for (Team team in teamSearch(widget.name)) {
      list.add(Container(
          child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TeamDisplayPage(team)),
          );
        },
        child: Text(
          team.name,
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
      )));
    }
    return list;
  }

  List<Card> buildMatchSearch() {
    List<Card> list = [];
    for (Match match in matchSearch(widget.name)) {
      list.add(Card(
        color: Colors.grey,
        child: eachMatchContainer(match),
      ));
    }
    return list;
  }

  List<Container> buildPlayerSearch() {
    List<Container> list = [];
    for (Team team in teamSearch(widget.name)) {
      list.add(Container(
        child: Text(team.name),
      ));
    }
    return list;
  }
} */




class _searchDetailsState extends State<searchDetails> {
  List<Team> teamSearchList = [];
  List<Player> playerSearchList = [];
  List<MatchDetails> matchSearchList = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    searchPressed(widget.name);
  }

  @override
  void didUpdateWidget(covariant searchDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.name != oldWidget.name || widget.selectedIndex != oldWidget.selectedIndex) {
      _debounceSearch(widget.name);
    }
  }

  //ανανεωνεται μονο αν ο χρηστης σταματησει την πληκτρολογηση για 300 ms
  void _debounceSearch(String name) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 300), () {
      searchPressed(name);
    });
  }

  void searchPressed(String name) {
    if (name.length < 2) { // Αν έχει λιγότερους από 2 χαρακτήρες, καθαρίζει τα αποτελέσματα
      setState(() {
        teamSearchList.clear();
        matchSearchList.clear();
        playerSearchList.clear();
      });
      return;
    }

    setState(() {
      switch (widget.selectedIndex) {
        case 0:
          teamSearchList = teamSearch(name);
          break;
        case 1:
          matchSearchList = matchSearch(name);
          break;
        case 2:
          playerSearchList = playerSearch(name);
          break;
      }
    });
  }

  List<Team> teamSearch(String name) {
    teamSearchList.clear();
    for (Team team in teams) {
      if (team.name.toLowerCase().contains(name.toLowerCase())) {
        teamSearchList.add(team);
      }
    }
    return teamSearchList;
  }

  List<MatchDetails> matchSearch(String name) {
    matchSearchList.clear();
    for (MatchDetails match in MatchHandle().getAllMatches()) {
      if (match.homeTeam.name.toLowerCase().contains(name.toLowerCase()) ||
          match.awayTeam.name.toLowerCase().contains(name.toLowerCase())) {
        matchSearchList.add(match);
      }
    }
    return matchSearchList;
  }

  List<Player> playerSearch(String name) {
    playerSearchList.clear();
    for (Player player in players) {
      if (player.name.toLowerCase().contains(name.toLowerCase())) {
        playerSearchList.add(player);
      }
    }
    return playerSearchList;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.selectedIndex == 0
            ? teamSearchList.length
            : widget.selectedIndex == 1
            ? matchSearchList.length
            : playerSearchList.length,
        itemBuilder: (context, index) {
          if (widget.selectedIndex == 0) {
            return ListTile(
              title: Text(
                  teamSearchList[index].name,
                style: TextStyle(
                  color:darkModeNotifier.value? Colors.white: Colors.black,
                    fontFamily: "Arial",
                  fontWeight: FontWeight.w600
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeamDisplayPage(teamSearchList[index])),
                );
              },
            );
          } else if (widget.selectedIndex == 1) {
            return Card(
              color: Color(0xFF121212),
              child: eachMatchContainer(matchSearchList[index]),
            );
          } else {
            return ListTile(
              title: Text(
                  playerSearchList[index].name,
                  style: TextStyle(
                    color: darkModeNotifier.value? Colors.white: Colors.black,
                    fontFamily: "Arial"
                  ),
              ),
            );
          }
        },
      ),
    );
  }
}
