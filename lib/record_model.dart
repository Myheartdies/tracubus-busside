import 'package:bus_side/stop_resolver.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'dart:math';
import 'businfo.dart';
import 'detailtime.dart';

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
  bool preparationFinished = false;
  final List<Map> _records = [];
  final Map<String, point> _stops = {};
  final List<point> _jumpPoints = [];
  Map<String, StopResolver> _ResolverPile = {};
  Map<String, List<EATcalculator>> _EATCalculatorPile = {};

  List<Map> get records => _records;
  Map<String, point> get stops => _stops;
  List<point> get jumpoints => _jumpPoints;
  bool get Finished => preparationFinished;
  StopResolver GetResolver(String route) {
    try {
      if (_ResolverPile.containsKey(route)) {
        return _ResolverPile[route]!;
      } else
        return EmptyResolver();
    } catch (e) {
      print(e);
      return EmptyResolver();
    }
  }

  List<EATcalculator> GetCalculators(String route) {
    try {
      if (_EATCalculatorPile.containsKey(route)) {
        return _EATCalculatorPile[route]!;
      }
      return [EATcalculator()];
    } catch (e) {
      print(e);
      return [EmptyEATcalculator()];
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
      _EATCalculatorPile[routename] = [];
      routeInfo.pieces.asMap().forEach((index, stopInfo) {
        _EATCalculatorPile[routename]!.add(EATcalculator());
        stopInfo.segs.forEach((segIndex) {
          //get all the segments for the piece
          busInfo.segments[segIndex].forEach((pointIndex) {
            _EATCalculatorPile[routename]![index]
                .segmentAddPoint(points[pointIndex]);
          });
        });
        _ResolverPile[routename]!.addStop(_stops[stopInfo.stop]!);
        _ResolverPile[routename]!.addJp(points[stopInfo.jump]);
        _ResolverPile[routename]!.addTime(stopInfo.time);
        _EATCalculatorPile[routename]![index].finalize(stopInfo.time);//finalize function partially as the addTime for EAT calculator
      });
    });
    preparationFinished = true;
    print(_ResolverPile["3"]);
    notifyListeners();
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
