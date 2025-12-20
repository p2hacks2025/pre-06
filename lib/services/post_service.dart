import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';
import 'day_key.dart';

class PostService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'anonymous';
    return user.uid;
  }

  Future<Map<String, dynamic>> _getMyProfile() async {
    final doc = await _db.collection('users').doc(_uid).get();
    if (doc.exists) {
      return {
        'nickname': doc.data()?['nickname'] ?? '名無し',
        'userColor': doc.data()?['userColor'] ?? 0xFFF5B7D2,
        'sns': doc.data()?['sns'] ?? '',
      };
    }
    return {'nickname': '名無し', 'userColor': 0xFF9E9E9E};
  }

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
    //if (await hasPostedToday()) throw Exception('今日はすでに投稿済みです');
    final profile = await _getMyProfile();

    final demoNames = [
      'mun',
      'noon',
      'ばらね',
      '73cham',
      'ぺちか',
      'ひろろん',
      'あんぱん',
      'たけ',
    ]; //randome user name
    // 2. その中からランダムに1つ選ぶ
    final randomName = (demoNames..shuffle()).first;

    final demoColors = [
      0xFFE57373,
      0xFF64B5F6,
      0xFF81C784,
      0xFFFFB74D,
      0xFFBA68C8,
    ];
    final randomColorValue = (demoColors..shuffle()).first;

    await _db.collection('posts').add({
      'uid': _uid,
      'dayKey': dayKey,
      'type': 'text',
      'text': trimmed,
      'photoUrl': null,
      'userName': profile['nickname'], //username
      'userColor': profile['userColor'], //icon color
      'sns': profile['sns'],
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
    if (await hasPostedToday())
      throw Exception('今日はすでに投稿済みです'); //何回でも投稿できるようにするなら変更

    //ダミー処理　バックできそうなら、変更！
    /* final path =
        'posts/$_uid/$dayKey/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final task = await _storage.ref(path).putFile(file);
    final url = await task.ref.getDownloadURL();
  */
    final demoNames = [
      'mun',
      'noon',
      'ばらね',
      '73cham',
      'ぺちか',
      'ひろろん',
      'あんぱん',
      'たけ',
    ];
    final randomName = (demoNames..shuffle()).first;

    final demoColors = [
      0xFFE57373,
      0xFF64B5F6,
      0xFF81C784,
      0xFFFFB74D,
      0xFFBA68C8,
    ];
    final randomColorValue = (demoColors..shuffle()).first;

    final profile = await _getMyProfile();

    final fakeUrl = file.path;
    //ダミー処理　ここまで！

    await _db.collection('posts').add({
      'uid': _uid,
      'dayKey': dayKey,
      'type': 'photo',
      'text': null,
      'photoUrl': fakeUrl,
      'userName': profile['nickname'],
      'userColor': profile['userColor'],
      'sns': profile['sns'],
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
