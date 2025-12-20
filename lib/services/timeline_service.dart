import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import 'day_key.dart';

class TimelineService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Post>> todayPostsStream({required String myUid}) {
    final dayKey = DayKey.fromNow(boundaryHour: 5);

    return _db
        .collection('posts')
        .where('dayKey', isEqualTo: dayKey)
        .where('deletedAt', isNull: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) {
      final posts = s.docs.map((d) => Post.fromDoc(d)).toList();
      // 自分の投稿も混ぜるかどうかは好み（ここでは混ぜる）
      return posts;
    });
  }
}

