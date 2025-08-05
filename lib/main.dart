import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

//for .env file
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'Credentials/.env');
  await Firebase.initializeApp();
  runApp(const MyApp());
}
