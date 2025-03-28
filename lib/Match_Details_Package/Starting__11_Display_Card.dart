import 'package:flutter/material.dart';
import 'package:untitled1/API/user_handle.dart';
import '../../Data_Classes/Match.dart';
import '../Data_Classes/Player.dart';

//ΑΥΤΟ ΤΟ ΚΟΜΜΑΤΙ ΑΦΟΡΑ ΤΙΣ ΣΥΝΘΕΣΕΙΣ ΠΟΥ ΘΑ ΕΜΦΑΝΙΖΟΝΤΑΙ ΓΙΑ ΤΗΝ ΚΑΘΕ ΟΜΆΔΑ

import 'package:flutter/material.dart';
import '../../Data_Classes/Match.dart';
import '../Data_Classes/Player.dart';

class Starting11Display extends StatefulWidget {
  final Match match;

  Starting11Display({super.key, required this.match});

  @override
  _Starting11DisplayState createState() => _Starting11DisplayState();
}

class _Starting11DisplayState extends State<Starting11Display> {
  // Διαθέσιμα Συστήματα Παιχνιδιού
  final Map<String, List<int>> formations = {
    "4-3-3": [1, 4, 3, 3],
    "4-4-2": [1, 4, 4, 2],
    "3-5-2": [1, 3, 5, 2],
    "5-3-2": [1, 5, 3, 2]
  };

  String selectedFormation = "4-3-3"; // Προεπιλεγμένο σύστημα

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dropdown για την επιλογή συστήματος
        DropdownButton<String>(
          value: selectedFormation,
          items: formations.keys.map((String formation) {
            return DropdownMenuItem<String>(
              value: formation,
              child: Text(formation),
            );
          }).toList(),
          onChanged: (String? newFormation) {
            if (newFormation != null) {
              setState(() {
                selectedFormation = newFormation;
                updateFormation(newFormation); // Ενημέρωση του γηπέδου
              });
            }
          },
        ),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              color: Colors.grey,
              height: 735, // Προσαρμόσιμο ύψος ανάλογα με το γήπεδο
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset("fotos/γηπεδο.png", fit: BoxFit.cover),
                  ),
                  buildFormation(), // Δημιουργεί τη διάταξη των παικτών
                ],
              ),
            ),
          ),

      ],
    );
  }

  // Ενημέρωση της λίστας των παικτών σύμφωνα με το νέο σύστημα
  void updateFormation(String formation) {
    List<int> positions = formations[formation]!;
    List<Player?> newPlayers = List.generate(11, (index) => null);

    int count = 0;
    for (int i = 0; i < positions.length; i++) {
      for (int j = 0; j < positions[i]; j++) {
        if (count < widget.match.players11[0].length) {
          newPlayers[count] = widget.match.players11[0][count];
          count++;
        }
      }
    }
    setState(() {
      widget.match.players11[0] = newPlayers;
    });
  }

  // Κατασκευή των σειρών των παικτών στο γήπεδο
  Widget buildFormation() {
    List<int> formation = formations[selectedFormation]!;
    List<Widget> rows = [];
    int index = 0;

    for (int numPlayers in formation) {
      rows.add(
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(numPlayers, (i) {
                return PlayerWidget(
                  players: widget.match.playersSelected[0],
                  playersList: widget.match.players11[0],
                  ind: index,
                );
              }),
            ),
            SizedBox(height: 40,)
          ],
        ),
      );
      index += numPlayers;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: rows,
    );
  }
}


class PlayerWidget extends StatefulWidget {
  Map<Player?, bool> players;
  List<Player?> playersList;
  int ind;
  PlayerWidget({super.key, required this.players,required this.playersList,required this.ind});

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {

  void tapped() {
    // Εμφάνιση διαλόγου ή bottom sheet με διαθέσιμους παίκτες
    showAvailablePlayers();
  }

  void showAvailablePlayers() {
    // Φιλτράρουμε τους διαθέσιμους παίκτες
    List<Player?> availablePlayers = widget.players.entries
        .where((entry) => !entry.value) // Ελέγχουμε την boolean τιμή
        .map((entry) => entry.key) // Παίρνουμε μόνο τα ονόματα
        .toList();

    if (availablePlayers.isEmpty) {
      // Αν δεν υπάρχουν διαθέσιμοι παίκτες
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Διαθέσιμοι Παίκτες"),
          content: Text("Δεν υπάρχουν διαθέσιμοι παίκτες."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Κλείσιμο"),
            ),
          ],
        ),
      );
      return;
    }

    // Εμφάνιση bottom sheet με διαθέσιμους παίκτες
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 400, // Ύψος του bottom sheet
          child: ListView.builder(
            itemCount: availablePlayers.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                    "${availablePlayers[index]?.name} ${availablePlayers[index]?.surname}"),
                onTap: () {
                  // Εδώ μπορείς να προσθέσεις τη λογική επιλογής παίκτη
                  setPlayer(availablePlayers[index]!);
                  widget.players[availablePlayers[index]] = true;
                  Navigator.of(context).pop(); // Κλείνει το bottom sheet
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Έλεγχος αν το index είναι εντός ορίων
    if (widget.ind < 0 || widget.ind >= widget.playersList.length) {
      return SizedBox.shrink(); // Επιστρέφει κενό widget αν το index είναι εκτός ορίων
    }

    Player? currentPlayer = widget.playersList[widget.ind]; // Παίκτης για το τρέχον index

    return InkWell(
      onTap: () {
        if (UserHandle().getLoggedUser()?.isAdmin ?? false) {
          if (currentPlayer == null) {
            tapped(); // Εμφάνιση διαθέσιμων παικτών αν δεν υπάρχει επιλεγμένος
          } else {
            // Αφαιρούμε τον παίκτη από τους επιλεγμένους
            setPlayer(null);
            widget.players[currentPlayer] = false;
            tapped(); // Καλούμε τη μέθοδο tapped
          }
        }
      },
      child: Column(
        children: [
          Container(
            width:  70, // Ορίζει το πλάτος του κύκλου
            height: 40, // Ορίζει το ύψος του κύκλου
            decoration: BoxDecoration(
              color: Colors.white70, // Χρώμα του κύκλου
              shape: BoxShape.circle, // Ορίζει το σχήμα ως κύκλο
            ),
            child: Icon(Icons.person, size: 40, color: (currentPlayer != null)? Colors.black87 : Colors.blue),
          ),
          if (currentPlayer != null) // Εμφανίζει τον παίκτη μόνο αν υπάρχει
            Text(
              "${currentPlayer.number} ${currentPlayer.name.substring(0, 1)}. ${currentPlayer.surname}",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 9,
              ),
            ),
        ],
      ),
    );
  }


  void setPlayer(Player? player) {

    for (Player? player in widget.playersList){
      print("${player?.surname} ${player?.name}");
    }
    setState(() {
      widget.playersList[widget.ind] = player;
    });
  }
}
