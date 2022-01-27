import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';


class GpsTest extends StatefulWidget {
  const GpsTest({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _GpsTestState createState() => _GpsTestState();
}

class _GpsTestState extends State<GpsTest> {
  final Location location = Location();

  Future<void> _showInfoDialog() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Demo Application'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Created by Guillaume Bernos'),
                InkWell(
                  child: const Text(
                    'https://github.com/Lyokone/flutterlocation',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTap: () =>print("dfdsff"),
                      //launch('https://github.com/Lyokone/flutterlocation'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GPS test"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: const <Widget>[
          //   PermissionStatusWidget(),
              Divider(height: 32),
         //     ServiceEnabledWidget(),
              Divider(height: 32),
        //      GetLocationWidget(),
              Divider(height: 32),
         //     ListenLocationWidget(),
              Divider(height: 32),
        //      ChangeSettings(),
              Divider(height: 32),
         //     EnableInBackgroundWidget(),
              Divider(height: 32),
          //    ChangeNotificationWidget()
            ],
          ),
        ),
      ),
    );
  }
}