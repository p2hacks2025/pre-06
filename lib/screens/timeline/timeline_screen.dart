import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  /// ===== モック投稿データ =====
  final List<Post> mockPosts = [
    Post(
      id: '1',
      uid: 'u1',
      dayKey: '2025-01-18',
      type: PostType.text,
      text: '朝の空気が少しだけ春っぽかった',
      photoUrl: null,
      userName: 'karin',
      sns: 'karin73',
      userColor: 0xFFE57373,
      createdAt: DateTime.now(),
    ),
    Post(
      id: '2',
      uid: 'u2',
      dayKey: '2025-01-18',
      type: PostType.photo,
      text: null,
      photoUrl: 'assets/mock/photo1.jpg', // ← 仮画像①
      userName: 'mahi',
      sns: 'noon61',
      userColor: 0xFF64B5F6,
      createdAt: DateTime.now(),
    ),
    Post(
      id: '3',
      uid: 'u3',
      dayKey: '2025-01-18',
      type: PostType.text,
      text: '夕焼けがやばかった',
      photoUrl: null,
      userName: 'maho',
      sns: 'maho-niship',
      userColor: 0xFF81C784,
      createdAt: DateTime.now(),
    ),
    Post(
      id: '4',
      uid: 'u4',
      dayKey: '2025-01-18',
      type: PostType.photo,
      text: null,
      photoUrl: 'assets/mock/photo2.jpg', // ← 仮画像②
      userName: 'miu',
      sns: 'mun-o2',
      userColor: 0xFFBA68C8,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// ===== ユーザープロフィールポップアップ =====
  void _showUserProfile(BuildContext context, Post p) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Color(p.userColor),
                child: Text(
                  p.userName[0],
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                p.userName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text('@${p.sns}', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('とじる'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('みんなの投稿')),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemCount: mockPosts.length,
          itemBuilder: (context, i) {
            final p = mockPosts[i];

            return GestureDetector(
              onTap: () => _showUserProfile(context, p),
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
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ユーザー行
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(p.userColor),
                          child: Text(
                            p.userName[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          p.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// 投稿内容
                    if (p.type == PostType.text && p.text != null)
                      Text(
                        p.text!,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(height: 1.7),
                      ),

                    if (p.type == PostType.photo && p.photoUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          p.photoUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
