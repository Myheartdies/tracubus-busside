import 'package:bus_side/record_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewRecord extends StatefulWidget {
  const ViewRecord({Key? key}) : super(key: key);

  @override
  _ViewRecordState createState() => _ViewRecordState();
}

class _ViewRecordState extends State<ViewRecord> {
  var items;
  @override
  void initState() {
    //  items=Provider.of<RecordModel>(context, listen: false).view();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordModel>(builder: (context, model, child) {
      return Scaffold(
          appBar: AppBar(
            title: Text("the record is here"),
          ),
          body: //Center(child: Text(Provider.of<RecordModel>(context, listen: false).view().toString()),),
              ListView.builder(
                  itemCount: (model == null) ? 0 : model.records.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                        padding: EdgeInsets.all(4),
                        child: Text(model.records[index].toString()));
                  }));
    });
  }
}
