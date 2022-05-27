import 'package:flutter/material.dart';
import 'package:osm_offline_download/utils/capitalize_string.dart';
import 'package:osm_offline_download/services/fetch_direction_service.dart';

showRouteSteps(
  BuildContext context, {
  List<OSMStep> steps = const [],
  Function(OSMStep)? onClick,
}) {
  showModalBottomSheet(
      context: context,
      barrierColor: Colors.black38,
      constraints: const BoxConstraints(maxWidth: 500),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (ctx) {
        return Container(
          width: 500,
          constraints: const BoxConstraints(maxWidth: 500),
          child: Builder(
            // enableDrag: false,
            // elevation: 0,
            // backgroundColor: Colors.white70,
            // onClosing: () => Navigator.pop(context),
            // constraints: const BoxConstraints(maxWidth: 500),
            builder: (context) {
              return Container(
                color: Colors.transparent,
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    AppBar(
                      automaticallyImplyLeading: false,
                      title: const Text("Steps"),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      foregroundColor: Colors.black,
                      centerTitle: false,
                      actions: [
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                          ),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: steps.length,
                        itemBuilder: (context, index) {
                          OSMStep step = steps[index];
                          return ListTile(
                            onTap: onClick == null
                                ? null
                                : () {
                                    Navigator.pop(context);
                                    onClick(step);
                                  },
                            leading: Text(
                              "${index + 1}.",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            title: Text(
                              step.pathName.toCapitalized(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "${step.type.toCapitalized()} ${step.mofifier}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Text("${step.distance}m"),
                            dense: true,
                            visualDensity: VisualDensity.compact,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      });
}
