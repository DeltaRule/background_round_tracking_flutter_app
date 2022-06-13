import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vibration/vibration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Kindacode.com',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  String bttnText = "Count Rounds";
  late int _rounds = 0;
  bool _isRunning = false;
  late double _lat = 0.0;
  late double _lon = 0.0;
  late DateTime _startTime;
  String timeGone = "";
  String distString = "";
  LocationData? _userLocation;
  late StreamSubscription<LocationData>? _s = null;
  late bool _inRound = true;
  Location location = Location();
  List<FlSpot> TimeTrackData = [];
  num calcDistance(num lat1, num lon1, num lat2, num lon2) {
    final num lat1Rad = lat1 * (pi / 180);
    final num lat2Rad = lat2 * (pi / 180);
    final num lon1Rad = lon1 * (pi / 180);
    final num lon2Rad = lon2 * (pi / 180);
    final num latDiff = (lat1Rad - lat2Rad);
    final num lonDiff = (lon1Rad - lon2Rad);

    final num a = sin(latDiff / 2) * sin(latDiff / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(lonDiff / 2) * sin(lonDiff / 2);
    final num c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return 6371 * c * 1000;
  }

  Future<void> _getUserLocation() async {
    // Check if location service is enable
    _serviceEnabled = await location.serviceEnabled();

    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Check if permission is granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    if (_isRunning) {
      location.enableBackgroundMode(enable: false);
      // print("Ich habe eine Vermutung");
      await _s!.cancel();
      // print("Oh goot");

      _inRound = true;
      _rounds = 0;
      setState(() {
        _isRunning = false;
        bttnText = "Count Rounds";
      });
    } else {
      final _locationData = await location.getLocation();
      if (_locationData.latitude == null) {
        return;
      }
      _lat = _locationData.latitude!;
      _lon = _locationData.longitude!;

      setState(() {
        _isRunning = true;
        bttnText = "Stop";
      });
      _startTime = DateTime.now();
      TimeTrackData = [];
      location.enableBackgroundMode(enable: true);
      _s = location.onLocationChanged.listen((LocationData locationData) {
        if (locationData.latitude == null) {
          return;
        }
        final timeDif = DateTime.now().difference(_startTime);

        num _dist = calcDistance(
            _lat, _lon, locationData.latitude!, locationData.longitude!);
        setState(() {
          timeGone =
              "${timeDif.inHours}h ${timeDif.inMinutes % 60}m ${timeDif.inSeconds % 60}s";
          distString = "${_dist.toStringAsFixed(0)}m";
        });
        if (_inRound && _dist > 40) {
          _inRound = false;
        } else if (_inRound == false && _dist < 20) {
          _inRound = true;

          setState(() {
            _rounds++;
            TimeTrackData.add(
                FlSpot(timeDif.inSeconds.toDouble(), _rounds.toDouble()));
          });
          Vibration.vibrate(duration: 1000);
        }
      });
      // }
    }

    // final _locationData = await location.getLocation();
    // setState(() {
    //   _userLocation = _locationData;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isRunning == false && TimeTrackData.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    height: 300,
                    child: LineChart(
                      LineChartData(
                          borderData: FlBorderData(show: false),
                          lineTouchData: LineTouchData(enabled: false),
                          // gridData: FlGridData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: TimeTrackData,
                              isCurved: true,
                              dotData: FlDotData(
                                show: false,
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.deepPurple.withOpacity(0.4),
                              ),
                            )
                          ]),
                    ),
                  )
                : Container(),
            _isRunning
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      direction: Axis.vertical,
                      children: [
                        Align(
                            alignment: Alignment.center,
                            child: Text('${_rounds}',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 150))),
                        Align(
                            alignment: Alignment.center,
                            child: Text(
                              "$timeGone",
                            )),
                        Align(
                            alignment: Alignment.center,
                            child: Text(
                              "$distString",
                            ))
                      ],
                    ),
                  )
                : Container(),
            ElevatedButton(
                onPressed: _getUserLocation, child: Text("$bttnText")),
            const SizedBox(height: 25),
            // Display latitude & longtitude
          ],
        ),
      ),
    );
  }
}
