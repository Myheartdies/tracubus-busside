import 'package:flutter/cupertino.dart';
import 'dart:io';

class RecordModel extends ChangeNotifier {
  final List<Map> _records = [];
  List<Map> get records => _records;
  void store(Map record) {
    _records.add(record);
    notifyListeners();
  }

  List view() {
    print(_records);
    //notifyListeners();
    return _records;
  }

}
