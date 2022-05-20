import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_offline_download/osm_map_box.dart';

class MapScreen extends StatelessWidget {
  MapScreen({Key? key}) : super(key: key);
  double progress = 0.0;

  bool tracking = true;
  final OSMMapOfflineController controller = OSMMapOfflineController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OSMMapBox(
        controller: controller,
        locationTrack: false,
        enableLocation: true,
      ),
      floatingActionButton: StatefulBuilder(
        builder: (context, setState) => Builder(builder: (context) {
          if (progress == 0.0 || progress == 1.0) {
            return FloatingActionButton(
              onPressed: () {
                controller.fetchDirection(
                  LatLng(27.6822, 85.3176),
                  LatLng(27.7013, 85.3400),
                );
                // tracking = !tracking;
                // controller.setTracking(tracking);
                // controller.addPolylines(
                //   points: [
                //     LatLng(27.7469, 85.359),
                //     LatLng(27.7469, 85.360),
                //     LatLng(27.7469, 85.361),
                //     LatLng(27.7469, 85.362),
                //     LatLng(27.7469, 85.363),
                //     LatLng(27.7449, 85.374),
                //     LatLng(27.7429, 85.355),
                //     LatLng(27.7469, 85.366),
                //     LatLng(27.7469, 85.367),
                //     LatLng(27.7469, 85.368),
                //     LatLng(27.7469, 85.369),
                //     LatLng(27.7469, 85.370),
                //     LatLng(27.7469, 85.371),
                //     LatLng(27.7469, 85.372),
                //     LatLng(27.7469, 85.373),
                //     LatLng(27.7469, 85.374),
                //   ],
                //   strokeWidth: 2,
                // );

                // controller.addPolylines(
                //   points: [
                //     LatLng(27.72, 85.459),
                //     LatLng(27.72, 85.574),
                //     LatLng(27.8469, 85.574),
                //     LatLng(27.8469, 85.459),
                //     LatLng(27.72, 85.459),
                //   ],
                //   strokeWidth: 3,
                //   color: Colors.blue,
                // );
                // controller.addMarkers(
                //   markers: [
                //     OSMMarker(LatLng(27.7469, 85.359)),
                //     OSMMarker(LatLng(27.7379, 85.369),
                //         child: const FlutterLogo()),
                //   ],
                // );

                // controller.addPolygons(
                //   points: [
                //     LatLng(27.65, 85.27),
                //     LatLng(27.65, 85.37),
                //     LatLng(27.75, 85.37),
                //     LatLng(27.75, 85.27),
                //   ],
                //   color: Colors.red.withOpacity(0.3),
                // );
                // controller.animateToPoint(
                //   LatLng(27.7469, 85.359),
                //   zoom: 13,
                // );

                OSMMapBox.downloadOffline(
                  eastNorthLatLng: LatLng(27.7469, 85.359),
                  southWestLatLng: LatLng(27.6574, 85.2775),
                  onProgress: (double p) {
                    setState(() => progress = p);
                  },
                );
              },
              child: const Icon(Icons.download),
            );
          } else {
            return Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${(progress * 100).toStringAsFixed(2)} %"),
                  LinearProgressIndicator(value: progress),
                ],
              ),
            );
          }
        }),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
