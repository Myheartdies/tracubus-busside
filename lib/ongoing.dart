import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:math';

import 'package:bus_side/detailtime.dart';
import 'package:bus_side/record_model.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import "package:web_socket_channel/web_socket_channel.dart";
import 'package:http/http.dart' as http;
// import 'package:web_socket_channel/status.dart' as status;

import 'package:location/location.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';

import 'stop_resolver.dart';
import 'package:wakelock/wakelock.dart';

class OnGoing extends StatefulWidget {
  final String lineNum;
  final String id;
  const OnGoing({Key? key, required this.lineNum, required this.id})
      : super(key: key);

  @override
  _OnGoingState createState() => _OnGoingState();
}

class _OnGoingState extends State<OnGoing> {
  late StopResolver resolver;
  String id = '';
  String status = "no";
  late WebSocketChannel _channel;
  var listener;
  String uri = "http://20.24.87.7:4242/api/gps-info";
  Location location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  late int timestamp;
  late Timer _timer;
  late List<EATcalculator> timeCalculators;
  int currentStop = 0;
  bool _clicked = false;
  bool locationEnabled = true;
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
  final snackBar = SnackBar(
    duration: const Duration(days: 2),
    content: Text('與服務器連接中斷，正在重連...'),
  );

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
      resolver = Provider.of<RecordModel>(context, listen: false)
          .GetResolver(widget.lineNum);
      timeCalculators=Provider.of<RecordModel>(context, listen: false).GetCalculators(widget.lineNum);
      Wakelock.enable(); //force the device to keep awake
    });
    connect(uri);
    location.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation != null) {
        _locationData = currentLocation;
      }
    });
    _timer = Timer.periodic(const Duration(milliseconds: 1100), (timer) {
      timestamp = (DateTime.now().millisecondsSinceEpoch) ~/
          1000; //the timestamp value assignment is moved to timer
      currentStop =
          resolver.resolve(_locationData.latitude!, _locationData.longitude!);
      if (status == "no") {
        setState(() {
          status = "connecting";
        });
        //  ScaffoldMessenger.of(context).showSnackBar(snackBar);
        connect(uri);
      }
      if (status == "connecting") {}
      if (status == "yes") {
        _sendMessage(
            widget.lineNum,
            _locationData.longitude!,
            _locationData.speed!,
            _locationData.latitude!,
            timestamp,
            id,
            currentStop,
            resolver.timeRemain());
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
              Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: const Text(
                  '''
您的當前路線是
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
若路線切換或者您已到達終點，
點按“返回主頁”按鈕
以回到主頁重新選取路線
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
                  "返回主頁",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  handleClose();
                },
              ),
              connectionReminder(),
              gpsReminder(),
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

  Widget connectionReminder() {
    if (status == "no" || status == "connecting")
      return Text("*與服務器連接中斷，正在重連...",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.red,
          ));
    return Container();
  }

  Widget gpsReminder() {
    if (!locationEnabled)
      return Text('''
*位置服務開啟失敗，
請確認GPS已經開啟，
並允許訪問位置''',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.red,
          ));
    return Container();
  }

  void locationSetup() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      print("service disabled");
      //locationMsg = 'service disabled';
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        locationEnabled = false;
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      print("permission denied");
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        locationEnabled = false;
        return;
      }
    }
    try {
      await location.enableBackgroundMode(enable: true);
    } catch (e) {
      debugPrint(e.toString());
    }
    // location.enableBackgroundMode(enable: true);
    locationEnabled = true;
    _locationData = await location.getLocation();
  }

//Send json with address message to server
  void _sendMessage(String route, double longit, double speed, double latit,
      int time, String id, int stop, int remaining) {
    debugPrint(longit.toString());
    debugPrint(latit.toString());
    debugPrint("id " + id);
    debugPrint(remaining.toString());
    var info = {
      "route": route,
      "longitude": longit,
      "speed": speed,
      "latitude": latit,
      "timestamp": time,
      "id": id,
      "stop": stop,
      "remaining": remaining,
    };
    debugPrint(info.toString());
    Provider.of<RecordModel>(context, listen: false).store(info);
    _channel.sink.add(jsonEncode(info));
  }

  void _sendTrajectory() async {
    //TODO: Handle the situation of not sending succesfully
    var sendUri = Uri.parse("http://20.24.87.7:4242/api/history");
    var trajectoryrec =
        Provider.of<RecordModel>(context, listen: false).records;
    var trajectory = {
      "trajectory": trajectoryrec,
    };
    try {
      var response = await http.post(sendUri, body: jsonEncode(trajectory));
      debugPrint('History sent, \nResponse status: ${response.statusCode}');
    } catch (e) {
      debugPrint('History sending failed, error: ${e}');
    }
  }

  void handleClose() async {
    if (!_clicked) {
      setState(() {
        _clicked = true;
        status = "pageclosed";
      });
      print("clicked on button");
      Wakelock.disable(); //stop force awake
      _sendTrajectory();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      Navigator.pop(context);
    }
  }
}
