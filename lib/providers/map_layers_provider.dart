import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:osm_offline_download/providers/map_tile_providers.dart';
import 'package:osm_offline_download/utils/singleton_class.dart';

TileLayerOptions tileProvider(BuildContext context, String appDirectory) =>
    TileLayerOptions(
      urlTemplate:
          '${Constants.hostUrl}tiles/?z={z}&x={x}&y={y}&API_KEY=${Constants().apiKey}&APP_KEY=${Constants().appId}',
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
          // If cannot fetch from remote and downloaded tiles exist, display local saved tile
          return Image.file(
            File(fileName),
            fit: BoxFit.fill,
          );
        } else {
          // If fetched from remote
          return Image(
            image: tile.imageProvider,
            fit: BoxFit.fill,
          );
        }
      },
    );
