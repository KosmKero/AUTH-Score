import 'package:flutter/material.dart';
import 'dart:async';

// --- FOOTBALL IMPORTS ---
import 'package:untitled1/API/Match_Handle.dart';
import 'Data_Classes/MatchDetails.dart';
import 'Data_Classes/Player.dart';
import 'Data_Classes/Team.dart';
import 'Firebase_Handle/TeamsHandle.dart';

// --- BASKETBALL IMPORTS ---
import 'Data_Classes/basketball/basketMatch.dart';
import 'Data_Classes/basketball/basketTeam.dart';
import 'Firebase_Handle/BasketTeamsHandle.dart';
import 'API/BasketballMatchHandle.dart';

// --- UI & GLOBALS IMPORTS ---
import 'Firebase_Handle/firebase_screen_stats_helper.dart';
import 'Team_Basket_Display_Package/Basket_Team_Display_Page.dart';
import 'Team_Display_Page_Package/TeamDisplayPage.dart';
import 'globals.dart';
import 'mContainers/BasketballContainer.dart';
import 'matchesContainer.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  int selectedIndex = 0;
  late String localSport;

  @override
  void initState() {
    super.initState();
    localSport = selectedSport.value;
  }

  void onSectionChange(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Search page', screenClass: 'Search page');
    bool isDark = darkModeNotifier.value;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : lightModeBackGround,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : lightModeBackGround,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: greek ? "Αναζήτηση..." : 'Search...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          onChanged: (text) {
            setState(() {});
          },
        ),
        actions: [
          /*
          IconButton(
            tooltip: greek ? "Εναλλαγή Αθλήματος" : "Switch Sport",
            icon: Icon(
              localSport == 'football'
                  ? Icons.sports_soccer
                  : Icons.sports_basketball,
              color: localSport == 'football' ? Colors.blue : Colors.orange,
              size: 28,
            ),
            onPressed: () {
              setState(() {
                localSport =
                    localSport == 'football' ? 'basketball' : 'football';
                _searchController.clear();
              });
            },
          ),
          const SizedBox(width: 10),

           */
        ],
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
          Expanded(
              child: searchDetails(
                  selectedIndex, _searchController.text, localSport)),
        ],
      ),
    );
  }

  Widget _buildTextButton(String text, int index) {
    bool isSelected = selectedIndex == index;
    bool isDark = darkModeNotifier.value;
    Color activeColor = localSport == 'football' ? Colors.blue : Colors.orange;

    return GestureDetector(
      onTap: () => _onButtonPressed(index),
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: isSelected
                    ? activeColor
                    : (isDark ? Colors.white : Colors.black),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: "Arial",
              ),
            ),
            const SizedBox(height: 4),
            if (isSelected)
              Container(
                width: 60,
                height: 3,
                color: activeColor,
              ),
          ],
        ),
      ),
    );
  }

  void _onButtonPressed(int index) {
    setState(() {
      selectedIndex = index;
    });
    onSectionChange(index);
  }
}

// ==========================================
// SEARCH DETAILS WIDGET (RACE-CONDITION PROOF)
// ==========================================
class searchDetails extends StatefulWidget {
  const searchDetails(this.selectedIndex, this.name, this.sport, {super.key});

  final int selectedIndex;
  final String name;
  final String sport;

  @override
  State<searchDetails> createState() => _searchDetailsState();
}

class _searchDetailsState extends State<searchDetails> {
  List<Team> teamSearchList = [];
  List<MatchDetails> matchSearchList = [];
  Map<int, List<MatchDetails>> cachedMatches = {};
  Map<int, List<Team>> cachedTeams = {};

  List<basketTeam> basketTeamSearchList = [];
  List<BasketMatch> basketMatchSearchList = [];
  Map<int, List<BasketMatch>> cachedBasketMatches = {};
  Map<int, List<basketTeam>> cachedBasketTeams = {};

  Timer? _debounce;
  List<int> seasons = [2026, 2025];
  int selectedSeason = 2026;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedSeason = thisYearNow;

    cachedTeams[thisYearNow] = teams;
    cachedMatches[thisYearNow] = MatchHandle().getAllMatches();

    cachedBasketTeams[thisYearNow] = basketTeams;
    cachedBasketMatches[thisYearNow] = BasketballMatchHandle().getAllMatches();

    searchPressed(widget.name);
  }

  @override
  void didUpdateWidget(covariant searchDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.name != oldWidget.name ||
        widget.selectedIndex != oldWidget.selectedIndex ||
        widget.sport != oldWidget.sport) {
      _debounceSearch(widget.name);
    }
  }

  void _debounceSearch(String name) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchPressed(name);
    });
  }

  Future<void> searchPressed(String name) async {
    setState(() {
      isLoading = true;
    });

    String query = name.trim().toLowerCase();

    final currentTab = widget.selectedIndex;
    final currentSport = widget.sport;
    final currentSeason = selectedSeason;

    if (query.isNotEmpty && query.length < 2 && currentTab != 2) {
      if (mounted &&
          widget.selectedIndex == currentTab &&
          widget.sport == currentSport) {
        setState(() {
          if (currentSport == 'football') {
            teamSearchList.clear();
            matchSearchList.clear();
          } else {
            basketTeamSearchList.clear();
            basketMatchSearchList.clear();
          }
          isLoading = false;
        });
      }
      return;
    }

    if (currentSport == 'football') {
      if (currentTab == 0) {
        List<Team> tList = teamSearch(query);
        if (mounted &&
            widget.selectedIndex == currentTab &&
            widget.sport == currentSport) {
          setState(() {
            teamSearchList = tList;
            isLoading = false;
          });
        }
      } else {
        List<MatchDetails> mList = await matchSearch(query,
            onlyCurrentSeason: currentTab == 1,
            season: currentTab == 2 ? currentSeason : null);

        if (mounted &&
            widget.selectedIndex == currentTab &&
            widget.sport == currentSport &&
            selectedSeason == currentSeason) {
          setState(() {
            matchSearchList = mList;
            isLoading = false;
          });
        }
      }
    } else {
      // --- BASKETBALL ---
      if (currentTab == 0) {
        List<basketTeam> btList = basketTeamSearch(query);
        if (mounted &&
            widget.selectedIndex == currentTab &&
            widget.sport == currentSport) {
          setState(() {
            basketTeamSearchList = btList;
            isLoading = false;
          });
        }
      } else {
        List<BasketMatch> bmList = await basketMatchSearch(query,
            onlyCurrentSeason: currentTab == 1,
            season: currentTab == 2 ? currentSeason : null);

        if (mounted &&
            widget.selectedIndex == currentTab &&
            widget.sport == currentSport &&
            selectedSeason == currentSeason) {
          setState(() {
            basketMatchSearchList = bmList;
            isLoading = false;
          });
        }
      }
    }
  }

  // ΕΞΥΠΝΗ ΑΝΑΖΗΤΗΣΗ FOOTBALL TEAM
  List<Team> teamSearch(String query) {
    if (query.isEmpty) return teams;
    return teams
        .where((team) =>
            team.name.toLowerCase().contains(query) ||
            team.displayGreek.toLowerCase().contains(query) ||
            team.displayEnglish.toLowerCase().contains(query))
        .toList();
  }

  //  ΕΞΥΠΝΗ ΑΝΑΖΗΤΗΣΗ FOOTBALL MATCHES
  Future<List<MatchDetails>> matchSearch(String query,
      {bool onlyCurrentSeason = false, int? season}) async {
    List<MatchDetails> matches;
    List<Team> list = teams;

    if (onlyCurrentSeason) {
      matches = MatchHandle().getAllMatches();
    } else if (season != null) {
      if (cachedMatches.containsKey(season)) {
        matches = cachedMatches[season]!;
      } else {
        list = await TeamsHandle().getAllTeamsByYear(season);
        matches = await MatchHandle().getMatchesByYear(season, list);
        cachedTeams[season] = list;
        cachedMatches[season] = matches;
      }
    } else {
      matches = MatchHandle().getAllMatches();
    }

    if (query.isEmpty) return matches;
    return matches
        .where((match) =>
            match.homeTeam.name.toLowerCase().contains(query) ||
            match.homeTeam.displayGreek.toLowerCase().contains(query) ||
            match.homeTeam.displayEnglish.toLowerCase().contains(query) ||
            match.awayTeam.name.toLowerCase().contains(query) ||
            match.awayTeam.displayGreek.toLowerCase().contains(query) ||
            match.awayTeam.displayEnglish.toLowerCase().contains(query))
        .toList();
  }

  //  ΕΞΥΠΝΗ ΑΝΑΖΗΤΗΣΗ BASKET TEAM (Αν δεν έχει displayGreek στο BasketTeam ακόμα)
  List<basketTeam> basketTeamSearch(String query) {
    if (query.isEmpty) return basketTeams;
    return basketTeams
        .where((team) =>
            team.name.toLowerCase().contains(query) ||
            team.name.toLowerCase().contains(query) ||
            team.name.toLowerCase().contains(query))
        .toList();
  }

  //ΕΞΥΠΝΗ ΑΝΑΖΗΤΗΣΗ BASKET MATCHES
  Future<List<BasketMatch>> basketMatchSearch(String query,
      {bool onlyCurrentSeason = false, int? season}) async {
    List<BasketMatch> matches;
    List<basketTeam> list = basketTeams;

    if (onlyCurrentSeason) {
      matches = BasketballMatchHandle().getAllMatches();
    } else if (season != null) {
      if (cachedBasketMatches.containsKey(season)) {
        matches = cachedBasketMatches[season]!;
      } else {
        list = await BasketTeamsHandle().getAllTeamsByYear(season);
        matches = await BasketTeamsHandle().getMatchesByYear(season, list);
        cachedBasketTeams[season] = list;
        cachedBasketMatches[season] = matches;
      }
    } else {
      matches = BasketballMatchHandle().getAllMatches();
    }

    if (query.isEmpty) return matches;
    return matches
        .where((match) =>
            match.homeTeam.name.toLowerCase().contains(query) ||
            match.homeTeam.name.toLowerCase().contains(query) ||
            match.homeTeam.name.toLowerCase().contains(query) ||
            match.awayTeam.name.toLowerCase().contains(query) ||
            match.awayTeam.name.toLowerCase().contains(query) ||
            match.awayTeam.name.toLowerCase().contains(query))
        .toList();
  }

  Widget _buildSeasonChips() {
    bool isDark = darkModeNotifier.value;
    Color activeColor =
        widget.sport == 'football' ? Colors.blue : Colors.orange;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: seasons.map((season) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text("${season - 1}-$season"),
              selected: selectedSeason == season,
              selectedColor: activeColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: selectedSeason == season
                    ? activeColor
                    : (isDark ? Colors.black : Colors.black),
                fontWeight: selectedSeason == season
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              onSelected: (_) async {
                setState(() {
                  selectedSeason = season;
                });
                searchPressed(widget.name);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Text(
        greek ? "Δεν βρέθηκαν αποτελέσματα" : "No results found",
        style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54, fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = darkModeNotifier.value;
    Color bgColor = isDark ? const Color(0xFF121212) : lightModeBackGround;

    if (isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: CircularProgressIndicator(
            color: widget.sport == 'football' ? Colors.blue : Colors.orange,
          ),
        ),
      );
    }

    // --- TAB 0: ΟΜΑΔΕΣ ---
    if (widget.selectedIndex == 0) {
      return Scaffold(
        backgroundColor: bgColor,
        body: widget.sport == 'football'
            ? (teamSearchList.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    itemCount: teamSearchList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: SizedBox(
                            height: 30,
                            width: 30,
                            child: teamSearchList[index].image),
                        title: Text(
                          greek
                              ? teamSearchList[index].displayGreek
                              : teamSearchList[index].displayEnglish,
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontFamily: "Arial",
                              fontWeight: FontWeight.w600),
                        ),
                        onTap: () async {
                          // 1. Περιμένουμε το αποτέλεσμα (το true που στέλνουμε με το pop)
                          bool? didChange = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TeamDisplayPage(teamSearchList[index]),
                            ),
                          );

                          // 2. Αν διαγράφηκε η ομάδα (ή έγινε edit), κάνουμε ΑΜΕΣΟ refresh!
                          if (didChange == true) {
                            setState(() {
                              // Τη σβήνουμε ακαριαία από την τοπική λίστα!
                              // Το UI θα την εξαφανίσει χωρίς το παραμικρό lag.
                              teamSearchList.removeAt(index);
                            });

                            searchPressed(widget.name);
                          }
                        },
                      );
                    },
                  ))
            : (basketTeamSearchList.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    itemCount: basketTeamSearchList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: SizedBox(
                            height: 30,
                            width: 30,
                            child: basketTeamSearchList[index].image),
                        title: Text(
                          basketTeamSearchList[index].name,
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontFamily: "Arial",
                              fontWeight: FontWeight.w600),
                        ),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BasketballTeamDisplayPage(
                                    basketTeamSearchList[index]))),
                      );
                    },
                  )),
      );
    }
    // --- TAB 1: ΑΓΩΝΕΣ ---
    else if (widget.selectedIndex == 1) {
      return Scaffold(
        backgroundColor: bgColor,
        body: widget.sport == 'football'
            ? (matchSearchList.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    itemCount: matchSearchList.length,
                    itemBuilder: (context, index) => eachMatchContainer(
                        matchSearchList[
                            index]), // 💡 Το eachMatchContainer ήδη χειρίζεται το display name εσωτερικά!
                  ))
            : (basketMatchSearchList.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    itemCount: basketMatchSearchList.length,
                    itemBuilder: (context, index) =>
                        eachMatchContainerBasket(basketMatchSearchList[index]),
                  )),
      );
    }
    // --- TAB 2: ΙΣΤΟΡΙΚΟ ---
    else {
      return Scaffold(
        backgroundColor: bgColor,
        body: Column(
          children: [
            _buildSeasonChips(),
            Expanded(
              child: widget.sport == 'football'
                  ? (matchSearchList.isEmpty
                      ? _buildEmptyState(isDark)
                      : ListView.builder(
                          itemCount: matchSearchList.length,
                          itemBuilder: (context, index) =>
                              eachMatchContainer(matchSearchList[index]),
                        ))
                  : (basketMatchSearchList.isEmpty
                      ? _buildEmptyState(isDark)
                      : ListView.builder(
                          itemCount: basketMatchSearchList.length,
                          itemBuilder: (context, index) =>
                              eachMatchContainerBasket(
                                  basketMatchSearchList[index]),
                        )),
            ),
          ],
        ),
      );
    }
  }
}
