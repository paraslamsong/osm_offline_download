import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_offline_download/osm_map_box.dart';
import 'package:osm_offline_download/providers/api_validity_provider.dart';
import 'package:osm_offline_download/utils/api_overlay.dart';
import 'package:osm_offline_download/utils/singleton_class.dart';
import 'package:provider/provider.dart';

class YetiTechOsm extends StatefulWidget {
  final OSMMapOfflineController controller;
  final String apiKey;
  final bool? locationTrack;
  final bool? enableLocation;
  final LatLng? center;
  final List<Polyline>? polylines;
  final List<Marker>? markers;
  final double? zoom;
  final Function(LatLng)? onUserLocationChange;

  const YetiTechOsm({
    super.key,
    required this.controller,
    required this.apiKey,
    this.locationTrack,
    this.enableLocation,
    this.center,
    this.polylines,
    this.markers,
    this.zoom,
    this.onUserLocationChange,
  });
  @override
  State<YetiTechOsm> createState() => _YetiTechOsmState();
}

class _YetiTechOsmState extends State<YetiTechOsm> {
  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails details) {
      log(details.exception.toString());
      FlutterError.presentError(details);
    };
    Constants().getSetCredentials(widget.apiKey);
    return OSMMapBox(
      controller: widget.controller,
      locationTrack: widget.locationTrack,
      enableLocation: widget.enableLocation,
      center: widget.center,
      polylines: widget.polylines,
      markers: widget.markers,
      zoom: widget.zoom,
      onUserLocationChange: widget.onUserLocationChange,
    );
  }
}
