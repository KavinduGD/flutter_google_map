import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location _locationController = new Location();
  static const _gampaha = LatLng(7.09170687490022, 79.99484031067877);
  static const _colombo = LatLng(6.927079, 79.861244);
  static const _kalutara = LatLng(6.5833, 79.96);
  LatLng? _currentLocation = null;

  @override
  void initState() {
    super.initState();
    getLocationUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: _colombo,
            zoom: 15,
          ),
          markers: {
            const Marker(
              markerId: MarkerId('Gampaha'),
              icon: BitmapDescriptor.defaultMarker,
              position: _gampaha,
            ),
            const Marker(
              markerId: MarkerId('Kalutha'),
              icon: BitmapDescriptor.defaultMarker,
              position: _kalutara,
              infoWindow: InfoWindow(
                title: "Sydney",
                snippet: "Capital of New South Wales",
              ),
            ),
          }),
    );
  }

  Future<void> getLocationUpdate() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();

    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    _permissionGranted = await _locationController.hasPermission();

    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted == PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged.listen(
      (LocationData currentLocation) {
        if (currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          setState(() {
            _currentLocation = LatLng(
              currentLocation.latitude!,
              currentLocation.longitude!,
            );
            print(_currentLocation.toString());
          });
        }
      },
    );
  }
}
