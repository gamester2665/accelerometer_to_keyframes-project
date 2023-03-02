import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accelerometer Chart Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: AccelerometerChartScreen(),
    );
  }
}

class AccelerometerChartScreen extends StatefulWidget {
  @override
  _AccelerometerChartScreenState createState() =>
      _AccelerometerChartScreenState();
}

class _AccelerometerChartScreenState extends State<AccelerometerChartScreen> {
  List<ChartSampleData> _data = [];

  @override
  void initState() {
    super.initState();
    _data = <ChartSampleData>[];
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _data.add(ChartSampleData(DateTime.now(), event.z));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accelerometer Chart'),
      ),
      body: Center(
        child: Container(
          child: SfCartesianChart(
            primaryXAxis: DateTimeAxis(),
            series: <ChartSeries<ChartSampleData, DateTime>>[
              LineSeries<ChartSampleData, DateTime>(
                dataSource: _data,
                xValueMapper: (ChartSampleData data, _) => data.time,
                yValueMapper: (ChartSampleData data, _) => data.value,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartSampleData {
  final DateTime time;
  final double value;

  ChartSampleData(this.time, this.value);
}
