import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:osm_offline_download/services/fetch_direction_service.dart';
import 'package:osm_offline_download/services/location_listen_service.dart';
import 'package:osm_offline_download/providers/map_layers_provider.dart';
import 'package:osm_offline_download/navigation_screen/osm_direction_steps_screen.dart';
import 'package:osm_offline_download/location_points/ripple_point.dart';
import 'services/download_map_service.dart';

// OSM Marker class
class OSMMarker {
  final LatLng latlng;
  final Widget? child;
  final bool? rotate;
  final double width, height;
  OSMMarker(
    this.latlng, {
    this.child,
    this.rotate,
    this.width = 30.0,
    this.height = 30.0,
  });
}

/* 
----------------------------------------------------------------------------------------
OSM controller this provides  access to dynamically add polygons, polylines, 
get positions, get zoom, change listen to user locations

----------------------------------------------------------------------------------------
*/
class OSMMapOfflineController {
  late _OSMMapBoxState _osmMapBoxState = _OSMMapBoxState();

  void setParent(osmMapBoxState) {
    _osmMapBoxState = osmMapBoxState;
  }

  void moveToPosition(LatLng latLng, {double? zoom}) {
    _osmMapBoxState._animateMove(latLng, zoom: zoom);
  }

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

  void removePolyline(int index) {
    _osmMapBoxState.polylines.removeAt(index);
    _osmMapBoxState
        .setState(() => _osmMapBoxState.polylines = _osmMapBoxState.polylines);
  }

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

  void removePolygons(int index) {
    _osmMapBoxState.polylines.removeAt(index);
    _osmMapBoxState
        .setState(() => _osmMapBoxState.polylines = _osmMapBoxState.polylines);
  }

  LatLng getCenterPosition() {
    double lat = _osmMapBoxState._controller.center.latitude;
    double lng = _osmMapBoxState._controller.center.longitude;
    return LatLng(lat, lng);
  }

  double getZoom() {
    return _osmMapBoxState._controller.zoom;
  }

  LatLngBounds getBoundary() {
    LatLngBounds latLngBounds = _osmMapBoxState._controller.bounds!;
    return latLngBounds;
  }

  animateToPoint(LatLng latLng, {double? zoom}) {
    _osmMapBoxState._animateMove(latLng, zoom: zoom);
  }

  setTracking(bool enable) {
    _osmMapBoxState.setState(() {
      _osmMapBoxState.locationTrack = enable;
      _osmMapBoxState.enableLocation = enable;
    });
    if (!enable) {
      _osmMapBoxState.locationNotifier!.stopListening();
    } else {
      _osmMapBoxState._listenToLocationChange();
    }
  }

  addMarkers({List<OSMMarker> markers = const []}) {
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

  fetchDirection(BuildContext context,
      {required LatLng startingpoint, required LatLng endpoint}) async {
    DirectionService directionService = DirectionService();
    await directionService.getDirections(startingpoint, endpoint);
    List<LatLng> points = directionService.directionpoints;
    dev.log(points.length.toString());
    List<Polyline> polylines = [];
    polylines.add(Polyline(
      points: points,
      color: Colors.red,
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
    _osmMapBoxState._gotoNavigation(
      polylines: polylines,
      markers: markersList,
      steps: directionService.steps,
    );
  }
}

class OSMMapBox extends StatefulWidget {
  final OSMMapOfflineController controller;
  final bool? locationTrack, enableLocation;
  final Function(LatLng)? onUserLocationChange;
  final LatLng? center;
  final double? zoom;
  final List<Polyline>? polylines;
  final List<Marker>? markers;
  const OSMMapBox({
    Key? key,
    required this.controller,
    this.locationTrack = false,
    this.enableLocation = false,
    this.center,
    this.polylines,
    this.markers,
    this.zoom,
    this.onUserLocationChange,
  }) : super(key: key);
  @override
  State<OSMMapBox> createState() => _OSMMapBoxState();
  static Future<void> downloadOffline({
    required LatLng eastNorthLatLng,
    required LatLng southWestLatLng,
    Function(double)? onProgress,
  }) async {
    downloadMap(
      eastNorthLatLng: eastNorthLatLng,
      southWestLatLng: southWestLatLng,
      onProgress: onProgress,
    );
  }
}

class _OSMMapBoxState extends State<OSMMapBox> with TickerProviderStateMixin {
  String imagePath = "";
  final MapController _controller = MapController();
  late final OSMMapOfflineController osmMapOfflineController;
  List<Polyline> polylines = [];
  List<Polygon> polygons = [];
  List<Marker> customMarkers = [];
  Marker? currentLocationMarker;
  bool locationTrack = false;
  bool enableLocation = false;

  @override
  void initState() {
    locationTrack = widget.locationTrack!;
    enableLocation = widget.enableLocation!;
    polylines = widget.polylines ?? [];
    customMarkers = widget.markers ?? [];
    _listenToLocationChange();
    super.initState();
    getImagePath();
    osmMapOfflineController = widget.controller;
  }

  String appDirectory = "";
  @override
  Widget build(BuildContext context) {
    osmMapOfflineController.setParent(this);
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            center: widget.center ?? LatLng(27.6466743, 85.3666588),
            zoom: widget.zoom ?? 12,
            minZoom: 3,
            maxZoom: 16,
          ),
          layers: [
            tileProvider(context, appDirectory),
            PolygonLayerOptions(polygons: polygons),
            PolylineLayerOptions(polylines: polylines),
            MarkerLayerOptions(markers: customMarkers),
            MarkerLayerOptions(
              markers: currentLocationMarker == null
                  ? []
                  : [
                      currentLocationMarker!,
                    ],
            ),
          ],
          mapController: _controller,
        ),
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            child: IconButton(
              onPressed: () => _animateRotate(0),
              color: Colors.white,
              iconSize: 30,
              icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: const Icon(
                    CupertinoIcons.location_north_fill,
                    size: 15,
                  )),
            ),
          ),
        ),
      ],
    );
  }

  LocationNotifier? locationNotifier;
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _listenToLocationChange() async {
    if (!enableLocation) {
      if (locationNotifier == null) return;
      locationNotifier = null;
      setState(() => currentLocationMarker = null);
      return;
    }
    locationNotifier = LocationNotifier();
    locationNotifier!.listenToLocation(
      (LocationData currentLocation) => setLocationMarker(currentLocation),
    );
  }

  void setLocationMarker(LocationData currentLocation) {
    String lat = currentLocation.latitude!.toStringAsFixed(2);
    String lng = currentLocation.longitude!.toStringAsFixed(2);
    String alt = currentLocation.altitude!.toStringAsFixed(2);
    dev.log(lat);
    dev.log(lng);
    LatLng latlng = LatLng(
      currentLocation.latitude!,
      currentLocation.longitude!,
    );
    currentLocationMarker = Marker(
      point: LatLng(currentLocation.latitude!, currentLocation.longitude!),
      rotate: true,
      builder: (ctx) => Tooltip(
        message: "Your location: $lat, $lng, $alt ",
        triggerMode: TooltipTriggerMode.tap,
        child: const RipplePoint(repeat: true),
      ),
    );
    if (locationTrack) _animateMove(latlng, zoom: _controller.zoom);
    setState(() => currentLocationMarker = currentLocationMarker);
    if (widget.onUserLocationChange == null) return;
    widget.onUserLocationChange!(latlng);
  }

  void getImagePath() async {
    String appDocumentsPath = await getTileDirectoryPath();
    setState(() {
      appDirectory = appDocumentsPath;
    });
  }

  _animateMove(LatLng latLng, {double? zoom}) {
    AnimationController animationController = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    LatLng curretnLatLng = _controller.center;
    final latTween =
        Tween<double>(begin: curretnLatLng.latitude, end: latLng.latitude);
    final lngTween =
        Tween<double>(begin: curretnLatLng.longitude, end: latLng.longitude);
    final zoomTween =
        Tween<double>(begin: _controller.zoom, end: zoom ?? _controller.zoom);
    Animation<double> animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.fastOutSlowIn,
    );
    animationController.addListener(() {
      _controller.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.dispose();
      } else if (status == AnimationStatus.dismissed) {
        animationController.dispose();
      }
    });

    animationController.forward();
  }

  _animateRotate(double degree) {
    double ang = _controller.rotation;
    double start = max(ang, degree);
    double end = min(ang, degree);
    if (start == 0) {
      start = end;
      end = 0;
    }
    _animatedRot(start, end);
  }

  _animatedRot(double start, double end) {
    AnimationController animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    final rotationTween = Tween<double>(
      begin: start,
      end: end,
    );
    Animation<double> animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.ease,
    );
    animationController.addListener(() {
      _controller.rotate(
        rotationTween.evaluate(animation),
      );
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.dispose();
      } else if (status == AnimationStatus.dismissed) {
        animationController.dispose();
      }
    });

    animationController.forward();
  }

  _gotoNavigation({
    required List<Polyline> polylines,
    required List<OSMStep> steps,
    required List<Marker> markers,
  }) {
    showOSMDirectionStepScreen(
      context,
      appDirectory: appDirectory,
      polylines: polylines,
      steps: steps,
      markers: markers,
    );
  }
}
