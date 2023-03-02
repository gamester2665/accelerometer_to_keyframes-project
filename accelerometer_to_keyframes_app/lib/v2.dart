import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ChartSampleData {
  final DateTime time;
  final double value;

  ChartSampleData(this.time, this.value);
}

class AccelerometerChartScreen extends StatefulWidget {
  @override
  _AccelerometerChartScreenState createState() =>
      _AccelerometerChartScreenState();
}

class _AccelerometerChartScreenState extends State<AccelerometerChartScreen> {
  List<List<ChartSampleData>> _dataList = [
    [], // for x values
    [], // for y values
    [], // for z values
  ];

  final List<Color> _lineColors = [
    Colors.red, // for x values
    Colors.green, // for y values
    Colors.blue, // for z values
  ];
  DateTime _startTime = DateTime.now();

  Duration _duration = Duration.zero;

  int _maxDataCount = 30;
  List<int> _maxDataCountList = [30, 60, 90, 100];

  AccelerometerEvent? _latestEvent;

  @override
  void initState() {
    super.initState();

    // Start listening to accelerometer events
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        // Add new values to the data list
        DateTime now = DateTime.now();
        _duration = now.difference(_startTime);
        _dataList[0].add(ChartSampleData(now, event.x));
        _dataList[1].add(ChartSampleData(now, event.y));
        _dataList[2].add(ChartSampleData(now, event.z));

        _latestEvent = event;

        // for _exxx
        // Only keep the last _maxDataCount values
        // if (_dataList[0].length > _maxDataCount) {
        //   for (int i = 0; i < 3; i++) {
        //     _dataList[i].removeAt(0);
        //   }
        // }
      });
    });
  }

  void _resetChart() {
    setState(() {
      _startTime = DateTime.now();
      _dataList = [
        [], // for x values
        [], // for y values
        [], // for z values
      ];
    });
  }

  // List<Widget> _exxx() {
  //   return [
  //     Text('Max Data Points: '),
  //     SizedBox(width: 10),
  //     DropdownButton<int>(
  //         value: _maxDataCount,
  //         onChanged: (value) {
  //           setState(() {
  //             _maxDataCount = value!;
  //           });
  //         },
  //         items: _maxDataCountList.map(
  //           (int value) {
  //             return DropdownMenuItem(
  //               value: value,
  //               child: Text(value.toString()),
  //             );
  //           },
  //         ).toList()),
  //   ];
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: Text('Accelerometer Chart'),
      // ),
      body: SafeArea(
        child: Column(
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
                        showTitles: true,

                        getTitlesWidget: (double value, TitleMeta meta) {
                          // Convert value to DateTime
                          DateTime time = _dataList[0][value.toInt()].time;
                          // Format time as HH:mm:ss
                          return Text(
                              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}');
                        },
                        // margin: 8
                      )),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2,
                        // textStyle: TextStyle(
                        //   fontSize: 12,
                        //   color: Colors.grey,
                        // ),
                        // margin: 10,
                      ))),
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
                        spots: _dataList[i].asMap().entries.map((entry) {
                          return FlSpot(
                              entry.key.toDouble(), entry.value.value);
                        }).toList(),
                        isCurved: true,
                        color: _lineColors[i],
                        barWidth: 2,
                        dotData: FlDotData(
                          show: true,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: _resetChart,
                    child: Text('Reset'),
                  ),
                  Text(_duration.toString()),
                  if (_latestEvent != null) ...[
                    Text(_latestEvent!.x.toString(),
                        style: TextStyle(color: _lineColors[0])),
                    Text(_latestEvent!.y.toString(),
                        style: TextStyle(color: _lineColors[1])),
                    Text(_latestEvent!.z.toString(),
                        style: TextStyle(color: _lineColors[2])),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
