import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class AccelerometerChartScreen extends StatefulWidget {
  @override
  _AccelerometerChartScreenState createState() =>
      _AccelerometerChartScreenState();
}

class _AccelerometerChartScreenState extends State<AccelerometerChartScreen> {
  final List<List<FlSpot>> _spotsList = [
    [], // for x values
    [], // for y values
    [], // for z values
  ];

  final List<Color> _lineColors = [
    Colors.red, // for x values
    Colors.green, // for y values
    Colors.blue, // for z values
  ];

  @override
  void initState() {
    super.initState();

    // Create empty spots
    for (int i = 0; i < 3; i++) {
      _spotsList[i] = [];
    }

    // Start listening to accelerometer events
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        // Add new values to the spots
        _spotsList[0].add(FlSpot(_spotsList[0].length.toDouble(), event.x));
        _spotsList[1].add(FlSpot(_spotsList[1].length.toDouble(), event.y));
        _spotsList[2].add(FlSpot(_spotsList[2].length.toDouble(), event.z));

        // Only keep the last 30 values
        if (_spotsList[0].length > 15) {
          for (int i = 0; i < 3; i++) {
            _spotsList[i].removeAt(0);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accelerometer Chart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(enabled: false),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey,
                      strokeWidth: 0.5,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey,
                      strokeWidth: 0.5,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                      showTitles: false,
                    )),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2,
                        // textStyle: TextStyle(
                        //   fontSize: 12,
                        // ),
                        // margin: 10,
                      ),
                    )),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey,
                    width: 0.5,
                  ),
                ),
                lineBarsData: [
                  for (int i = 0; i < 3; i++)
                    LineChartBarData(
                      spots: _spotsList[i],
                      isCurved: true,
                      color: _lineColors[i],
                      barWidth: 2,
                      dotData: FlDotData(
                        show: false,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
