import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'accelerometer.dart';
import 'gyroscope.dart';

Future<void> writeDataToCsv(List<AccelerometerData> accelerometerData, List<GyroscopeData> gyroscopeData) async{
  List<List<dynamic>> csvData = [
    ["Timestamp", "AccX", "AccY", "AccZ", "GyroX", "GyroY", "GyroZ"]
  ];

  int length = accelerometerData.length > gyroscopeData.length ? accelerometerData.length : gyroscopeData.length;

  for (int i = 0; i < length; i++) {
    String time = i < accelerometerData.length ? accelerometerData[i].date.toIso8601String() : gyroscopeData[i].date.toIso8601String();
    double? accX = i < accelerometerData.length ? accelerometerData[i].value[0] : null;
    double? accY = i < accelerometerData.length ? accelerometerData[i].value[1] : null;
    double? accZ = i < accelerometerData.length ? accelerometerData[i].value[2] : null;
    double? gyrX = i < gyroscopeData.length ? gyroscopeData[i].value[0] : null;
    double? gyrY = i < gyroscopeData.length ? gyroscopeData[i].value[1] : null;
    double? gyrZ = i < gyroscopeData.length ? gyroscopeData[i].value[2] : null;

    List<dynamic> row = [time, accX, accY, accZ, gyrX, gyrY, gyrZ];
    csvData.add(row);
  }

  String csv = const ListToCsvConverter().convert(csvData);

  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/sensors_data_${DateTime.now()}.csv';
  final file = File(path);

  await file.writeAsString(csv);
  print('Data written to $path');
}