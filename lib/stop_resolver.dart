import 'package:provider/provider.dart';
import 'record_model.dart';
import 'dart:math';
import 'package:http/http.dart' as http;

class StopResolver {
  bool isValid = true;
  void addStop(point input) {
    _stops.add(input);
    detecting.add(false);
  }

  void addJp(point input) {
    _jumpPoints.add(input);
    detecting.add(false);
  }

  List<point> _stops = []; //This is all stops of one bus route
  List<point> _jumpPoints =
      []; //This is all jumppoints of stops of one bus route
  List<bool> detecting = []; //TODO: initialize the detecting values
  bool isInOrder = true;
  int closest = 0;
  int current = 0; //the index of the stop bus currenty at
  bool listening = false;

  // double PI = 3.1415926; //53589793238;
  // double degreeToRadian(double degree) {
  //   return degree * PI / 180;
  // }

  // Iterable<int> backto(int num) sync* {
  //   while (num > 0) {
  //     yield num--;
  //   }
  // }

  int resolve(double currentLati, double currentLongi) {
    var currentp = point(currentLati, currentLongi);
    int closest = findClosest(currentp, _stops + _jumpPoints, 0.0001);
    print("debug: the closest is: $closest");
    if (closest >= _stops.length) {//if the bus is closes to a jump point
      if (!detecting[closest - _stops.length]) {
        return current;
      }
      for (int i = 0; i < detecting.length; i++) {
        detecting[i] = false;
      }
      current = closest - _stops.length;
      return current;
    } else if (closest > -1) {// if the bus is closest to a stop check status:
      if (closest == current + 1) {//if this is the natural next stop, change current stop
        current = closest;
        for (int i = 0; i < detecting.length; i++) {
          detecting[i] = false;//clear detecting list
        }
        return current;
      }
      if (closest <= current) { // if this is a stop already arrived before, ignore
        return current;
      }
      detecting[closest] = true;// if it is none of the above, add the 
      return current;
    } else if (closest == -1) {
      return current;
    }
    print("wrong index");

    return -1;
  }

  int findClosest(
      point currentPoint, List<point> chosenStops, double maxviable) {
    //expects stops to be a list of list of two doubles which indicates Latitude and Longitude
    //currentLati=degreeToRadian(currentLati);
    // currentLongi=degreeToRadian(currentLongi);
    double minDistance = 999; //placeholder
    double tempDist;
    int index = 0;  
    int length=chosenStops.length;
    print("debug: the list length is $length");
    for (int i = chosenStops.length; i >=0; i--) {
      tempDist = point.distance(currentPoint, chosenStops[i]);
      print("debug: calculated distance is $tempDist");
      if (tempDist < minDistance) {
        minDistance = tempDist;
        index = i;
      }
    }
    if (minDistance > maxviable) {
      return -1;
    }
    return index;
  }

  double bogusDistSquared(
      double Lati1, double Longi1, double Lati2, double Longi2) {
    return (pow(2, Lati1 - Lati2) + pow(2, Longi1 - Longi2)).toDouble();
  }

  reachStop() {}
}

class EmptyResolver extends StopResolver {
  @override
  int resolve(double currentLati, double currentLongi) {
    print("Not enough information for Stop reslover, the resolver is empty");
    return -1;
  }
}
