import 'package:bus_side/stop_resolver.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'dart:math';
import 'businfo.dart';

class point {
  double latitude;
  double longitude;
  point(this.latitude, this.longitude);
  static double distance(point p1, point p2) {
    return (pow(p1.latitude - p2.latitude, 2) +
            pow(p1.longitude - p2.longitude, 2))
        .toDouble();
  }
}

//This provider now provide status management for both storing history and resloving stop
class RecordModel extends ChangeNotifier {
  final List<Map> _records = [];
  final Map<String, point> _stops = {};
  final List<point> _jumpPoints = [];
  Map<String, StopResolver> _ResolverPile = {};

  List<Map> get records => _records;
  Map<String, point> get stops => _stops;
  List<point> get jumpoints => _jumpPoints;
  StopResolver GetResolver(String route) {
    try {
      if (_ResolverPile.containsKey(route)) {
        return _ResolverPile[route]!;
      }
      else return EmptyResolver();
    } catch (e) {
      print(e);
      return EmptyResolver();
    }
  }

  convertInfo(Map<String, dynamic> data) {
    List<point> points = [];
    //a pile of StopResolver that is mapped to each route

    BusInfo busInfo = BusInfo.fromJson(data);
    
    busInfo.points.forEach((element) {
      points.add(point(element[0], element[1])); //get value of points
    });
    busInfo.stops.forEach((key, value) {
      _stops[key] = point(points[value].latitude,
          points[value].longitude); //get value of stops name->point
    });
    busInfo.routes.forEach((routename, routeInfo) {
      _ResolverPile[routename] = StopResolver();
      routeInfo.pieces.forEach((stopInfo) {
        _ResolverPile[routename]!.addStop(_stops[stopInfo.stop]!);
        _ResolverPile[routename]!.addJp(points[stopInfo.jump]);
      });
    });
  }

  void store(Map record) {
    _records.add(record);
    notifyListeners();
  }

  List view() {
    print(_records);
    return _records;
  }
}
