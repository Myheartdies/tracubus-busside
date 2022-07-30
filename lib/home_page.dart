import 'dart:convert';
import 'dart:io';

import 'package:bus_side/record_model.dart';
import 'package:bus_side/view_record.dart';
import 'package:flutter/material.dart';
import 'text_block_clickable.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

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
          title: const Text("選擇你的路線"),
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
    fetchInfo();
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

  Future<void> fetchInfo() async {
    if (!Provider.of<RecordModel>(context, listen: false).Finished) {
      var data;
      try {
        var response = await http
            .get(Uri.parse("http://20.24.96.85:4242/api/routes.json"));
        data = jsonDecode(response.body) as Map<String, dynamic>;
        print(response.statusCode);
        print(data["routes"]);
        Provider.of<RecordModel>(context, listen: false).convertInfo(data);
        //TODO: Implement a way to await the finish of converting before entering onGoing page
      } catch (e) {
        print(e);
      }
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
