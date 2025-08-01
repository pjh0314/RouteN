import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart'; // geocoding 패키지 import

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};
  CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(37.5665, 126.9780), // 서울 기본값
    zoom: 12,
  );

  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    final city = args?['city'] ?? 'Seoul';

    _setLocation(city);
  }

  Future<void> _setLocation(String city) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // geocoding 패키지의 locationFromAddress 사용
      final locations = await locationFromAddress(city);
      final loc = locations.first;

      if (!mounted) return;

      final targetLatLng = LatLng(loc.latitude, loc.longitude);

      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            markerId: MarkerId('target_marker'),
            position: targetLatLng,
            infoWindow: InfoWindow(title: city),
          ),
        );

        _initialPosition = CameraPosition(target: targetLatLng, zoom: 12);

        _isLoading = false;
      });

      if (_controller != null) {
        _controller!.animateCamera(
          CameraUpdate.newCameraPosition(_initialPosition),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _markers.clear();
        _markers.add(
          const Marker(
            markerId: MarkerId('default_marker'),
            position: LatLng(37.5665, 126.9780),
            infoWindow: InfoWindow(title: 'Seoul (Default)'),
          ),
        );
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location for $city: $e')),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;

    _controller!.animateCamera(
      CameraUpdate.newCameraPosition(_initialPosition),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Google Map')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Google Map')),
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        onMapCreated: _onMapCreated,
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
      ),
    );
  }
}
