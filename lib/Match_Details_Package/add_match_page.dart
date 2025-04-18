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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Παρακαλώ εισάγετε ημέρα';
                        }
                        try {
                          int dayValue = int.parse(value);
                          if (dayValue < 1 || dayValue > 31) {
                            return 'Η ημέρα πρέπει να είναι μεταξύ 1 και 31';
                          }
                        } catch (e) {
                          return 'Παρακαλώ εισάγετε έγκυρο αριθμό';
                        }
                        return null;
                      },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Παρακαλώ εισάγετε μήνα';
                        }
                        try {
                          int monthValue = int.parse(value);
                          if (monthValue < 1 || monthValue > 12) {
                            return 'Ο μήνας πρέπει να είναι μεταξύ 1 και 12';
                          }
                        } catch (e) {
                          return 'Παρακαλώ εισάγετε έγκυρο αριθμό';
                        }
                        return null;
                      },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Παρακαλώ εισάγετε έτος';
                        }
                        try {
                          int.parse(value);
                        } catch (e) {
                          return 'Παρακαλώ εισάγετε έγκυρο αριθμό';
                        }
                        return null;
                      },
                      onSaved: (value) => year = int.parse(value!),
                      style: TextStyle(color:  darkModeNotifier.value
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Παρακαλώ εισάγετε αριθμό αγωνιστικής';
                  }
                  try {
                    int.parse(value);
                  } catch (e) {
                    return 'Παρακαλώ εισάγετε έγκυρο αριθμό';
                  }
                  return null;
                },
                onSaved: (value) => game = int.parse(value!),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState?.save();

                    // Validate date combination
                    bool isValidDate = true;
                    String errorMessage = '';

                    // Check for valid days in each month
                    if (month == 2) { // February
                      bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
                      if (isLeapYear && day > 29) {
                        isValidDate = false;
                        errorMessage = 'Ο Φεβρουάριος έχει 29 ημέρες σε δίσεκτο έτος';
                      } else if (!isLeapYear && day > 28) {
                        isValidDate = false;
                        errorMessage = 'Ο Φεβρουάριος έχει 28 ημέρες';
                      }
                    } else if ([4, 6, 9, 11].contains(month) && day > 30) { // April, June, September, November
                      isValidDate = false;
                      errorMessage = 'Αυτός ο μήνας έχει 30 ημέρες';
                    }

                    if (!isValidDate) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errorMessage)));
                      return;
                    }

                    // Check for empty fields
                    if (homeTeam == null || awayTeam == null || matchTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content:
                          Text("Παρακαλώ συμπληρώστε όλα τα πεδία"),
                            backgroundColor: Colors.red,
                          )
                      );
                      return;
                    }


                    DateTime currentDate = DateTime.now();
                    DateTime matchDate = DateTime(year, month, day,);
                    if(matchDate.isBefore(currentDate))
                      {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content:
                            Text("Δεν γίνεται να βάλεις παρελθοντική ημερομηνία!"),
                              backgroundColor: Colors.red,
                            )
                        );
                        return;
                      }


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
                    }
                    else
                    {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "Πρέπει να είσαι διαχειριστής τουλάχιστον της μίας ομάδας")));
                    }
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