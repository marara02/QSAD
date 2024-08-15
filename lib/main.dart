import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:safedriving/auth/auth.dart';
import 'package:safedriving/auth/login.dart';
import 'package:safedriving/firebase_options.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'auth/login_or_reg.dart';
import 'sensorsData/accelerometer.dart';
import 'drowsinessDetect/camera.dart';
import 'chart.dart';
import 'sensorsData/gyroscope.dart';
import 'save_data.dart';
import 'sensorsData/euler_sensors_data.dart';
import 'package:http/http.dart' as http;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sensors Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const AuthPage(),
      // home: const MyHomePage(title: 'Flutter Sensor Data Home Page'),
    );
  }
}

