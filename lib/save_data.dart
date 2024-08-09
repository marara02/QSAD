import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'sensorsData/accelerometer.dart';
import 'sensorsData/gyroscope.dart';

Future<List<Map<String, dynamic>>> writeDataToCsv(List<AccelerometerData> accelerometerData, List<GyroscopeData> gyroscopeData) async{
  // List<List<dynamic>> csvData = [
  //   ["AccX", "AccY", "AccZ", "GyroX", "GyroY", "GyroZ", "Timestamp",]
  // ];
  List<Map<String, dynamic>> jsonData = [];

  int length = accelerometerData.length > gyroscopeData.length ? accelerometerData.length : gyroscopeData.length;

  for (int i = 0; i < length; i++) {
    String time = i < accelerometerData.length ? accelerometerData[i].date.toIso8601String() : gyroscopeData[i].date.toIso8601String();
    double? accX = i < accelerometerData.length ? accelerometerData[i].value[0] : null;
    double? accY = i < accelerometerData.length ? accelerometerData[i].value[1] : null;
    double? accZ = i < accelerometerData.length ? accelerometerData[i].value[2] : null;
    double? gyrX = i < gyroscopeData.length ? gyroscopeData[i].value[0] : null;
    double? gyrY = i < gyroscopeData.length ? gyroscopeData[i].value[1] : null;
    double? gyrZ = i < gyroscopeData.length ? gyroscopeData[i].value[2] : null;

    // List<dynamic> row = [accX, accY, accZ, gyrX, gyrY, gyrZ, time];
    // csvData.add(row);

    // Save data in json format
    Map<String, dynamic> jsonItem = {
      "AccX": accX,
      "AccY": accY,
      "AccZ": accZ,
      "GyroX": gyrX,
      "GyroY": gyrY,
      "GyroZ": gyrZ,
      "Timestamp": time
    };
    jsonData.add(jsonItem);
  }

  // String csv = const ListToCsvConverter().convert(csvData);
  //
  // final directory = await getApplicationDocumentsDirectory();
  // final path = '${directory.path}/sensors_data_${DateTime.now()}.csv';
  // final file = File(path);
  //
  // await file.writeAsString(csv);
  // print('Data written to $path');
  print(jsonData[0]);
  return jsonData;
}