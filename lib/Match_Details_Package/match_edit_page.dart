import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:untitled1/Data_Classes/MatchDetails.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';

import '../Data_Classes/Team.dart';
import '../globals.dart';
import '../main.dart';

class MatchEditPage extends StatefulWidget {
  final MatchDetails match;

  const MatchEditPage({super.key, required this.match});

  @override
  State<MatchEditPage> createState() => _MatchEditPageState();
}

class _MatchEditPageState extends State<MatchEditPage> {
  late Team _selectedHomeTeam;
  late Team _selectedAwayTeam;
  late TextEditingController _gameController;
  late TimeOfDay _selectedTime;
  late DateTime _selectedDate;
  bool _isGroupPhase = false;

  @override
  void initState() {
    super.initState();

    _selectedHomeTeam = widget.match.homeTeam;
    _selectedAwayTeam = widget.match.awayTeam;
    _gameController = TextEditingController(text: widget.match.game.toString());

    int hour = widget.match.time ~/ 100;
    int minute = widget.match.time % 100;
    _selectedTime = TimeOfDay(hour: hour, minute: minute);

    _selectedDate =
        DateTime(widget.match.year, widget.match.month, widget.match.day);
    _isGroupPhase = widget.match.isGroupPhase;
  }

  Future<void> _saveMatch() async {
    int formattedTime = _selectedTime.hour * 100 + _selectedTime.minute;

    if (!widget.match.hasMatchStarted) {
      if (globalUser.controlTheseTeams(
          widget.match.homeTeam.name, widget.match.awayTeam.name)) {
        final nav = navigatorKey.currentState;

        await TeamsHandle().deleteMatch(widget.match);

        await TeamsHandle().addMatch(
            _selectedHomeTeam,
            _selectedAwayTeam,
            _selectedDate.day,
            _selectedDate.month,
            _selectedDate.year,
            int.parse(_gameController.text),
            false,
            _isGroupPhase,
            formattedTime,
            "upcoming",
            0,
            0);


        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.pushReplacementNamed('/home');
        });
      }
    }

    // Εδώ βάζεις την αποθήκευση ή αποστολή στο backend
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Επεξεργασία Αγώνα')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownSearch<Team>(
              selectedItem: _selectedHomeTeam,
              items: teams,
              itemAsString: (Team t) => t.name,
              popupProps: const PopupProps.menu(
                showSearchBox: true,
              ),
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Ομάδα Εντός",
                ),
              ),
              onChanged: (Team? value) {
                if (value != null) {
                  setState(() {
                    _selectedHomeTeam = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownSearch<Team>(
              selectedItem: _selectedAwayTeam,
              items: teams,
              itemAsString: (Team t) => t.name,
              popupProps: const PopupProps.menu(
                showSearchBox: true,
              ),
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Ομάδα Εκτός",
                ),
              ),
              onChanged: (Team? value) {
                if (value != null) {
                  setState(() {
                    _selectedAwayTeam = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                  'Ημερομηνία: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            ListTile(
              title: Text('Ώρα: ${_selectedTime.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: _pickTime,
            ),
            SwitchListTile(
              title: const Text('Φάση Ομίλων'),
              value: _isGroupPhase,
              onChanged: (value) {
                setState(() => _isGroupPhase = value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _gameController,
              decoration: const InputDecoration(labelText: 'Παιχνίδι'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveMatch,
              child: const Text('Αποθήκευση'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }
}
