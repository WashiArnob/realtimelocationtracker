import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  late StreamSubscription<Position> positionStream;

  // Initial camera position
  CameraPosition initialPosition = CameraPosition(
    target: LatLng(23.8103, 90.4125), // Default: Dhaka
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  Future<void> _startLocationUpdates() async {
    // Check and request location permissions
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    // Start listening to location updates
    positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      LatLng currentLocation = LatLng(position.latitude, position.longitude);

      // Update marker and polyline
      setState(() {
        markers.add(
          Marker(
            markerId: MarkerId('currentLocation'),
            position: currentLocation,
            infoWindow: InfoWindow(
              title: 'My Current Location',
              snippet: 'Lat: ${position.latitude}, Lng: ${position.longitude}',
            ),
          ),
        );

        polylineCoordinates.add(currentLocation);

        polylines.add(Polyline(
          polylineId: PolylineId('route'),
          points: polylineCoordinates,
          color: Colors.blue,
          width: 5,
        ));

        // Move camera to the current location
        mapController.animateCamera(
          CameraUpdate.newLatLng(currentLocation),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-Time Location Tracker'),
      ),
      body: GoogleMap(
        initialCameraPosition: initialPosition,
        markers: markers,
        polylines: polylines,
        myLocationEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
    );
  }
}
