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

class MotionSampleData {
  final DateTime time;
  final double x;
  final double y;
  final double z;

  MotionSampleData(this.time, this.x, this.y, this.z);
}

class MyAnimation {
  DateTime _startTime;
  Duration _duration;

  double _startX;
  double _startY;
  double _startZ;

  double _dx;
  double _dy;
  double _dz;

  MyAnimation(this._startTime, this._duration, this._startX, this._startY,
      this._startZ, this._dx, this._dy, this._dz);

  // Get the position at a specific point in time
  double getPosition(DateTime time) {
    // Calculate the elapsed time
    Duration elapsedTime = time.difference(_startTime);
    double dt = elapsedTime.inSeconds.toDouble();

    // Calculate the position using the displacement equations
    double x = _startX + _dx * dt;
    double y = _startY + _dy * dt;
    double z = _startZ + _dz * dt;

    // Return the y position
    return y;
  }
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

  List<MotionSampleData> _dataList2 = [];

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

  double _x = 0;
  double _y = 0;
  double _z = 0;
  double _roll = 0;
  double _pitch = 0;

  double _gx = 0;
  DateTime _lastTime = DateTime.now();
  double _vx = 0;
  double _vy = 0;
  double _vz = 0;
  double _dx = 0;
  double _dy = 0;
  double _dz = 0;

  @override
  void initState() {
    super.initState();

// MyAnimation animation = MyAnimation(startTime, duration, startX, startY, startZ, dx, dy, dz);
// double positionAt3Seconds = animation.getPosition(startTime.add(Duration(seconds: 3)));

    void calculateVelocityAndDisplacement(double vx, double dt) {
      DateTime now = DateTime.now();

      _vx += vx;
      _vy += _y * dt;
      _vz += _z * dt;

      _dx += _vx * dt;
      _dy += _vy * dt;
      _dz += _vz * dt;

      _dataList2.add(MotionSampleData(now, _dx, _dy, _dz));

      // _dataList[0].add(ChartSampleData(now, _dx));
      // _dataList[1].add(ChartSampleData(now, _dy));
      // _dataList[2].add(ChartSampleData(now, _dz));
    }

// Start listening to accelerometer events
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        DateTime now = DateTime.now();
        _x = event.x;
        _y = event.y;
        _z = event.z;
        _roll = atan2(_y, _z);
        _pitch = atan2(-_x, sqrt(_y * _y + _z * _z));

        _duration = now.difference(_startTime);
        _dataList[0].add(ChartSampleData(now, _x));
        _dataList[1].add(ChartSampleData(now, _y));
        _dataList[2].add(ChartSampleData(now, _z));

        _latestEvent = event;
      });
    });

    gyroscopeEvents.listen((GyroscopeEvent event) {
      // handle gyroscope data

      setState(() {
        DateTime now = DateTime.now();
        Duration delta = now.difference(_lastTime);
        _lastTime = now;

        _gx = event.x;
        double dt = delta.inMilliseconds.toDouble() / 1000.0;
        double vx = _gx * dt;

        calculateVelocityAndDisplacement(vx, dt);
      });
    });

    // Timer.periodic(Duration(seconds: 1), (timer) {

    // });
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
                    Text(_latestEvent!.x.ceilToDouble().toString(),
                        style: TextStyle(color: _lineColors[0])),
                    Text(_latestEvent!.y.ceilToDouble().toString(),
                        style: TextStyle(color: _lineColors[1])),
                    Text(_latestEvent!.z.ceilToDouble().toString(),
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
