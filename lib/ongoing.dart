import 'package:flutter/material.dart';
import "package:web_socket_channel/web_socket_channel.dart";
//import 'info_sender.dart';
import 'dart:convert';
import 'package:location/location.dart';
import 'dart:async';

class OnGoing extends StatefulWidget {
  final String lineNum;
  const OnGoing({Key? key, required this.lineNum}) : super(key: key);

  @override
  _OnGoingState createState() => _OnGoingState();
}

class _OnGoingState extends State<OnGoing> {
  final _channel = WebSocketChannel.connect(
      Uri.parse("ws://13.251.160.105:8080/api/gps-info"));
  Location location = new Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  late int timestamp;
  var colormap = {
    '1A': Color.fromARGB(255, 225, 221, 52),
    '1B': Color.fromARGB(255, 225, 221, 52),
    '2': Color.fromARGB(255, 224, 102, 199),
    '3': Color.fromARGB(255, 163, 185, 96),
    '4': Color.fromARGB(255, 224, 149, 77),
    '5': Color.fromARGB(255, 193, 220, 231),
    '6A': Color.fromARGB(255, 126, 145, 68),
    '6B': Color.fromARGB(255, 137, 167, 219),
    '7': Color.fromARGB(255, 191, 191, 191),
    '8': Color.fromARGB(255, 239, 191, 79),
    'N': Color.fromARGB(255, 172, 159, 196),
    'H': Color.fromARGB(255, 130, 0, 149),
  };

  void dispose() {
    _channel.sink.close();
    //  _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 1300), (timer) {
      int now = DateTime.now().second;
      if (_locationData != null) {
        _SendMessage(widget.lineNum, _locationData.longitude!,
            _locationData.speed!, _locationData.latitude!, timestamp);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    locationSetup();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder(
                  stream: location.onLocationChanged,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var loc = snapshot.data as LocationData;
                      // DateTime currentPhoneDate = DateTime.now();
                      if (loc != null) {
                     //   setState(() {
                          _locationData = loc;
                          timestamp = DateTime.now().microsecondsSinceEpoch;
                     //   });
                      }
                      return Container();
                      //  return Text((loc.longitude!+loc.latitude!+loc.speed!).toString());
                    } else
                      return Container();
                  }),
              Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: const Text(
                  '''
您的当前路线是
''',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Contoured(widget.lineNum),
              // Container(
              //   //padding: EdgeInsets.all(8.0),
              //   alignment: Alignment.center,
              //   child: Text(
              //     widget.lineNum,
              //     textAlign: TextAlign.center,
              //     style: TextStyle(
              //       color: colormap[widget.lineNum],
              //       fontSize: 180,
              //       fontWeight: FontWeight.w500,
              //     ),
              //   ),
              // ),
              Container(
                padding: EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: const Text(
                  '''
若路线切换，点按“切换路线”按钮
回到路线选择页面
''',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 43, 65, 190),
                  minimumSize: Size(200, 90),
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
                icon: const Icon(Icons.directions_bus, size: 50),
                label: const Text(
                  "切换路线",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget Contoured(String input) {
    return Stack(children: [
      Container(
        //padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(
          widget.lineNum,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: colormap[input],
              fontSize: 180,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  // bottomLeft
                  offset: Offset(2, 2),
                  color: Color.fromARGB(66, 29, 29, 29),
                ),
              ]),
        ),
      ),
    ]);
  }

  void locationSetup() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      print("service disabled");
      //locationMsg = 'service disabled';
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      print("permission denied");
      //  locationMsg = 'permission denied';
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    // print("asdfs");
    _locationData = await location.getLocation();
  }

//Send json with address message to server
  void _SendMessage(
      String route, double longit, double speed, double latit, int time) {
    print(time);
    _channel.sink.add(jsonEncode({
      "route": route,
      "longitude": longit,
      "speed": speed,
      "latitude": latit,
      "timestamp": time,
    }));
  }
}
