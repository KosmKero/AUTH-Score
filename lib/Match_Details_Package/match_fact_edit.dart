import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import '../Data_Classes/MatchDetails.dart';
import '../Data_Classes/Player.dart';
import '../Data_Classes/match_facts.dart';
import '../globals.dart';

class EditMatchFactModal extends StatefulWidget {
  final Goal fact;
  final MatchDetails match;

  const EditMatchFactModal({
    required this.fact,
    super.key,
    required this.match
  });

  @override
  State<EditMatchFactModal> createState() => _EditMatchFactModalState();
}

class _EditMatchFactModalState extends State<EditMatchFactModal> {
  late TextEditingController minuteController;
  late bool isOwnGoal;
  String? goalScorer;
  String? errorMessage;
  late int half;

  @override
  void initState() {
    super.initState();
    minuteController = TextEditingController(text: widget.fact.timeString);
    half = widget.fact.half;

    isOwnGoal = widget.fact.name.contains("(ΑΥΤ.)");

    if (isOwnGoal) {
      goalScorer = widget.fact.name.replaceAll(" (ΑΥΤ.)", "");
    } else {
      goalScorer = widget.fact.name;
    }
  }

  @override
  void dispose() {
    minuteController.dispose();
    super.dispose();
  }

  bool isMinuteValidForHalf(int minute, int half) {
    switch (half) {
      case 0:
        return minute >= 1 && minute <= 60; // Περιθώριο για μεγάλες καθυστερήσεις
      case 1:
        return minute >= 46 && minute <= 110;
      case 2:
        return minute >= 91 && minute <= 120;
      case 3:
        return minute >= 106 && minute <= 150;
      default:
        return false;
    }
  }

  void save() async {
    int? parsedMinute = int.tryParse(minuteController.text);

    if (parsedMinute == null) {
      setState(() => errorMessage = "Παρακαλώ εισάγετε έγκυρο λεπτό.");
      return;
    }

    if (goalScorer == null) {
      setState(() => errorMessage = "Παρακαλώ επιλέξτε σκόρερ.");
      return;
    }

    if (!isMinuteValidForHalf(parsedMinute, half)) {
      setState(() => errorMessage = 'Το λεπτό $parsedMinute δεν αντιστοιχεί στο ${half == 0 ? '1ο ημίχρονο.' : half == 1 ? '2ο ημίχρονο.' : half == 2 ? '1ο ημίχρονο παράτασης.' : '2ο ημίχρονο παράτασης.'}');
      return;
    }

    int rawSeconds = (parsedMinute - 1) * 60;

    // 👇 Η ΔΙΟΡΘΩΣΗ ΕΙΝΑΙ ΕΔΩ 👇
    String finalName;
    if (goalScorer == "Άλλος" || goalScorer == "Γκολ") {
      finalName = "Άλλος";
    } else if (goalScorer!.contains(" - ")) {
      // Αν ο χρήστης άλλαξε το dropdown (οπότε η μορφή είναι "10 - Γ. Παπαδόπουλος")
      finalName = goalScorer!.split(" - ")[1];
    } else {
      // Αν ο χρήστης δεν το άλλαξε, το goalScorer είναι ήδη το καθαρό όνομα!
      finalName = goalScorer!;
    }

    if (isOwnGoal && finalName != "Άλλος") {
      finalName = "$finalName (ΑΥΤ.)";
    }

    Goal newGoal = Goal(
      scorerName: finalName,
      homeScore: widget.fact.homeScore,
      awayScore: widget.fact.awayScore,
      minute: rawSeconds,
      isHomeTeam: widget.fact.isHomeTeam,
      team: widget.fact.team,
      half: half,
    );

    Navigator.pop(context);
    widget.match.editGoal(widget.fact, newGoal);

  }

  @override
  Widget build(BuildContext context) {
    // --- ΠΑΛΕΤΑ ΧΡΩΜΑΤΩΝ ΓΙΑ ΤΕΛΕΙΟ DARK MODE ---
    bool isDark = darkModeNotifier.value;
    Color bgColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    Color fieldColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey[100]!;
    Color textColor = isDark ? Colors.white : Colors.black87;
    Color labelColor = isDark ? Colors.blue[200]! : Colors.blue[800]!;

    final team = widget.fact.isHomeTeam ? widget.match.homeTeam : widget.match.awayTeam;
    final opposingTeam = widget.fact.isHomeTeam ? widget.match.awayTeam : widget.match.homeTeam;
    final currentTeamList = isOwnGoal ? opposingTeam : team;

    final currentStartersKeys = (currentTeamList.name == widget.match.homeTeam.name)
        ? widget.match.homeStarters
        : widget.match.awayStarters;

    List<Player> sortedPlayers = List.from(currentTeamList.players);
    sortedPlayers.sort((a, b) {
      bool isAActive = currentStartersKeys.contains("${a.name}${a.number}");
      bool isBActive = currentStartersKeys.contains("${b.name}${b.number}");
      if (isAActive && !isBActive) return -1;
      if (!isAActive && isBActive) return 1;
      return widget.match.getDisplayNumber(a).compareTo(widget.match.getDisplayNumber(b));
    });

    Map<String, bool> playerActiveStatus = {};
    List<String> dropdownItems = sortedPlayers.map((player) {
      String key = "${player.name}${player.number}";
      bool isActive = currentStartersKeys.contains(key);
      String itemString = "${widget.match.getDisplayNumber(player)} - ${player.name.substring(0, 1)}. ${player.surname}";
      playerActiveStatus[itemString] = isActive;
      return itemString;
    }).toList();

    dropdownItems.add("Άλλος");
    playerActiveStatus["Άλλος"] = false;

    String? initialSelectedItem;
    if (goalScorer == "Άλλος" || goalScorer == "Γκολ") {
      initialSelectedItem = "Άλλος";
    } else {
      try {
        initialSelectedItem = dropdownItems.firstWhere((item) => item.contains(goalScorer!));
      } catch (e) {
        initialSelectedItem = "Άλλος";
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 10,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🌟 ΝΕΟ: Drag Handle (η μικρή γκρι μπάρα στην κορυφή)
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            Text(
              isOwnGoal ? "Επεξεργασία Αυτογκόλ" : "Επεξεργασία Γκολ",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor
              ),
            ),
            const SizedBox(height: 15),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Είναι Αυτογκόλ;", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.w500)),
              value: isOwnGoal,
              activeColor: Colors.redAccent,
              onChanged: (bool value) {
                setState(() {
                  isOwnGoal = value;
                  goalScorer = null;
                });
              },
            ),
            const SizedBox(height: 10),

            DropdownSearch<String>(
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: "Αναζήτηση...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
                menuProps: MenuProps(
                  backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                itemBuilder: (context, item, isSelected) {
                  bool isOther = item == "Άλλος";
                  bool isActive = playerActiveStatus[item] ?? false;
                  String number = isOther ? "" : item.split(" - ")[0];
                  String name = isOther ? "Άλλος" : item.split(" - ")[1];

                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: isOther ? Colors.grey : (isOwnGoal ? Colors.red[600] : (isActive ? Colors.blue[700] : Colors.blue[200])),
                      child: isOther
                          ? const Icon(Icons.person, size: 14, color: Colors.white)
                          : Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                    title: Text(name, style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
                  );
                },
              ),
              items: dropdownItems,
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: isOwnGoal ? "Παίκτης που έβαλε το αυτογκόλ:" : "Σκόρερ:",
                  labelStyle: TextStyle(color: labelColor),
                  filled: true,
                  fillColor: fieldColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                baseStyle: TextStyle(color: textColor),
              ),
              selectedItem: initialSelectedItem,
              onChanged: (val) => setState(() {
                goalScorer = val;
                if (errorMessage != null) errorMessage = null;
              }),
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                // ΠΕΔΙΟ ΛΕΠΤΟΥ
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: minuteController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                    onChanged: (val) {
                      if (errorMessage != null) setState(() => errorMessage = null);
                    },
                    decoration: InputDecoration(
                      labelText: "Λεπτό",
                      labelStyle: TextStyle(color: labelColor),
                      filled: true,
                      fillColor: fieldColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: Icon(Icons.timer_outlined, color: isDark ? Colors.grey[400] : Colors.grey[700]),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // ΠΕΔΙΟ ΗΜΙΧΡΟΝΟΥ
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<int>(
                    value: half,
                    dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      labelText: "Ημίχρονο",
                      labelStyle: TextStyle(color: labelColor),
                      filled: true,
                      fillColor: fieldColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: [
                      const DropdownMenuItem(value: 0, child: Text('1ο Ημίχρονο')),
                      const DropdownMenuItem(value: 1, child: Text('2ο Ημίχρονο')),
                      if (widget.match.hasExtraTimeStarted)
                        const DropdownMenuItem(value: 2, child: Text('1ο Ημ. Παράτασης')),
                      if (widget.match.hasSecondHalfExtraTimeStarted)
                        const DropdownMenuItem(value: 3, child: Text('2ο Ημ. Παράτασης')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        half = value ?? 1;
                        if (errorMessage != null) errorMessage = null;
                      });
                    },
                  ),
                ),
              ],
            ),

            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        title: Text('Επιβεβαίωση', style: TextStyle(color: textColor)),
                        content: Text('Είσαι σίγουρος ότι θέλεις να διαγράψεις αυτό το Γκολ;', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Ακύρωση', style: TextStyle(color: Colors.grey)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              Navigator.of(context).pop();
                              widget.match.cancelGoal(widget.fact);
                            },
                            child: const Text('Διαγραφή', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text("Διαγραφή", style: TextStyle(color: Colors.red[600], fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)
                  ),
                  onPressed: save,
                  child: const Text("Αποθήκευση", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}