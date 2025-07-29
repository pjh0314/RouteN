import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> _saveTravelPlan({
    required String city,
    required String start,
    required String end,
    required String theme,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Need to Sign In')));
      return;
    }
    try {
      await _fireStore
          .collection('users')
          .doc(user.uid)
          .collection('course')
          .add({
            'city': city,
            'startDate': start,
            'endDate': end,
            'theme': theme,
            'createdAt': FieldValue.serverTimestamp(), //save when it was saved
          });
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _saveTravelPlan(city: city, start: start, end: end, theme: theme);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
