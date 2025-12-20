import 'package:cloud_firestore/cloud_firestore.dart';

enum PostType { photo, text }

class Post {
  final String id;
  final String uid;
  final String dayKey;
  final PostType type;
  final String? text;
  final String? photoUrl;
  final String userName;
  final int userColor;
  final String sns;
  final DateTime createdAt;
  final DateTime? deletedAt;

  Post({
    required this.id,
    required this.uid,
    required this.dayKey,
    required this.type,
    this.text,
    this.photoUrl,
    required this.userName,
    required this.userColor,
    required this.sns,
    required this.createdAt,
    this.deletedAt,
  });

  factory Post.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      uid: data['uid'] as String,
      dayKey: data['dayKey'] as String,
      type: (data['type'] as String) == 'photo'
          ? PostType.photo
          : PostType.text,
      text: data['text'] as String?,
      photoUrl: data['photoUrl'] as String?,
      userName: data['userName'] ?? 'muku',
      userColor: data['userColor'] ?? 0xFF9E9E9E,
      sns: data['sns'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
    );
  }
}
