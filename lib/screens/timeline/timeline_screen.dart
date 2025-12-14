import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/timeline_service.dart';
import '../../services/post_service.dart';
import '../../models/post_model.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final timeline = TimelineService();
    final postService = PostService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('みんなの投稿（今日だけ）'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.person),
          )
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('スクショは推奨しません 🙏'),
          ),
          Expanded(
            child: StreamBuilder<List<Post>>(
              stream: timeline.todayPostsStream(myUid: uid),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final posts = snap.data!;
                if (posts.isEmpty) {
                  return const Center(child: Text('まだ投稿がありません'));
                }
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, i) {
                    final p = posts[i];
                    return Card(
                      child: ListTile(
                        title: Text(p.type == PostType.text ? (p.text ?? '') : '📷 写真投稿'),
                        subtitle: Text('dayKey: ${p.dayKey}'),
                        trailing: p.uid == uid
                            ? IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => postService.deletePost(p.id),
                              )
                            : IconButton(
                                icon: const Icon(Icons.flag),
                                onPressed: () {
                                  // 通報は後で report_service に繋ぐ
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('通報（仮）')),
                                  );
                                },
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
