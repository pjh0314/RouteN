import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      },
      home: StreamBuilder<User?>(
        //made for screen moving by authentication status. //not sure how it works
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(body: Center(child: Text('Something went wrong')));
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return snapshot.hasData ? const HomeScreen() : const AuthScreen();
        },
      ),
    );
  }
}
