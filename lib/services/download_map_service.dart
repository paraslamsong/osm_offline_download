import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_offline_download/utils/api_calls.dart';
import 'package:osm_offline_download/utils/singleton_class.dart';
import 'package:path_provider/path_provider.dart';

class Tile {
  late String imageUrl;
  late int x, y, z;
  Tile.fromMap(map) {
    imageUrl = map['url'];
    x = map['x'];
    y = map['y'];
    z = map['z'];
  }
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
  Function(Object)? onError,
  Function()? onDownloadCompleted,
}) async {
  String appDocumentsPath = await getTileDirectoryPath();
  double x1 = southWestLatLng.latitude;
  double y1 = southWestLatLng.longitude;
  double x2 = eastNorthLatLng.latitude;
  double y2 = eastNorthLatLng.longitude;

  Future<void> saveTile(Tile tile) async {
    String imageUrl = tile.imageUrl;
    String filePath =
        '$appDocumentsPath/tile-${tile.z}-${tile.x}-${tile.y}.png';
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

  try {
    Response response = await API().get(
        "download-map/?x1=$x1&y1=$y1&x2=$x2&y2=$y2&API_KEY=${Constants().apiKey}&APP_KEY=${Constants().appId}");
    if (response.statusCode == 200) {
      log(response.data.toString());
      var tiles = response.data['data'];
      int index = 0;
      int total = tiles.length;
      for (var tile in tiles) {
        if (onProgress != null) {
          onProgress(index / total);
        }
        index++;
        await saveTile(Tile.fromMap(tile));
      }
      if (onProgress != null) {
        onProgress(1.0);
        onDownloadCompleted!();
      }
    } else {
      onError!(Error.safeToString(response.data['data']));
    }
  } catch (error) {
    onError!(error);
  }
}
