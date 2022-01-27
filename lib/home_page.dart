import 'dart:io';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'text_block_clickable.dart';
import 'package:device_info_plus/device_info_plus.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String id = 'unknown';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: const Text("选择你的路线"),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(child: expandedRow(['1A', '1B', '2'])),
              Expanded(child: expandedRow(['3', '4', '5'])),
              Expanded(child: expandedRow(['6A', '6B', '7'])),
              Expanded(child: expandedRow(['8', 'N', 'H'])),
              //Expanded(child: expandedRow(['H', 'N'])),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initId();
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

  Widget expandedRow(List<String> line) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (String a in line)
            Expanded(child: ClickableTextBlock(lineNum: a, id: id)),
        ]);
  }
}
