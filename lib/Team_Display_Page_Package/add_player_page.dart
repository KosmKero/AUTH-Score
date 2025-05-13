

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Data_Classes/Player.dart';
import '../Data_Classes/Team.dart';
import '../globals.dart';

class AddPlayerScreen extends StatefulWidget {
  final Team team;
  final Function(Player) onPlayerAdded;  // Callback για την προσθήκη του παίκτη

  AddPlayerScreen({required this.team, required this.onPlayerAdded});

  @override
  _AddPlayerScreenState createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _numberController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedPosition = 'Τερματοφύλακας'; // Default αρχική τιμή
  final List<String> positions = ['Τερματοφύλακας', 'Αμυντικός', 'Μέσος', 'Επιθετικός'];

  void _savePlayer() {
    final name = _nameController.text.trim();
    final surname = _surnameController.text.trim();
    final position = _selectedPosition;
    final number = int.tryParse(_numberController.text.trim());
    //final age = int.tryParse(_ageController.text.trim());

    if (name.isEmpty || surname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Συμπλήρωσε όνομα, επώνυμο')),
      );
      return;
    }

    if (number == null || number < 1 || number > 99) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ο αριθμός πρέπει να είναι μεταξύ 1 και 99')),
      );
      return;
    }

    //if (age == null || age < 5 || age > 55) {
    //  ScaffoldMessenger.of(context).showSnackBar(
    //    SnackBar(content: Text('Η ηλικία πρέπει να είναι μεταξύ 5 και 50')),
    //  );
    //  return;
    //}

    int pos = (position == 'Τερματοφύλακας') ? 0 : (position == 'Αμυντικός') ? 1 : (position == 'Μέσος') ? 2 : 3;

    final newPlayer = Player(name, surname, pos, 0, number, 20, widget.team.name, 0, 0,widget.team.nameEnglish);
    widget.onPlayerAdded(newPlayer);  // Καλούμε το callback για την προσθήκη του παίκτη
    Navigator.pop(context, newPlayer);  // Επιστροφή στην προηγούμενη οθόνη
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkModeNotifier.value?Color(0xFF121212):Colors.white,
      appBar: AppBar(
          backgroundColor: darkModeNotifier.value?Color(0xFF121212):Colors.white,
          iconTheme:IconThemeData(
            color: darkModeNotifier.value ? Colors.white : Colors.black, // Set icon color
          ),
          title: Text(
            'Προσθήκη νέου παίκτη',
            style:
            TextStyle(fontSize: 24,
                fontWeight: FontWeight.w600,
                fontFamily: 'Arial',
                color:darkModeNotifier.value? Colors.white: Colors.black
            ),
          )
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              style: TextStyle(
                  color: darkModeNotifier.value?Colors.white:Colors.black,
                  fontSize: 14.5,
                  fontFamily: "Arial"
              ),
              controller: _nameController,
              decoration: InputDecoration(
                  labelText: 'Όνομα',
                  labelStyle: TextStyle(
                      color: darkModeNotifier.value?Colors.white:Colors.black,
                      fontSize: 16,
                      fontFamily: "Arial"
                  )
              ),
            ),
            SizedBox(height: 20,),
            TextField(
              style: TextStyle(
                  color: darkModeNotifier.value?Colors.white:Colors.black,
                  fontSize: 16,
                  fontFamily: "Arial"
              ),
              controller: _surnameController,
              decoration: InputDecoration(
                  labelText: 'Επώνυμο',
                  labelStyle: TextStyle(
                      color: darkModeNotifier.value?Colors.white:Colors.black
                  )
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedPosition,
              dropdownColor: darkModeNotifier.value ? Colors.grey[850] : Colors.white,
              style: TextStyle(
                  color: darkModeNotifier.value ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontFamily: "Arial"
              ),
              decoration: InputDecoration(
                labelText: 'Θέση',
                labelStyle: TextStyle(
                    color: darkModeNotifier.value?Colors.white:Colors.black,
                    fontFamily: "Arial",
                    fontSize: 20
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: darkModeNotifier.value ? Colors.white : Colors.black,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: darkModeNotifier.value ? Colors.white : Colors.black,
                  ),
                ),
              ),
              items: positions.map((position) {
                return DropdownMenuItem<String>(
                  value: position,
                  child: Text(
                    position,
                    style: TextStyle(
                        color: darkModeNotifier.value ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontFamily: "Arial"
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPosition = value!;
                });
              },
            ),
            SizedBox(height: 20,),
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                  color: darkModeNotifier.value?Colors.white:Colors.black,
                  fontSize: 16,
                  fontFamily: "Arial"
              ),
              decoration: InputDecoration(
                  labelText: 'Αριθμός Φανέλας',
                  labelStyle: TextStyle(
                      color: darkModeNotifier.value?Colors.white:Colors.black,
                      fontSize: 16
                  )
              ),
            ),
            SizedBox(height: 20,),
            //TextField(
            //  controller: _ageController,
            //  keyboardType: TextInputType.number,
            //  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            //  style: TextStyle(
            //      color: darkModeNotifier.value?Colors.white:Colors.black,
            //      fontSize: 16,
            //      fontFamily: "Arial"
            //  ),
            //  decoration: InputDecoration(
            //      labelText: 'Ηλικία',
            //      labelStyle: TextStyle(
            //          color: darkModeNotifier.value?Colors.white:Colors.black,
            //          fontSize: 16,
            //          fontFamily: "Arial"
            //      )
            //  ),
            //),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePlayer,
              child: Text(
                'Αποθήκευση',
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Arial"
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

