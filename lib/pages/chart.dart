import 'package:flutter/material.dart';
import 'package:safedriving/sensorsData/driving_result.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../sensorsData/accelerometer.dart';
import '../sensorsData/gyroscope.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen(
      {super.key,
      required this.accelerometerData,
      required this.gyroscopeData,
      required this.drivingResult});

  final List<AccelerometerData> accelerometerData;
  final List<GyroscopeData> gyroscopeData;
  final DrivingResult? drivingResult;

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF1FAFF),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF1FAFF),
          title: const Text('Driving session result'),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            SfRadialGauge(axes: <RadialAxis>[
              RadialAxis(minimum: -50, maximum: 100, ranges: <GaugeRange>[
                GaugeRange(
                    startValue: -50,
                    endValue: 0,
                    color: Colors.red,
                    startWidth: 10,
                    endWidth: 10),
                GaugeRange(
                    startValue: 0,
                    endValue: 50,
                    color: Colors.orange,
                    startWidth: 10,
                    endWidth: 10),
                GaugeRange(
                    startValue: 50,
                    endValue: 100,
                    color: Colors.green,
                    startWidth: 10,
                    endWidth: 10)
              ], pointers: <GaugePointer>[
                NeedlePointer(value: widget.drivingResult!.getSafetyScore)
              ], annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                    widget: Container(
                        child: Text('${widget.drivingResult!.getSafetyScore}',
                            style: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold))),
                    angle: 90,
                    positionFactor: 0.5)
              ])
            ]),
            const Text(
              'Total safety score for driving',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Center(
              child: Card(
                color: const Color(0xFFFFFFFF),
                margin: const EdgeInsets.all(5.0),
                child: ListTile(
                  subtitle: Text(
                      'Aggressive style: ${widget.drivingResult?.getAggressiveRate}%\n'
                      'Normal style : ${widget.drivingResult?.getNormalRate}%\n'
                      'Date: ${widget.drivingResult?.getDate.toLocal()}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black
                      )),
                ),
              ),
            ),
            //Initialize the chart widget
            // SfCartesianChart(
            //     primaryXAxis: CategoryAxis(),
            //     // Chart title
            //     title: ChartTitle(text: 'Acceleration Sensor Data'),
            //     // Enable legend
            //     legend: Legend(isVisible: true),
            //     // Enable tooltip
            //     tooltipBehavior: TooltipBehavior(enable: false),
            //     series: <ChartSeries<AccelerometerData, DateTime>>[
            //       LineSeries<AccelerometerData, DateTime>(
            //           dataSource: widget.accelerometerData,
            //           xValueMapper: (AccelerometerData value, _) =>
            //               value.getDate,
            //           yValueMapper: (AccelerometerData value, _) =>
            //               value.getValue[0],
            //           name: 'X'),
            //       LineSeries<AccelerometerData, DateTime>(
            //           dataSource: widget.accelerometerData,
            //           xValueMapper: (AccelerometerData value, _) =>
            //               value.getDate,
            //           yValueMapper: (AccelerometerData value, _) =>
            //               value.getValue[1],
            //           name: 'Y'),
            //       LineSeries<AccelerometerData, DateTime>(
            //           dataSource: widget.accelerometerData,
            //           xValueMapper: (AccelerometerData value, _) =>
            //               value.getDate,
            //           yValueMapper: (AccelerometerData value, _) =>
            //               value.getValue[2],
            //           name: 'Z'),
            //     ]),
            // SfCartesianChart(
            //     primaryXAxis: CategoryAxis(),
            //     // Chart title
            //     title: ChartTitle(text: 'Gyroscope Sensor Data'),
            //     // Enable legend
            //     legend: Legend(isVisible: true),
            //     // Enable tooltip
            //     tooltipBehavior: TooltipBehavior(enable: false),
            //     series: <ChartSeries<GyroscopeData, DateTime>>[
            //       LineSeries<GyroscopeData, DateTime>(
            //           dataSource: widget.gyroscopeData,
            //           xValueMapper: (GyroscopeData value, _) => value.getDate,
            //           yValueMapper: (GyroscopeData value, _) =>
            //               value.getValue[0],
            //           name: 'X'),
            //       LineSeries<GyroscopeData, DateTime>(
            //           dataSource: widget.gyroscopeData,
            //           xValueMapper: (GyroscopeData value, _) => value.getDate,
            //           yValueMapper: (GyroscopeData value, _) =>
            //               value.getValue[1],
            //           name: 'Y'),
            //       LineSeries<GyroscopeData, DateTime>(
            //           dataSource: widget.gyroscopeData,
            //           xValueMapper: (GyroscopeData value, _) => value.getDate,
            //           yValueMapper: (GyroscopeData value, _) =>
            //               value.getValue[2],
            //           name: 'Z'),
            //     ]),
          ]),
        ));
  }
}
