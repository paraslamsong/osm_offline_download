import 'package:dio/dio.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

class GeoCode {
  late int placeId, osmId;
  late String licence;
  late LatLngBounds boundingbox;
  late LatLng center;
  late String displayName;

  fromMap(map) {
    placeId = map['place_id'] ?? 0;
    osmId = map['osm_id'] ?? 0;
    licence = map['licence'] ?? "";
    displayName = map['display_name'] ?? "";

    num lat1 = num.parse(map['boundingbox'][0]);
    num lat2 = num.parse(map['boundingbox'][1]);
    num lng1 = num.parse(map['boundingbox'][2]);
    num lng2 = num.parse(map['boundingbox'][3]);

    num lat = num.parse(map['lat']);
    num lng = num.parse(map['lon']);

    boundingbox = LatLngBounds.fromPoints([
      LatLng(lat1.toDouble(), lng1.toDouble()),
      LatLng(lat2.toDouble(), lng2.toDouble()),
    ]);
    center = LatLng(lat.toDouble(), lng.toDouble());
  }

  Future<GeoCode> fetchGeoLocationUsingLocation(String location) async {
    Response response = await Dio().get(
        "https://nominatim.openstreetmap.org/search/$location?format=json&limit=1");
    if (response.statusCode == 200) {
      try {
        for (var data in response.data) {
          fromMap(data);
        }
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
  late int placeId, osmId;
  late String licence;
  late String displayName;
  late LatLng center;
  late LatLngBounds boundingbox;

  fromMap(map) {
    placeId = map["place_id"] ?? 0;
    osmId = map["osm_id"] ?? 0;
    licence = map["licence"] ?? "";
    displayName = map["display_name"] ?? "";

    num lat1 = num.parse(map['boundingbox'][0]);
    num lat2 = num.parse(map['boundingbox'][1]);
    num lng1 = num.parse(map['boundingbox'][2]);
    num lng2 = num.parse(map['boundingbox'][3]);

    num lat = num.parse(map['lat']);
    num lng = num.parse(map['lon']);

    boundingbox = LatLngBounds.fromPoints([
      LatLng(lat1.toDouble(), lng1.toDouble()),
      LatLng(lat2.toDouble(), lng2.toDouble()),
    ]);
    center = LatLng(lat.toDouble(), lng.toDouble());
  }

  Future<ReverseGeoCode> fetchLocationUsingGeoLocation(LatLng latlng) async {
    Response response = await Dio().get(
      "https://nominatim.openstreetmap.org/reverse?format=json&lat=${latlng.latitude}&lon=${latlng.longitude}",
    );
    if (response.statusCode == 200) {
      try {
        fromMap(response.data);
        return this;
      } catch (e) {
        throw e.toString();
      }
    } else {
      throw "Error fetching GeoCoding";
    }
  }
}
