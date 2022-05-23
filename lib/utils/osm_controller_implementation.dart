/* 
--------------------------------------------------------------------------------------------
Implementing OSMMapOfflineController 
--------------------------------------------------------------------------------------------
*/
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_offline_download/location_points/ripple_point.dart';
import 'package:osm_offline_download/osm_map_box.dart';
import 'package:osm_offline_download/services/fetch_direction_service.dart';

class OSMMapOfflineControllerImplementation implements OSMMapOfflineController {
  late OSMMapBoxState _osmMapBoxState = OSMMapBoxState();

  @override
  void setParent(osmMapBoxState) {
    _osmMapBoxState = osmMapBoxState;
  }

  @override
  void moveToPosition(LatLng latLng, {double? zoom}) {
    _osmMapBoxState.animateMove(latLng, zoom: zoom);
  }

  @override
  void addPolylines({
    required List<LatLng> points,
    Color? color,
    double? strokeWidth,
  }) {
    dev.log("hello");
    _osmMapBoxState.polylines.add(Polyline(
      points: points,
      color: color ?? Colors.red,
      strokeWidth: strokeWidth ?? 3,
    ));
    dev.log(points.length.toString());

    _osmMapBoxState
        .setState(() => _osmMapBoxState.polylines = _osmMapBoxState.polylines);
  }

  @override
  void removePolyline(int index) {
    if (_osmMapBoxState.polylines.length > index) {
      _osmMapBoxState.polylines.removeAt(index);
    }
    _osmMapBoxState
        .setState(() => _osmMapBoxState.polylines = _osmMapBoxState.polylines);
  }

  @override
  void addPolygons({
    required List<LatLng> points,
    Color? color,
    Color borderColor = const Color(0xFFFFFF00),
    double borderStrokeWidth = 0.0,
    bool isDotted = false,
    bool disableHolesBorder = false,
  }) {
    dev.log("Hellorrrr ");
    dev.log(points.length.toString());
    _osmMapBoxState.polygons.add(Polygon(
      points: points,
      color: color ?? Colors.red,
      borderColor: borderColor,
      borderStrokeWidth: borderStrokeWidth,
      disableHolesBorder: disableHolesBorder,
      isDotted: isDotted,
    ));
    _osmMapBoxState
        .setState(() => _osmMapBoxState.polylines = _osmMapBoxState.polylines);
  }

  @override
  void removePolygons(int index) {
    _osmMapBoxState.polylines.removeAt(index);
    _osmMapBoxState
        .setState(() => _osmMapBoxState.polylines = _osmMapBoxState.polylines);
  }

  @override
  LatLng getCenterPosition() {
    double lat = _osmMapBoxState.controller.center.latitude;
    double lng = _osmMapBoxState.controller.center.longitude;
    return LatLng(lat, lng);
  }

  @override
  double getZoom() {
    return _osmMapBoxState.controller.zoom;
  }

  @override
  LatLngBounds getBoundary() {
    LatLngBounds latLngBounds = _osmMapBoxState.controller.bounds!;
    return latLngBounds;
  }

  @override
  void animateToPoint(LatLng latLng, {double? zoom}) {
    _osmMapBoxState.animateMove(latLng, zoom: zoom);
  }

  @override
  void setTracking(bool enable) {
    _osmMapBoxState.setState(() {
      _osmMapBoxState.locationTrack = enable;
      _osmMapBoxState.enableLocation = enable;
    });
    if (!enable) {
      _osmMapBoxState.locationNotifier!.stopListening();
    } else {
      _osmMapBoxState.listenToLocationChange();
    }
  }

  @override
  void addMarkers({List<OSMMarker> markers = const []}) {
    List<Marker> markersList = [];
    for (var marker in markers) {
      markersList.add(
        Marker(
          point: marker.latlng,
          rotate: marker.rotate,
          width: marker.width,
          height: marker.height,
          builder: (ctx) =>
              marker.child ??
              const RipplePoint(
                repeat: false,
                duration: Duration(seconds: 3),
              ),
        ),
      );
    }
    _osmMapBoxState.setState(() {
      _osmMapBoxState.customMarkers = markersList;
    });
  }

  @override
  void fetchDirection(
    BuildContext context, {
    required LatLng startingpoint,
    required LatLng endpoint,
    Color? highlightColor,
    Color? routeColor,
  }) async {
    DirectionService directionService = DirectionService();
    await directionService.getDirections(startingpoint, endpoint);
    List<LatLng> points = directionService.directionpoints;
    dev.log(points.length.toString());
    List<Polyline> polylines = [];
    polylines.add(Polyline(
      points: points,
      color: routeColor ?? Colors.red.withOpacity(0.6),
      strokeWidth: 10,
    ));
    dev.log(points.length.toString());
    var markers = [
      OSMMarker(
        points.first,
        rotate: true,
        height: 20,
        width: 20,
        child: const PinPoint(color: Colors.red),
      ),
      OSMMarker(
        points.last,
        rotate: true,
        height: 20,
        width: 20,
        child: const PinPoint(color: Colors.teal),
      ),
    ];
    List<Marker> markersList = [];
    for (var marker in markers) {
      markersList.add(
        Marker(
          point: marker.latlng,
          rotate: marker.rotate,
          width: marker.width,
          height: marker.height,
          builder: (ctx) =>
              marker.child ??
              const RipplePoint(
                repeat: false,
                duration: Duration(seconds: 3),
              ),
        ),
      );
    }
    _osmMapBoxState.gotoNavigation(
      polylines: polylines,
      markers: markersList,
      steps: directionService.steps,
      routeColor: routeColor,
      highlightColor: highlightColor,
    );
  }
}
