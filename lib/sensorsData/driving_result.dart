class DrivingResult {
  final String username;
  final DateTime date;
  final int aggressiveRate;
  final int normalRate;
  final double drowsyRate;
  final int safetyScore;

  DrivingResult(this.username, this.date, this.aggressiveRate, this.normalRate, this.drowsyRate, this.safetyScore);

  String get getUsername => username;
  DateTime get getDate => date;
  int get getAggressiveRate => aggressiveRate;
  int get getNormalRate => normalRate;
  double get getDrowsyRate => drowsyRate;
  int get getSafetyScore => safetyScore;

}