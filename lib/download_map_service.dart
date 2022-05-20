import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
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
    await NetworkAssetBundle(Uri.parse(imageUrl)).load("").then((imageData) {
      String filePath = appDocumentsPath + '/tile-$z-$x-$y.png';
      File file = File(filePath);
      file.writeAsBytes(imageData.buffer.asInt8List());
    }).onError((error, stackTrace) {
      debugPrint(error.toString());
      return;
    });
  }

  List<TileXYZ> tiles = [];
  // return;
  for (int zoom = 2; zoom <= 16; zoom++) {
    TileXYZ southwestTile = getTileFromLatLng(southWestLatLng, zoom);
    // southwestTile.southwest(zoom);
    TileXYZ northeastTile = getTileFromLatLng(eastNorthLatLng, zoom);
    // northeastTile.northeast(zoom);

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
