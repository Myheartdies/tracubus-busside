import 'dart:io';

import 'package:bus_side/record_model.dart';
import 'package:bus_side/view_record.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'text_block_clickable.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';

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
          title: const Text("选择你的路线"),
          //The button here is for debug purpose
          leading: recordButton(), //TODO: Remove it when release
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(child: expandedRow(['1A', '1B', '2'])),
              Expanded(child: expandedRow(['3', '4', '5'])),
              Expanded(child: expandedRow(['6A', '6B', '7'])),
              Expanded(child: expandedRow(['8', 'N', 'H'])),
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

  //TODO: Remove it
  Widget recordButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ViewRecord()),
        );
        Provider.of<RecordModel>(context, listen: false).view();
      },
      child: const Icon(
        Icons.add,
      ),
    );
  }
}
