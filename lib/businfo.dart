import 'package:json_annotation/json_annotation.dart';

part 'businfo.g.dart';

@JsonSerializable()
class BusRoute {
  BusRoute(this.pieces);

  @JsonKey(required: true)
  final List<StopInRoute> pieces;

  factory BusRoute.fromJson(Map<String, dynamic> json) =>
      _$BusRouteFromJson(json);

  Map<String, dynamic> toJson() => _$BusRouteToJson(this);
}

@JsonSerializable()
class StopInRoute {
  StopInRoute(this.stop, this.segs, this.time, this.jump);

  @JsonKey(required: true)
  final String stop;

  @JsonKey(required: true)
  final List<int> segs;

  @JsonKey(required: true)
  final int time;

  @JsonKey(required: true)
  final int jump;

  factory StopInRoute.fromJson(Map<String, dynamic> json) =>
      _$StopInRouteFromJson(json);

  Map<String, dynamic> toJson() => _$StopInRouteToJson(this);
}

@JsonSerializable()
class BusInfo {
  BusInfo(this.points, this.segments, this.stops, this.routes);

  /// points[idx] == [lat, lng]
  @JsonKey(required: true)
  final List<List<double>> points;

  /// segments[idx] == [point1Idx, point2Idx, ...]
  @JsonKey(required: true)
  final List<List<int>> segments;

  /// stops['id'] == pointIdx
  @JsonKey(required: true)
  final Map<String, int> stops;

  @JsonKey(required: true)
  final Map<String, BusRoute> routes;

  factory BusInfo.fromJson(Map<String, dynamic> json) =>
      _$BusInfoFromJson(json);

  Map<String, dynamic> toJson() => _$BusInfoToJson(this);
}
