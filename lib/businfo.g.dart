// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'businfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusRoute _$BusRouteFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['pieces'],
  );
  return BusRoute(
    (json['pieces'] as List<dynamic>)
        .map((e) => StopInRoute.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$BusRouteToJson(BusRoute instance) => <String, dynamic>{
      'pieces': instance.pieces,
    };

StopInRoute _$StopInRouteFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['stop', 'segs', 'time', 'jump'],
  );
  return StopInRoute(
    json['stop'] as String,
    (json['segs'] as List<dynamic>).map((e) => e as int).toList(),
    (json['time'] as num).toDouble(),
    json['jump'] as int,
  );
}

Map<String, dynamic> _$StopInRouteToJson(StopInRoute instance) =>
    <String, dynamic>{
      'stop': instance.stop,
      'segs': instance.segs,
      'time': instance.time,
      'jump': instance.jump,
    };

BusInfo _$BusInfoFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['points', 'segments', 'stops', 'routes'],
  );
  return BusInfo(
    (json['points'] as List<dynamic>)
        .map((e) =>
            (e as List<dynamic>).map((e) => (e as num).toDouble()).toList())
        .toList(),
    (json['segments'] as List<dynamic>)
        .map((e) => (e as List<dynamic>).map((e) => e as int).toList())
        .toList(),
    Map<String, int>.from(json['stops'] as Map),
    (json['routes'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(k, BusRoute.fromJson(e as Map<String, dynamic>)),
    ),
  );
}

Map<String, dynamic> _$BusInfoToJson(BusInfo instance) => <String, dynamic>{
      'points': instance.points,
      'segments': instance.segments,
      'stops': instance.stops,
      'routes': instance.routes,
    };
