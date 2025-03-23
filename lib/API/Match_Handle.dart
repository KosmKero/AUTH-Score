import '../Data_Classes/Match.dart';

class MatchHandle {
  static final MatchHandle _instance = MatchHandle._internal();
  static List<List<Match>> matchesList = [];

  // Ιδιωτικός constructor
  MatchHandle._internal();

  // Μέθοδος για επιστροφή του ίδιου instance
  factory MatchHandle() {
    return _instance;
  }

  void initializeMatces(List<List<Match>> matchList){
    matchesList=matchList;
  }
  void matchFinished(Match match){
    matchesList[0].remove(match);
    matchesList[1].add(match);
  }
  void matchNotFinished(Match match){
    matchesList[1].remove(match);
    matchesList[0].add(match);
  }

  // Μέθοδοι για πρόσβαση στα δεδομένα
  List<Match> getUpcomingMatches() => matchesList[0];
  List<Match> getPreviousMatches() => matchesList[1];
  List<Match> getAllMatches() => matchesList.expand((i) => i).toList();
}
