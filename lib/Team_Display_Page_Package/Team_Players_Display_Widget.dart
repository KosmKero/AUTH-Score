import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Data_Classes/Player.dart';
import '../Data_Classes/Team.dart';
import '../globals.dart';

class TeamPlayersDisplayWidget extends StatefulWidget {
  const TeamPlayersDisplayWidget({super.key, required this.team});
  final Team team;

  @override
  State<TeamPlayersDisplayWidget> createState() => _TeamPlayersDisplayWidgetState();
}

class _TeamPlayersDisplayWidgetState extends State<TeamPlayersDisplayWidget> {
  List<Player> positionList(int pos) {
    return widget.team.players.where((player) => player.position == pos).toList();
  }

  void _updatePlayerList(Player newPlayer) {
    setState(() {
      widget.team.addPlayer(newPlayer);  // Προσθέτουμε τον νέο παίκτη στην ομάδα
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            (globalUser.controlTheseTeams(widget.team.name,null)) ? addPlayer() : SizedBox.shrink(),
            playersCard(0, positionList(0)),
            playersCard(1, positionList(1)),
            playersCard(2, positionList(2)),
            playersCard(3, positionList(3)),
            if((globalUser.controlTheseTeams(widget.team.name,null)))
              Padding(
                padding: EdgeInsets.only(top: 300,left: 10),
                child: Text(
                  greek? "*Για να διαγράψεις ένα παίκτη πάτα παρατεταμένα πάνω του.": "*To remove a player, long-press on their name.",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Arial',
                    color: darkModeNotifier.value ? Colors.white : Colors.black
                  ),
                ),
              ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget playersCard(int position, List<Player> players) {
    String pos;
    if (position == 0) {
      pos = "Τερματοφύλακας";
    } else if (position == 1) {
      pos = "Αμυντικός";
    } else if (position == 2) {
      pos = "Μέσος";
    } else {
      pos = "Επιθετικός";
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color:darkModeNotifier.value? Color(0xFF121212):Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                pos,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Arial',
                  color: darkModeNotifier.value?Colors.white:Colors.black
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 8),
              child: Column(
                children: players
                    .map((player) => Column(
                  children: [
                    playerName(player),
                    Divider(height: 10, thickness: 1, color: darkModeNotifier.value?Colors.white:Colors.black)
                  ],
                )).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget playerName(Player player) {
    return GestureDetector(
      onLongPress: (globalUser.controlTheseTeams(widget.team.name,null)) ?  ()  async {
        final confirm = await showDialog<bool>(
          context: context, // ή χρησιμοποίησε context αν έχεις
          builder: (context) => AlertDialog(
            title: Text('Διαγραφή Παίκτη'),
            content: Text('Είσαι σίγουρος ότι θέλεις να διαγράψεις τον ${player.name};'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Ακύρωση'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Διαγραφή', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );

        if (confirm == true) {
          widget.team.deletePlayer(player);

          setState(() {});
        }
      } : null,
      child: Column(
        children: [
          Row(children: [
            SizedBox(
                width: 31, height: 31, child: Image.asset('fotos/randomUserPic.png')),
            SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(" ${player.name} ${player.surname}",
                style: TextStyle(
                  color:darkModeNotifier.value?Colors.white:Colors.black,
                  fontFamily: "Arial",
                  fontSize: 16.5
                ),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(" ${player.number}", style: TextStyle(color: darkModeNotifier.value?Colors.white:Colors.black,
                      fontFamily: "Arial",
                      fontSize: 15
                      )
                    ),
                    Text("  ${player.age} έτη", style: TextStyle(color:darkModeNotifier.value?Colors.white:Colors.black,
                      fontFamily: "Arial",
                      fontSize: 15
                      )
                    ),
                  ],
                ),
              ],
            )
          ]),
          SizedBox(height: 3),
        ],
      ),
    );
  }


  Widget addPlayer() {
    return IconButton(
      onPressed: () async {
        final newPlayer = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddPlayerScreen(
              team: widget.team,
              onPlayerAdded: _updatePlayerList,  // Περνάμε το callback
            ),
          ),
        );

        // Αν το νέο player δεν είναι null, ανανεώνουμε την UI με το setState
        if (newPlayer != null && newPlayer is Player) {
          setState(() {});
        }
      },
      icon: Icon(
        Icons.add,
        color: darkModeNotifier.value?Colors.white:Colors.black,
      ),
    );
  }
}



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
    final age = int.tryParse(_ageController.text.trim());

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

    if (age == null || age < 5 || age > 55) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Η ηλικία πρέπει να είναι μεταξύ 5 και 50')),
      );
      return;
    }

    int pos = (position == 'Τερματοφύλακας') ? 0 : (position == 'Αμυντικός') ? 1 : (position == 'Μέσος') ? 2 : 3;

    final newPlayer = Player(name, surname, pos, 0, number, age, widget.team.name, 0, 0);
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
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                  color: darkModeNotifier.value?Colors.white:Colors.black,
                  fontSize: 16,
                  fontFamily: "Arial"
              ),
              decoration: InputDecoration(
                  labelText: 'Ηλικία',
                  labelStyle: TextStyle(
                      color: darkModeNotifier.value?Colors.white:Colors.black,
                    fontSize: 16,
                    fontFamily: "Arial"
                  )
              ),
            ),
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

