import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:charts_flutter/flutter.dart' as charts;

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
  List<charts.Series<TimeSeriesAccelerometerData, DateTime>> _seriesData = [];
  List<TimeSeriesAccelerometerData> _data = [];

  @override
  void initState() {
    super.initState();
    _data = <TimeSeriesAccelerometerData>[];
    _seriesData = <charts.Series<TimeSeriesAccelerometerData, DateTime>>[];
    _seriesData.add(charts.Series(
      id: 'Accelerometer',
      data: _data,
      domainFn: (TimeSeriesAccelerometerData data, _) => data.time,
      measureFn: (TimeSeriesAccelerometerData data, _) => data.value,
    ));

    // Listen for accelerometer events and update the chart data.
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _data.add(TimeSeriesAccelerometerData(DateTime.now(), event.z));
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    // Stop listening for accelerometer events when the widget is disposed.
    accelerometerEvents.drain();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accelerometer Chart'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(8),
          child: charts.TimeSeriesChart(
            _seriesData,
            animate: true,
            dateTimeFactory: const charts.LocalDateTimeFactory(),
          ),
        ),
      ),
    );
  }
}

class TimeSeriesAccelerometerData {
  final DateTime time;
  final double value;

  TimeSeriesAccelerometerData(this.time, this.value);
}
