import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_offline_download/providers/api_validity_provider.dart';
import 'package:osm_offline_download/utils/api_overlay.dart';
import 'package:osm_offline_download/utils/capitalize_string.dart';
import 'package:osm_offline_download/services/fetch_direction_service.dart';
import 'package:osm_offline_download/osm_map_box.dart';
import 'package:osm_offline_download/navigation_screen/show_route_bottom_sheet.dart';
import 'package:osm_offline_download/utils/unit_convertor.dart';
import 'package:provider/provider.dart';

showOSMDirectionStepScreen(
  BuildContext context, {
  required String appDirectory,
  required List<Polyline> polylines,
  required List<OSMStep> steps,
  required List<Marker> markers,
  Color? routeColor,
  Color? highlightColor,
}) {
  routeColor = routeColor ?? Colors.red.withOpacity(0.7);
  highlightColor = highlightColor ?? Colors.yellow.withOpacity(0.7);
  showGeneralDialog(
    context: context,
    pageBuilder: (_, __, ___) {
      return OSMDirectionStepsScreen(
        appDirectory: appDirectory,
        polylines: polylines,
        steps: steps,
        markers: markers,
        routeColor: routeColor!,
        highlightColor: highlightColor!,
      );
    },
  );
}

class OSMDirectionStepsScreen extends StatefulWidget {
  final String appDirectory;
  final List<Polyline> polylines;
  final List<OSMStep> steps;
  final List<Marker> markers;
  final Color routeColor, highlightColor;

  const OSMDirectionStepsScreen({
    super.key,
    required this.appDirectory,
    required this.polylines,
    required this.steps,
    required this.markers,
    required this.routeColor,
    required this.highlightColor,
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

  bool showBottomInformation = false;
  final controller = PageController(initialPage: 0);

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
            child: AnimatedScale(
              scale: showBottomInformation ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 140,
                    child: PageView.builder(
                      itemCount: widget.steps.length,
                      controller: controller,
                      allowImplicitScrolling: true,
                      onPageChanged: (index) {
                        addPathInformation(context, step: widget.steps[index]);
                      },
                      itemBuilder: (context, index) {
                        return _bottomInfo(context, step: widget.steps[index]);
                      },
                    ),
                  ),
                  Visibility(
                    visible: Platform.isMacOS ||
                        Platform.isWindows ||
                        Platform.isLinux,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton(
                          mini: true,
                          onPressed: () {
                            controller.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          },
                          child: const Icon(
                            Icons.arrow_back_ios,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 30),
                        FloatingActionButton(
                          onPressed: () {
                            controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          },
                          mini: true,
                          child: const RotatedBox(
                            quarterTurns: 2,
                            child: Icon(
                              Icons.arrow_back_ios,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => MapValidity(context),
            child: const APIValidityOverlay(),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: AnimatedScale(
          scale: !showBottomInformation ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: FloatingActionButton(
            child: const Icon(Icons.directions),
            onPressed: () {
              showRouteSteps(
                context,
                steps: widget.steps,
                onClick: (OSMStep step) =>
                    addPathInformation(context, step: step),
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  void addPathInformation(BuildContext context, {required OSMStep step}) {
    setState(() => showBottomInformation = true);
    osmMapOfflineController.removePolyline(1);
    osmMapOfflineController.addPolylines(
      points: step.points,
      color: widget.highlightColor,
      strokeWidth: 10,
    );
    osmMapOfflineController.animateToPoint(LatLng(step.lat, step.lng));

    debugPrint("Index  ${widget.steps.indexOf(step)}");
    if (showBottomInformation) {
      controller.jumpToPage(widget.steps.indexOf(step));
    }
  }

  Widget _bottomInfo(BuildContext context, {required OSMStep step}) {
    return Container(
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
                  showCupertinoDialog(
                    context: context,
                    builder: (ctx) => CupertinoAlertDialog(
                      title: Text(step.pathName),
                      content: Column(
                        children: [
                          Text(
                            "${step.type.toCapitalized()} ${step.mofifier}",
                          ),
                          Text(
                            "Length: ${step.distance.inDistance()}",
                          ),
                        ],
                      ),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text("Ok"),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
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
                  setState(() => showBottomInformation = false);
                  osmMapOfflineController.removePolyline(1);
                  // setState(() => bottomInformationMarker = null);
                },
                icon: const Icon(Icons.close),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
