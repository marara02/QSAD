import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_month_picker/flutter_custom_month_picker.dart';
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
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../components/navBar.dart';
import '../services/add_data.dart';

class MainPage extends StatelessWidget {
  MainPage({super.key});

  final currentUser = FirebaseAuth.instance.currentUser!;
  CloudFirestoreService service = CloudFirestoreService(FirebaseFirestore.instance);

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  Widget buildMiniGauge(double progressValue, double gaugeWidth) {
    return SizedBox(
      width: gaugeWidth,
      height: gaugeWidth,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 0,
                maximum: 100,
                startAngle: 270,
                endAngle: 270,
                showLabels: false,
                showTicks: false,
                axisLineStyle: AxisLineStyle(
                  thickness: 0.1,
                  thicknessUnit: GaugeSizeUnit.factor,
                  color: Color(0xFF00a9b5).withOpacity(0.2),
                ),
                pointers: <GaugePointer>[
                  RangePointer(
                    value: progressValue,
                    width: 0.1,
                    sizeUnit: GaugeSizeUnit.factor,
                    cornerStyle: CornerStyle.startCurve,
                    gradient: const SweepGradient(
                      colors: <Color>[
                        Color(0xFF837DFF),
                        Color(0xFF09F9BF),
                      ],
                      stops: <double>[0.25, 0.75],
                    ),
                  ),
                  MarkerPointer(
                    value: progressValue,
                    markerType: MarkerType.circle,
                    color: const Color(0xFF87e8e8),
                  ),
                ],
              ),
            ],
          ),
          // Text displaying the progress value
          Text(
            '${progressValue.toInt()}%',
            style: TextStyle(
              fontSize: gaugeWidth * 0.15,
              // Adjust size according to the gauge size
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get 30% of the screen width
    double gaugeWidth = MediaQuery.of(context).size.width * 0.6;
    double progressValue = 80; // Set your progress value here (out of 100)

    return Scaffold(
      backgroundColor: const Color(0xFFF1FAFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1FAFF),
        title: const Text('Driving History'),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            buildMiniGauge(progressValue, gaugeWidth),
            const SizedBox(height: 16), // Space between gauge and title
            const Text(
              'Average Safety Score',
              style: TextStyle(
                fontSize: 18, // Adjust the size as needed
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 25),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                    height: 400,
                    child: StreamBuilder(
                        stream: service.getDrivingStory(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting ||
                              snapshot.connectionState ==
                                  ConnectionState.none) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text(
                                'Error with fetching data: ${snapshot.data}');
                          } else if (snapshot.hasData &&
                              snapshot.data?.docs.isEmpty == true) {
                            return const Center(
                                child: Text('Empty collection'));
                          }
                          final documents = snapshot.data?.docs;
                          return ListView.builder(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: documents?.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  color: const Color(0xFFFFFFFF),
                                  margin: const EdgeInsets.all(5.0),
                                  child: ListTile(
                                    leading: const Text('time'),
                                    title: Text('Aggressiveness: ${documents?[index]['aggressiveRate']}%'),
                                    subtitle: Text('Normal: ${documents?[index]['normalRate']}%'),
                                    trailing: buildMiniGauge(documents?[index]['safetyScore'].toDouble(), 60),
                                  ),
                                );
                              });
                        })))
          ]),
        ),
      ),
    );
  }
}
