import 'dart:async';

import 'package:location/location.dart';

class LocationNotifier {
  Location location = Location();
  late bool serviceEnabled;
  late PermissionStatus permissionGranted;
  StreamSubscription? streamSubscription;
  listenToLocation(Function(LocationData) onLocationChanged) async {
    if (streamSubscription == null) {
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }
      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }
      streamSubscription =
          location.onLocationChanged.listen((LocationData currentLocation) {
        onLocationChanged(currentLocation);
      });
    } else {
      streamSubscription!.resume();
    }
  }

  stopListening() {
    if (streamSubscription != null) streamSubscription!.pause();
  }
}
