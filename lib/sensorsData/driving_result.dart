class DrivingResult {
  final String username;
  final DateTime date;
  final int aggressiveRate;
  final int normalRate;
  final int drowsyRate;
  final double safetyScore;

  DrivingResult(this.username, this.date, this.aggressiveRate, this.normalRate, this.drowsyRate, this.safetyScore);

  String get getUsername => username;
  DateTime get getDate => date;
  int get getAggressiveRate => aggressiveRate;
  int get getNormalRate => normalRate;
  int get getDrowsyRate => drowsyRate;
  double get getSafetyScore => safetyScore;

}