import 'package:flutter/cupertino.dart';

class RecordModel extends ChangeNotifier{
  final List<Map> _records=[];
  void add(Map record){
    _records.add(record);
    notifyListeners();
  }
  List view(){
    return _records;
  }

}