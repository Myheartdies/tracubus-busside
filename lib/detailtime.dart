import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'record_model.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
class EATcalculator{
  List<point> _segment=[];
  late int _stopNumber;
  int closest=0;
  void set stopNumber(int stop){
    _stopNumber=stop;
  }
  void segmentAddPoint(point input){
    _segment.add(input);
  }

  int timeremain(double currentLati, double currentLongi){
    return 0;
  }
  
}
class EmptyEATcalculator extends EATcalculator{
  @override
  int timeremain(double currentLati, double currentLongi){
    return 0;
  }
}