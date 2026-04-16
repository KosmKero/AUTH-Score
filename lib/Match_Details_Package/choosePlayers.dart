import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Data_Classes/MatchDetails.dart';
import '../Data_Classes/Player.dart';
import '../Data_Classes/match_facts.dart';
import '../globals.dart';
import '../globals.dart' as global;

class LiveLineupScreen extends StatefulWidget {
  final MatchDetails match;
  final bool initialIsHomeTeam;

  const LiveLineupScreen(
      {super.key, required this.match, required this.initialIsHomeTeam});

  @override
  State<LiveLineupScreen> createState() => _LiveLineupScreenState();
}

class _LiveLineupScreenState extends State<LiveLineupScreen> {
  bool showHomeTeam = true;
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // Μεταβλητές για το Staff & τον Αρχηγό
  String? selectedCaptain;
  final TextEditingController coachController = TextEditingController();
  final TextEditingController assistantController = TextEditingController();
  final TextEditingController kitmanController = TextEditingController();

  Set<String> homeSquad = {};
  Set<String> homeStarters = {};
  Set<String> awaySquad = {};
  Set<String> awayStarters = {};

  @override
  void initState() {
    super.initState();
    homeSquad = widget.match.homeSquad.toSet();
    homeStarters = widget.match.homeStarters.toSet();
    awaySquad = widget.match.awaySquad.toSet();
    awayStarters = widget.match.awayStarters.toSet();

    showHomeTeam = widget.initialIsHomeTeam;

    _loadStaffDataForCurrentTeam();
  }

  void _loadStaffDataForCurrentTeam() {
    if (showHomeTeam) {
      selectedCaptain = widget.match.homeCaptain;
      coachController.text = widget.match.homeCoach ?? "";
      assistantController.text = widget.match.homeAssistant ?? "";
      kitmanController.text = widget.match.homeKitman ?? "";
    } else {
      selectedCaptain = widget.match.awayCaptain;
      coachController.text = widget.match.awayCoach ?? "";
      assistantController.text = widget.match.awayAssistant ?? "";
      kitmanController.text = widget.match.awayKitman ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Player> currentList = showHomeTeam
        ? List.from(widget.match.homeTeam.players)
        : List.from(widget.match.awayTeam.players);
    currentList.sort((a, b) => widget.match
        .getDisplayNumber(a)
        .compareTo(widget.match.getDisplayNumber(b)));

    Set<String> currentSquad = showHomeTeam ? homeSquad : awaySquad;
    Set<String> currentStarters = showHomeTeam ? homeStarters : awayStarters;

    List<Player> filteredList = currentList.where((p) {

      if (widget.match.hasMatchStarted && !currentSquad.contains(p.uniqueKey)) {
        return false;
      }

      String fullName = "${p.name} ${p.surname}".toLowerCase();
      String input = searchQuery.toLowerCase();
      String displayNum = widget.match.getDisplayNumber(p).toString();
      return fullName.contains(input) || displayNum.contains(input);
    }).toList();


    return Scaffold(
      backgroundColor:
          darkModeNotifier.value ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
            darkModeNotifier.value ? Colors.grey[900] : Colors.blue[800],
        title: Text(greek ? "Επεξεργασία Αποστολής" : "Edit Squad",
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildTeamSelectionButtons(),
          Expanded(
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 5.0),
                        child: Card(
                          color: darkModeNotifier.value
                              ? Colors.grey[850]
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          child: ExpansionTile(
                            initiallyExpanded: !widget.match.hasMatchStarted,
                            leading: const Icon(Icons.shield,
                                color: Colors.blueAccent),
                            title: Text("Επιτελείο Ομάδας & Αρχηγός",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: darkModeNotifier.value
                                        ? Colors.white
                                        : Colors.black87)),
                            childrenPadding: const EdgeInsets.all(15.0),
                            children: [
                              // --- 1. DROPDOWN ΑΡΧΗΓΟΥ ---
                              Builder(
                                builder: (context) {
                                  // 1. Μαζεύουμε τα κλειδιά για να αποφύγουμε τα διπλότυπα
                                  Set<String> validKeys = {};
                                  List<DropdownMenuItem<String>> dropdownItems = [];

                                  for (var player in currentList) {
                                    String pKey = player.uniqueKey;

                                    // 🌟 Η ΜΑΓΕΙΑ: Τον βάζουμε στη λίστα ΑΝ είναι βασικός Ή ΑΝ είναι ο ήδη επιλεγμένος αρχηγός (ακόμα κι αν βγήκε αλλαγή)
                                    if (currentStarters.contains(pKey) || pKey == selectedCaptain) {
                                      if (!validKeys.contains(pKey)) {
                                        validKeys.add(pKey);
                                        dropdownItems.add(
                                          DropdownMenuItem<String>(
                                            value: pKey,
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 12,
                                                  backgroundColor: darkModeNotifier.value ? Colors.blue[800] : Colors.blue[200],
                                                  child: Text(
                                                    widget.match.getDisplayNumber(player).toString(),
                                                    style: TextStyle(
                                                        color: darkModeNotifier.value ? Colors.white : Colors.black87,
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    "${player.surname} ${player.name}",
                                                    overflow: TextOverflow.ellipsis,
                                                    // Αν έχει βγει αλλαγή, δείξτο με γκρι γράμματα στο Dropdown!
                                                    style: TextStyle(
                                                      color: (!currentStarters.contains(pKey) && widget.match.hasMatchStarted)
                                                          ? Colors.grey
                                                          : (darkModeNotifier.value ? Colors.white : Colors.black),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }

                                  // 2. Δικλείδα Ασφαλείας: Αν ο selectedCaptain για κάποιο λόγο διαγράφηκε τελείως, κάντον null
                                  String? safeCaptain = validKeys.contains(selectedCaptain) ? selectedCaptain : null;

                                  return DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: greek ? "Αρχηγός Ομάδας (C)" : "Captain",
                                      labelStyle: TextStyle(
                                          color: darkModeNotifier.value ? Colors.blue[200] : Colors.blue[800]),
                                      filled: true,
                                      fillColor: darkModeNotifier.value ? Colors.grey[900] : Colors.grey[100],
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                    ),
                                    dropdownColor: darkModeNotifier.value ? Colors.grey[800] : Colors.white,

                                    value: safeCaptain, // 🌟 Βάζουμε το Safe Value
                                    isExpanded: true,
                                    items: dropdownItems, // 🌟 Βάζουμε τη λίστα που φτιάξαμε

                                    style: TextStyle(
                                        color: widget.match.hasMatchStarted
                                            ? Colors.grey
                                            : (darkModeNotifier.value ? Colors.white : Colors.black)),
                                    onChanged: widget.match.hasMatchStarted
                                        ? null
                                        : (val) {
                                      setState(() {
                                        selectedCaptain = val;
                                      });
                                    },
                                  );
                                },
                              ),                              const SizedBox(height: 15),
                              TextField(
                                controller: coachController,
                                readOnly: widget.match.hasMatchStarted, // 🌟 ΚΛΕΙΔΩΜΑ
                                style: TextStyle(color: widget.match.hasMatchStarted ? Colors.grey : (darkModeNotifier.value ? Colors.white : Colors.black)),
                                decoration: InputDecoration(
                                    labelText: "Προπονητής",
                                    labelStyle: TextStyle(color: darkModeNotifier.value ? Colors.grey[400] : Colors.grey[700]),
                                    filled: true,
                                    fillColor: darkModeNotifier.value ? Colors.grey[900] : Colors.grey[100],
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: assistantController,
                                readOnly: widget.match.hasMatchStarted, // 🌟 ΚΛΕΙΔΩΜΑ
                                style: TextStyle(color: widget.match.hasMatchStarted ? Colors.grey : (darkModeNotifier.value ? Colors.white : Colors.black)),
                                decoration: InputDecoration(
                                    labelText: "Βοηθός Προπονητή",
                                    labelStyle: TextStyle(color: darkModeNotifier.value ? Colors.grey[400] : Colors.grey[700]),
                                    filled: true,
                                    fillColor: darkModeNotifier.value ? Colors.grey[900] : Colors.grey[100],
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: kitmanController,
                                readOnly: widget.match.hasMatchStarted, // 🌟 ΚΛΕΙΔΩΜΑ
                                style: TextStyle(color: widget.match.hasMatchStarted ? Colors.grey : (darkModeNotifier.value ? Colors.white : Colors.black)),
                                decoration: InputDecoration(
                                    labelText: "Φροντιστής / Ιατρός",
                                    labelStyle: TextStyle(color: darkModeNotifier.value ? Colors.grey[400] : Colors.grey[700]),
                                    filled: true,
                                    fillColor: darkModeNotifier.value ? Colors.grey[900] : Colors.grey[100],
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => searchQuery = val),
                          style: TextStyle(
                              color: darkModeNotifier.value
                                  ? Colors.white
                                  : Colors.black),
                          decoration: InputDecoration(
                            hintText: greek
                                ? "Αναζήτηση με όνομα ή νούμερο..."
                                : "Search by name or number...",
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.grey),
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => searchQuery = "");
                                    })
                                : null,
                            filled: true,
                            fillColor: darkModeNotifier.value
                                ? Colors.grey[850]
                                : Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final player = filteredList[index];
                      String playerKey = player.uniqueKey;
                      bool isInRoster = currentSquad.contains(playerKey);
                      bool isStarter = currentStarters.contains(playerKey);
                      return _buildPlayerCard(
                          player, isInRoster, isStarter, playerKey);
                    },
                    childCount: filteredList.length,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: (!widget.match.hasMatchStarted)
          ? _buildBottomStickyActions(
              currentSquad.length, currentStarters.length)
          : null,
    );
  }

  Widget _buildTeamSelectionButtons() {
    bool canEditHome = globalUser.controlTheseTeamsFootball(
            widget.match.homeTeam.name, null) ||
        globalUser.isUpperAdmin;
    bool canEditAway = globalUser.controlTheseTeamsFootball(
            widget.match.awayTeam.name, null) ||
        globalUser.isUpperAdmin;

    // 🌟 Αν είναι Admin και ελέγχει ΚΑΙ ΤΙΣ 2 ΟΜΑΔΕΣ, δείξε τα κουμπιά εναλλαγής
    if (canEditHome && canEditAway) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
                child: _teamBtn(
                    widget.match.homeTeam.name, true, Colors.blue[800]!)),
            const SizedBox(width: 10),
            Expanded(
                child: _teamBtn(
                    widget.match.awayTeam.name, false, Colors.red[800]!)),
          ],
        ),
      );
    }

    // Δείξε του απλά έναν ωραίο, ξεκάθαρο τίτλο με το όνομα της ομάδας του.
    String teamName =
        showHomeTeam ? widget.match.homeTeam.name : widget.match.awayTeam.name;
    Color teamColor = showHomeTeam ? Colors.blue[800]! : Colors.red[800]!;

    return Padding(
      padding: const EdgeInsets.all(12.0),
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
                fontSize: 16),
          ),
        ),
      ),
    );
  }

  // Αυτό το κουμπί τώρα θα χρησιμοποιείται ΜΟΝΟ από τους Admins
  Widget _teamBtn(String name, bool isHome, Color color) {
    bool active = showHomeTeam == isHome;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? color : Colors.grey[300],
        foregroundColor: active ? Colors.white : Colors.black54,
        elevation: active ? 3 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: () {
        setState(() {
          showHomeTeam = isHome;
          _loadStaffDataForCurrentTeam();
        });
      },
      child: Text(name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPlayerCard(
      Player player, bool isInRoster, bool isStarter, String playerKey) {
    List<String> currentSubsOut =
        showHomeTeam ? widget.match.homeSubsOut : widget.match.awaySubsOut;
    List<String> currentSubsIn =
        showHomeTeam ? widget.match.homeSubsIn : widget.match.awaySubsIn;

    bool isSubbedOut = currentSubsOut.contains(playerKey);
    bool isSubbedIn = currentSubsIn.contains(playerKey);

    return Card(
      color: darkModeNotifier.value ? Colors.grey[850] : Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: isStarter ? 3 : 1,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
              color: isStarter
                  ? Colors.green
                  : (isInRoster ? Colors.blue : Colors.transparent),
              width: 2)),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            if (!widget.match.hasMatchStarted) {
              _showEditNumberDialog(context, player, widget.match);
            } else {
              _showErrorSnackbar(greek
                  ? "Το ματς έχει ήδη ξεκινήσει! Η αλλαγή φανέλας πάει στις παρατηρήσεις."
                  : "Match started!");
            }
          },
          child: CircleAvatar(
            backgroundColor: isSubbedOut
                ? Colors.grey[600]
                : (isStarter ? Colors.green :
                  (isInRoster ? Colors.blue :
                                Colors.grey[300])),
            child: Text(widget.match.getDisplayNumber(player).toString(),
                style: TextStyle(
                    color: isInRoster ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        title: Row(
          children: [
            Flexible(
                child: Text("${player.surname} ${player.name}",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isInRoster ? FontWeight.bold : FontWeight.normal,
                        color: isSubbedOut
                            ? Colors.grey
                            : (darkModeNotifier.value
                                ? Colors.white
                                : Colors.black)),
                    overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
          ],
        ),
        subtitle: Text(
            isSubbedOut
                ? (greek ? "Βγήκε Αλλαγή" : "Subbed Out")
                : isSubbedIn
                    ? (greek ? "Μπήκε Αλλαγή" : "Subbed In")
                    : isStarter
                        ? (greek ? "Βασικός" : "Starter")
                        : isInRoster
                            ? (greek ? "Πάγκος" : "Bench")
                            : (greek ? "Εκτός" : "Out"),
            style: TextStyle(
                color: isSubbedOut
                    ? Colors.grey
                    : isStarter
                        ? Colors.green
                        : (isInRoster ? Colors.blue : Colors.grey),
                fontSize: 12)),
        trailing: _buildTrailingActions(
            player, isInRoster, isStarter, playerKey, isSubbedOut),
      ),
    );
  }

  Widget _buildTrailingActions(Player player, bool isInRoster, bool isStarter,
      String playerKey, bool isSubbedOut) {
    if (widget.match.hasMatchStarted) {
      List<String> currentSubsIn =
          showHomeTeam ? widget.match.homeSubsIn : widget.match.awaySubsIn;
      bool isSubbedIn = currentSubsIn.contains(playerKey);
      if (isSubbedOut || isSubbedIn) {
        return IconButton(
            icon: const Icon(Icons.undo, color: Colors.orange, size: 24),
            tooltip: greek ? "Ακύρωση Αλλαγής" : "Undo Sub",
            onPressed: () => _undoSubDialog(player, isSubbedOut, isSubbedIn));
      }
      return (isStarter && !isSubbedOut)
          ? IconButton(
              icon: const Icon(Icons.swap_horiz, color: Colors.blue, size: 28),
              onPressed: () => _showSubDialog(player))
          : const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
            onTap: () {
              if (globalUser.isUpperAdmin) {
                _showHealthCardDialog(player);
              } else {
                _showErrorSnackbar(greek
                    ? "Μόνο η διοργάνωση μπορεί να επεξεργαστεί τις Κάρτες Υγείας."
                    : "Only admins can edit Health Cards.");
              }
            },
            child: Container(
                padding: const EdgeInsets.all(4),
                child: _buildHealthCardStatus(player.cardExpiryDate))),
        IconButton(
            icon: Icon(
                isInRoster ? Icons.check_circle : Icons.add_circle_outline,
                color: isInRoster ? Colors.blue : Colors.grey,
                size: 28),
            onPressed: () => _toggleRoster(playerKey, player)),
        IconButton(
            icon: Icon(isStarter ? Icons.star : Icons.star_border,
                color: isStarter ? Colors.green : Colors.grey, size: 28),
            onPressed: () => _toggleStarter(playerKey, player)),
      ],
    );
  }

  Widget _buildBottomStickyActions(int squadCount, int startersCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
          color: darkModeNotifier.value ? Colors.grey[900] : Colors.white,
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
          ],
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _statusCounter(
                greek ? "ΑΠΟΣΤΟΛΗ" : "SQUAD", squadCount, 22, Colors.blue),
            _statusCounter(greek ? "ΒΑΣΙΚΟΙ" : "STARTERS", startersCount, 11,
                Colors.green),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      (startersCount == 11) ? Colors.green : Colors.grey,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: () => _saveStuffToFirebase(startersCount),
              child: Text(greek ? "ΑΠΟΘΗΚΕΥΣΗ" : "SAVE",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _statusCounter(String label, int current, int max, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        Text("$current / $max",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: (current == max)
                    ? color
                    : (darkModeNotifier.value
                        ? Colors.white
                        : Colors.black87))),
      ],
    );
  }

  void _toggleRoster(String playerKey, Player player) {
    Set<String> currentSquad = showHomeTeam ? homeSquad : awaySquad;
    Set<String> currentStarters = showHomeTeam ? homeStarters : awayStarters;
    setState(() {
      if (currentSquad.contains(playerKey)) {
        currentSquad.remove(playerKey);
        currentStarters.remove(playerKey);
      } else {
        if (currentSquad.length < 22)
          currentSquad.add(playerKey);
        else
          _showErrorSnackbar(
              greek ? "Η αποστολή είναι γεμάτη (22)." : "Squad is full (22).");
      }
    });
  }

  void _showHealthCardDialog(Player player) {
    DateTime selectedDate = player.cardExpiryDate ?? DateTime.now();
    String messageGreek;
    String messageEnglish;

    if (player.cardExpiryDate == null) {
      messageGreek =
          "Ο παίκτης ${player.surname} δεν έχει κάρτα υγείας. Θέλετε να καταχωρήσετε νέα;";
      messageEnglish =
          "Player ${player.surname} has no health card. Add a new one?";
    } else {
      final expiration = DateTime(player.cardExpiryDate!.year + 1,
          player.cardExpiryDate!.month, player.cardExpiryDate!.day);
      final today = DateTime.now();
      if (expiration.isBefore(today)) {
        messageGreek =
            "Η κάρτα του/της ${player.surname} έχει λήξει. Θέλετε να την ανανεώσετε;";
        messageEnglish =
            "The card for ${player.surname} has expired. Renew it?";
      } else {
        messageGreek =
            "Ο παίκτης ${player.surname} έχει ενεργή κάρτα. Θέλετε να την ανανεώσετε με νέα ημερομηνία έκδοσης;";
        messageEnglish =
            "${player.surname} has an active card. Renew with a new issue date?";
      }
    }

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor:
                  darkModeNotifier.value ? Colors.grey[900] : Colors.white,
              title: Text(greek ? "Κάρτα Υγείας" : "Health Card",
                  style: TextStyle(
                      color: darkModeNotifier.value
                          ? Colors.white
                          : Colors.black)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greek ? messageGreek : messageEnglish,
                      style: TextStyle(
                          color: darkModeNotifier.value
                              ? Colors.white70
                              : Colors.black87)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "${greek ? 'Έκδοση' : 'Issued'}: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: darkModeNotifier.value
                                  ? Colors.white
                                  : Colors.black)),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_month,
                            color: Colors.blue),
                        label: Text(greek ? "ΑΛΛΑΓΗ" : "CHANGE",
                            style: const TextStyle(color: Colors.blue)),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                    data: darkModeNotifier.value
                                        ? ThemeData.dark()
                                        : ThemeData.light(),
                                    child: child!);
                              });
                          if (picked != null)
                            setStateDialog(() => selectedDate = picked);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                      greek
                          ? "*Αν δεν αλλάξεις ημερομηνία, θα αποθηκευτεί η σημερινή."
                          : "*If unchanged, today's date will be used.",
                      style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic))
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(greek ? "ΑΚΥΡΟ" : "CANCEL",
                        style: const TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () {
                    Navigator.pop(context);
                    _updateHealthCardInFirebase(player, selectedDate);
                  },
                  child: Text(greek ? "ΑΠΟΘΗΚΕΥΣΗ" : "SAVE",
                      style: const TextStyle(color: Colors.white)),
                ),
              ],
            );
          });
        });
  }

  Future<void> _updateHealthCardInFirebase(
      Player player, DateTime newDate) async {
    try {
      setState(() {});
      player.setCardExpiryDate(newDate);
      _showErrorSnackbar(
          greek ? "Η κάρτα υγείας ενημερώθηκε!" : "Health card updated!");
    } catch (e) {
      _showErrorSnackbar("Error updating health card: $e");
    }
  }

  void _toggleStarter(String playerKey, Player player) {
    Set<String> currentSquad = showHomeTeam ? homeSquad : awaySquad;
    Set<String> currentStarters = showHomeTeam ? homeStarters : awayStarters;
    setState(() {
      if (currentStarters.contains(playerKey)) {
        currentStarters.remove(playerKey);

      } else {
        if (currentStarters.length < 11) {
          currentStarters.add(playerKey);
          if (!currentSquad.contains(playerKey)) {
            if (currentSquad.length < 22)
              currentSquad.add(playerKey);
            else {
              currentStarters.remove(playerKey);
              _showErrorSnackbar(greek
                  ? "Η αποστολή είναι γεμάτη (22)."
                  : "Squad is full (22).");
            }
          }
        } else {
          _showErrorSnackbar(greek
              ? "Έχεις ήδη 11 βασικούς."
              : "You already have 11 starters.");
        }
      }
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    HapticFeedback.vibrate();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
  }

  Future<void> _saveStuffToFirebase(int startersCount) async {
    if (startersCount != 11) {
      _showErrorSnackbar(greek
          ? "Πρέπει να επιλέξεις 11 βασικούς."
          : "You must select 11 starters.");
      return;
    }
    if (selectedCaptain == null) {
      _showErrorSnackbar(greek
          ? "Πρέπει να επιλέξεις Αρχηγό (C)!"
          : "You must select a Captain (C)!");
      return;
    }
    try {
      await widget.match.saveLineupAndStaff(
        isHomeTeam: showHomeTeam,
        newSquad: showHomeTeam ? homeSquad.toList() : awaySquad.toList(),
        newStarters:
            showHomeTeam ? homeStarters.toList() : awayStarters.toList(),
        captain: selectedCaptain,
        coach: coachController.text.trim().isEmpty
            ? null
            : coachController.text.trim(),
        assistant: assistantController.text.trim().isEmpty
            ? null
            : assistantController.text.trim(),
        kitman: kitmanController.text.trim().isEmpty
            ? null
            : kitmanController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(greek ? "Αποθηκεύτηκε!" : "Saved!"),
          backgroundColor: Colors.green,
          duration: const Duration(milliseconds: 1700)));
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackbar("Error saving: $e");
    }
  }

  void _showSubDialog(Player playerOut) {
    Set<String> currentSquad = showHomeTeam ? homeSquad : awaySquad;
    Set<String> currentStarters = showHomeTeam ? homeStarters : awayStarters;
    List<String> currentSubsOut =
        showHomeTeam ? widget.match.homeSubsOut : widget.match.awaySubsOut;
    List<Player> teamRoster = showHomeTeam
        ? widget.match.homeTeam.players
        : widget.match.awayTeam.players;

    List<Player> availableSubs = teamRoster.where((p) {
      String pKey = p.uniqueKey;
      return currentSquad.contains(pKey) &&
          !currentStarters.contains(pKey) &&
          !currentSubsOut.contains(pKey);
    }).toList();

    availableSubs.sort((a, b) => widget.match
        .getDisplayNumber(a)
        .compareTo(widget.match.getDisplayNumber(b)));

    if (availableSubs.isEmpty) {
      _showErrorSnackbar(
          greek ? "Κανένας παίκτης διαθέσιμος!" : "No players available!");
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            darkModeNotifier.value ? Colors.grey[900] : Colors.white,
        title: Text(
            greek
                ? "Αλλαγή (Βγαίνει: ${playerOut.surname})"
                : "Sub (Out: ${playerOut.surname})",
            style: TextStyle(
                color: darkModeNotifier.value ? Colors.white : Colors.black,
                fontSize: 16)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableSubs.length,
            itemBuilder: (context, i) {
              final playerIn = availableSubs[i];
              return ListTile(
                leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                        widget.match.getDisplayNumber(playerIn).toString(),
                        style: const TextStyle(color: Colors.white))),
                title: Text("${playerIn.surname} ${playerIn.name}",
                    style: TextStyle(
                        color: darkModeNotifier.value
                            ? Colors.white
                            : Colors.black)),
                trailing: const Icon(Icons.input, color: Colors.green),
                onTap: () {
                  Navigator.pop(context);
                  _performSubstitution(playerOut, playerIn);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _performSubstitution(Player playerOut, Player playerIn) async {
    String keyOut = playerOut.uniqueKey;
    String keyIn = playerIn.uniqueKey;
    String nameOut = "${playerOut.surname} ${playerOut.name}";
    String nameIn = "${playerIn.surname} ${playerIn.name}";

    try {
      await widget.match
          .performSubstitution(keyOut, keyIn, nameOut, nameIn, showHomeTeam);
      setState(() {
        if (showHomeTeam) {
          homeStarters.remove(keyOut);
          homeStarters.add(keyIn);
        } else {
          awayStarters.remove(keyOut);
          awayStarters.add(keyIn);
        }
      });
      _showErrorSnackbar(
          greek ? "Η αλλαγή ολοκληρώθηκε!" : "Substitution Complete!");
    } catch (e) {
      _showErrorSnackbar("Error: $e");
    }
  }

  void _undoSubDialog(Player player, bool isSubbedOut, bool isSubbedIn) {
    String pKey = player.uniqueKey;
    String pairedPlayerName = "Άγνωστος";
    for (int i = 0; i < 4; i++) {
      if (widget.match.matchFact.containsKey(i)) {
        for (var fact in widget.match.matchFact[i]!) {
          if (fact is Substitution) {
            if (fact.playerOut == pKey) {
              pairedPlayerName = fact.playerInName;
              break;
            } else if (fact.playerIn == pKey) {
              pairedPlayerName = fact.playerOutName;
              break;
            }
          }
        }
      }
      if (pairedPlayerName != "Άγνωστος") break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            darkModeNotifier.value ? Colors.grey[900] : Colors.white,
        title: Text(greek ? "Ακύρωση Λάθους" : "Undo Mistake",
            style: TextStyle(
                color: darkModeNotifier.value ? Colors.white : Colors.black)),
        content: Text(
            isSubbedOut
                ? (greek
                    ? "Να επιστρέψει ο ${player.surname} στο γήπεδο;\n\n(Θα ακυρωθεί η είσοδος: $pairedPlayerName)"
                    : "Return ${player.surname} to the pitch?\n\n(Will cancel entry for $pairedPlayerName)")
                : (greek
                    ? "Να ακυρωθεί η είσοδος του ${player.surname};\n\n(Θα επιστρέψει στο γήπεδο: $pairedPlayerName)"
                    : "Cancel entry for ${player.surname}?\n\n(Will return $pairedPlayerName to the pitch)"),
            style: TextStyle(
                color:
                    darkModeNotifier.value ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(greek ? "Άκυρο" : "Cancel")),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                Navigator.pop(context);
                _performUndoSub(player, isSubbedOut, isSubbedIn);
              },
              child: Text(greek ? "Επιστροφή" : "Return",
                  style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Future<void> _performUndoSub(
      Player player, bool wasSubbedOut, bool wasSubbedIn) async {
    String pKey = player.uniqueKey;
    try {
      await widget.match.cancelSubstitution(pKey, showHomeTeam);
      setState(() {
        if (showHomeTeam)
          homeStarters = widget.match.homeStarters.toSet();
        else
          awayStarters = widget.match.awayStarters.toSet();
      });
      _showErrorSnackbar(greek ? "Η αλλαγή ακυρώθηκε!" : "Undo Complete!");
    } catch (e) {
      _showErrorSnackbar("Error: $e");
    }
  }

  void _showEditNumberDialog(
      BuildContext context, Player player, MatchDetails match) {
    TextEditingController numController =
        TextEditingController(text: match.getDisplayNumber(player).toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            darkModeNotifier.value ? Colors.grey[900] : Colors.white,
        title: Text(
            greek ? "Νούμερο: ${player.surname}" : "Number: ${player.surname}",
            style: TextStyle(
                color: darkModeNotifier.value ? Colors.white : Colors.black,
                fontSize: 16)),
        content: TextField(
          controller: numController,
          keyboardType: TextInputType.number,
          style: TextStyle(
              color: darkModeNotifier.value ? Colors.white : Colors.black),
          decoration: InputDecoration(
              labelText: greek ? "Νέος Αριθμός Φανέλας" : "New Jersey Number",
              labelStyle: const TextStyle(color: Colors.grey),
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue))),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(greek ? "ΑΚΥΡΟ" : "CANCEL",
                  style: const TextStyle(color: Colors.grey))),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                if (numController.text.isNotEmpty) {
                  int? newNumber = int.tryParse(numController.text);
                  if (newNumber != null) {
                    match.updateTemporaryNumber(player.name, newNumber);
                    setState(() {});
                  }
                }
                Navigator.pop(context);
              },
              child: Text(greek ? "ΑΠΟΘΗΚΕΥΣΗ" : "SAVE",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildHealthCardStatus(DateTime? issueDate) {
    if (issueDate == null) {
      return const Icon(Icons.error, color: Colors.red, size: 22);
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiration =
        DateTime(issueDate.year + 1, issueDate.month, issueDate.day);
    final daysLeft = expiration.difference(today).inDays;
    if (daysLeft < 0) {
      return const Icon(Icons.cancel, color: Colors.red, size: 22);
    } else if (daysLeft <= 30) {
      return const Icon(Icons.warning_amber_rounded,
          color: Colors.orange, size: 22);
    } else {
      return const Icon(Icons.health_and_safety, color: Colors.green, size: 22);
    }
  }
}
