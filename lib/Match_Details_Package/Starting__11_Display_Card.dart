import 'package:flutter/material.dart';
import '../Data_Classes/MatchDetails.dart';
import '../Data_Classes/Player.dart';
import '../Data_Classes/match_facts.dart';
import '../globals.dart';
import 'choosePlayers.dart';

class LineupsDisplayTab extends StatefulWidget {
  final MatchDetails match;

  const LineupsDisplayTab({super.key, required this.match, });

  @override
  State<LineupsDisplayTab> createState() => _LineupsDisplayTabState();
}

class _LineupsDisplayTabState extends State<LineupsDisplayTab> {
  bool showHomeTeam = true;

  @override
  void initState() {
    super.initState();
    // Αν ο χρήστης ελέγχει ΜΟΝΟ τους φιλοξενούμενους, άνοιξε απευθείας αυτούς!
    bool canEditHome = globalUser.controlTheseTeamsFootball(widget.match.homeTeam.name, null) || globalUser.isUpperAdmin;
    bool canEditAway = globalUser.controlTheseTeamsFootball(widget.match.awayTeam.name, null) || globalUser.isUpperAdmin;

    if (!canEditHome && canEditAway) {
      showHomeTeam = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool canEditHome = globalUser.controlTheseTeamsFootball(widget.match.homeTeam.name, null) || globalUser.isUpperAdmin;
    bool canEditAway = globalUser.controlTheseTeamsFootball(widget.match.awayTeam.name, null) || globalUser.isUpperAdmin;
    bool isSpectator = !canEditHome && !canEditAway && !globalUser.isUpperAdmin;

    // Ελέγχει αν έχει δικαίωμα στην ομάδα που ΒΛΕΠΕΙ αυτή τη στιγμή
    bool canEditCurrentTeam = showHomeTeam ? canEditHome : canEditAway;

    // Αν είναι φίλαθλος και δεν έχουν δηλωθεί οι συνθέσεις
    if (isSpectator && widget.match.homeStarters.isEmpty && widget.match.awayStarters.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            greek ? "Οι συνθέσεις δεν είναι διαθέσιμες ακόμα." : "Lineups are not available yet.",
            style: TextStyle(color: darkModeNotifier.value ? Colors.white54 : Colors.black54),
          ),
        ),
      );
    }

    List<Player> teamRoster = showHomeTeam ? widget.match.homeTeam.players : widget.match.awayTeam.players;
    List<String> squadKeys = showHomeTeam ? widget.match.homeSquad : widget.match.awaySquad;
    List<String> starterKeys = showHomeTeam ? widget.match.homeStarters : widget.match.awayStarters;

    List<Player> starters = teamRoster.where((p) => starterKeys.contains(p.uniqueKey)).toList();
    starters.sort((a, b) => widget.match.getDisplayNumber(a).compareTo(widget.match.getDisplayNumber(b)));

    List<Player> bench = teamRoster.where((p) {
      String key = p.uniqueKey;
      return squadKeys.contains(key) && !starterKeys.contains(key);
    }).toList();
    bench.sort((a, b) => widget.match.getDisplayNumber(a).compareTo(widget.match.getDisplayNumber(b)));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. ΚΟΥΜΠΙ ΕΠΕΞΕΡΓΑΣΙΑΣ (Μόνο αν ελέγχει την τρέχουσα ομάδα)
        if (canEditCurrentTeam && !widget.match.hasMatchEndedFinal)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkModeNotifier.value ? Colors.blue[700] : Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.edit, color: Colors.white),
                label: Text(greek ? "Επεξεργασία Αποστολής" : "Edit Squad", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LiveLineupScreen(
                            match: widget.match,
                            initialIsHomeTeam: showHomeTeam, // Περνάει τη σωστή ομάδα!
                          )
                      )
                  ).then((_) => setState(() {}));
                },
              ),
            ),
          ),

        // 2. ΕΠΙΛΟΓΗ ΟΜΑΔΑΣ (Κουμπιά ή Στατικός Τίτλος)
        _buildTeamSelector(canEditHome, canEditAway, isSpectator),

        // 3. ΛΙΣΤΕΣ ΠΑΙΚΤΩΝ & STAFF
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(greek ? "ΒΑΣΙΚΟΙ (${starters.length})" : "STARTERS (${starters.length})", Colors.green),
            _buildPlayerList(starters, Colors.green),
            const SizedBox(height: 10),
            _buildSectionHeader(greek ? "ΠΑΓΚΟΣ (${bench.length})" : "BENCH (${bench.length})", Colors.blue),
            _buildPlayerList(bench, Colors.blue),

            const SizedBox(height: 10),

            _buildStaffSection(),

            const SizedBox(height: 30),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamSelector(bool canEditHome, bool canEditAway, bool isSpectator) {
    if ((canEditHome && canEditAway) || isSpectator) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          children: [
            Expanded(child: _teamBtn(widget.match.homeTeam.displayName, true, Colors.blue[800]!)),
            const SizedBox(width: 8),
            Expanded(child: _teamBtn(widget.match.awayTeam.displayName, false, Colors.red[800]!)),
          ],
        ),
      );
    }

    String teamName = showHomeTeam ? widget.match.homeTeam.name : widget.match.awayTeam.name;
    Color teamColor = showHomeTeam ? Colors.blue[800]! : Colors.red[800]!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: teamColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: teamColor.withOpacity(0.5), width: 2),
        ),
        child: Center(
          child: Text(
            "Ρόστερ: $teamName",
            style: TextStyle(
                color: darkModeNotifier.value ? Colors.white : teamColor,
                fontWeight: FontWeight.bold,
                fontSize: 16
            ),
          ),
        ),
      ),
    );
  }

  Widget _teamBtn(String name, bool isHome, Color color) {
    bool active = showHomeTeam == isHome;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? color : Colors.grey[300],
        foregroundColor: active ? Colors.white : Colors.black54,
      ),
      onPressed: () => setState(() => showHomeTeam = isHome),
      child: Text(name, overflow: TextOverflow.ellipsis),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 10, bottom: 5),
      child: Row(
        children: [
          Icon(Icons.sports_soccer, color: color, size: 18),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkModeNotifier.value ? Colors.white70 : Colors.black54)),
        ],
      ),
    );
  }

  // --- 💡 CUSTOM WIDGETS ΓΙΑ ΤΙΣ ΚΑΡΤΕΣ ---

  // 1. Ορθογώνια μονή κάρτα
  Widget _buildSingleCard(Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Container(
        width: 10,
        height: 15,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: Colors.black45, width: 0.5), // Απαλό περίγραμμα για να φαίνεται σε κάθε background
        ),
      ),
    );
  }

  // 2. Η "2η Κίτρινη" (Μισή κίτρινη - Μισή κόκκινη, κολλημένες)
  Widget _buildSplitCard() {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Container(
        width: 14, // Λίγο πιο πλατιά για να ξεχωρίζουν τα χρώματα
        height: 15,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: Colors.black45, width: 0.5),
          gradient: const LinearGradient(
            colors: [Colors.amber, Colors.red],
            stops: [0.5, 0.5], // Τέλειο κόψιμο στη μέση
          ),
        ),
      ),
    );
  }

  // --- Επιστρέφει εικονίδια για Γκολ και Κάρτες ---
  Widget _buildPlayerEvents(Player player, bool isHomeTeam) {
    int goals = 0;
    int yellowCards = 0;
    bool hasDirectRed = false;
    bool hasSecondYellowRed = false;

    // Το format του ονόματος όπως αποθηκεύεται στα matchFacts ("Α. Ντουρος")
    String formattedName = "${player.name.isNotEmpty ? player.name[0] : ''}. ${player.surname}";

    // Σαρώνουμε όλα τα ημίχρονα (0, 1, 2, 3)
    for (int i = 0; i < 4; i++) {
      if (widget.match.matchFact.containsKey(i)) {
        for (var fact in widget.match.matchFact[i]!) {
          if (fact.isHomeTeam == isHomeTeam) {

            if (fact is Goal && fact.name == formattedName) {
              goals++;
            } else if (fact is CardP && fact.name == formattedName) {
              if (fact.isYellow) {
                yellowCards++;
              } else {
                // Είναι κόκκινη κάρτα. Ελέγχουμε αν είναι 2η κίτρινη ή απευθείας!
                if (fact.isSecondYellow) {
                  hasSecondYellowRed = true;
                } else {
                  hasDirectRed = true;
                }
              }
            }

          }
        }
      }
    }

    List<Widget> icons = [];

    // --- 1. ΛΟΓΙΚΗ ΚΑΡΤΩΝ (Με απόλυτο διαχωρισμό) ---
    if (hasSecondYellowRed || yellowCards >= 2) {
      // Περίπτωση Α: Αποβολή με 2η Κίτρινη -> Δείχνουμε την κολλημένη Κίτρινη/Κόκκινη
      icons.add(_buildSplitCard());
    } else {
      // Περίπτωση Β: 1 Απλή Κίτρινη
      if (yellowCards == 1) {
        icons.add(_buildSingleCard(Colors.amber));
      }
    }

    // Περίπτωση Γ: Απευθείας Κόκκινη Κάρτα (Ξεχωριστά από τη 2η κίτρινη!)
    if (hasDirectRed) {
      icons.add(_buildSingleCard(Colors.red));
    }

    // --- 2. ΛΟΓΙΚΗ ΓΚΟΛ ---
    if (goals > 0) {
      Color ballColor = darkModeNotifier.value ? Colors.white : Colors.black87;
      icons.add(Padding(
        padding: const EdgeInsets.only(left: 6.0),
        child: Row(
          children: [
            Icon(Icons.sports_soccer, color: ballColor, size: 15),
            if (goals > 1) // Αν έβαλε 2+ γκολ, δείχνουμε x2, x3 κ.λπ.
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: Text("x$goals", style: TextStyle(color: ballColor, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ));
    }

    if (icons.isEmpty) return const SizedBox.shrink();

    return Row(mainAxisSize: MainAxisSize.min, children: icons);
  }
  Widget _buildPlayerList(List<Player> players, Color highlightColor) {
    if (players.isEmpty) return Padding(padding: const EdgeInsets.all(16.0), child: Text(greek ? "Δεν έχουν δηλωθεί παίκτες" : "No players declared"));

    String? currentCaptainKey = showHomeTeam ? widget.match.homeCaptain : widget.match.awayCaptain;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        String playerKey = "${player.name}${player.number}";
        bool isSubbedOut = (showHomeTeam ? widget.match.homeSubsOut : widget.match.awaySubsOut).contains(playerKey);
        bool isSubbedIn = (showHomeTeam ? widget.match.homeSubsIn : widget.match.awaySubsIn).contains(playerKey);
        bool isCaptain = (currentCaptainKey == playerKey);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          color: darkModeNotifier.value ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(side: BorderSide(color: highlightColor.withOpacity(0.5), width: 1), borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              backgroundColor: highlightColor.withOpacity(0.2), radius: 16,
              child: Text(widget.match.getDisplayNumber(player).toString(), style: TextStyle(color: highlightColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            title: Row(
              children: [
                Expanded(
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(text: "${player.surname} ${player.name}", style: TextStyle(color: isSubbedOut ? Colors.grey : (darkModeNotifier.value ? Colors.white : Colors.black), fontSize: 14)),
                        if (isCaptain) TextSpan(text: " (C)", style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, fontSize: 13)),
                      ],
                    ),
                  ),
                ),

                // Τα εικονίδια γεγονότων (Γκολ/Κάρτες)
                if (widget.match.hasMatchStarted)
                  _buildPlayerEvents(player, showHomeTeam),

                const SizedBox(width: 8),
                if (!widget.match.hasMatchStarted)
                  _buildHealthCardStatus(player.cardExpiryDate),
              ],
            ),
            trailing: isSubbedOut ? Icon(Icons.output, color: Colors.red[300], size: 20) : isSubbedIn ? Icon(Icons.input, color: Colors.green[300], size: 20) : null,
          ),
        );
      },
    );
  }

  Widget _buildHealthCardStatus(DateTime? issueDate) {
    if (issueDate == null) return const Tooltip(message: "Χωρίς Κάρτα Υγείας", triggerMode: TooltipTriggerMode.tap, showDuration: Duration(seconds: 3), child: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiration = DateTime(issueDate.year + 1, issueDate.month, issueDate.day);
    final daysLeft = expiration.difference(today).inDays;
    if (daysLeft < 0) return const Tooltip(message: "Ληγμένη Κάρτα Υγείας!", triggerMode: TooltipTriggerMode.tap, showDuration: Duration(seconds: 3), child: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20));
    else return SizedBox.fromSize();
  }

  Widget _buildStaffSection() {
    String? coach = showHomeTeam ? widget.match.homeCoach : widget.match.awayCoach;
    String? assistant = showHomeTeam ? widget.match.homeAssistant : widget.match.awayAssistant;
    String? kitman = showHomeTeam ? widget.match.homeKitman : widget.match.awayKitman;

    if ((coach == null || coach.isEmpty) &&
        (assistant == null || assistant.isEmpty) &&
        (kitman == null || kitman.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(greek ? "ΤΕΧΝΙΚΟ ΕΠΙΤΕΛΕΙΟ" : "TECHNICAL STAFF", Colors.orange),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          color: darkModeNotifier.value ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.orange.withOpacity(0.5), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                if (coach != null && coach.isNotEmpty)
                  _staffRow(Icons.person, greek ? "Προπονητής:" : "Coach:", coach),

                if (assistant != null && assistant.isNotEmpty) ...[
                  if (coach != null && coach.isNotEmpty) const Divider(height: 12, thickness: 0.5),
                  _staffRow(Icons.group, greek ? "Βοηθός:" : "Assistant:", assistant),
                ],

                if (kitman != null && kitman.isNotEmpty) ...[
                  if ((coach != null && coach.isNotEmpty) || (assistant != null && assistant.isNotEmpty))
                    const Divider(height: 12, thickness: 0.5),
                  _staffRow(Icons.medical_services, greek ? "Ιατρ. / Φροντ.:" : "Medical / Kitman:", kitman),
                ],
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _staffRow(IconData icon, String role, String name) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 10),
        Text(role, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
        const SizedBox(width: 8),
        Expanded(
            child: Text(
              name,
              style: TextStyle(
                  color: darkModeNotifier.value ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 14
              ),
              overflow: TextOverflow.ellipsis,
            )
        ),
      ],
    );
  }
}