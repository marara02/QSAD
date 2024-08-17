import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safedriving/auth/login.dart';
import 'package:safedriving/sensorsData/driving_result.dart';
import 'package:safedriving/services/add_data.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:safedriving/save_data.dart';
import 'package:safedriving/auth/login_or_reg.dart';
import 'package:safedriving/sensorsData/accelerometer.dart';
import 'package:safedriving/drowsinessDetect/camera.dart';
import 'package:safedriving/chart.dart';
import 'package:safedriving/sensorsData/gyroscope.dart';
import 'package:safedriving/save_data.dart';
import 'package:safedriving/sensorsData/euler_sensors_data.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<double>? _accelerometerValues;
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  List<double>? _magnetometerValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  EulerSensorsData _processor = EulerSensorsData();
  final double _samplingInterval = 0.5;
  List<AccelerometerData> _accelerometerData = [];
  List<GyroscopeData> _gyroscopeData = [];
  DrivingResult? drivingResult;
  List<double>? _latestAccelValues;
  List<double>? _latestGyroValues;
  Timer? _dataTimer;
  int backAndForth = 0;

  final currentUser = FirebaseAuth.instance.currentUser!;
  CloudFirestoreService? service;

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final accelerometer = _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final gyroscope = _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final userAccelerometer = _userAccelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final magnetometer = _magnetometerValues?.map((double v) => v.toStringAsFixed(1)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Sensor Data'),
        actions: [
          IconButton(
              onPressed: signOut,
              icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(width: 1.0, color: Colors.black38),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Accelerometer: $accelerometer'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('UserAccelerometer: $userAccelerometer'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Gyroscope: $gyroscope'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Magnetometer: $magnetometer'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Date: ${DateTime.now()}'),
              ],
            ),
          ),
          ElevatedButton(
            child: const Text("Start"),
            onPressed: _startCollectingData,
          ),
          ElevatedButton(
            child: const Text("Stop"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: _stopCollectingData,
          ),
          // ElevatedButton(
          //   style: ElevatedButton.styleFrom(
          //   backgroundColor: Colors.green,
          //   ),
          //   onPressed: _openCamera,
          //   child: const Text("Camera"),
          // ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stopCollectingData();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    service = CloudFirestoreService(FirebaseFirestore.instance);


    // Listen to accelerometer events
    _streamSubscriptions.add(
      accelerometerEvents.listen((AccelerometerEvent event) {
        _latestAccelValues = [event.x, event.y, event.z];
      }),
    );

    // Listen to gyroscope events
    _streamSubscriptions.add(
      gyroscopeEvents.listen((GyroscopeEvent event) {
        _latestGyroValues = [event.x, event.y, event.z];
      }),
    );

    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
            (UserAccelerometerEvent event) {
          setState(() {
            _userAccelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );

    _streamSubscriptions.add(
      magnetometerEvents.listen(
            (MagnetometerEvent event) {
          setState(() {
            _magnetometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
  }

  void _startCollectingData() {
    if (backAndForth % 2 == 1) {
      _accelerometerData.clear();
      _gyroscopeData.clear();
    }

    // _dataTimer?.cancel(); // Cancel any existing timer

    // Set up a timer to process data every 0.5 seconds
    _dataTimer = Timer.periodic(const Duration(milliseconds: 500), (Timer timer) {
      if (_latestAccelValues != null && _latestGyroValues != null) {
        _processSensorData(_latestAccelValues!, _latestGyroValues!);
      }
    });

    backAndForth++;
  }

  void _stopCollectingData() async {
    _dataTimer?.cancel();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    // _streamSubscriptions.clear(); // Clear the list of subscriptions


    List<dynamic> dataLst = await writeDataToCsv(_accelerometerData, _gyroscopeData);
    final response = await http.post(
      Uri.parse('https://backapi-okqa.onrender.com/predict'),
      headers: <String, String>{
        'Content-Type':'application/json; charset=UTF-8',
      },
      body: jsonEncode(dataLst),
    );

    if(response.statusCode == 200){
      List<dynamic> predictionsList = jsonDecode(response.body);

      // Assuming you want the first item in the list
      if (predictionsList.isNotEmpty) {
        Map<String, dynamic> item = predictionsList[0];
        final String? email = currentUser.email;
        String currEmail;
        // Create DrivingResult using values from the first item
        if(email != null ){
          currEmail = email;
          drivingResult = DrivingResult(
              currEmail,
              DateTime.now(),
              item['AGGRESSIVE'],
              item['NORMAL'],
              0.0,
              50
          );

          service?.add({
            'username': currEmail,
            'time': DateTime.now(),
            'aggressiveRate': item['AGGRESSIVE'],
            'normalRate': item['NORMAL'],
            'drowsyRate': 0,
            'safetyScore': 70
          });
        }
        print("First Prediction: $item");
      } else {
        print("The predictions list is empty.");
      }
    }
    else{
      throw Exception('Failed to get predictions: ${response.statusCode}');
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChartScreen(
          accelerometerData: _accelerometerData,
          gyroscopeData: _gyroscopeData,
          drivingResult: drivingResult
        ),
      ),
    );
  }

  // void _openCamera(){
  //   Navigator.push(
  //       context, MaterialPageRoute(
  //       builder: (context) => EyeDetectionScreen()));
  // }

  void _processSensorData(List<double> accelValues, List<double> gyroValues) {
    // Provide default values if necessary (though not needed here)
    accelValues = accelValues.isNotEmpty ? accelValues : [1.0, 1.0, 1.0];
    gyroValues = gyroValues.isNotEmpty ? gyroValues : [1.0, 1.0, 1.0];

    // Calculate orientation and reoriented sensor data
    _processor.computeOrientationAngle(accelValues, gyroValues, _samplingInterval);
    List<List<double>> rotationMatrix = _processor.getRotationMatrix();

    // Reorient accelerometer and gyroscope data
    List<double> reorientedAccel = _processor.reorientatedData(accelValues, rotationMatrix);
    List<double> reorientedGyro = _processor.reorientatedData(gyroValues, rotationMatrix);

    // Update state
    setState(() {
      _accelerometerValues = reorientedAccel;
      _gyroscopeValues = reorientedGyro;

      // Optionally store data if needed
      _accelerometerData.add(AccelerometerData(DateTime.now(), reorientedAccel));
      _gyroscopeData.add(GyroscopeData(DateTime.now(), reorientedGyro));
    });
    print("Reor: $_gyroscopeValues");
    print("or: $gyroValues");
  }
}
