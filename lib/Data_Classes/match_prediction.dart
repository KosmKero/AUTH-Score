class MatchPrediction {
  final double prob1;
  final double probX;
  final double prob2;
  final String exactScore;
  final double exactProb;

  MatchPrediction({
    required this.prob1,
    required this.probX,
    required this.prob2,
    required this.exactScore,
    required this.exactProb,
  });

  factory MatchPrediction.empty() {
    return MatchPrediction(
      prob1: 33.3,
      probX: 33.4,
      prob2: 33.3,
      exactScore: 'N/A',
      exactProb: 0.0,
    );
  }
}