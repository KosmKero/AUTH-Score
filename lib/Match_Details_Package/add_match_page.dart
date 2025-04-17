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
      backgroundColor: darkModeNotifier.value? Color(0xFF1E1E1E):Colors.white,
      appBar: AppBar(
        title: Text(
            "Προσθήκη Ματς",
            style: TextStyle(
                color: darkModeNotifier.value?Colors.white:Colors.black,
                fontSize: 22,
                fontFamily: "Arial"
            )
        ),
        backgroundColor: darkModeNotifier.value? Color(0xFF1E1E1E):Colors.white,
        iconTheme: IconThemeData(color: darkModeNotifier.value?Colors.white:Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Team>(
                dropdownColor: darkModeNotifier.value?Colors.grey[900]:Colors.white,
                style: TextStyle(
                  color: darkModeNotifier.value?Colors.white:Colors.grey[900],
                  fontFamily: "Arial"
                ),
                decoration: InputDecoration(
                    labelText: 'Γηπεδούχος Ομάδα',
                    labelStyle: TextStyle(
                        color: darkModeNotifier.value?Colors.white:Colors.grey[800]
                    )
                ),
                value: homeTeam,
                items: teams.map((team) {
                  return DropdownMenuItem<Team>(
                    value: team,
                    child: Text(team.name),
                  );
                }).toList(),
                onChanged: (Team? value) {
                  setState(() {
                    homeTeam = value!;
                  });
                },
              ),

              SizedBox(height: 12),

              DropdownButtonFormField<Team>(
                dropdownColor: darkModeNotifier.value?Colors.grey[900]:Colors.white,
                style: TextStyle(
                  color:darkModeNotifier.value?Colors.white:Colors.grey[900]
                ),
                decoration: InputDecoration(
                    labelText: 'Φιλοξενούμενη Ομάδα',
                    labelStyle: TextStyle(
                        color: darkModeNotifier.value?Colors.white:Colors.grey[800]
                    )
                ),
                value: awayTeam,
                items: teams.map((team) {
                  return DropdownMenuItem<Team>(
                    value: team,
                    child: Text(team.name),
                  );
                }).toList(),
                onChanged: (Team? value) {
                  setState(() {
                    awayTeam = value!;
                  });
                },
              ),
              SizedBox(height: 20,),
              ListTile(
                title: Text('Ώρα: ${matchTime != null ? matchTime!.format(context) : 'Επιλέξτε Ώρα'}',
                  style: TextStyle(
                      color: darkModeNotifier.value?Colors.white:Colors.grey[900]
                  ),
                ),
                trailing: Icon(
                  Icons.access_time,
                  color: darkModeNotifier.value?Colors.white:Colors.grey[900],
                ),
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
                      decoration: InputDecoration(
                          labelText: 'Ημέρα',
                          labelStyle: TextStyle(
                              color: darkModeNotifier.value?Colors.white:Colors.grey[900]
                          )
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => day = int.parse(value!),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Μήνας',
                          labelStyle: TextStyle(
                              color:darkModeNotifier.value?Colors.white:Colors.grey[900]
                          )
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => month = int.parse(value!),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Έτος',
                          labelStyle: TextStyle(
                              color:darkModeNotifier.value?Colors.white:Colors.grey[900]
                          )
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => year = int.parse(value!),
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                title: Text(
                    "Φάση Ομίλων;",
                  style: TextStyle(
                    color:darkModeNotifier.value?Colors.white:Colors.grey[900]
                  ),
                ),
                value: isGroupPhase,
                onChanged: (value) {
                  setState(() {
                    isGroupPhase = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Αριθμός Αγωνιστικής',
                  labelStyle: TextStyle(
                    color:darkModeNotifier.value?Colors.white:Colors.grey[900]
                  )
                ),
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
                  }
                  else{
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Πρέπει να είσαι διαχειριστής τουλάχιστον της μίας ομάδας")));
                  }




                },
                child: Text(
                    'Προσθήκη Ματς',
                    style: TextStyle(
                      fontFamily: "Arial",
                      fontSize: 17,

                    ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
