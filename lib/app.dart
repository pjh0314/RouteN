import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:route_n_firebase/screens/home_screen.dart';

import 'screens/auth_screen.dart';
import 'screens/input_screen.dart';
import 'screens/map_screen.dart';
import 'screens/result_screen.dart';

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
      initialRoute: '/',
      routes: {
        //'/': (context) => AuthScreen(),
        '/home': (context) => HomeScreen(title: 'RouteN Demo Homepage'),
        '/input': (context) => InputScreen(),
        '/result': (context) => ResultScreen(),
        '/map': (context) => MapScreen(),
      },
      home: StreamBuilder<User?>(
        //made for screen moving by authentication status. //not sure how it works
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return HomeScreen(title: 'RouteN Demo Homepage');
          }
          return AuthScreen();
        },
      ),
    );
  }
}
