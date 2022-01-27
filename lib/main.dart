
import 'package:flutter/material.dart';
import 'home_page.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Side app',
      theme: ThemeData(
        // This is the theme of your application.
        //

        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
     // home: TestPage(),
     //home: GpsTest(),
     //home:SocketTest(),
    );
  }
}

