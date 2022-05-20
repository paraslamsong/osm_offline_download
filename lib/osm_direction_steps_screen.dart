import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_offline_download/fetch_direction_service.dart';
import 'package:osm_offline_download/osm_map_box.dart';
import 'package:osm_offline_download/ripple_point.dart';
import 'package:osm_offline_download/show_route_bottom_sheet.dart';

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("NAVIGATION")),
      body: OSMMapBox(
        controller: osmMapOfflineController,
        center: LatLng(
          widget.steps.first.lat,
          widget.steps.first.lng,
        ),
        zoom: 15,
        polylines: widget.polylines,
        locationTrack: true,
        enableLocation: true,
        markers: widget.markers,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.directions),
        onPressed: () {
          showRouteSteps(
            context,
            steps: widget.steps,
            onClick: (OSMStep step) {
              List<OSMMarker> markers = [
                OSMMarker(
                  widget.markers.first.point,
                  rotate: true,
                  height: 20,
                  width: 20,
                  child: const PinPoint(color: Colors.red),
                ),
                OSMMarker(
                  widget.markers.last.point,
                  rotate: true,
                  height: 20,
                  width: 20,
                  child: const PinPoint(color: Colors.teal),
                ),
              ];

              osmMapOfflineController.addMarkers(markers: markers);
              osmMapOfflineController.addMarkers(
                markers: [
                  ...markers,
                  OSMMarker(
                    LatLng(step.lat, step.lng),
                    rotate: true,
                    width: 160,
                    height: 100,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 40),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              step.pathName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () => osmMapOfflineController.addMarkers(
                              markers: markers,
                            ),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
              osmMapOfflineController.animateToPoint(
                LatLng(step.lat, step.lng),
              );
            },
          );
        },
      ),
    );
  }
}
