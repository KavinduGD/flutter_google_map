import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location_tracker/consts.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location _locationController = new Location();

  final Completer<GoogleMapController> _mapcontroller =
      Completer<GoogleMapController>();

  static const _gampaha = LatLng(7.09170687490022, 79.99484031067877);
  static const _colombo = LatLng(7.086147758959452, 80.0335855548613);

  LatLng? _currentLocation = null;

  Map<PolylineId, Polyline> polygonlines = {};

  @override
  void initState() {
    super.initState();
    getLocationUpdate().then(
      (_) => {
        getPolygonPoints().then(
          (coordinates) => {
            generatePollyLineFormPoints(coordinates),
          },
        )
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentLocation == null
          ? const Center(
              child: Text("Loding ......"),
            )
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapcontroller.complete(controller);
              },
              //mapType: MapType.satellite,
              initialCameraPosition: const CameraPosition(
                target: _colombo,
                zoom: 13,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('Your Location'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _currentLocation!,
                  infoWindow: InfoWindow(
                    title: "Your Location",
                  ),
                ),
                const Marker(
                  markerId: MarkerId('Gampaha'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _gampaha,
                  infoWindow: InfoWindow(
                    title: "Gampaha",
                    snippet: "Gampaha is a District in Sri Lanka",
                  ),
                ),
                const Marker(
                  markerId: MarkerId('Colombo'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _colombo,
                  infoWindow: InfoWindow(
                    title: "Colombo",
                    snippet: "Colombo is a District in Sri Lanka",
                  ),
                ),
              },
              polylines: Set<Polyline>.of(polygonlines.values)),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapcontroller.future;
    CameraPosition _newCameraPosition = CameraPosition(target: pos, zoom: 13);
    await controller.animateCamera(CameraUpdate.newCameraPosition(
      _newCameraPosition,
    ));
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
            _cameraToPosition(_currentLocation!);
          });
        }
      },
    );
  }

  Future<List<LatLng>> getPolygonPoints() async {
    List<LatLng> polygonPoints = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      GOOGLE_MAPS_API_KEY,
      PointLatLng(_gampaha.latitude, _gampaha.longitude),
      PointLatLng(_colombo.latitude, _colombo.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polygonPoints.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print("No Points");
    }

    return polygonPoints;
  }

  void generatePollyLineFormPoints(List<LatLng> polylineCorrdinates) async {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCorrdinates,
      width: 8,
    );

    setState(() {
      polygonlines[id] = polyline;
    });
  }
}
