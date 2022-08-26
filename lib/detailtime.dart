import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'record_model.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
class EATcalculator{
  List<point> _segment=[];
  int closest=0;
 
  void segmentAddPoint(point input){
    _segment.add(input);
  }

  int timeremain(double currentLati, double currentLongi){
    if(_segment.length<=1){
      return 0; //In this case, the current stop is the final stop
    }
    return 0;
  }
  
}
class EmptyEATcalculator extends EATcalculator{
  @override
  int timeremain(double currentLati, double currentLongi){
    print("The EAT calculator is empty, returning dummy value");
    return 0;
  }
}