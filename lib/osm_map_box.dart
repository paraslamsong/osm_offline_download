import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:osm_offline_download/fetch_direction_service.dart';
import 'package:osm_offline_download/location_listen_service.dart';
import 'package:osm_offline_download/ripple_point.dart';
import 'download_map_service.dart';
import 'map_tile_providers.dart';

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

  fetchDirection(LatLng startingpoint, LatLng endpoint) async {
    DirectionService directionService = DirectionService();
    await directionService.getDirections(startingpoint, endpoint);
    List<LatLng> points = directionService.directionpoints;
    dev.log(points.length.toString());

    addPolylines(
      points: points,
      strokeWidth: 10,
    );

    addMarkers(
      markers: [
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
      ],
    );
  }
}

class OSMMapBox extends StatefulWidget {
  final OSMMapOfflineController controller;
  final bool? locationTrack, enableLocation;
  final Function(LatLng)? onUserLocationChange;
  const OSMMapBox({
    Key? key,
    required this.controller,
    this.locationTrack = false,
    this.enableLocation = false,
    this.onUserLocationChange,
  }) : super(key: key);
  @override
  State<OSMMapBox> createState() => _OSMMapBoxState();
  static Future<void> downloadOffline({
    required LatLng eastNorthLatLng,
    required LatLng southWestLatLng,
    Function(double)? onProgress,
  }) async {}
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
    super.initState();
    getImagePath();
    osmMapOfflineController = widget.controller;
    if (enableLocation) {
      _listenToLocationChange();
    }
  }

  String appDirectory = "";
  @override
  Widget build(BuildContext context) {
    osmMapOfflineController.setParent(this);
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            center: LatLng(27.6466743, 85.3666588),
            zoom: 10,
            minZoom: 3,
            maxZoom: 16,
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              tileProvider: CachedTileProvider(),
              minZoom: 3,
              maxZoom: 16,
              fastReplace: false,
              backgroundColor: Colors.white,
              tileBuilder: (BuildContext context, Widget widget, Tile tile) {
                bool isError = tile.loadError;
                if (isError) {
                  int z = tile.coords.z.toInt();
                  int x = tile.coords.x.toInt();
                  int y = tile.coords.y.toInt();
                  String fileName = '${appDirectory}tile-$z-$x-$y.png';
                  return Image.file(
                    File(fileName),
                    fit: BoxFit.fill,
                  );
                } else {
                  return Image(
                    image: tile.imageProvider,
                    fit: BoxFit.fill,
                  );
                }
              },
            ),
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
          right: 20,
          child: SafeArea(
            child: IconButton(
              onPressed: () {
                _animateRotate(0);
              },
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

  _listenToLocationChange() async {
    if (!enableLocation) {
      if (locationNotifier == null) return;
      locationNotifier = null;
      return;
    }
    locationNotifier = LocationNotifier();
    locationNotifier!.listenToLocation((LocationData currentLocation) {
      String lat = currentLocation.latitude!.toStringAsFixed(2);
      String lng = currentLocation.longitude!.toStringAsFixed(2);
      String alt = currentLocation.altitude!.toStringAsFixed(2);
      LatLng latlng =
          LatLng(currentLocation.latitude!, currentLocation.longitude!);
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
    });
  }

  void getImagePath() async {
    String appDocumentsPath = await getTileDirectoryPath();
    setState(() {
      appDirectory = appDocumentsPath;
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
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
}