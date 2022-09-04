import 'record_model.dart';
import 'package:kdtree/kdtree.dart';
import 'dart:math';

class EATcalculator {
  List<Map<String, double>> _segment = [];
  int closest = 0;
  late KDTree tree;
  late int total;
  late int _time;
  bool finalized = false;
  num distance(a, b) {
    return pow(a['lati'] - b['lati'], 2) + pow(a['longi'] - b['longi'], 2);
  }

  void finalize(int timeinput) {
    total = _segment.length;
    tree = KDTree(_segment, distance, ['lati', 'longi']);
    try{
    _time = timeinput;
    }
    catch(e){
      _time=0;
    }
    finalized = true;
  }

  void segmentAddPoint(point input) {
    _segment.add({'lati': input.latitude, 'longi': input.longitude});
  }

  int timeRemain(double currentLati, double currentLongi) {
    print("timeremain function evoked");
    if (!finalized) {
      print(
          "The detail time calculator is not finalized, returning dummy value");
      return 0;
    } else {
      if (_segment.length <= 1) {
      print("current station is final stopA");
        return 0; //In this case, the current stop is the final stop
      } else {
        int closest = findclosest(currentLati, currentLongi);
        print("bus at point $closest of $total");
        return max((_time * (total - closest) / total).round(), 0);
      }
    }
  }

  int findclosest(double currentLati, double currentLongi) {
    //Use kd tree to find closest point
    var nearest = tree.nearest({'lati': currentLati, 'longi': currentLongi}, 1);
    print(nearest);
    try {
      return _segment.indexOf(nearest[0][0]);
    } catch (e) {
      return -1;
    }
  }
}

class EmptyEATcalculator extends EATcalculator {
  @override
  int timeRemain(double currentLati, double currentLongi) {
    print("The EAT calculator is empty, returning dummy value");
    return 0;
  }
}
