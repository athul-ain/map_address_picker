library map_address_picker;

export 'package:google_maps_flutter_platform_interface/src/types/ui.dart';
export 'package:google_maps_flutter_platform_interface/src/types/location.dart';
export 'package:google_maps_flutter_platform_interface/src/types/ui.dart';
export 'package:google_maps_flutter_platform_interface/src/types/location.dart';
export 'package:geolocator_platform_interface/src/enums/location_accuracy.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_address_picker/pages/location_picker.dart';
import 'models/location_result.dart';

/// Returns a [LatLng] object of the location that was picked.
///
/// [initialCenter] The geographical location that the camera is pointing
/// until the current user location is know if you want to change this
/// set [automaticallyAnimateToCurrentLocation] to false.
///
///
Future<LocationResult?> showLocationPicker(
  BuildContext context, {
  MapType mapType = MapType.normal,
  LatLng initialCenter = const LatLng(28.612925, 77.229512),
  bool requiredGPS = false,
  LocationAccuracy desiredAccuracy = LocationAccuracy.best,
  bool automaticallyAnimateToCurrentLocation = true,
  String? title,
  bool layersButtonEnabled = true,
  double initialZoom = 16,
  FloatingActionButtonLocation floatingActionButtonLocation =
      FloatingActionButtonLocation.endFloat,
}) async {
  final results = await Navigator.of(context).push(
    MaterialPageRoute<dynamic>(
      builder: (BuildContext context) {
        return LocationPickerPage(
          mapType: mapType,
          initialCenter: initialCenter,
          autoAnimateToCurrentLocation: automaticallyAnimateToCurrentLocation,
          desiredAccuracy: desiredAccuracy,
          requiredGPS: requiredGPS,
          title: title,
          layersButtonEnabled: layersButtonEnabled,
          initialZoom: initialZoom,
          floatingActionButtonLocation: floatingActionButtonLocation,
        );
      },
    ),
  );

  if (results != null && results.containsKey('location')) {
    return results['location'];
  } else {
    return null;
  }
}
