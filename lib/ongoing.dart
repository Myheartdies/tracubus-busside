import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:math';

import 'package:bus_side/record_model.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import "package:web_socket_channel/web_socket_channel.dart";
import 'package:http/http.dart' as http;
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
  String status = "no";
  late WebSocketChannel _channel;
  var listener;
  String uri = "http://20.24.96.85:4242/api/gps-info";
  Location location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  late int timestamp;
  late Timer _timer;
  bool _clicked = false;
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

  @override
  void dispose() {
    if (status == "yes") {
      _channel.sink.close();
    }
    _timer.cancel();
    if (listener != null) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    id = widget.id;
    setState(() {
      status = "connecting";
    });
    connect(uri);
    _timer = Timer.periodic(const Duration(milliseconds: 1300), (timer) {
      if (status == "no") {
        setState(() {
          status = "connecting";
        });
        connect(uri);
      }
      if (status == "connecting") {}
      if (status == "yes") {
        _sendMessage(widget.lineNum, _locationData.longitude!,
            _locationData.speed!, _locationData.latitude!, timestamp, id);
      }
    });
    initId();
  }

  void connect(String url) {
    Random r = Random();
    String key = base64.encode(List<int>.generate(8, (_) => r.nextInt(255)));

    HttpClient client = HttpClient();
    client
        .getUrl(Uri.parse(url))
        .timeout(const Duration(seconds: 10))
        .then((request) {
      request.headers.add('Connection', 'upgrade');
      request.headers.add('Upgrade', 'websocket');
      request.headers.add('sec-websocket-version', '13');
      request.headers.add('sec-websocket-key', key);

      request.close().then((response) {
        response.detachSocket().then((socket) {
          final webSocket =
              WebSocket.fromUpgradedSocket(socket, serverSide: false);
          webSocket.pingInterval = const Duration(milliseconds: 5000);
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
      return;
    });
  }

  void checkCon() {
    print("listening");
    listener = _channel.stream.listen(
      (dynamic message) {
        debugPrint('message $message');
      },
      onDone: () {
        print('ws channel closed');
        // print("connection closed abnormally, need reconnection");
        setState(() {
          status = "no";
        });
      },
      onError: (error) {
        debugPrint(timestamp.toString());
        print('ws error $error');
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
                      _locationData = loc;
                      timestamp = DateTime.now().microsecondsSinceEpoch;
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
              contoured(widget.lineNum),
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
                  handleClose();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget contoured(String input) {
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
  void _sendMessage(String route, double longit, double speed, double latit,
      int time, String id) {
    // debugPrint(time.toString());
    debugPrint("id" + id);
    //int did = int.parse(Id);
    var info = {
      "route": route,
      "longitude": longit,
      "speed": speed,
      "latitude": latit,
      "timestamp": time,
      "id": id,
    };
    Provider.of<RecordModel>(context, listen: false).store(info);
    _channel.sink.add(jsonEncode(info));
  }

  void _sendTrajectory() async {
    //TODO: Handle the situation of not sending succesfully
    var sendUri = Uri.parse("http://20.24.96.85:4242/api/history");
    var trajectoryrec =
        Provider.of<RecordModel>(context, listen: false).records;
    var trajectory = {
      "trajectory": trajectoryrec,
    };
    var response = await http.post(sendUri, body: jsonEncode(trajectory));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }

  void handleClose() async {
    if (!_clicked) {
      setState(() {
        _clicked = true;
      });
      print("clicked on button");
      _sendTrajectory();
      Navigator.pop(context);
    }
  }
}
