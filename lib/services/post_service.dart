import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';
import 'day_key.dart';

class PostService {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  Future<bool> hasPostedToday() async {
    final dayKey = DayKey.fromNow(boundaryHour: 5);
    final q = await _db
        .collection('posts')
        .where('uid', isEqualTo: _uid)
        .where('dayKey', isEqualTo: dayKey)
        .where('deletedAt', isNull: true)
        .limit(1)
        .get();
    return q.docs.isNotEmpty;
  }

  Future<void> createTextPost({
    required String text,
    int maxChars = 200,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) throw Exception('テキストが空です');
    if (trimmed.length > maxChars) throw Exception('文字数が多すぎます（最大$maxChars文字）');

    final dayKey = DayKey.fromNow(boundaryHour: 5);
    if (await hasPostedToday()) throw Exception('今日はすでに投稿済みです');

    await _db.collection('posts').add({
      'uid': _uid,
      'dayKey': dayKey,
      'type': 'text',
      'text': trimmed,
      'photoUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
      'deletedAt': null,
    });
  }

  Future<void> createPhotoPost({required File file, String? text}) async {
    final trimmedText = text?.trim();

    if (trimmedText != null && trimmedText.isNotEmpty) {
      throw Exception('写真投稿時にはテキストは使用できません。');
    }

    final dayKey = DayKey.fromNow(boundaryHour: 5);
    if (await hasPostedToday()) throw Exception('今日はすでに投稿済みです');

    //ダミー処理　バックできそうなら、変更！
    /* final path =
        'posts/$_uid/$dayKey/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final task = await _storage.ref(path).putFile(file);
    final url = await task.ref.getDownloadURL();
  */

    final fakeUrl = file.path;
    //ダミー処理　ここまで！

    await _db.collection('posts').add({
      'uid': _uid,
      'dayKey': dayKey,
      'type': 'photo',
      'text': null,
      'photoUrl': fakeUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'deletedAt': null,
    });
  }

  Future<void> deletePost(String postId) async {
    await _db.collection('posts').doc(postId).update({
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Post>> myPostsStream() {
    return _db
        .collection('posts')
        .where('uid', isEqualTo: _uid)
        .where('deletedAt', isNull: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Post.fromDoc(d)).toList());
  }
}
