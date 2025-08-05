import 'package:flutter/material.dart';
import 'package:route_n_firebase/upload_itinerary_screen.dart';
import 'community_screen.dart';
import 'my_list_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SearchScreen(title: 'Anywhere Everywhere'),
                  ),
                );
              },
              child: const Text('Make your best plan for trip'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyListScreen()),
                );
              },
              child: const Text('Your Lists'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CommunityScreen()),
                );
              },
              child: const Text('Community'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UploadItineraryScreen(),
                  ),
                );
              },
              child: const Text('🛠 Upload Itinerary DB'),
            ),
          ],
        ),
      ),
    );
  }
}
