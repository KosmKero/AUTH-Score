import 'package:flutter/cupertino.dart';

class BasketMatch extends ChangeNotifier {


  bool matchStarted = false;
  bool matchFinished = false;

  List<PeriodScore> periods = [];

  BasketMatch() {
    // Αρχικοποίηση με 4 κανονικές περιόδους
    for (int i = 0; i < 4; i++) {
      periods.add(PeriodScore());
    }
  }

  void startPeriod({bool overtime = false}) {
    // Προσθήκη περιόδου αν είναι παράταση
    periods.add(PeriodScore(isOvertime: overtime));
    notifyListeners();
  }

  void finishPeriod(int index) {
    if (index < periods.length) {
      periods[index].finished = true;
      notifyListeners();
    }
  }

  void updateScore(int index, int team1Score, int team2Score) {
    if (index < periods.length) {
      periods[index].team1Score = team1Score;
      periods[index].team2Score = team2Score;
      notifyListeners();
    }
  }

  int get totalTeam1Score =>
      periods.fold(0, (sum, p) => sum + p.team1Score);

  int get totalTeam2Score =>
      periods.fold(0, (sum, p) => sum + p.team2Score);
}

class PeriodScore {
  int team1Score;
  int team2Score;
  bool finished;
  bool isOvertime;

  PeriodScore({
    this.team1Score = 0,
    this.team2Score = 0,
    this.finished = false,
    this.isOvertime = false,
  });
}
