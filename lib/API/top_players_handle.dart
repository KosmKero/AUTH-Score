import 'package:flutter/material.dart';
import 'dart:collection';
import 'package:collection/collection.dart';

import '../Data_Classes/Player.dart';
import '../Data_Classes/Team.dart'; // Για το PriorityQueue

class TopPlayersHandle extends ChangeNotifier {
  static List<Team> _teamsList = [];
  static List<Player> _topPlayers = [];

  // **Κανονικός Κατασκευαστής**
  TopPlayersHandle();

  // Getter για τη λίστα των top παικτών (για ασφάλεια, δεν εκθέτουμε την ίδια τη λίστα)
  List<Player> get topPlayers => _topPlayers;

  // **Αρχικοποίηση της λίστας των ομάδων**
  void initializeList(List<Team> list) {
    _teamsList = list;
    sortTopPlayers();
  }

  void playerScored(String scorerName){
    for (Team team in _teamsList){
      for (Player player in team.players){
        if ("${player.name.substring(0,1)}. ${player.surname}"==scorerName){
          player.scoredGoal();
          sortTopPlayers();
          return;
        }
      }
    }
    sortTopPlayers();
  }

  void goalCancelled(String scorerName){
    for (Team team in _teamsList){
      for (Player player in team.players){
        if ("${player.name.substring(0,1)}. ${player.surname}"==scorerName){
          player.goalCancelled();
          sortTopPlayers();
          return;
        }
      }
    }
    sortTopPlayers();
  }

  // **Ταξινόμηση των κορυφαίων 15 σκόρερ με Min-Heap**
  void sortTopPlayers() {
    PriorityQueue<Player> minHeap =
    PriorityQueue((a, b) => a.goals.compareTo(b.goals));

    for (Team team in _teamsList) {
      for (Player player in team.players) {
        minHeap.add(player);
        if (minHeap.length > 15) {
          minHeap.removeFirst(); // Διατηρούμε μόνο τους 15 κορυφαίους
        }
      }
    }

    _topPlayers = minHeap.toList();
    _topPlayers.sort((a, b) => b.goals.compareTo(a.goals));

    print("Η λίστα των παικτών ενημερώθηκε!${_topPlayers.length}");

    // for (Player player in _topPlayers){
    //   print(player.surname+player.goals.toString());
    // }
    notifyListeners(); // ✅ Ενημερώνουμε τους listeners για να ανανεωθεί το UI
  }
}
