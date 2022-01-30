import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:math';

import 'package:bus_side/record_model.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import "package:web_socket_channel/web_socket_channel.dart";
// import 'package:web_socket_channel/status.dart' as status;

import 'package:location/location.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';

class OnGoing extends StatefulWidget {
  final String lineNum;
  final String id;
  const OnGoing({Key? key, required this.lineNum, required this.id})
      : super(key: key);

  @override
  _OnGoingState createState() => _OnGoingState();
}

class _OnGoingState extends State<OnGoing> {
  String id = '';
  // bool connected = false;
  String status = "no";
  late WebSocketChannel _channel;
  var listener;
  Location location = new Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  late int timestamp;
  late Timer _timer;
  var colormap = {
    '1A': const Color.fromARGB(255, 225, 221, 52),
    '1B': const Color.fromARGB(255, 225, 221, 52),
    '2': const Color.fromARGB(255, 224, 102, 199),
    '3': const Color.fromARGB(255, 163, 185, 96),
    '4': const Color.fromARGB(255, 224, 149, 77),
    '5': const Color.fromARGB(255, 193, 220, 231),
    '6A': const Color.fromARGB(255, 126, 145, 68),
    '6B': const Color.fromARGB(255, 137, 167, 219),
    '7': const Color.fromARGB(255, 191, 191, 191),
    '8': const Color.fromARGB(255, 239, 191, 79),
    'N': const Color.fromARGB(255, 172, 159, 196),
    'H': const Color.fromARGB(255, 130, 0, 149),
  };

  void dispose() {
    _channel.sink.close();
    _timer.cancel();
    if (listener != null) {
      listener.cancel();
    }
    super.dispose();
  }

//TODO: implement getting the IMEI and parse it to int
  @override
  void initState() {
    super.initState();
    id = widget.id;
    _timer = Timer.periodic(const Duration(milliseconds: 1300), (timer) {
      if (status == "no") {
        setState(() {
          status = "connecting";
        });
        connect();
      }
      if (status == "connecting") {
      }
      if (status == "yes") {
        _SendMessage(widget.lineNum, _locationData.longitude!,
            _locationData.speed!, _locationData.latitude!, timestamp, id);
      }
    });
    initId();
  }

  // connect() {
  //   print("connecting");
  //   _channel = IOWebSocketChannel.connect(
  //       Uri.parse("ws://20.24.96.85:4242/api/gps-info"),
  //       //   Uri.parse("ws://12.251.160.105:4242/api/gps-info"),
  //       pingInterval: Duration(milliseconds: 5000));
  //   setState(() {
  //     connected = true;
  //   });
  // }

  connect() {
    Random r = new Random();
    String key = base64.encode(List<int>.generate(8, (_) => r.nextInt(255)));

    HttpClient client = HttpClient();
    client
        .getUrl(Uri.parse("http://20.24.96.85:4242/api/gps-info"))
        .timeout(Duration(seconds: 10))
        .then((request) {
      request.headers.add('Connection', 'upgrade');
      request.headers.add('Upgrade', 'websocket');
      request.headers.add('sec-websocket-version', '13');
      request.headers.add('sec-websocket-key', key);

      request.close().then((response) {
        response.detachSocket().then((socket) {
          final webSocket =
              WebSocket.fromUpgradedSocket(socket, serverSide: false);
          webSocket.pingInterval = Duration(milliseconds: 5000);
          _channel = IOWebSocketChannel(webSocket);
          checkCon();
          setState(() {
            status = "yes";
          });
        });
      });
    }).catchError((error) {
      print(error);
      setState(() {
        status = "no";
      });
      return null;
    });
  }

  void checkCon() {
    print("listening");
    listener = _channel.stream.listen(
      (dynamic message) {
        debugPrint('message $message');
      },
      onDone: () {
        debugPrint('ws channel closed');
        // print("connection closed abnormally, need reconnection");
        setState(() {
          status = "no";
        });
      },
      onError: (error) {
        print(timestamp);
        debugPrint('ws error $error');
        setState(() {
          status = "no";
        });
      },
    );
  }

  Future<void> initId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      id = androidInfo.androidId!;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      id = iosInfo.identifierForVendor!;
    }
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
                      if (loc != null) {
                        _locationData = loc;
                        timestamp = DateTime.now().microsecondsSinceEpoch;
                      }
                      return Container();
                      //  return Text((loc.longitude!+loc.latitude!+loc.speed!).toString());
                    } else {
                      return Container();
                    }
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
              Container(
                padding: const EdgeInsets.all(8.0),
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
                  primary: const Color.fromARGB(255, 43, 65, 190),
                  minimumSize: const Size(200, 90),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
              shadows: const [
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
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
  }

//Send json with address message to server
  void _SendMessage(String route, double longit, double speed, double latit,
      int time, String Id) {
    // debugPrint(time.toString());
    print("id" + Id);
    //int did = int.parse(Id);
    var info = {
      "route": route,
      "longitude": longit,
      "speed": speed,
      "latitude": latit,
      "timestamp": time,
      "id": Id,
    };
    Provider.of<RecordModel>(context, listen: false).store(info);
    // debugPrint(info.toString());
    _channel.sink.add(jsonEncode(info));
  }
}
