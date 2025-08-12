import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:route_n_firebase/upload_itinerary_screen.dart';

import 'screens/my_list_screen.dart';
import 'screens/authentication/auth_screen.dart';
import 'screens/community_screen.dart';
import 'screens/home_screen.dart';
import 'screens/input_screen.dart';
import 'screens/map_screen.dart';
import 'screens/result_screen.dart';
import 'screens/search_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Route N',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: {
        '/home': (context) => HomeScreen(),
        '/search': (context) => SearchScreen(title: 'Anywhere Everywhere'),
        '/input': (context) => InputScreen(),
        '/result': (context) => ResultScreen(),
        '/map': (context) => MapScreen(),
        '/list': (context) => MyListScreen(),
        '/community': (context) => CommunityScreen(),
        '/upload': (context) => UploadItineraryScreen(),
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Something went wrong: ${snapshot.error}'),
              ),
            );
          }

          // 로그인 돼 있으면 Home, 아니면 Auth
          return snapshot.hasData ? const HomeScreen() : const AuthScreen();
        },
      ),
    );
  }
}
