import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safedriving/auth/login.dart';
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

class MainPage extends StatefulWidget {
  const MainPage({super.key});


  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BottomNavigationBar Demo'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: 'Calls',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
        ],
      ),
    );
  }
}