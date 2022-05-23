import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_offline_download/services/background_service.dart';
import 'package:path_provider/path_provider.dart';

class TileXYZ {
  late int x, y, z;
  TileXYZ(this.x, this.y, this.z);
}

Future<String> getTileDirectoryPath() async {
  Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();

  final Directory appDocDirFolder =
      Directory("${appDocumentsDirectory.path}/MapTiles/");
  if (await appDocDirFolder.exists()) {
    String appDocumentsPath = appDocDirFolder.path;
    return appDocumentsPath;
  } else {
    final Directory appDocDirNewFolder =
        await appDocDirFolder.create(recursive: true);
    String appDocumentsPath = appDocDirNewFolder.path;
    return appDocumentsPath;
  }
}

Future<void> downloadMap({
  required LatLng eastNorthLatLng,
  required LatLng southWestLatLng,
  Function(double)? onProgress,
}) async {
  String appDocumentsPath = await getTileDirectoryPath();

  TileXYZ getTileFromLatLng(LatLng latlng, int zoom) {
    double latRad = latlng.latitude * pi / 180;
    num n = pow(2, zoom);
    int xtile = n * (latlng.longitude + 180) ~/ 360;
    int ytile =
        ((n / 2) * (1 - log(tan(latRad) + 1 / (cos(latRad))) / pi)).toInt();
    return TileXYZ(xtile, ytile, zoom);
  }

  List<TileXYZ> getTilesList(TileXYZ northeast, TileXYZ southwest) {
    List<TileXYZ> tilesList = [];
    int minX = min(southwest.x, northeast.x);
    int maxX = max(southwest.x, northeast.x);

    int minY = min(northeast.y, southwest.y);
    int maxY = max(northeast.y, southwest.y);

    for (int i = minX; i <= maxX; i++) {
      for (int j = minY; j <= maxY; j++) {
        tilesList.add(TileXYZ(i, j, northeast.z));
      }
    }
    return tilesList;
  }

  Future<void> saveTile(int x, int y, int z) async {
    String imageUrl = 'https://tile.openstreetmap.org/$z/$x/$y.png';
    String filePath = '$appDocumentsPath/tile-$z-$x-$y.png';
    File file = File(filePath);
    if (!file.existsSync()) {
      await NetworkAssetBundle(Uri.parse(imageUrl)).load("").then((imageData) {
        file.writeAsBytes(imageData.buffer.asInt8List());
      }).onError((error, stackTrace) {
        debugPrint(error.toString());
        return;
      });
    }
  }

  List<TileXYZ> tiles = [];
  for (int zoom = 2; zoom <= 16; zoom++) {
    TileXYZ southwestTile = getTileFromLatLng(southWestLatLng, zoom);
    TileXYZ northeastTile = getTileFromLatLng(eastNorthLatLng, zoom);
    List<TileXYZ> zoomTiles = getTilesList(northeastTile, southwestTile);

    for (var zoomtile in zoomTiles) {
      tiles.add(zoomtile);
    }
  }
  int index = 0;
  int total = tiles.length;
  for (var tile in tiles) {
    if (onProgress != null) {
      onProgress(index / total);
    }
    index++;
    await saveTile(tile.x, tile.y, tile.z);
  }
  if (onProgress != null) {
    onProgress(1.0);
  }
}

downloadService({
  required LatLng eastNorthLatLng,
  required LatLng southWestLatLng,
  Function(double)? onProgress,
}) async {
  await initializeService().then((value) {
    startService(
      eastNorthLatLng: eastNorthLatLng,
      southWestLatLng: southWestLatLng,
      onProgress: onProgress,
    );
  });
  if (await FlutterBackgroundService().isRunning()) {
    startService(
      eastNorthLatLng: eastNorthLatLng,
      southWestLatLng: southWestLatLng,
      onProgress: onProgress,
    );
  } else {
    await FlutterBackgroundService().startService().then((value) {
      startService(
        eastNorthLatLng: eastNorthLatLng,
        southWestLatLng: southWestLatLng,
        onProgress: onProgress,
      );
    });
  }
}

startService({
  required LatLng eastNorthLatLng,
  required LatLng southWestLatLng,
  Function(double)? onProgress,
}) {
  FlutterBackgroundService().invoke("osm_offline_map", {
    "action": "download",
    "lat1": eastNorthLatLng.latitude,
    "lon1": eastNorthLatLng.longitude,
    "lat2": southWestLatLng.latitude,
    "lon2": southWestLatLng.longitude,
  });
  FlutterBackgroundService().on('osm_offline_map_progress').listen(
        (event) {
          if (event == null) return;
          if (event['action'] == "progress") {
            if (onProgress != null) {
              onProgress(event['progress'] + 0.0);
            }
          }
        },
        onDone: () {},
        onError: (error) {
          debugPrint(error.toString());
        },
      );
}
