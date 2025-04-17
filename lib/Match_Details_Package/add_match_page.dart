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
  int game = 0;

  TimeOfDay? matchTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          darkModeNotifier.value ? Color(0xFF1E1E1E) : Colors.white,
      appBar: AppBar(
        title: Text("Προσθήκη Ματς",
            style: TextStyle(
                color: darkModeNotifier.value ? Colors.white : Colors.black,
                fontSize: 22,
                fontFamily: "Arial")),
        backgroundColor:
            darkModeNotifier.value ? Color(0xFF1E1E1E) : Colors.white,
        iconTheme: IconThemeData(
            color: darkModeNotifier.value ? Colors.white : Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownSearch<Team>(
                popupProps: PopupProps.menu(
                  showSearchBox: true,  // Enable search box for filtering teams
                  menuProps: MenuProps(
                    backgroundColor: darkModeNotifier.value ? Colors.grey[900] : Colors.white,
                  ),
                  searchFieldProps: TextFieldProps(
                    style: TextStyle(
                      color: darkModeNotifier.value ? Colors.white : Colors.black,  // Ρύθμιση του χρώματος του κειμένου του search box
                    ),
                  ),
                  itemBuilder: (context, Team item, isSelected) {
                    return ListTile(
                      title: Text(
                        item.name,
                        style: TextStyle(
                          color: darkModeNotifier.value ? Colors.white : Colors.grey[900],  // Set text color based on dark mode
                        ),
                      ),
                    );
                  },
                ),
                itemAsString: (Team team) => team.name,  // Display the team name in the dropdown list
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Γηπεδούχος Ομάδα',
                    labelStyle: TextStyle(
                      color: darkModeNotifier.value ? Colors.white : Colors.grey[800],  // Set label color based on dark mode
                    ),
                  ),
                ),
                selectedItem: homeTeam,
                items: teams,
                onChanged: (Team? value) {
                  setState(() {
                    homeTeam = value!;
                  });
                },
                dropdownBuilder: (context, selectedItem) {
                  return Text(
                    selectedItem != null ? selectedItem.name : 'Επιλέξτε Ομάδα',
                    style: TextStyle(
                      color: darkModeNotifier.value ? Colors.white : Colors.grey[900],  // Set text color based on dark mode
                    ),
                  );
                },
              ),
              SizedBox(height: 12),


        DropdownSearch<Team>(
        popupProps: PopupProps.menu(
          showSearchBox: true,  // Enable search box for filtering teams
          menuProps: MenuProps(
            backgroundColor: darkModeNotifier.value ? Colors.grey[900] : Colors.white,
          ),
          searchFieldProps: TextFieldProps(
            style: TextStyle(
              color: darkModeNotifier.value ? Colors.white : Colors.black,  // Ρύθμιση του χρώματος του κειμένου του search box
            ),
          ),
          itemBuilder: (context, Team item, isSelected) {
            return ListTile(
              title: Text(
                item.name,
                style: TextStyle(
                  color: darkModeNotifier.value ? Colors.white : Colors.grey[900],  // Set text color based on dark mode
                ),
              ),
            );
          },
        ),
        itemAsString: (Team team) => team.name,  // Display the team name in the dropdown list
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: 'Φιλοξενούμενη Ομάδα',
            labelStyle: TextStyle(
              color: darkModeNotifier.value ? Colors.white : Colors.grey[800],  // Set label color based on dark mode
            ),

          ),
        ),
        selectedItem: awayTeam,
        items: teams,
        onChanged: (Team? value) {
          setState(() {
            awayTeam = value!;
          });
        },
        dropdownBuilder: (context, selectedItem) {
          return Text(
            selectedItem != null ? selectedItem.name : 'Επιλέξτε Ομάδα',
            style: TextStyle(
              color: darkModeNotifier.value ? Colors.white : Colors.grey[900],  // Set text color based on dark mode
            ),
          );
        },


      ),

      SizedBox(
                height: 20,
              ),
              ListTile(
                title: Text(
                  'Ώρα: ${matchTime != null ? matchTime!.format(context) : 'Επιλέξτε Ώρα'}',
                  style: TextStyle(
                      color: darkModeNotifier.value
                          ? Colors.white
                          : Colors.grey[900]),
                ),
                trailing: Icon(
                  Icons.access_time,
                  color:
                      darkModeNotifier.value ? Colors.white : Colors.grey[900],
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
                              color: darkModeNotifier.value
                                  ? Colors.white
                                  : Colors.grey[900])),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => day = int.parse(value!),
                      style: TextStyle(color:  darkModeNotifier.value
                      ? Colors.white
                          : Colors.grey[900]),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Μήνας',
                          labelStyle: TextStyle(
                              color: darkModeNotifier.value
                                  ? Colors.white
                                  : Colors.grey[900])),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => month = int.parse(value!),
                      style: TextStyle(color:  darkModeNotifier.value
                          ? Colors.white
                          : Colors.grey[900]),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Έτος',
                          labelStyle: TextStyle(
                              color: darkModeNotifier.value
                                  ? Colors.white
                                  : Colors.grey[900])),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => year = int.parse(value!),style: TextStyle(color:  darkModeNotifier.value
                        ? Colors.white
                        : Colors.grey[900]),

                    ),
                  ),
                ],
              ),
              SwitchListTile(
                title: Text(
                  "Φάση Ομίλων;",
                  style: TextStyle(
                      color: darkModeNotifier.value
                          ? Colors.white
                          : Colors.grey[900]),
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
                        color: darkModeNotifier.value
                            ? Colors.white
                            : Colors.grey[900])),
                keyboardType: TextInputType.number,
                onSaved: (value) => game = int.parse(value!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _formKey.currentState?.save();

                  if (globalUser.controlTheseTeams(
                      homeTeam!.name, awayTeam!.name)) {
                    TeamsHandle().addMatch(
                        homeTeam!,
                        awayTeam!,
                        day,
                        month,
                        year,
                        game,
                        false,
                        isGroupPhase,
                        matchTime!.hour * 100 + matchTime!.minute,
                        "upcoming",
                        0,
                        0);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Το ματς προστέθηκε!")));
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            "Πρέπει να είσαι διαχειριστής τουλάχιστον της μίας ομάδας")));
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
