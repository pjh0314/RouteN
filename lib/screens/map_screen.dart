import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};
  CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(37.5665, 126.9780),
    zoom: 12,
  );

  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    final city = args?['city'] ?? 'Seoul';
    final type = args?['type'] ?? 'Alone';

    _fetchItineraries(city, type);
  }

  Future<void> _fetchItineraries(String city, String type) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      List<DocumentSnapshot> docs = [];

      if (type == 'All') {
        // 해당 도시의 모든 타입 문서 가져오기
        final querySnapshot = await firestore.collection('itineraries').get();
        docs = querySnapshot.docs
            .where((doc) => doc.id.startsWith('${city}_'))
            .toList();

        if (docs.isEmpty) {
          throw Exception('No itineraries found for $city');
        }
      } else {
        // 단일 문서만 가져오기
        final docId = '${city}_$type';
        final doc = await firestore.collection('itineraries').doc(docId).get();

        if (!doc.exists) {
          throw Exception('No itinerary found for $docId');
        }

        docs = [doc];
      }

      final Set<Marker> newMarkers = {};
      bool isFirstPlace = true;

      for (final doc in docs) {
        final data = doc.data() as Map<String, dynamic>?;
        final places = data?['places'] as List<dynamic>?;

        if (places == null || places.isEmpty) continue;

        for (final place in places) {
          final marker = Marker(
            markerId: MarkerId('${doc.id}_${place['name']}'),
            position: LatLng(place['lat'], place['lng']),
            infoWindow: InfoWindow(
              title: place['name'],
              snippet: place['description'],
            ),
          );
          newMarkers.add(marker);

          if (isFirstPlace) {
            _initialPosition = CameraPosition(
              target: LatLng(place['lat'], place['lng']),
              zoom: 12,
            );
            isFirstPlace = false;
          }
        }
      }

      setState(() {
        _markers.clear();
        _markers.addAll(newMarkers);
        _isLoading = false;
      });

      if (_controller != null && !_isLoading) {
        _controller!.animateCamera(
          CameraUpdate.newCameraPosition(_initialPosition),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading itinerary: $e')));
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
