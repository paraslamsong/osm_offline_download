import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class OSMStep {
  late double lat, lng;
  late String mofifier, type, pathName;
  late double distance;
  OSMStep.fromMap(map) {
    lat = map['maneuver']['location'][1];
    lng = map['maneuver']['location'][0];
    mofifier = map['maneuver']['modifier'] ?? "";
    type = map['maneuver']['type'] ?? "";
    if (type == "new name") type = "Continue";
    pathName = map['name'] == "" ? "unknown" : map['name'];
    num dis = map["distance"];

    distance = (dis + 0.0);
  }
}

class DirectionService {
  List<LatLng> directionpoints = [];
  late LatLng startingPoint, endPoint;
  List<OSMStep> steps = [];

  getDirections(LatLng startingpoint, LatLng endpoint) async {
    startingPoint = startingpoint;
    endPoint = endpoint;
    String directionApiUrl =
        '''https://routing.openstreetmap.de/routed-car/route/v1/driving/${startingpoint.longitude},${startingpoint.latitude};${endpoint.longitude},${endpoint.latitude}?overview=false&geometries=polyline&steps=true''';

    log(directionApiUrl);
    var response = await Dio().get(directionApiUrl);

    if (response.statusCode == 200) {
      directionpoints = [];
      steps = [];
      for (var route in response.data['routes']) {
        for (var leg in route['legs']) {
          for (var step in leg['steps']) {
            for (var intersection in step['intersections']) {
              double latitude = intersection['location'][1];
              double longitude = intersection['location'][0];
              directionpoints.add(LatLng(latitude, longitude));
            }
            steps.add(OSMStep.fromMap(step));
          }
        }
      }
    }
  }
}
