# Map Address Picker

[![Pub](https://img.shields.io/pub/v/map_address_picker.svg)](https://pub.dev/packages/map_address_picker)

A simple flutter plugin for picking users location using google maps. 


<p>
  <img src="https://raw.githubusercontent.com/athul-ain/map_address_picker/main/screenshots/Screenshot1.png" width=265/>
</p>

## Usage

To use this plugin, add `map_address_picker` as a dependency in your[ pubspec.yaml ](https://flutter.dev/docs/development/platform-integration/platform-channels) file.

## Getting Started

* Get an API key at <https://cloud.google.com/maps-platform/>.

* Enable Google Map SDK for each platform.
  * Go to [Google Developers Console](https://console.cloud.google.com/).
  * Choose the project that you want to enable Google Maps on.
  * Select the navigation menu and then select "Google Maps".
  * Select "APIs" under the Google Maps menu.
  * To enable Google Maps for Android, select "Maps SDK for Android" in the "Additional APIs" section, then select "ENABLE".
  * To enable Google Maps for iOS, select "Maps SDK for iOS" in the "Additional APIs" section, then select "ENABLE".
  * Make sure the APIs you enabled are under the "Enabled APIs" section.

For more details, see [Getting started with Google Maps Platform](https://developers.google.com/maps/gmp-get-started).

### Android

1. Set the `minSdkVersion` in `android/app/build.gradle`:

groovy
android {
    defaultConfig {
        minSdkVersion 20
    }
}


This means that app will only be available for users that run Android SDK 20 or higher.

2. Specify your API key in the application manifest `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...
  <application ...
    <meta-data android:name="com.google.android.geo.API_KEY"
               android:value="YOUR KEY HERE"/>
```

### iOS

Specify your API key in the application delegate `ios/Runner/AppDelegate.m`:

```objectivec
#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "GoogleMaps/GoogleMaps.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GMSServices provideAPIKey:@"YOUR KEY HERE"];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
@end
```


Or in your swift code, specify your API key in the application delegate `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR KEY HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```


### Sample Usage

```dart
import 'package:map_address_picker/map_address_picker.dart';

LocationResult result = await showLocationPicker(context);

```


### Example 

```dart
import 'package:flutter/material.dart';
import 'package:map_address_picker/map_address_picker.dart';
import 'package:map_address_picker/models/location_result.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Map Address Picker Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(),
      home: MyHomePage(title: 'Map Address Picker Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LocationResult? locationResult;
  _openLocationPicker() async {
    var _result = await showLocationPicker(
      context,
      mapType: MapType.terrain,
      requiredGPS: true,
      automaticallyAnimateToCurrentLocation: true,
      // initialCenter: LatLng(28.612925, 77.229512),
      // desiredAccuracy: LocationAccuracy.best,
      // title: "Pick your location",
      // layersButtonEnabled: true,
      // initialZoom: 16,
      //floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );

    setState(() {
      locationResult = _result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _openLocationPicker,
              child: Text("Pick Location"),
            ),
            Text(
              locationResult == null
                  ? "null"
                  : "${locationResult!.latLng!.latitude}\n${locationResult!.latLng!.longitude}",
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }
}

```


## Credits

The google map from [Flutter's](https://github.com/flutter) [google_maps_flutter](https://pub.dev/packages/google_maps_flutter) package

current location and permission from [BaseflowIT's](https://github.com/BaseflowIT) [flutter-geolocator](https://github.com/baseflowit/flutter-geolocator) package.

Inspired from [google_map_location_picker](https://github.com/humazed/google_map_location_picker) package.