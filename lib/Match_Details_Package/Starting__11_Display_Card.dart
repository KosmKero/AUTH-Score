import 'package:flutter/material.dart';
import 'package:untitled1/API/user_handle.dart';
import 'package:untitled1/Firebase_Handle/user_handle_in_base.dart';
import 'package:untitled1/main.dart';
import '../../Data_Classes/MatchDetails.dart';
import '../Data_Classes/Player.dart';

//ΑΥΤΟ ΤΟ ΚΟΜΜΑΤΙ ΑΦΟΡΑ ΤΙΣ ΣΥΝΘΕΣΕΙΣ ΠΟΥ ΘΑ ΕΜΦΑΝΙΖΟΝΤΑΙ ΓΙΑ ΤΗΝ ΚΑΘΕ ΟΜΆΔΑ

import 'package:flutter/material.dart';
import '../../Data_Classes/MatchDetails.dart';
import '../Data_Classes/Player.dart';
import '../globals.dart';

class Starting11Display extends StatefulWidget {
  final MatchDetails match;

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


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dropdown για την επιλογή συστήματος
        (globalUser.controlTheseTeams(widget.match.homeTeam.name, widget.match.awayTeam.name) ?? false )?DropdownButton<String>(
          value: widget.match.selectedFormationHome,
          items: formations.keys.map((String formation) {
            return DropdownMenuItem<String>(
              value: formation,
              child: Text(formation),
            );
          }).toList(),
          onChanged: (String? newFormation) {
            if (newFormation != null) {
              setState(() {
                widget.match.selectedFormationHome = newFormation;
                updateFormation(newFormation , true); // Ενημέρωση του γηπέδου
              });
            }
          },
        ) : SizedBox.shrink(),
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
                  Column(
                   // crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildFormation(true), // Δημιουργεί τη διάταξη των παικτών
                      buildFormation(false),
                    ],
                  )
                ],
              ),
            ),
          ),
        (globalUser.controlTheseTeams(widget.match.homeTeam.name, widget.match.awayTeam.name))?DropdownButton<String>(
          value: widget.match.selectedFormationAway,
          items: formations.keys.map((String formation) {
            return DropdownMenuItem<String>(
              value: formation,
              child: Text(formation),
            );
          }).toList(),
          onChanged: (String? newFormation) {
            if (newFormation != null) {
              setState(() {
                widget.match.selectedFormationAway = newFormation;
                updateFormation(newFormation,false); // Ενημέρωση του γηπέδου
              });
            }
          },
        ) : SizedBox.shrink(),
        SizedBox(height: 10,)

      ],
    );
  }

  // Ενημέρωση της λίστας των παικτών σύμφωνα με το νέο σύστημα
  void updateFormation(String formation,bool isHomeTeam) {
    List<int> positions = formations[formation]!;
    List<Player?> newPlayers = List.generate(11, (index) => null);

    int count = 0;
    int lim =(isHomeTeam) ? widget.match.players11[0].length: widget.match.players11[1].length;

    for (int i = 0; i < positions.length; i++) {
      for (int j = 0; j < positions[i]; j++) {
        if (count < lim ) {
         // newPlayers[count] = widget.match.players11[0][count];
          newPlayers[count]=null;

          count++;
        }
      }
    }
    (isHomeTeam) ? widget.match.makeAllFalse(0) : widget.match.makeAllFalse(1);


    setState(() {
      if (isHomeTeam) {
        widget.match.players11[0] = newPlayers;
      }
      else {
        widget.match.players11[1] = newPlayers;
      }
    });
  }

  // Κατασκευή των σειρών των παικτών στο γήπεδο
  Widget buildFormation(bool isHomeTeam) {
    List<int> formation = (isHomeTeam) ? formations[widget.match.selectedFormationHome]! : formations[widget.match.selectedFormationAway]!;
    List<Widget> rows = [];


    int index = (isHomeTeam) ? 0 : 11; // Ξεκινά από 0
    for (int numPlayers in (isHomeTeam) ? formation : formation.reversed) {
      rows.add(
        Column(
          children: [
            SizedBox(height: 5,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              textDirection: (isHomeTeam) ? TextDirection.ltr : TextDirection.rtl,
              children: List.generate(numPlayers, (i) {
                // Αποθηκεύουμε την τρέχουσα τιμή πριν την αυξήσουμε
                (isHomeTeam) ? index++ : index--; // Αυξάνουμε το index κατά 1 ή τομειωνουμε
                return PlayerWidget(
                  players: (isHomeTeam) ? widget.match.playersSelected[0] : widget.match.playersSelected[1],
                  playersList: (isHomeTeam) ? widget.match.players11[0] : widget.match.players11[1],
                  ind: (isHomeTeam) ? index-1: index, // Χρησιμοποιούμε το σωστό index
                  profColor: (isHomeTeam)? Colors.black : Colors.blueGrey,
                );
              }),
            ),
            SizedBox(height: 18),
          ],
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: rows,
    );
  }
}


class PlayerWidget extends StatefulWidget {
  final Map<Player?, bool> players;
  final List<Player?> playersList;
  final  int ind;
  final Color profColor;
  const PlayerWidget({super.key, required this.players,required this.playersList,required this.ind,required this.profColor});

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
        if (globalUser.isAdmin) {
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
      child: SizedBox(
        height: 68,
        child: Column(
          children: [
            Container(
              width:  70, // Ορίζει το πλάτος του κύκλου
              height: 40, // Ορίζει το ύψος του κύκλου
              decoration: BoxDecoration(
                color: Colors.white70, // Χρώμα του κύκλου
                shape: BoxShape.circle, // Ορίζει το σχήμα ως κύκλο
              ),
              child: Icon(Icons.person, size: 40, color: (currentPlayer != null) ? widget.profColor : Colors.blue),
            ),
            if (currentPlayer != null) // Εμφανίζει τον παίκτη μόνο αν υπάρχει
              Column(
                children: [
                  (currentPlayer.surname.length<5)?Text(
                    "${currentPlayer.number} ${currentPlayer.name.substring(0, 1)}. ${currentPlayer.surname}",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ):Text(
                    "${currentPlayer.number} ${currentPlayer.name.substring(0, 1)}.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  if (currentPlayer.surname.length>=5)Text(
                    currentPlayer.surname,
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  )
                ],
              ),
          ],
        ),
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
