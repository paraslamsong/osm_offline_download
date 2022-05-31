import 'dart:developer';
import 'package:latlong2/latlong.dart';
import 'package:osm_offline_download/utils/api_calls.dart';
import 'package:osm_offline_download/utils/singleton_class.dart';

class OSMStep {
  late double lat, lng;
  late String mofifier, type, pathName;
  late double distance;
  late List<LatLng> points = [];
  OSMStep.fromMap(map) {
    lat = map['maneuver']['location'][1];
    lng = map['maneuver']['location'][0];
    mofifier = map['maneuver']['modifier'] ?? "";
    type = map['maneuver']['type'] ?? "";
    if (type == "new name") type = "Continue";
    pathName = map['name'] == "" ? "unknown" : map['name'];
    num dis = map["distance"];
    for (var intersection in map['intersections']) {
      double latitude = intersection['location'][1];
      double longitude = intersection['location'][0];
      points.add(LatLng(latitude, longitude));
    }
    distance = (dis + 0.0);
  }
}

class DirectionService {
  List<LatLng> directionpoints = [];
  List<OSMStep> steps = [];
  getDirections(LatLng startingpoint, LatLng endpoint) async {
    double x1 = startingpoint.latitude;
    double y1 = startingpoint.longitude;
    double x2 = endpoint.latitude;
    double y2 = endpoint.longitude;
    String directionApiUrl =
        "get-direction/?x1=$x1&y1=$y1&x2=$x2&y2=$y2&API_KEY=${Constants().apiKey}&APP_KEY=${Constants().appId}";
    log(directionApiUrl);
    var response = await API().get(directionApiUrl);
    if (response.statusCode == 200) {
      log(response.data.toString());
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
      log("Steps${steps.length}");
      log("Directions${directionpoints.length}");
    } else {
      log(response.data['data']);
    }
  }
}
