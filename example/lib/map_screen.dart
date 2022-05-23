import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_offline_download/osm_map_box.dart';
import 'package:osm_offline_download/services/geocoding_service.dart';
import 'package:speed_dial_fab/speed_dial_fab.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  double progress = 0.0;

  bool tracking = true;

  final OSMMapOfflineController controller = OSMMapOfflineController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OSMMapBox(
        controller: controller,
        locationTrack: false,
        enableLocation: false,
      ),
      floatingActionButton: SpeedDialFabWidget(
        primaryForegroundColor: Colors.white,
        primaryBackgroundColor: Theme.of(context).primaryColor,
        secondaryIconsList: const [
          Icons.download,
          Icons.directions,
          Icons.line_axis_rounded,
          Icons.location_on,
          Icons.track_changes,
          CupertinoIcons.location_north_fill,
          Icons.location_searching,
          Icons.square,
        ],
        secondaryIconsText: const [
          "Download Tiles",
          "Navigation",
          "Draw Lines",
          "Geo Location",
          "Enable/Diable Tracking",
          "Add Marker",
          "Animate to point",
          "Add Polygon"
        ],
        secondaryIconsOnPress: [
          () {
            OSMMapBox.downloadOffline(
              eastNorthLatLng: LatLng(27.7469, 85.359),
              southWestLatLng: LatLng(27.6574, 85.2775),
              onProgress: (double p) {
                setState(() => progress = p);
              },
            );
          },
          () {
            controller.getDirection(
              context,
              startpoint: LatLng(27.6822, 85.3176),
              endpoint: LatLng(27.7013, 85.3400),
            );
          },
          () {
            controller.addPolylines(
              points: [
                LatLng(27.72, 85.459),
                LatLng(27.72, 85.574),
                LatLng(27.8469, 85.574),
                LatLng(27.8469, 85.459),
                LatLng(27.72, 85.459),
              ],
              strokeWidth: 3,
              color: Colors.blue,
            );
          },
          () async {
            String query = "kathmandu";
            GeoCode geoCode = await OSMMapBox.getGeoCoding(query: query);
            log("GeoCoding (Searched: $query ) : (Result: ${geoCode.center.latitude}, ${geoCode.center.longitude} )");
            LatLng coord = LatLng(27.7469, 85.359);
            ReverseGeoCode reverseGeoCode =
                await OSMMapBox.getReverseGeoCoding(coord: coord);
            log("Reverse GeoCoding (Searched:  ${coord.latitude}, ${coord.longitude} ) : (Result: ${reverseGeoCode.displayName})");
          },
          () {
            tracking = !tracking;
            controller.setTracking(tracking);
          },
          () {
            controller.addMarkers(
              markers: [
                OSMMarker(LatLng(27.7469, 85.359)),
              ],
            );
          },
          () {
            controller.animateToPoint(
              LatLng(27.7469, 85.359),
              zoom: 13,
            );
          },
          () {
            controller.addPolygons(
              points: [
                LatLng(27.65, 85.27),
                LatLng(27.65, 85.37),
                LatLng(27.75, 85.37),
                LatLng(27.75, 85.27),
              ],
              color: Colors.red.withOpacity(0.3),
              borderColor: Colors.red,
              borderStrokeWidth: 2,
            );
          }
        ],
      ),
      bottomNavigationBar: StatefulBuilder(
        builder: (context, setState) => Builder(builder: (context) {
          if (progress == 0.0 || progress == 1.0) {
            return const SizedBox();
          } else {
            return Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Downloading: ${(progress * 100).toStringAsFixed(2)} %"),
                  LinearProgressIndicator(value: progress),
                ],
              ),
            );
          }
        }),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
