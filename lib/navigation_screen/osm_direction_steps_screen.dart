import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_offline_download/utils/capitalize_string.dart';
import 'package:osm_offline_download/services/fetch_direction_service.dart';
import 'package:osm_offline_download/osm_map_box.dart';
import 'package:osm_offline_download/location_points/ripple_point.dart';
import 'package:osm_offline_download/navigation_screen/show_route_bottom_sheet.dart';

showOSMDirectionStepScreen(
  BuildContext context, {
  required String appDirectory,
  required List<Polyline> polylines,
  required List<OSMStep> steps,
  required List<Marker> markers,
}) {
  showGeneralDialog(
    context: context,
    pageBuilder: (_, __, ___) {
      return OSMDirectionStepsScreen(
        appDirectory: appDirectory,
        polylines: polylines,
        steps: steps,
        markers: markers,
      );
    },
  );
}

class OSMDirectionStepsScreen extends StatefulWidget {
  final String appDirectory;
  final List<Polyline> polylines;
  final List<OSMStep> steps;
  final List<Marker> markers;

  const OSMDirectionStepsScreen({
    super.key,
    required this.appDirectory,
    required this.polylines,
    required this.steps,
    required this.markers,
  });

  @override
  State<OSMDirectionStepsScreen> createState() =>
      _OSMDirectionStepsScreenState();
}

class _OSMDirectionStepsScreenState extends State<OSMDirectionStepsScreen>
    with TickerProviderStateMixin {
  final OSMMapOfflineController osmMapOfflineController =
      OSMMapOfflineController();

  Widget? bottomInformationMarker;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NAVIGATION"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          OSMMapBox(
            controller: osmMapOfflineController,
            center: LatLng(
              widget.steps.first.lat,
              widget.steps.first.lng,
            ),
            zoom: 15,
            polylines: widget.polylines,
            locationTrack: false,
            enableLocation: false,
            markers: widget.markers,
          ),
          Positioned(
            bottom: 15,
            width: min(MediaQuery.of(context).size.width, 500),
            child: Builder(builder: (context) {
              if (bottomInformationMarker == null) {
                return const SizedBox();
              } else {
                return bottomInformationMarker!;
              }
            }),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.directions),
        onPressed: () {
          showRouteSteps(
            context,
            steps: widget.steps,
            onClick: (OSMStep step) => addPathInformation(context, step: step),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void addPathInformation(BuildContext context, {required OSMStep step}) {
    osmMapOfflineController.removePolyline(1);
    osmMapOfflineController.addPolylines(
      points: step.points,
      color: Colors.yellow,
      strokeWidth: 10,
    );
    bottomInformationMarker = Container(
      margin: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 40),
      // height: 60,
      padding: const EdgeInsets.all(10),
      constraints: const BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black45, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Material(
              child: IconButton(
                padding: const EdgeInsets.all(3),
                iconSize: 20,
                onPressed: () {
                  // showCupertinoDialog(
                  //   context: context,
                  //   builder: (ctx) => CupertinoAlertDialog(
                  //     title: Text(step.pathName),
                  //     content: Column(
                  //       children: [
                  //         Text(
                  //           "${step.type.toCapitalized()} ${step.mofifier}",
                  //         ),
                  //         Text(
                  //           "Distance: ${step.distance.toStringAsFixed(2)} meters",
                  //         ),
                  //       ],
                  //     ), d
                  //     actions: [
                  //       CupertinoDialogAction(
                  //         child: const Text("Ok"),
                  //         onPressed: () =>
                  //             setState(() => bottomInformationMarker = null),
                  //       ),
                  //     ],
                  //   ),
                  // );
                },
                icon: const Icon(CupertinoIcons.share),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.pathName.toCapitalized(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${step.type.toCapitalized()} ${step.mofifier.toCapitalized()}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Material(
              child: IconButton(
                padding: const EdgeInsets.all(3),
                iconSize: 20,
                onPressed: () {
                  osmMapOfflineController.removePolyline(1);
                  setState(() => bottomInformationMarker = null);
                },
                icon: const Icon(Icons.close),
              ),
            ),
          ),
        ],
      ),
    );

    setState(() => bottomInformationMarker = bottomInformationMarker);

    osmMapOfflineController.animateToPoint(
      LatLng(step.lat, step.lng),
    );
  }
}
