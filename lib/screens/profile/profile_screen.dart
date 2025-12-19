import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // 🔹 仮データ
  List<Post> get dummyPosts => [
    Post(
      id: '1',
      uid: 'me',
      userName: 'muku-69',
      userColor: AppTheme.terracotta.value, // ← .value 必須！
      dayKey: '2025-01-18',
      type: PostType.text,
      text: '今日は朝の光がきれいだった',
      photoUrl: null,
      createdAt: DateTime.now(),
    ),
    Post(
      id: '2',
      uid: 'me',
      userName: 'muku-69',
      userColor: AppTheme.oliveGreen.value,
      dayKey: '2025-01-17',
      type: PostType.text,
      text: 'コーヒーがいつもより美味しく感じた',
      photoUrl: null,
      createdAt: DateTime.now(),
    ),
  ];

  void _showPostDetail(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          decoration: BoxDecoration(
            color: AppTheme.cream,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// --- ハンドル ---
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppTheme.softGray.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

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

                /// --- お題本文（仮） ---
                Text(
                  '今日いちばん心が動いた瞬間',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 22,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 32),

                /// --- 投稿本文 ---
                Text(
                  post.text ?? '',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 17,
                    height: 1.8,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 40),

                /// --- 閉じるボタン ---
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('閉じる'),
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
    return Scaffold(
      appBar: AppBar(title: const Text('プロフィール')),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: const [
                  CircleAvatar(radius: 36, child: Icon(Icons.person, size: 36)),
                  SizedBox(height: 12),
                  Text('muku-69'),
                ],
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
                    child: Text(
                      post.text!,
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
