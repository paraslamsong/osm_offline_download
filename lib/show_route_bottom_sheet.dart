import 'package:flutter/material.dart';
import 'package:osm_offline_download/fetch_direction_service.dart';

showRouteSteps(
  BuildContext context, {
  List<OSMStep> steps = const [],
  Function(OSMStep)? onClick,
}) {
  showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return BottomSheet(
          enableDrag: false,
          backgroundColor: Colors.transparent,
          onClosing: () => Navigator.pop(context),
          builder: (context) {
            return Center(
              child: ConstrainedBox(
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
                              title: Text(
                                step.pathName.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "${step.type} ${step.mofifier}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: Text("${step.distance}M"));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      });
}
