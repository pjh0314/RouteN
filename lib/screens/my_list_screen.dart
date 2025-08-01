import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyListScreen extends StatelessWidget {
  const MyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text("Need to sign in first")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Plans")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('course')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Your list is empty"));
          }
          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final city = data['city'] ?? 'None';
              final startDate = data['startDate'] ?? '';
              final endDate = data['endDate'] ?? '';
              final theme = data['theme'] ?? 'None';

              return ListTile(
                title: Text('$city ($theme)'),
                subtitle: Text('$startDate - $endDate'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/map',
                    arguments: {
                      'city': city,
                      'start': startDate,
                      'end': endDate,
                      'theme': theme,
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
