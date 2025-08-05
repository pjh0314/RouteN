import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadItineraryScreen extends StatelessWidget {
  const UploadItineraryScreen({super.key});

  final Map<String, List<Map<String, dynamic>>> itineraryData = const {
    'Seoul_Alone': [
      {
        'name': 'Bukchon Hanok Village',
        'description': 'Traditional village ideal for a peaceful solo walk.',
        'lat': 37.5826,
        'lng': 126.9830,
      },
      {
        'name': 'Seoul Forest',
        'description': 'A relaxing nature park with art and trails.',
        'lat': 37.5443,
        'lng': 127.0374,
      },
      {
        "name": "Ikseon-dong",
        "description": "Trendy area full of cozy cafes and boutiques.",
        "lat": 37.5721,
        "lng": 126.9917,
      },
    ],
    'New York_Alone': [
      {
        'name': 'Central Park',
        'description':
            'A large city park ideal for solo walks, reading, and people-watching.',
        'lat': 40.785091,
        'lng': -73.968285,
      },
      {
        'name': 'The Metropolitan Museum of Art',
        'description':
            'One of the world’s largest and finest art museums with diverse exhibits.',
        'lat': 40.779437,
        'lng': -73.963244,
      },
      {
        'name': 'High Line',
        'description':
            'An elevated linear park built on a former rail line, perfect for a solo afternoon stroll.',
        'lat': 40.7480,
        'lng': -74.0048,
      },
      {
        'name': 'Chelsea Market',
        'description':
            'A trendy indoor market with a variety of food vendors, perfect for a casual solo meal.',
        'lat': 40.7424,
        'lng': -74.0060,
      },
      {
        'name': 'Times Square',
        'description':
            'Iconic NYC spot with bright lights and energy, great for people-watching at night.',
        'lat': 40.7580,
        'lng': -73.9855,
      },
    ],
    'Tokyo_Couple': [
      {
        'name': 'Tokyo Tower',
        'description': 'Romantic view of the city from the iconic red tower.',
        'lat': 35.6586,
        'lng': 139.7454,
      },
      {
        'name': 'Odaiba Seaside Park',
        'description':
            'Waterfront area with shopping and night views for couples.',
        'lat': 35.6272,
        'lng': 139.7766,
      },
      {
        'name': 'TeamLab Planets',
        'description': 'Immersive art experience perfect for a couple date.',
        'lat': 35.6198,
        'lng': 139.8007,
      },
    ],
    'Tokyo_Friends': [
      {
        'name': 'Shibuya Crossing',
        'description': 'World-famous scramble crossing, fun with friends.',
        'lat': 35.6595,
        'lng': 139.7005,
      },
      {
        'name': 'Karaoke-kan Shibuya',
        'description': 'Popular karaoke chain great for groups.',
        'lat': 35.6592,
        'lng': 139.7004,
      },
      {
        'name': 'Takeshita Street',
        'description': 'Trendy shopping street ideal for group selfies.',
        'lat': 35.6703,
        'lng': 139.7020,
      },
    ],
    //여기에 추가해서 한번에 올리면 DB에 저장할수 있음 근데 아직 DB로 올리진 않음 ㅈㄴ귀찮아
  };

  Future<void> uploadAllItineraries(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;

    for (final entry in itineraryData.entries) {
      final docId = entry.key;
      final places = entry.value;

      await firestore.collection('itineraries').doc(docId).set({
        'places': places,
      });
      debugPrint('✅ Uploaded $docId');
    }

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Upload completed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Itinerary')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => uploadAllItineraries(context),
          child: const Text('Upload All Itineraries'),
        ),
      ),
    );
  }
}
