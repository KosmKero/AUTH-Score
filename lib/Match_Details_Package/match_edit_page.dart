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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_gameController.text.trim().isEmpty) {
      _showSnackBar("Συμπλήρωσε το πεδίο 'Παιχνίδι'");
      return;
    }

    if (_selectedHomeTeam == _selectedAwayTeam) {
      _showSnackBar("Οι ομάδες πρέπει να είναι διαφορετικές");
      return;
    }

    if (_selectedDate.isBefore(today)) {
      _showSnackBar("Η ημερομηνία δεν μπορεί να είναι παλαιότερη από σήμερα");
      return;
    }

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
          int.tryParse(_gameController.text) ?? 0,
          false,
          _isGroupPhase,
          formattedTime,
          "upcoming",
          0,
          0,
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.pushReplacementNamed('/home');
        });
      }
    }

    Navigator.pop(context);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkModeNotifier.value? Color(0xFF121212) : Colors.white,
      appBar: AppBar(
          title:  Text(
              'Επεξεργασία Αγώνα',
              style: TextStyle(
                color: darkModeNotifier.value? Colors.white: Colors.black,
                fontFamily: "Arial"
              ),
          ),
        iconTheme: IconThemeData(
          color: darkModeNotifier.value? Colors.white : Colors.black
        ),
        backgroundColor: darkModeNotifier.value? Color(0xFF121212) : Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownSearch<Team>(
              selectedItem: _selectedHomeTeam,
              items: teams,
              itemAsString: (Team t) => t.name,
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  style: TextStyle(
                    color: darkModeNotifier.value ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: "Αναζήτηση",
                    labelStyle: TextStyle(
                    ),
                  ),
                ),
              ),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Ομάδα Εντός",
                  labelStyle: TextStyle(
                    color: darkModeNotifier.value ? Colors.white : Colors.black,
                    fontSize: 20
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: darkModeNotifier.value ? Colors.white : Colors.black,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: darkModeNotifier.value ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                baseStyle: TextStyle(
                  color: darkModeNotifier.value ? Colors.white : Colors.black,
                  fontSize: 16,
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
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  style: TextStyle(
                    color: darkModeNotifier.value ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: "Αναζήτηση",
                    labelStyle: TextStyle(

                    ),
                  ),
                ),
              ),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Ομάδα Εκτός",
                  labelStyle: TextStyle(
                    color: darkModeNotifier.value ? Colors.white : Colors.black,
                    fontSize: 20
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: darkModeNotifier.value ? Colors.white : Colors.black,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: darkModeNotifier.value ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                baseStyle: TextStyle(
                  color: darkModeNotifier.value ? Colors.white : Colors.black,
                  fontSize: 16,
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
                  'Ημερομηνία: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                style: TextStyle(
                  color: darkModeNotifier.value? Colors.white: Colors.black,
                  fontSize: 18
                ),
              ),
              trailing:  Icon(
                  Icons.calendar_today,
                  color: darkModeNotifier.value? Colors.white: Colors.black,
              ),
              onTap: _pickDate,
            ),
            ListTile(
              title: Text('Ώρα: ${_selectedTime.format(context)}',
                style: TextStyle(
                    color: darkModeNotifier.value? Colors.white: Colors.black,
                    fontSize: 18
                ),
              ),
              trailing:  Icon(
                  Icons.access_time,
                color: darkModeNotifier.value? Colors.white: Colors.black,
              ),
              onTap: _pickTime,
            ),
            SwitchListTile(
              title:  Text('Φάση Ομίλων',
                style: TextStyle(
                    color: darkModeNotifier.value? Colors.white: Colors.black,
                    fontSize: 18
                ),
              ),
              value: _isGroupPhase,
              onChanged: (value) {
                setState(() => _isGroupPhase = value);
              },
            ),
            const SizedBox(height: 16),
            (!_isGroupPhase)?TextField(
              controller: _gameController,
              decoration:  InputDecoration(labelText: 'Παιχνίδι',
                  labelStyle: TextStyle(
                      color: darkModeNotifier.value? Colors.white: Colors.black,
                      fontSize: 20
                  )
              ),
              style: TextStyle(
                color: darkModeNotifier.value? Colors.white: Colors.black,
                fontSize: 16,
              ),
            ) : SizedBox.shrink(),
             SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveMatch,
              child:  Text('Αποθήκευση',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "Arial"

                )
              ),
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
