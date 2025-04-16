import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../Data_Classes/Team.dart';
import '../Firebase_Handle/TeamsHandle.dart';
import '../globals.dart';

class AddMatchScreen extends StatefulWidget {
  @override
  _AddMatchScreenState createState() => _AddMatchScreenState();
}

class _AddMatchScreenState extends State<AddMatchScreen> {
  final _formKey = GlobalKey<FormState>();

  Team? homeTeam;
  Team? awayTeam;
  int time = 0;
  int day = 0;
  int month = 0;
  int year = 0;
  bool isGroupPhase = true;
  int  game = 0;

  TimeOfDay? matchTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Προσθήκη Ματς")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownSearch<Team>(
                items: teams,
                itemAsString: (Team t) => t.name,
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                ),
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Γηπεδούχος Ομάδα",
                  ),
                ),
                onChanged: (Team? value) {
                  if (value != null) {
                    setState(() {
                      homeTeam = value;
                    });
                  }
                },
              ),

              SizedBox(height: 12),
              DropdownSearch<Team>(
                items: teams,
                itemAsString: (Team t) => t.name,
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                ),
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Φιλοξενούμενη Ομάδα",
                  ),
                ),
                onChanged: (Team? value) {
                  if (value != null) {
                    setState(() {
                      awayTeam = value;
                    });
                  }
                },
              ),
              ListTile(
                title: Text('Ώρα: ${matchTime != null ? matchTime!.format(context) : 'Επιλέξτε Ώρα'}'),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: matchTime ?? TimeOfDay(hour: 20, minute: 15),
                  );
                  if (picked != null) {
                    setState(() {
                      matchTime = picked;
                    });
                  }
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Ημέρα'),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => day = int.parse(value!),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Μήνας'),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => month = int.parse(value!),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Έτος'),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => year = int.parse(value!),
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                title: Text("Φάση Ομίλων;"),
                value: isGroupPhase,
                onChanged: (value) {
                  setState(() {
                    isGroupPhase = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Αριθμός Αγωνιστικής'),
                keyboardType: TextInputType.number,
                onSaved: (value) => game = int.parse(value!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _formKey.currentState?.save();

                  if (globalUser.controlTheseTeams(homeTeam!.name, awayTeam!.name)) {
                    TeamsHandle().addMatch(homeTeam!, awayTeam!, day, month, year, game, false, isGroupPhase,  matchTime!.hour*100+matchTime!.minute, "upcoming", 0, 0);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Το ματς προστέθηκε!")));
                    Navigator.pop(context);
                    navigatorKey.currentState?.pushReplacementNamed('/home');
                  }
                  else{
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Πρέπει να είσαι διαχειριστής τουλάχιστον της μίας ομάδας")));
                  }




                },
                child: Text('Προσθήκη Ματς'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
