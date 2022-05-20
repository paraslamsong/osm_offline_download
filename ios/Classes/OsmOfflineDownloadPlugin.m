#import "OsmOfflineDownloadPlugin.h"
#if __has_include(<osm_offline_download/osm_offline_download-Swift.h>)
#import <osm_offline_download/osm_offline_download-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "osm_offline_download-Swift.h"
#endif

@implementation OsmOfflineDownloadPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftOsmOfflineDownloadPlugin registerWithRegistrar:registrar];
}
@end
