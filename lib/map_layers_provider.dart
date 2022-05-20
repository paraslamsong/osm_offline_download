import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:osm_offline_download/map_tile_providers.dart';

TileLayerOptions tileProvider(BuildContext context, String appDirectory) =>
    TileLayerOptions(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      tileProvider: CachedTileProvider(),
      minZoom: 3,
      maxZoom: 16,
      fastReplace: false,
      backgroundColor: Colors.white,
      tileBuilder: (BuildContext context, Widget widget, Tile tile) {
        bool isError = tile.loadError;
        if (isError) {
          int z = tile.coords.z.toInt();
          int x = tile.coords.x.toInt();
          int y = tile.coords.y.toInt();
          String fileName = '${appDirectory}tile-$z-$x-$y.png';
          return Image.file(
            File(fileName),
            fit: BoxFit.fill,
          );
        } else {
          return Image(
            image: tile.imageProvider,
            fit: BoxFit.fill,
          );
        }
      },
    );
