import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // 🔹 仮データ
  List<Post> get dummyPosts => [
    Post(
      id: '1',
      uid: 'me',
      userName: 'muku-69',
      userColor: AppTheme.terracotta.value,
      dayKey: '2025-01-18',
      type: PostType.photo,
      text: null,
      photoUrl: 'assets/images/cat.jpg',
      sns: 'sns',
      createdAt: DateTime.now(),
      theme: '名前を呼ばれた瞬間',
    ),
    Post(
      id: '2',
      uid: 'me',
      userName: 'muku-69',
      userColor: AppTheme.oliveGreen.value,
      dayKey: '2025-01-17',
      type: PostType.text,
      text: 'コーヒーがいつもより美味しく感じた！',
      photoUrl: null,
      sns: 'sns',
      createdAt: DateTime.now(),
      theme: '心が温まった瞬間',
    ),
    Post(
      id: '3',
      uid: 'me',
      userName: 'muku-69',
      userColor: AppTheme.terracotta.value,
      dayKey: '2025-01-16',
      type: PostType.photo,
      text: null,
      photoUrl: 'assets/images/tree.jpg',
      sns: 'sns',
      createdAt: DateTime.now(),
      theme: '温かい気持ちになった瞬間',
    ),
  ];

  void _showPostDetail(BuildContext context, Post post) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// --- 日付 ---
                Text(
                  post.dayKey,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    letterSpacing: 1.2,
                    color: AppTheme.softGray,
                  ),
                ),

                const SizedBox(height: 16),

                /// --- お題ラベル ---
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.terracotta.withOpacity(0.15),
                        AppTheme.oliveGreen.withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '今日のお題',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// --- お題本文 ---
                Text(
                  post.theme ?? '今日いちばん心が動いた瞬間',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 22,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24),

                /// --- 投稿本文 ---
                if (post.text != null && post.text!.isNotEmpty)
                  Text(
                    post.text!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 17,
                      height: 1.8,
                      letterSpacing: 0.3,
                    ),
                  ),

                const SizedBox(height: 24),

                /// --- 閉じるボタン ---
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('とじる'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 現在ログイン中のユーザー情報を取得
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('プロフィール')),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final userData =
                      snapshot.data?.data() as Map<String, dynamic>?;
                  final name = userData?['nickname'] ?? 'muku-69';
                  final sns = userData?['sns'] ?? '';
                  final photoUrl = userData?['photoUrl'] as String?;

                  // デバッグ用ログ
                  print('📸 Profile Screen - photoUrl: $photoUrl');
                  print('📸 Profile Screen - userData: $userData');

                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                            ? NetworkImage(photoUrl) as ImageProvider
                            : const AssetImage('assets/images/profile.jpg'),
                        onBackgroundImageError: (exception, stackTrace) {
                          print('❌ Profile image load error: $exception');
                        },
                      ),
                      const SizedBox(height: 12),

                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (sns.isNotEmpty)
                        Text(
                          '@$sns',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, i) {
                final post = dummyPosts[i];
                return GestureDetector(
                  onTap: () => _showPostDetail(context, post),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.softGray.withOpacity(0.08),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: post.type == PostType.photo && post.photoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              post.photoUrl!,
                              fit: BoxFit.cover,
                              height: 200,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: AppTheme.softGray.withOpacity(0.1),
                                  child: const Icon(Icons.broken_image, size: 48),
                                );
                              },
                            ),
                          )
                        : Text(
                            post.text ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                );
              }, childCount: dummyPosts.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }
}
