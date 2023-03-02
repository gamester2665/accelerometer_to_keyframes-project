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
  List<List<ChartSampleData>> _data = [];

  @override
  void initState() {
    super.initState();
    _data = List.generate(3, (_) => <ChartSampleData>[]);
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _data[0].add(ChartSampleData(DateTime.now(), event.x));
        _data[1].add(ChartSampleData(DateTime.now(), event.y));
        _data[2].add(ChartSampleData(DateTime.now(), event.z));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accelerometer Chart'),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('x: ${_data[0].last.value.toStringAsFixed(2)}'),
                Text('y: ${_data[1].last.value.toStringAsFixed(2)}'),
                Text('z: ${_data[2].last.value.toStringAsFixed(2)}'),
                SizedBox(height: 16),
                Expanded(
                  child: SfCartesianChart(
                    primaryXAxis: DateTimeAxis(),
                    series: <ChartSeries<ChartSampleData, DateTime>>[
                      LineSeries<ChartSampleData, DateTime>(
                        dataSource: _data[0],
                        xValueMapper: (ChartSampleData data, _) => data.time,
                        yValueMapper: (ChartSampleData data, _) => data.value,
                        color: Colors.red,
                      ),
                      LineSeries<ChartSampleData, DateTime>(
                        dataSource: _data[1],
                        xValueMapper: (ChartSampleData data, _) => data.time,
                        yValueMapper: (ChartSampleData data, _) => data.value,
                        color: Colors.green,
                      ),
                      LineSeries<ChartSampleData, DateTime>(
                        dataSource: _data[2],
                        xValueMapper: (ChartSampleData data, _) => data.time,
                        yValueMapper: (ChartSampleData data, _) => data.value,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ChartSampleData {
  final DateTime time;
  final double value;

  ChartSampleData(this.time, this.value);
}
