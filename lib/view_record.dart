import 'package:bus_side/record_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewRecord extends StatefulWidget {
  const ViewRecord({ Key? key }) : super(key: key);

  @override
  _ViewRecordState createState() => _ViewRecordState();
}

class _ViewRecordState extends State<ViewRecord> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("the record is here"),),
      body: Center(child: Text(Provider.of<RecordModel>(context, listen: false).view().toString()),),
    );
  }
}