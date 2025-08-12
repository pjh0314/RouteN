import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_edit_review_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ReviewDetailScreen extends StatefulWidget {
  final String reviewId;
  const ReviewDetailScreen({super.key, required this.reviewId});

  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  late final uid = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _addComment(String userName) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('reviews')
        .doc(widget.reviewId)
        .collection('comments')
        .add({
          'userId': uid,
          'userName': userName,
          'text': text,
          'createdAt': FieldValue.serverTimestamp(),
        });

    _commentController.clear();
  }

  Future<void> _toggleLike(DocumentSnapshot reviewSnap) async {
    final docRef = FirebaseFirestore.instance
        .collection('reviews')
        .doc(widget.reviewId);
    if (uid == null) return;

    FirebaseFirestore.instance.runTransaction((tx) async {
      final fresh = await tx.get(docRef);
      if (!fresh.exists) return;
      final data = fresh.data() as Map<String, dynamic>;
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

  Future<void> _deleteReview(Map<String, dynamic> data) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure to delete this Review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final docRef = FirebaseFirestore.instance
        .collection('reviews')
        .doc(widget.reviewId);

    // Delete Images(Optional)
    final photos = List<String>.from(data['photos'] ?? []);
    for (final url in photos) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(url);
        await ref.delete();
      } catch (_) {
        // Ignore Delete Error
      }
    }

    // Delete the comment first (Simple way: Delete each docs of collection)
    final commentsSnap = await docRef.collection('comments').get();
    for (final c in commentsSnap.docs) {
      await c.reference.delete();
    }

    // Delete Review Docs
    await docRef.delete();

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final reviewDoc = FirebaseFirestore.instance
        .collection('reviews')
        .doc(widget.reviewId);

    return Scaffold(
      appBar: AppBar(title: const Text('Specific Review')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: reviewDoc.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text('Cannot Find Reviews.'));
          }

          final data = snap.data!.data() as Map<String, dynamic>;
          final photos = List<String>.from(data['photos'] ?? []);

          final authorId = data['userId'] as String?;
          final isAuthor = uid != null && authorId == uid;
          final likedBy = List<String>.from(data['likedBy'] ?? []);
          final isLiked = uid != null && likedBy.contains(uid);

          // bring the coure data from the list
          final courseData = data['courseData'] as Map<String, dynamic>?;
          final courseTitle = courseData != null
              ? '${courseData['city'] ?? 'Unknown'} (${courseData['theme'] ?? 'No theme'})'
              : 'None Course Name';

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    if (photos.isNotEmpty)
                      SizedBox(
                        height: 220,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: photos
                              .map(
                                (p) => Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Image.network(
                                    p,
                                    height: 220,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ListTile(
                      leading: data['userProfileImage'] != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                data['userProfileImage'],
                              ),
                            )
                          : const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(courseTitle),
                      subtitle: Text(
                        '${data['userName'] ?? 'Anonymous'} · ⭐ ${data['rating'] ?? 0}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isLiked ? Colors.red : null,
                                ),
                                onPressed: () => _toggleLike(snap.data!),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints(),
                              ),
                              Text(
                                '${data['likes'] ?? 0}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                          if (isAuthor)
                            PopupMenuButton<String>(
                              onSelected: (v) async {
                                if (v == 'edit') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddEditReviewScreen(
                                        reviewId: widget.reviewId,
                                        existingData: data,
                                      ),
                                    ),
                                  );
                                } else if (v == 'delete') {
                                  await _deleteReview(data);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(data['reviewText'] ?? ''),
                    ),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4,
                      ),
                      child: Text(
                        'Comment',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: reviewDoc
                          .collection('comments')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, csnap) {
                        if (!csnap.hasData) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final comments = csnap.data!.docs;
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, i) {
                            final c =
                                comments[i].data() as Map<String, dynamic>;
                            return ListTile(
                              leading: const Icon(Icons.comment),
                              title: Text(c['userName'] ?? 'Anonymous'),
                              subtitle: Text(c['text'] ?? ''),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Write Comments',
                          ),
                          maxLines: 1,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.send,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Need to Sign In.')),
                            );
                            return;
                          }
                          final userDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .get();
                          final userName =
                              userDoc.data()?['name'] ??
                              user.email ??
                              'Anonymous';
                          await _addComment(userName);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
