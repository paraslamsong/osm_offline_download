//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import location
import osm_offline_download
import package_info_plus_macos
import path_provider_macos
import sqflite

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  LocationPlugin.register(with: registry.registrar(forPlugin: "LocationPlugin"))
  OsmOfflineDownloadPlugin.register(with: registry.registrar(forPlugin: "OsmOfflineDownloadPlugin"))
  FLTPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FLTPackageInfoPlusPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  SqflitePlugin.register(with: registry.registrar(forPlugin: "SqflitePlugin"))
}
