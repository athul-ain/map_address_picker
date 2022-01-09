import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_address_picker/models/location_result.dart';

class LocationPickerPage extends StatefulWidget {
  final String? title;
  final MapType mapType;
  final LatLng initialCenter;
  final LocationAccuracy desiredAccuracy;
  final bool requiredGPS;
  final bool autoAnimateToCurrentLocation;
  final bool layersButtonEnabled;
  final double initialZoom;
  final FloatingActionButtonLocation floatingActionButtonLocation;
  const LocationPickerPage({
    Key? key,
    required this.mapType,
    required this.initialCenter,
    required this.desiredAccuracy,
    required this.requiredGPS,
    required this.autoAnimateToCurrentLocation,
    this.title,
    required this.layersButtonEnabled,
    required this.initialZoom,
    required this.floatingActionButtonLocation,
  }) : super(key: key);

  @override
  _LocationPickerPageState createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  Completer<GoogleMapController> mapController = Completer();
  Position? _currentPosition;
  LatLng? _lastMapPosition;
  MapType? selectedMapType;
  Set<Marker> _markers = {};

  // this also checks for location permission.
  Future<void> _initCurrentLocation() async {
    await _checkGeolocationPermission();
    Position? currentPosition;
    try {
      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: widget.desiredAccuracy,
      );
    } catch (e) {
      currentPosition = null;
      print(e);
    }

    if (mounted && currentPosition != null)
      setState(() => _currentPosition = currentPosition);
    if (currentPosition != null || _currentPosition != null) {
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId("defaultMarker"),
          position: currentPosition == null
              ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
              : LatLng(currentPosition.latitude, currentPosition.longitude),
        ));
      });
    }

    if (_currentPosition != null)
      await moveToCurrentLocation(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude));
  }

  Future moveToCurrentLocation(LatLng currentLocation) async {
    final controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: currentLocation, zoom: widget.initialZoom),
    ));
  }

  @override
  void initState() {
    if (widget.autoAnimateToCurrentLocation && !widget.requiredGPS)
      _initCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (selectedMapType == null) selectedMapType = widget.mapType;

    if (widget.requiredGPS) {
      _checkGeolocationPermission();
      if (_currentPosition == null && widget.autoAnimateToCurrentLocation)
        _initCurrentLocation();
    }

    bool darkIcons = ((selectedMapType == MapType.hybrid) ||
        (selectedMapType == MapType.satellite));

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              darkIcons ? Brightness.light : Brightness.dark,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: Theme.of(context).iconTheme.copyWith(
              color: darkIcons ? Colors.white : null,
            ),
        title: Text(widget.title ?? ""),
        toolbarTextStyle: Theme.of(context)
            .textTheme
            .copyWith(
              headline6: TextStyle(
                color: darkIcons ? null : Colors.black,
              ),
            )
            .bodyText2,
        titleTextStyle: Theme.of(context)
            .textTheme
            .copyWith(
              headline6: TextStyle(
                color: darkIcons ? null : Colors.black,
              ),
            )
            .headline6,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          GoogleMap(
            mapType: selectedMapType ?? MapType.normal,
            initialCameraPosition: CameraPosition(
              target: widget.initialCenter,
              zoom: widget.initialZoom,
            ),
            onMapCreated: (GoogleMapController controller) {
              mapController.complete(controller);

              _markers.add(Marker(
                markerId: MarkerId("defaultMarker"),
                position: widget.initialCenter,
              ));

              _lastMapPosition = widget.initialCenter;
            },
            markers: _markers,
            onTap: (argument) {
              setState(() {
                _markers.add(Marker(
                  markerId: MarkerId("defaultMarker"),
                  position: argument,
                ));
              });
            },
            onLongPress: (argument) {
              setState(() {
                _markers.add(Marker(
                  markerId: MarkerId("defaultMarker"),
                  position: argument,
                ));
              });
            },
            onCameraIdle: () async {
              print("onCameraIdle#_lastMapPosition = $_lastMapPosition");
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            padding: EdgeInsets.only(
              bottom: kBottomNavigationBarHeight + 30,
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.only(top: kToolbarHeight + 30, right: 8),
            child: Column(
              children: [
                if (widget.layersButtonEnabled)
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        if (selectedMapType == MapType.normal) {
                          selectedMapType = MapType.hybrid;
                        } else {
                          selectedMapType = MapType.normal;
                        }
                      });
                    },
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    mini: true,
                    child: const Icon(Icons.layers),
                    heroTag: "layers",
                  ),
                if (widget.requiredGPS)
                  FloatingActionButton(
                    onPressed: _initCurrentLocation,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    mini: true,
                    child: const Icon(Icons.gps_fixed),
                    heroTag: "layers2",
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_forward),
        onPressed: () {
          Navigator.of(context).pop(
            {'location': LocationResult(latLng: _lastMapPosition)},
          );
        },
      ),
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
    );
  }

  var dialogOpen;

  Future _checkGeolocationPermission() async {
    await Geolocator.requestPermission();
    final geolocationStatus = await Geolocator.checkPermission();
    print("geolocationStatus = $geolocationStatus");

    if (geolocationStatus == LocationPermission.denied && dialogOpen == null) {
      dialogOpen = _showDeniedDialog();
    } else if (geolocationStatus == LocationPermission.deniedForever &&
        dialogOpen == null) {
      dialogOpen = _showDeniedForeverDialog();
    } else if (geolocationStatus == LocationPermission.whileInUse ||
        geolocationStatus == LocationPermission.always) {
      print('GeolocationStatus.granted');

      if (dialogOpen != null) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogOpen = null;
      }
    }
  }

  Future _showDeniedDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context, rootNavigator: true).pop();
            return true;
          },
          child: AlertDialog(
            title: Text('Access to location denied'),
            content: Text('Allow access to the location services.'),
            actions: <Widget>[
              TextButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  _initCurrentLocation();
                  dialogOpen = null;
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future _showDeniedForeverDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context, rootNavigator: true).pop();
            return true;
          },
          child: AlertDialog(
            title: Text(
              'Access to location permanently denied',
            ),
            content: Text(
              'Allow access to the location services for this App using the device settings.',
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  Geolocator.openAppSettings();
                  dialogOpen = null;
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
