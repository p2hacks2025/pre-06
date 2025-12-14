import 'package:flutter/material.dart';
import '../../services/post_service.dart';
import '../../models/post_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final postService = PostService();

    return Scaffold(
      appBar: AppBar(title: const Text('プロフィール（自分の投稿）')),
      body: StreamBuilder<List<Post>>(
        stream: postService.myPostsStream(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final posts = snap.data!;
          if (posts.isEmpty) return const Center(child: Text('まだ投稿がありません'));
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, i) {
              final p = posts[i];
              return ListTile(
                title: Text(p.type == PostType.text ? (p.text ?? '') : '📷 写真投稿'),
                subtitle: Text(p.dayKey),
              );
            },
          );
        },
      ),
    );
  }
}
