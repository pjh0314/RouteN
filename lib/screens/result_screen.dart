import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart'; // city -> coordinates

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  List<LatLng> _locations = [];
  late CameraPosition _initialCamera;
  bool _isLoadingLocation = true;

  Future<void> _saveTravelPlan({
    required String city,
    required String start,
    required String end,
    required String theme,
    List<LatLng>? locations,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Need to Sign In')));
      return;
    }
    try {
      final docData = {
        'city': city,
        'startDate': start,
        'endDate': end,
        'theme': theme,
        'createdAt': FieldValue.serverTimestamp(),
      };
      if (locations != null && locations.isNotEmpty) {
        // 위치 배열을 리스트로 저장
        docData['locations'] = locations
            .map((loc) => {'lat': loc.latitude, 'lng': loc.longitude})
            .toList();
      }
      await _fireStore
          .collection('users')
          .doc(user.uid)
          .collection('course')
          .add(docData);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The Travel Route is saved')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error has occured in Saving: $e')),
      );
    }
  }

  Future<void> _resolveCityToLatLng(String city) async {
    try {
      final locations = await locationFromAddress(city);
      if (locations.isNotEmpty) {
        final first = locations.first;
        setState(() {
          _locations = [LatLng(first.latitude, first.longitude)];
          _initialCamera = CameraPosition(target: _locations.first, zoom: 12);
          _isLoadingLocation = false;
        });
      } else {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String city = args['city'];
    if (_isLoadingLocation) {
      _resolveCityToLatLng(city);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final String city = args['city'];
    final PickerDateRange period = args['period'];
    final String theme = args['theme'];

    final start = DateFormat('yyyy-MM-dd').format(period.startDate!);
    final end = period.endDate != null
        ? DateFormat('yyyy-MM-dd').format(period.endDate!)
        : '';

    // _locations 리스트를 Set<Marker>로 변환
    Set<Marker> markers = _locations.asMap().entries.map((entry) {
      final idx = entry.key;
      final loc = entry.value;
      return Marker(
        markerId: MarkerId('marker_$idx'),
        position: loc,
        infoWindow: InfoWindow(
          title: idx == 0 ? 'Start: $city' : 'Place #$idx',
        ),
      );
    }).toSet();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
        title: const Text('Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('City: $city', style: const TextStyle(fontSize: 18)),
            Text('Period: $start ~ $end', style: const TextStyle(fontSize: 18)),
            Text('Theme: $theme', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoadingLocation
                  ? const Center(child: CircularProgressIndicator())
                  : _locations.isEmpty
                  ? const Center(child: Text('Could not resolve city location'))
                  : GoogleMap(
                      initialCameraPosition: _initialCamera,
                      markers: markers,
                      polylines: {
                        Polyline(
                          polylineId: const PolylineId('route'),
                          points: _locations,
                          color: Colors.blue,
                          width: 4,
                        ),
                      },
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: true,
                      onTap: (LatLng tappedLoc) {
                        // 지도 탭 시 위치 추가
                        setState(() {
                          _locations.add(tappedLoc);
                        });
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _saveTravelPlan(
            city: city,
            start: start,
            end: end,
            theme: theme,
            locations: _locations,
          );
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
