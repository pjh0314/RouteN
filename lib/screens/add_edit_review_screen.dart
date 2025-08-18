import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class AddEditReviewScreen extends StatefulWidget {
  final String? reviewId;
  final Map<String, dynamic>? existingData;

  const AddEditReviewScreen({super.key, this.reviewId, this.existingData});

  @override
  State<AddEditReviewScreen> createState() => _AddEditReviewScreenState();
}

class _AddEditReviewScreenState extends State<AddEditReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0;
  List<String> _existingPhotoUrls = [];
  List<File> _newPickedFiles = [];
  bool _isLoading = false;

  final List<String> _photosToDelete = [];

  // 새로 추가: 선택된 코스 데이터 저장
  Map<String, dynamic>? _selectedCourse;
  String? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      final d = widget.existingData!;
      _reviewController.text = d['reviewText'] ?? '';
      _rating = (d['rating'] ?? 0).toDouble();
      _existingPhotoUrls = List<String>.from(d['photos'] ?? []);
      if (d['courseId'] != null && d['courseData'] != null) {
        _selectedCourseId = d['courseId'] as String?;
        _selectedCourse = Map<String, dynamic>.from(d['courseData']);
      } else if (d['courseName'] != null) {
        _selectedCourse = {'city': d['courseName'], 'theme': ''};
      }
    }
  }

  Future<void> _pickImages() async {
    final picked = await ImagePicker().pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _newPickedFiles.addAll(picked.map((p) => File(p.path)));
      });
    }
  }

  Future<List<String>> _uploadNewImages() async {
    final uploaded = <String>[];

    for (final f in _newPickedFiles) {
      try {
        // 실제 파일 확장자 가져오기 (.jpg, .png 등)
        final ext = path.extension(f.path).isNotEmpty
            ? path.extension(f.path)
            : '.jpg';
        // UUID를 붙여서 절대 중복되지 않는 파일명 생성
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4()}$ext';

        final ref = FirebaseStorage.instance.ref().child(
          'review_images/$fileName',
        );

        // 업로드 실행
        final uploadTask = await ref.putFile(f);
        if (uploadTask.state == TaskState.success) {
          final url = await ref.getDownloadURL();
          uploaded.add(url);
        } else {
          print('DEBUG: Failed to upload file ${f.path}');
        }
      } on FirebaseException catch (e) {
        print('DEBUG: Firebase upload error - ${e.code} for file ${f.path}');
      } catch (e) {
        print('DEBUG: Unknown error during upload - $e');
      }
    }

    return uploaded;
  }

  Future<void> _save() async {
    if (_rating == 0 || _reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the review and rate.')),
      );
      return;
    }
    if (_selectedCourse == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a course.')));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Need to sign in.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userName = userDoc.data()?['name'] ?? user.email ?? 'Anonymous';
      final userProfile = userDoc.data()?['profileImageUrl'];

      final newUrls = await _uploadNewImages();
      final finalPhotos = [..._existingPhotoUrls, ...newUrls];

      if (widget.reviewId == null) {
        await FirebaseFirestore.instance.collection('reviews').add({
          'userId': user.uid,
          'userName': userName,
          'userProfileImage': userProfile,
          'courseId': _selectedCourseId,
          'courseData': _selectedCourse,
          'rating': _rating,
          'reviewText': _reviewController.text.trim(),
          'photos': finalPhotos,
          'likes': 0,
          'likedBy': [],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        final docRef = FirebaseFirestore.instance
            .collection('reviews')
            .doc(widget.reviewId);
        await docRef.update({
          'courseId': _selectedCourseId,
          'courseData': _selectedCourse,
          'rating': _rating,
          'reviewText': _reviewController.text.trim(),
          'photos': finalPhotos,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      for (final url in _photosToDelete) {
        if (kDebugMode) {
          print('DEBUG: Attempting to delete URL: $url');
        }
        try {
          await FirebaseStorage.instance.refFromURL(url).delete();
          if (kDebugMode) {
            print('DEBUG: Successfully deleted: $url');
          }
        } on FirebaseException catch (e) {
          if (e.code == 'object-not-found') {
            if (kDebugMode) {
              print(
                'DEBUG: File not found in Storage, ignoring delete error for: $url',
              );
            }
          } else {
            if (kDebugMode) {
              print(
                'DEBUG: !!! FAILED to delete old image. URL: $url, Error: $e',
              );
            }
            rethrow;
          }
        } catch (e) {
          if (kDebugMode) {
            print(
              'DEBUG: !!! FAILED to delete old image. URL: $url, Error: $e',
            );
          }
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _removeExistingPhoto(int index) {
    setState(() {
      final removedUrl = _existingPhotoUrls.removeAt(index);
      if (!_photosToDelete.contains(removedUrl)) {
        _photosToDelete.add(removedUrl);
      }
    });
  }

  void _removeNewPicked(int index) {
    setState(() {
      _newPickedFiles.removeAt(index);
    });
  }

  Future<void> _showCourseSelectionModal() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Need to sign in.')));
      return;
    }

    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('course')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return const Center(child: Text('No saved courses found.'));
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final city = data['city'] ?? 'None';
                final theme = data['theme'] ?? 'None';
                final startDate = data['startDate'] ?? '';
                final endDate = data['endDate'] ?? '';

                return ListTile(
                  title: Text('$city ($theme)'),
                  subtitle: Text('$startDate - $endDate'),
                  onTap: () {
                    Navigator.pop(context, {'id': doc.id, 'data': data});
                  },
                );
              },
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedCourseId = selected['id'] as String;
        _selectedCourse = selected['data'] as Map<String, dynamic>;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.reviewId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit review' : 'Compose review')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Course (select):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showCourseSelectionModal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _selectedCourse != null
                            ? '${_selectedCourse?['city'] ?? 'Unknown'} (${_selectedCourse?['theme'] ?? 'No theme'})'
                            : 'Tap to select a course',
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedCourse != null
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Text(
                        'Rate: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemBuilder: (context, _) =>
                            const Icon(Icons.star, color: Colors.amber),
                        onRatingUpdate: (r) => setState(() => _rating = r),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _reviewController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Write the review',
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_existingPhotoUrls.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Uploaded Picture (Tap to delete)'),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _existingPhotoUrls.length,
                        itemBuilder: (context, i) {
                          final url = _existingPhotoUrls[i];
                          return GestureDetector(
                            onTap: () => _removeExistingPhoto(i),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  Image.network(
                                    url,
                                    width: 120,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black45,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (_newPickedFiles.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Extra Pictures (Tap to delete)'),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _newPickedFiles.length,
                        itemBuilder: (context, i) {
                          final f = _newPickedFiles[i];
                          return GestureDetector(
                            onTap: () => _removeNewPicked(i),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  Image.file(
                                    f,
                                    width: 120,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black45,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Select Image'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: Text(isEdit ? 'Fix and Save' : 'Upload'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
