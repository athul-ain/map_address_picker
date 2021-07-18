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

    if (mounted) setState(() => locationResult = _result);
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
