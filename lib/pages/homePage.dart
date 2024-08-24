import 'dart:async';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safedriving/auth/login.dart';
import 'package:safedriving/drowsinessDetect/detector.dart';
import 'package:safedriving/drowsinessDetect/face_detecter.dart';
import 'package:safedriving/sensorsData/driving_result.dart';
import 'package:safedriving/services/add_data.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:safedriving/save_data.dart';
import 'package:safedriving/auth/login_or_reg.dart';
import 'package:safedriving/sensorsData/accelerometer.dart';
import 'package:safedriving/drowsinessDetect/camera.dart';
import 'package:safedriving/sensorsData/gyroscope.dart';
import 'package:safedriving/save_data.dart';
import 'package:safedriving/sensorsData/euler_sensors_data.dart';
import 'package:http/http.dart' as http;

import '../components/switch.dart';
import 'chart.dart';

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
  final double wNormal = 1;
  final double wAgg = 2;
  final double wDrowsy = 10;

  final currentUser = FirebaseAuth.instance.currentUser!;
  CloudFirestoreService? service;

  //Camera
  bool _cameraEnabled = false;

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
    _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        .toList();

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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            if (_cameraEnabled)
              SizedBox(
                height: 600,
                child: DrowsinessDetectionLive(), // Camera widget
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Text('Allow Drowsiness detection: '),
                  Switch(
                    // This bool value toggles the switch.
                    value: _cameraEnabled,
                    activeColor: Colors.green,
                    onChanged: (bool value) {
                      // This is called when the user toggles the switch.
                      setState(() {
                        _cameraEnabled = value;
                      });
                    },
                  ),
                  // const SizedBox(height: 15),
                  Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(width: 1.0, color: Colors.black38),
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(16.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: <Widget>[
                  //       Text('Accelerometer: $accelerometer'),
                  //     ],
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.all(16.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: <Widget>[
                  //       Text('UserAccelerometer: $userAccelerometer'),
                  //     ],
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.all(16.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: <Widget>[
                  //       Text('Gyroscope: $gyroscope'),
                  //     ],
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.all(16.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: <Widget>[
                  //       Text('Date: ${DateTime.now()}'),
                  //     ],
                  //   ),
                  // ),
                  ElevatedButton(
                    onPressed: _startCollectingData,
                    child: const Text("Start driving"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: _stopCollectingData,
                    child: const Text("Stop driving"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dataTimer?.cancel();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _streamSubscriptions.clear();
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
  }

  void _startCollectingData() {
    if (backAndForth % 2 == 1) {
      _accelerometerData.clear();
      _gyroscopeData.clear();
    }

    // _dataTimer?.cancel(); // Cancel any existing timer

    // Set up a timer to process data every 0.5 seconds
    _dataTimer =
        Timer.periodic(const Duration(milliseconds: 500), (Timer timer) {
      if (_latestAccelValues != null && _latestGyroValues != null) {
        _processSensorData(_latestAccelValues!, _latestGyroValues!);
      }
    });

    backAndForth++;
  }

  void _stopCollectingData() async {
    _dataTimer?.cancel();
    for (final subscription in _streamSubscriptions) {
      await subscription.cancel();
    }
    // _streamSubscriptions.clear();
    setState(() {
      _cameraEnabled = false;
    });

    List<dynamic> dataLst =
        await writeDataToCsv(_accelerometerData, _gyroscopeData);
    final response = await http.post(
      Uri.parse('https://backapi-okqa.onrender.com/predict'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(dataLst),
    );

    if (response.statusCode == 200) {
      List<dynamic> predictionsList = jsonDecode(response.body);

      if (predictionsList.isNotEmpty) {
        Map<String, dynamic> item = predictionsList[0];
        final String? email = currentUser.email;
        String currEmail;
        int isDrowsy = 0;
        double? safetyScore = 0;
        // Create DrivingResult using values from the first item
        if (email != null) {
          currEmail = email;

          safetyScore = (wNormal * item['NORMAL'] -
              (wAgg * item['AGGRESSIVE']) -
              wDrowsy * isDrowsy);
          drivingResult = DrivingResult(currEmail, DateTime.now(),
              item['AGGRESSIVE'], item['NORMAL'], 0, safetyScore);

          service?.add({
            'username': currEmail,
            'time': DateTime.now(),
            'aggressiveRate': item['AGGRESSIVE'],
            'normalRate': item['NORMAL'],
            'drowsyRate': 0,
            'safetyScore': safetyScore
          });
        }
        print("First Prediction: $item");
      } else {
        print("The predictions list is empty.");
      }
    } else {
      throw Exception('Failed to get predictions: ${response.statusCode}');
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChartScreen(
            accelerometerData: _accelerometerData,
            gyroscopeData: _gyroscopeData,
            drivingResult: drivingResult),
      ),
    );
  }

// It was function for button to refer to the camera page
  Future<void> _openCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => DrowsinessDetectionLive()));
  }

  void _processSensorData(List<double> accelValues, List<double> gyroValues) {
    accelValues = accelValues.isNotEmpty ? accelValues : [1.0, 1.0, 1.0];
    gyroValues = gyroValues.isNotEmpty ? gyroValues : [1.0, 1.0, 1.0];

    // Calculate orientation and reoriented sensor data
    _processor.computeOrientationAngle(
        accelValues, gyroValues, _samplingInterval);
    List<List<double>> rotationMatrix = _processor.getRotationMatrix();

    // Reorient accelerometer and gyroscope data
    List<double> reorientedAccel =
        _processor.reorientatedData(accelValues, rotationMatrix);
    List<double> reorientedGyro =
        _processor.reorientatedData(gyroValues, rotationMatrix);

    setState(() {
      _accelerometerValues = reorientedAccel;
      _gyroscopeValues = reorientedGyro;

      _accelerometerData
          .add(AccelerometerData(DateTime.now(), reorientedAccel));
      _gyroscopeData.add(GyroscopeData(DateTime.now(), reorientedGyro));
    });
    print("Reor: $_gyroscopeValues");
    print("or: $gyroValues");
  }
}
