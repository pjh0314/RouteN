import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<List<Marker>> getNearbyPlacesMarkers({
  required LatLng location,
  required String placeType,
  int radius = 1500,
}) async {
  final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  final url = Uri.parse(
    'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
    '?location=${location.latitude},${location.longitude}'
    '&radius=$radius'
    '&type=$placeType'
    '&key=$apiKey',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      final results = data['results'] as List<dynamic>;

      return results.map((place) {
        final loc = place['geometry']['location'];
        return Marker(
          markerId: MarkerId(place['place_id']),
          position: LatLng(loc['lat'], loc['lng']),
          infoWindow: InfoWindow(title: place['name']),
        );
      }).toList();
    } else {
      throw Exception('Places API error: ${data['status']}');
    }
  } else {
    throw Exception('Failed to fetch places');
  }
}
