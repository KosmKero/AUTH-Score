import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:untitled1/API/Match_Handle.dart';
import 'Data_Classes/MatchDetails.dart';
import 'Data_Classes/Player.dart';
import 'Data_Classes/Team.dart';
import 'Firebase_Handle/TeamsHandle.dart';
import 'Firebase_Handle/firebase_screen_stats_helper.dart';
import 'Team_Display_Page_Package/TeamDisplayPage.dart';
import 'globals.dart';
import 'matchesContainer.dart';
import 'dart:async';
import 'package:untitled1/Match_Details_Package/add_match_page.dart';
import 'package:untitled1/ad_manager.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  int selectedIndex = 0;


  @override
  void initState() {
    super.initState();
  }

  void onSectionChange(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Search page', screenClass: 'Search page');

    return Scaffold(
      backgroundColor:
          darkModeNotifier.value ? Color(0xFF121212) : lightModeBackGround,
      appBar: AppBar(
        backgroundColor:
            darkModeNotifier.value ? Color(0xFF121212) : lightModeBackGround,
        iconTheme: IconThemeData(
          color: darkModeNotifier.value ? Colors.white : Colors.black,
        ),
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: greek ? "Αναζήτηση..." : 'Search...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: darkModeNotifier.value ? Colors.white : Colors.black,
            ),
          ),
          style: TextStyle(
              color: darkModeNotifier.value ? Colors.white : Colors.black),
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
                _buildTextButton(greek ? "Ομάδα" : "Team", 0),
                _buildTextButton(greek ? "Αγώνας" : "Match", 1),
                _buildTextButton(greek ? "Ιστορικό" : "History", 2),
              ],
            ),
          ),
          Expanded(child: searchDetails(selectedIndex, _searchController.text)),
        ],
      ),
    );
  }

  void _onButtonPressed(int index) {
    setState(() {
      selectedIndex = index;
    });
    onSectionChange(index);
  }

  Widget _buildTextButton(String text, int index) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => _onButtonPressed(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: isSelected
                  ? Colors.blue
                  : (darkModeNotifier.value ? Colors.white : Colors.black),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontFamily: "Arial",
            ),
          ),
          SizedBox(height: 4),
          if (isSelected)
            Container(
              width: 60,
              height: 3,
              color: Colors.blue,
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

class _searchDetailsState extends State<searchDetails> {
  List<Team> teamSearchList = [];
  List<Player> playerSearchList = [];
  List<MatchDetails> matchSearchList = [];
  Map<int, List<MatchDetails>> cachedMatches = {};
  Map<int, List<Team>> cachedTeams = {};


  Timer? _debounce;

  // seasons (πρόσθεσε όσες θέλεις)
  List<int> seasons = [2026, 2025];
  int selectedSeason = 2026;

  BannerAd? _bannerTeam;
  BannerAd? _bannerMatch;
  BannerAd? _bannerHistory;

  bool _isTeamAdReady = false;
  bool _isMatchAdReady = false;
  bool _isHistoryAdReady = false;

  @override
  void initState() {
    super.initState();

    searchPressed(widget.name);

    cachedTeams[thisYearNow] = teams;
    cachedMatches[thisYearNow] = MatchHandle().getAllMatches();

    searchPressed(widget.name);

    cachedTeams[thisYearNow] = teams;
    cachedMatches[thisYearNow] = MatchHandle().getAllMatches();


    if (_bannerTeam == null && !_isTeamAdReady) {
      _bannerTeam = AdManager.createBannerAd(
        onStatusChanged: (status) {
          setState(() {
            _isTeamAdReady = status;
          });
        },
      )
        ..load();
    }

    if (_bannerMatch == null && !_isMatchAdReady) {
      _bannerMatch = AdManager.createBannerAd(
        onStatusChanged: (status) {
          setState(() {
            _isMatchAdReady = status;
          });
        },
      )
        ..load();
    }

    if (_bannerHistory == null && !_isHistoryAdReady) {
      _bannerHistory = AdManager.createBannerAd(
        onStatusChanged: (status) {
          setState(() {
            _isHistoryAdReady = status;
          });
        },
      )
        ..load();
    }
  }
  @override
  void dispose() {
    _debounce?.cancel();
    _bannerTeam?.dispose();
    _bannerMatch?.dispose();
    _bannerHistory?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant searchDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.name != oldWidget.name ||
        widget.selectedIndex != oldWidget.selectedIndex) {
      _debounceSearch(widget.name);
    }
  }

  void _debounceSearch(String name) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 300), () {
      searchPressed(name);
    });
  }

  Future<void> searchPressed(String name) async {
    if (name.length < 2 && widget.selectedIndex != 2) {
      // clear μόνο για Team/Match, όχι για ιστορικό
      setState(() {
        teamSearchList.clear();
        matchSearchList.clear();
        playerSearchList.clear();
      });
      return;
    }
    List<MatchDetails> matchList = [];
    switch (widget.selectedIndex) {
      case 1:
        matchList = await matchSearch(name, onlyCurrentSeason: true);
        break;
      case 2:
        matchList = await matchSearch(name,
            onlyCurrentSeason: false, season: selectedSeason);
        break;
    }

    setState(() {
      switch (widget.selectedIndex) {
        case 0:
          teamSearchList = teamSearch(name);
          break;
        case 1:
          matchSearchList = matchList;
          break;
        case 2:
          matchSearchList = matchList;
          break;
      }
    });
  }

  List<Team> teamSearch(String name) {
    return teams
        .where((team) => team.name.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }

  Future<List<MatchDetails>> matchSearch(String name,
      {bool onlyCurrentSeason = false, int? season}) async {
    List<MatchDetails> matches;
    List<Team> list = teams;
    if (onlyCurrentSeason) {
      matches = MatchHandle()
          .getAllMatches(); //MatchHandle().getMatchesBySeason(2025); // ή τρέχουσα σεζόν
    } else if (season != null) {
      if (cachedTeams.containsKey(season)) {
        list = cachedTeams[season]!;
        matches = cachedMatches[season]!;
      } else {
        list = await TeamsHandle().getAllTeamsByYear(season);
        matches = await MatchHandle().getMatchesByYear(season, list);

        setState(() {
          cachedTeams[season] = list;
          cachedMatches[season] = matches;
        });
      }
    } else {
      matches = MatchHandle().getAllMatches();
    }

    return matches
        .where((match) =>
    match.homeTeam.name.toLowerCase().contains(name.toLowerCase()) ||
        match.awayTeam.name.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }

  Widget _buildSeasonChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: seasons.map((season) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text("${season - 1}-$season"),
              selected: selectedSeason == season,
              onSelected: (_) async {
                List<MatchDetails> m =
                await matchSearch(widget.name, season: season);

                setState(() {
                  selectedSeason = season;
                  matchSearchList = m;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }






  Widget _buildBanner(BannerAd? banner, bool isReady) {
    if (!isReady || banner == null) return SizedBox();
    return SizedBox(
      width: banner.size.width.toDouble(),
      height: banner.size.height.toDouble(),
      child: AdWidget(ad: banner),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedIndex == 0) {
      // Ομάδες
      return Scaffold(
        backgroundColor:
        darkModeNotifier.value ? Color(0xFF121212) : lightModeBackGround,
        body: ListView.builder(
          itemCount: teamSearchList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                teamSearchList[index].name,
                style: TextStyle(
                  color: darkModeNotifier.value ? Colors.white : Colors.black,
                  fontFamily: "Arial",
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TeamDisplayPage(teamSearchList[index])),
                );
              },
            );
          },
        ),
        bottomNavigationBar: _buildBanner(_bannerTeam, _isTeamAdReady),
      );
    } else if (widget.selectedIndex == 1) {
      // Αγώνες
      return Scaffold(
        backgroundColor:
        darkModeNotifier.value ? Color(0xFF121212) : lightModeBackGround,
        body: FutureBuilder<List<MatchDetails>>(
          future: matchSearch(widget.name, onlyCurrentSeason: true),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("Δεν βρέθηκαν αγώνες"));
            }
            final matches = snapshot.data!;
            return ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                return eachMatchContainer(matches[index]);
              },
            );
          },
        ),
        bottomNavigationBar: _buildBanner(_bannerMatch, _isMatchAdReady),
      );
    } else {
      // Ιστορικό
      return Scaffold(
        backgroundColor:
        darkModeNotifier.value ? Color(0xFF121212) : lightModeBackGround,
        body: Column(
          children: [
            _buildSeasonChips(),
            Expanded(
              child: FutureBuilder<List<MatchDetails>>(
                future: matchSearch(widget.name,
                    onlyCurrentSeason: false, season: selectedSeason),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("Δεν βρέθηκαν αγώνες"));
                  }
                  final matches = snapshot.data!;
                  return ListView.builder(
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      return eachMatchContainer(matches[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBanner(_bannerHistory, _isHistoryAdReady),
      );
    }
  }
}



