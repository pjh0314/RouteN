// CommunityScreen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:route_n_firebase/screens/add_edit_review_screen.dart';
import 'package:route_n_firebase/screens/review_detail_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reviews')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text('There is no review yet.'));
          }

          final docs = snap.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final photos = List<String>.from(data['photos'] ?? []);
              final likedBy = List<String>.from(data['likedBy'] ?? []);
              final isLiked = uid != null && likedBy.contains(uid);
              final courseData = data['courseData'] as Map<String, dynamic>?;
              final courseName = courseData != null
                  ? '${courseData['city'] ?? 'Unknown'} (${courseData['theme'] ?? 'No theme'})'
                  : 'None Course yet';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ListTile(
                  leading: photos.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            photos[0],
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const CircleAvatar(child: Icon(Icons.image)),
                  title: Text(courseName),
                  subtitle: Text(
                    '⭐ ${data['rating'] ?? 0} · ${data['userName'] ?? 'Anonymous'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : null,
                            ),
                            onPressed: () => _toggleLike(doc.id),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                          ),
                          Text(
                            '${data['likes'] ?? 0}',
                            style: const TextStyle(fontSize: 12, height: 1.2),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReviewDetailScreen(reviewId: doc.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditReviewScreen()),
          );
        },
      ),
    );
  }

  Future<void> _toggleLike(String reviewId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('reviews')
        .doc(reviewId);

    FirebaseFirestore.instance.runTransaction((tx) async {
      final snapshot = await tx.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final likedBy = List<String>.from(data['likedBy'] ?? []);
      final likes = (data['likes'] ?? 0) as int;

      if (likedBy.contains(uid)) {
        tx.update(docRef, {
          'likedBy': FieldValue.arrayRemove([uid]),
          'likes': (likes - 1).clamp(0, 999999),
        });
      } else {
        tx.update(docRef, {
          'likedBy': FieldValue.arrayUnion([uid]),
          'likes': likes + 1,
        });
      }
    });
  }
}
