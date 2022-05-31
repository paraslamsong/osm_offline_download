import 'package:dio/dio.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_offline_download/utils/api_calls.dart';
import 'package:osm_offline_download/utils/singleton_class.dart';

class GeoCode {
  late LatLngBounds boundingbox;
  late LatLng center;
  late String displayName;

  fromMap(map) {
    displayName = map['display_name'] ?? "";

    num lat1 = num.parse(map['boundingbox'][0]);
    num lat2 = num.parse(map['boundingbox'][1]);
    num lng1 = num.parse(map['boundingbox'][2]);
    num lng2 = num.parse(map['boundingbox'][3]);

    num lat = num.parse(map['latitude']);
    num lng = num.parse(map['longitude']);

    boundingbox = LatLngBounds.fromPoints([
      LatLng(lat1.toDouble(), lng1.toDouble()),
      LatLng(lat2.toDouble(), lng2.toDouble()),
    ]);
    center = LatLng(lat.toDouble(), lng.toDouble());
  }

  Future<GeoCode> fetchGeoLocationUsingLocation(String location) async {
    Response response = await API().get(
        "location-coordinate/?location=$location&API_KEY=${Constants().apiKey}&APP_KEY=${Constants().appId}");
    if (response.statusCode == 200) {
      try {
        fromMap(response.data['data']);
        return this;
      } catch (e) {
        throw e.toString();
      }
    } else {
      throw "Error fetching GeoCoding";
    }
  }
}

class ReverseGeoCode {
  late String displayName;
  late LatLng center;
  late LatLngBounds boundingbox;

  fromMap(map) {
    displayName = map["display_name"] ?? "";

    num lat1 = num.parse(map['boundingbox'][0]);
    num lat2 = num.parse(map['boundingbox'][1]);
    num lng1 = num.parse(map['boundingbox'][2]);
    num lng2 = num.parse(map['boundingbox'][3]);

    num lat = num.parse(map['latitude']);
    num lng = num.parse(map['longitude']);

    boundingbox = LatLngBounds.fromPoints([
      LatLng(lat1.toDouble(), lng1.toDouble()),
      LatLng(lat2.toDouble(), lng2.toDouble()),
    ]);
    center = LatLng(lat.toDouble(), lng.toDouble());
  }

  Future<ReverseGeoCode> fetchLocationUsingGeoLocation(LatLng latlng) async {
    Response response = await API().get(
        "coordinate-location/?latitude=${latlng.latitude}&longitude=${latlng.longitude}&API_KEY=${Constants().apiKey}&APP_KEY=${Constants().appId}");
    if (response.statusCode == 200) {
      try {
        fromMap(response.data['data']);
        return this;
      } catch (e) {
        throw e.toString();
      }
    } else {
      throw "Error fetching GeoCoding";
    }
  }
}
