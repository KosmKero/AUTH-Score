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
import 'mContainers/matchesContainer.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void onSectionChange(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Search page', screenClass: 'Search page');

    // Πλέον παίρνουμε το theme ΜΙΑ φορά και το χρησιμοποιούμε παντού
    final theme = Theme.of(context);

    return Scaffold(
      // Το background το αναλαμβάνει αυτόματα το Scaffold, δεν χρειάζεται να το δηλώσεις καν!
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent, // Για να πάρει το χρώμα του Scaffold
        iconTheme: IconThemeData(color: theme.textTheme.bodyLarge?.color),
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: theme.cardColor, // Χρησιμοποιεί το lightModeContainer ή darkModeWidgets αυτόματα!
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            style: theme.textTheme.bodyMedium, // Παίρνει το σωστό χρώμα κειμένου αυτόματα
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: theme.textTheme.bodySmall?.color, // Το "ξεθωριασμένο" χρώμα για υπο-κείμενα
                size: 20,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: theme.textTheme.bodySmall?.color,
                  size: 18,
                ),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                  });
                },
              )
                  : null,
              hintText: greek ? "Αναζήτηση..." : 'Search...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              hintStyle: theme.textTheme.bodySmall?.copyWith(fontSize: 15),
            ),
            onChanged: (text) => setState(() {}),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 52,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabButton(greek ? "Ομάδες" : "Teams", 0, theme),
                _buildTabButton(greek ? "Αγώνες" : "Matches", 1, theme),
                _buildTabButton(greek ? "Ιστορικό" : "History", 2, theme),
              ],
            ),
          ),
          Expanded(
            child: SearchDetails(
              selectedIndex: selectedIndex,
              name: _searchController.text,
              sport: localSport,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index, ThemeData theme) {
    final bool isSelected = selectedIndex == index;
    // Εδώ κρατάμε τη λογική για το άθλημα, το primaryColor είναι το Μπλε που έβαλες στο AppTheme
    final Color activeColor = localSport == 'football' ? theme.primaryColor : Colors.orange;

    return InkWell(
      onTap: () => onSectionChange(index),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                // Αν είναι επιλεγμένο παίρνει το χρώμα του αθλήματος, αλλιώς το δευτερεύον χρώμα κειμένου
                color: isSelected ? activeColor : theme.textTheme.bodySmall?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontFamily: "Arial",
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 36 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// SEARCH DETAILS WIDGET
// ==========================================
class SearchDetails extends StatefulWidget {
  final int selectedIndex;
  final String name;
  final String sport;

  const SearchDetails({
    super.key,
    required this.selectedIndex,
    required this.name,
    required this.sport,
  });

  @override
  State<SearchDetails> createState() => _SearchDetailsState();
}

class _SearchDetailsState extends State<SearchDetails> {
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
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SearchDetails oldWidget) {
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
        List<MatchDetails> mList = await matchSearch(
          query,
          onlyCurrentSeason: currentTab == 1,
          season: currentTab == 2 ? currentSeason : null,
        );

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
        List<BasketMatch> bmList = await basketMatchSearch(
          query,
          onlyCurrentSeason: currentTab == 1,
          season: currentTab == 2 ? currentSeason : null,
        );

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

  List<Team> teamSearch(String query) {
    if (query.isEmpty) return teams;
    return teams
        .where((team) =>
    team.name.toLowerCase().contains(query) ||
        team.displayGreek.toLowerCase().contains(query) ||
        team.displayEnglish.toLowerCase().contains(query))
        .toList();
  }

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

  List<basketTeam> basketTeamSearch(String query) {
    if (query.isEmpty) return basketTeams;
    return basketTeams
        .where((team) => team.name.toLowerCase().contains(query))
        .toList();
  }

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
        match.awayTeam.name.toLowerCase().contains(query))
        .toList();
  }

  Widget _buildSeasonChips(ThemeData theme) {
    final Color activeColor = widget.sport == 'football' ? theme.primaryColor : Colors.orange;
    final bool isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: seasons.map((season) {
          final bool isSelected = selectedSeason == season;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text("${season - 1}-$season"),
              selected: isSelected,
              selectedColor: activeColor,
              backgroundColor: theme.cardColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : theme.textTheme.bodyMedium?.color, // Δυναμικό χρώμα
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? activeColor
                      : (isDark ? Colors.transparent : Colors.black12),
                ),
              ),
              onSelected: (_) {
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

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Text(
          greek ? "Δεν βρέθηκαν αποτελέσματα" : "No results found",
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildTeamCard({
    required Widget image,
    required String name,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Card(
      color: theme.cardColor, // Το χρώμα της κάρτας κληρονομείται από το AppTheme
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: SizedBox(height: 36, width: 36, child: image),
        title: Text(
          name,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: "Arial",
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: theme.textTheme.bodySmall?.color, // Ξεθωριασμένο βελάκι
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: widget.sport == 'football' ? theme.primaryColor : Colors.orange,
        ),
      );
    }

    if (widget.selectedIndex == 0) {
      if (widget.sport == 'football') {
        if (teamSearchList.isEmpty) return _buildEmptyState(theme);
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: teamSearchList.length,
          itemBuilder: (context, index) {
            final team = teamSearchList[index];
            return _buildTeamCard(
              image: team.image,
              name: greek ? team.displayGreek : team.displayEnglish,
              theme: theme, // Περνάμε το theme στη function
              onTap: () async {
                bool? didChange = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeamDisplayPage(team)),
                );
                if (didChange == true) {
                  setState(() {
                    teamSearchList.removeAt(index);
                  });
                  searchPressed(widget.name);
                }
              },
            );
          },
        );
      } else {
        if (basketTeamSearchList.isEmpty) return _buildEmptyState(theme);
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: basketTeamSearchList.length,
          itemBuilder: (context, index) {
            final bTeam = basketTeamSearchList[index];
            return _buildTeamCard(
              image: bTeam.image,
              name: bTeam.name,
              theme: theme,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BasketballTeamDisplayPage(bTeam),
                ),
              ),
            );
          },
        );
      }
    }

    if (widget.selectedIndex == 1) {
      if (widget.sport == 'football') {
        if (matchSearchList.isEmpty) return _buildEmptyState(theme);
        return ListView.builder(
          itemCount: matchSearchList.length,
          itemBuilder: (context, index) => eachMatchContainer(matchSearchList[index]),
        );
      } else {
        if (basketMatchSearchList.isEmpty) return _buildEmptyState(theme);
        return ListView.builder(
          itemCount: basketMatchSearchList.length,
          itemBuilder: (context, index) =>
              eachMatchContainerBasket(basketMatchSearchList[index]),
        );
      }
    }

    return Column(
      children: [
        _buildSeasonChips(theme),
        Expanded(
          child: widget.sport == 'football'
              ? (matchSearchList.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
            itemCount: matchSearchList.length,
            itemBuilder: (context, index) =>
                eachMatchContainer(matchSearchList[index]),
          ))
              : (basketMatchSearchList.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
            itemCount: basketMatchSearchList.length,
            itemBuilder: (context, index) =>
                eachMatchContainerBasket(basketMatchSearchList[index]),
          )),
        ),
      ],
    );
  }
}