import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Data_Classes/MatchDetails.dart';

import '../Data_Classes/match_facts.dart';

class EditMatchFactModal extends StatefulWidget {
  final MatchFact fact;
  final MatchDetails match;
  //final void Function(MatchFact updatedFact) onSave;

  const EditMatchFactModal(
      {required this.fact, super.key, required this.match});

  @override
  State<EditMatchFactModal> createState() => _EditMatchFactModalState();
}

class _EditMatchFactModalState extends State<EditMatchFactModal> {
  late TextEditingController minuteController;
  late TextEditingController assistController;
  late bool isYellow;
  late int half;
  late String selectedScorer;

  @override
  void initState() {
    super.initState();
    selectedScorer = widget.fact.name;
    minuteController =
        TextEditingController(text: (widget.fact.minute ~/ 60 +1).toString());
    assistController = TextEditingController(
      text: widget.fact is Goal ? (widget.fact as Goal).assistName ?? '' : '',
    );
    isYellow = widget.fact is CardP ? (widget.fact as CardP).isYellow : true;
    half = widget.fact.half;
  }

  bool isMinuteValidForHalf(int minute, int half) {
    switch (half) {
      case 0:
        return minute >= 1 && minute <= 55;
      case 1:
        return minute >= 46 && minute <= 105;
      case 2:
        return minute >= 91 && minute<=115;
      case 3:
        return minute>=110;
      default:
        return false;
    }
  }

  void save() {
    final minute = int.tryParse(minuteController.text) ?? 0;

    if (!isMinuteValidForHalf(minute, half)) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Μη έγκυρο λεπτό'),
          content: Text(
              'Το λεπτό $minute δεν αντιστοιχεί στο ${half == 0 ? '1ο ημίχρονο.' : half == 1 ? '2ο ημίχρονο.' : half == 2 ? '1ο ημίχρονο παράτασης.' : '2ο ημίχρονο παράτασης.'} '),
          actions: [
            TextButton(
              child: const Text('ΟΚ'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return; // μην συνεχίσεις το save
    }
    final updatedFact = widget.fact is Goal
        ? Goal(
            scorerName: selectedScorer,
            assistName:
                assistController.text.isEmpty ? null : assistController.text,
            homeScore: (widget.fact as Goal).homeScore,
            awayScore: (widget.fact as Goal).awayScore,
            minute: minute*60-1,
            isHomeTeam: widget.fact.isHomeTeam,
            team: widget.fact.team,
            half: half,
          )
        : CardP(
            playerName: selectedScorer,
            isYellow: isYellow,
            minute: minute*60-1,
            isHomeTeam: widget.fact.isHomeTeam,
            team: widget.fact.team,
            half: half,
          );

    widget.fact is Goal ? widget.match.editGoal(widget.fact as Goal, updatedFact as Goal) : widget.match.editCard(widget.fact as CardP, updatedFact as CardP);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isGoal = widget.fact is Goal;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
          DropdownSearch<String>(
          popupProps: const PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              labelText: "Αναζήτηση παίκτη",
            ),
          ),
        ),
        items: widget.fact.team.players.map((p) => '${p.name.substring(0,1)}. ${p.surname}').toList(),
        selectedItem: selectedScorer,
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: "Σκόρερ",
          ),
        ),
        onChanged: (value) {
          setState(() {
            selectedScorer = value ?? '';
          });
        },
      ),
            if (isGoal)
              TextField(
                controller: assistController,
                decoration: InputDecoration(labelText: 'Assist (optional)'),
              ),
            TextField(
              controller: minuteController,
              decoration: const InputDecoration(labelText: 'Minute'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<int>(
              value: half,
              items: [
                DropdownMenuItem(value: 0, child: Text('1st Half')),
                DropdownMenuItem(value: 1, child: Text('2nd Half')),
                if (widget.match.hasExtraTimeStarted)
                  DropdownMenuItem(
                      value: 2, child: Text('1st Half Extra Time')),
                if (widget.match.hasSecondHalfExtraTimeStarted)
                  DropdownMenuItem(
                      value: 3, child: Text('2nd Half Extra Time')),
              ],
              onChanged: (value) => setState(() => half = value ?? 1),
            ),
            if (!isGoal)
              SwitchListTile(
                title: const Text("Yellow Card"),
                value: isYellow,
                onChanged: (value) => setState(() => isYellow = value),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Επιβεβαίωση'),
                          content: const Text(
                              'Είσαι σίγουρος ότι θέλεις να διαγράψεις αυτό το γεγονός;'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(ctx).pop(), // ακύρωση
                              child: const Text('Ακύρωση'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop(); // κλείσε το dialog
                                Navigator.of(context).pop(); // κλείσε το modal
                                (widget.fact is Goal)
                                    ? widget.match
                                        .cancelGoal(widget.fact as Goal)
                                    : widget.match.cancelCard(widget.fact
                                        as CardP); // κάλεσε την διαγραφή
                              },
                              child: const Text('Διαγραφή',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: (widget.fact is Goal)
                        ? Text('Διαγραφή Γκολ')
                        : Text('Διαγραφή κάρτας')),
                ElevatedButton(onPressed: save, child: const Text('Save')),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
