import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:osm_offline_download/services/fetch_direction_service.dart';
import 'package:osm_offline_download/services/geocoding_service.dart';
import 'package:osm_offline_download/services/location_listen_service.dart';
import 'package:osm_offline_download/providers/map_layers_provider.dart';
import 'package:osm_offline_download/navigation_screen/osm_direction_steps_screen.dart';
import 'package:osm_offline_download/location_points/ripple_point.dart';
import 'package:osm_offline_download/utils/osm_controller_implementation.dart';
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
abstract class OSMMapOfflineController {
  factory OSMMapOfflineController() {
    return OSMMapOfflineControllerImplementation();
  }
  // it connects controller to parent state
  void setParent(dynamic);

  // animate map to latitude and longitude with certain zoom
  void moveToPosition(LatLng latLng, {double? zoom});
  // add poly line to the map
  void addPolylines({
    required List<LatLng> points,
    Color? color,
    double? strokeWidth,
  });
  // remove polyline with index if exist
  void removePolyline(int index);
  // add polygon to map
  void addPolygons({
    required List<LatLng> points,
    Color? color,
    Color borderColor = const Color(0xFFFFFF00),
    double borderStrokeWidth = 0.0,
    bool isDotted = false,
    bool disableHolesBorder = false,
  });
  // remove polygon with index if exist
  void removePolygons(int index);
  // get center position of the map
  LatLng getCenterPosition();
  // get zoom level of map
  double getZoom();
  // get coundary on the map on view port
  LatLngBounds getBoundary();
  // move to certain point in map with animation
  void animateToPoint(LatLng latLng, {double? zoom});
  // enable tracking on map using location api
  void setTracking(bool enable);
  // add markers to map
  void addMarkers({List<OSMMarker> markers = const []});
  // go to navigation with given start location adn end location
  void getDirection(
    BuildContext context, {
    required LatLng startpoint,
    required LatLng endpoint,
    Color? highlightColor,
    Color? routeColor,
  });
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
  State<OSMMapBox> createState() => OSMMapBoxState();

  static Future<void> downloadOffline({
    required LatLng eastNorthLatLng,
    required LatLng southWestLatLng,
    Function(double)? onProgress,
    Function()? onDownloadCompleted,
    Function(Object)? onError,
  }) async {
    downloadMap(
      eastNorthLatLng: eastNorthLatLng,
      southWestLatLng: southWestLatLng,
      onProgress: onProgress,
      onError: onError,
      onDownloadCompleted: onDownloadCompleted,
    );
  }

  static Future<GeoCode> getGeoCoding({required String query}) {
    GeoCode geoCode = GeoCode();
    return geoCode.fetchGeoLocationUsingLocation(query);
  }

  static Future<ReverseGeoCode> getReverseGeoCoding({required LatLng coord}) {
    ReverseGeoCode reverseGeoCode = ReverseGeoCode();
    return reverseGeoCode.fetchLocationUsingGeoLocation(coord);
  }
}

class OSMMapBoxState extends State<OSMMapBox> with TickerProviderStateMixin {
  String imagePath = "";
  final MapController controller = MapController();
  late final OSMMapOfflineController osmMapOfflineController;
  List<Polyline> polylines = [];
  List<Polygon> polygons = [];
  List<Marker> customMarkers = [];
  Marker? currentLocationMarker;
  bool locationTrack = false;
  bool enableLocation = false;

  double mapRotation = 0;

  @override
  void initState() {
    locationTrack = widget.locationTrack!;
    enableLocation = widget.enableLocation!;
    polylines = widget.polylines ?? [];
    customMarkers = widget.markers ?? [];
    listenToLocationChange();

    super.initState();

    getImagePath();
    osmMapOfflineController = widget.controller;

    controller.mapEventStream.listen((event) {
      if (controller.rotation != mapRotation) {
        setState(() => mapRotation = controller.rotation);
      }
    });
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
          mapController: controller,
        ),
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            child: IconButton(
              onPressed: () => animateRotate(0),
              color: Colors.white,
              iconSize: 40,
              icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: AnimatedRotation(
                      duration: const Duration(milliseconds: 0),
                      turns: mapRotation / 360,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "N",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Icon(
                            CupertinoIcons.location_north_line_fill,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
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

  listenToLocationChange() async {
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
    if (locationTrack) animateMove(latlng, zoom: controller.zoom);
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

  animateMove(LatLng latLng, {double? zoom}) {
    AnimationController animationController = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    LatLng curretnLatLng = controller.center;
    final latTween =
        Tween<double>(begin: curretnLatLng.latitude, end: latLng.latitude);
    final lngTween =
        Tween<double>(begin: curretnLatLng.longitude, end: latLng.longitude);
    final zoomTween =
        Tween<double>(begin: controller.zoom, end: zoom ?? controller.zoom);
    Animation<double> animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.fastOutSlowIn,
    );
    animationController.addListener(() {
      controller.move(
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

  animateRotate(double degree) {
    double ang = controller.rotation;
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
      controller.rotate(
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

  gotoNavigation({
    required List<Polyline> polylines,
    required List<OSMStep> steps,
    required List<Marker> markers,
    Color? highlightColor,
    Color? routeColor,
  }) {
    showOSMDirectionStepScreen(
      context,
      appDirectory: appDirectory,
      polylines: polylines,
      steps: steps,
      markers: markers,
      highlightColor: highlightColor,
      routeColor: routeColor,
    );
  }
}
