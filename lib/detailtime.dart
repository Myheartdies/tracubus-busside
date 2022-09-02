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
    _time=timeinput;
  }

  void segmentAddPoint(point input) {
    _segment.add({'lati': input.latitude, 'longi': input.longitude});
  }

  int timeRemain(double currentLati, double currentLongi) {
    if (!finalized) {
      print(
          "The detail time calculator is not finalized, returning dummy value");
      return 0;
    }
    if (_segment.length <= 1) {
      return 0; //In this case, the current stop is the final stop
    }
    return 0;
  }

  int findclosest(double currentLati, double currentLongi) {
    var nearest=tree.nearest({'lati':currentLati,'longi':currentLongi}, 2);
    return -1;
  }
}

class EmptyEATcalculator extends EATcalculator {
  @override
  int timeRemain(double currentLati, double currentLongi) {
    print("The EAT calculator is empty, returning dummy value");
    return 0;
  }
}
