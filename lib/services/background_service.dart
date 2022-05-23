import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_offline_download/services/download_map_service.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

void onStart(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  service.invoke("okay");
  service.on("osm_offline_map").listen(
    (event) async {
      if (event == null) return;
      if (event["action"] == "download") {
        double lat1 = event["lat1"];
        double lat2 = event["lat2"];
        double lon1 = event["lon1"];
        double lon2 = event["lon2"];
        await downloadMap(
          eastNorthLatLng: LatLng(lat1, lon1),
          southWestLatLng: LatLng(lat2, lon2),
          onProgress: (double progress) {
            service.invoke(
              "osm_offline_map_progress",
              {
                "action": "progress",
                "progress": progress,
              },
            );
            if (progress == 1.0) {
              service.stopSelf();
            }
          },
        );
        return;
      }
    },
  );
}

Future<bool> onIosBackground(service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}
