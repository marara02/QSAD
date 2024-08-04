import 'dart:math';

class EulerSensorsData{
  double roll = 0.0;
  double pitch = 0.0;
  double yaw = 0.0;
  double alpha = 0.98;

  void computeOrientationAngle(List<double> acceleration, List<double> gyroscope, double dt){
    double accRoll = atan2(acceleration[1], acceleration[2]);
    double accPitch = atan2(-acceleration[0], sqrt(acceleration[1] * acceleration[1] + acceleration[2] * acceleration[2]));

    roll = alpha * (roll + gyroscope[0] * dt) + (1 - alpha) * accRoll;
    pitch = alpha * (pitch + gyroscope[1] * dt) + (1 - alpha) * accPitch;
    yaw += gyroscope[2] * dt;
  }

  List<List<double>> getRotationMatrix(){
    List<List<double>> rX = [
      [1, 0, 0],
      [0, cos(roll), -sin(roll)],
      [0, sin(roll), cos(roll)]
    ];

    List<List<double>> rY = [
      [cos(pitch), 0, sin(pitch)],
      [0, 1, 0],
      [-sin(pitch), 0, cos(pitch)]
    ];

    List<List<double>> rZ = [
      [cos(yaw), -sin(yaw), 0],
      [sin(yaw), cos(yaw), 0],
      [0, 0, 1]
    ];

    return matrixMultiply(matrixMultiply(rZ, rY), rX);
  }

  List<List<double>> matrixMultiply(List<List<double>> A, List<List<double>> B){
    int n = A.length;
    int m = A[0].length;
    int p = B[0].length;

    List<List<double>> C = List.generate(n, (_) => List.generate(p, (_) => 0.0));
    for(int i = 0; i < n; i++){
      for(int j = 0; j < p; j++){
        for(int k = 0; k < m; k++){
          C[i][j] += A[i][k] * B[k][j];
        }
      }
    }
    return C;
  }

  List<double> reorientatedData(List<double> data, List<List<double>> rotationMatrix){
    List<double> result = [0, 0, 0];

    for(int i = 0; i < 3; i++){
      result[i] = data[0] * rotationMatrix[i][0] + data[1] * rotationMatrix[i][1] + data[2] * rotationMatrix[i][2];
    }

    return result;
  }
}