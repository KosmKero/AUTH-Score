import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import '../Data_Classes/Player.dart';
import '../Data_Classes/Team.dart';

class TopPlayersHandle extends ChangeNotifier {
  static List<Team> _teamsList = [];
  static List<Player> _topPlayers = [];

  TopPlayersHandle();

  // Getter για τη λίστα των top παικτών
  List<Player> get topPlayers => _topPlayers;

  // **Αρχικοποίηση της λίστας των ομάδων**
  void initializeList(List<Team> list) {
    _teamsList = list;
    sortTopPlayers();
  }

  Future<void> playerScored(Player player) async {

    await player.scoredGoal();
    sortTopPlayers();
  }

  Future<void> goalCancelled(Player player) async {
    await player.goalCancelled();
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
    notifyListeners(); //  Ενημερώνουμε τους listeners για να ανανεωθεί το UI
  }
}
