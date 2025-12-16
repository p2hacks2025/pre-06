import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/timeline_service.dart';
import '../../services/post_service.dart';
import '../../models/post_model.dart';
import '../../theme/app_theme.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final timeline = TimelineService();
    final postService = PostService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('みんなの投稿'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.person_outline),
          )
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header message
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: AppTheme.softPeach.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '今日だけ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '·',
                    style: TextStyle(color: AppTheme.softGray),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'スクショ非推奨',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Posts list
            Expanded(
              child: StreamBuilder<List<Post>>(
                stream: timeline.todayPostsStream(myUid: uid),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.terracotta,
                        strokeWidth: 2,
                      ),
                    );
                  }
                  final posts = snap.data!;
                  if (posts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 48,
                            color: AppTheme.softGray.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'まだ投稿がありません',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: posts.length,
                    itemBuilder: (context, i) {
                      final p = posts[i];
                      final isMyPost = p.uid == uid;

                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 300 + (i * 50)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
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
                              // Post content
                              Text(
                                p.type == PostType.text ? (p.text ?? '') : '📷 写真投稿',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontSize: 16,
                                  height: 1.7,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Footer with actions
                              Row(
                                children: [
                                  // Day indicator
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.warmBeige.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      p.dayKey,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                  const Spacer(),

                                  // Action button
                                  if (isMyPost)
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: AppTheme.terracotta,
                                        size: 20,
                                      ),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('投稿を削除'),
                                            content: const Text('本当に削除しますか？'),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('キャンセル'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: Text(
                                                  '削除',
                                                  style: TextStyle(color: AppTheme.terracotta),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await postService.deletePost(p.id);
                                        }
                                      },
                                    )
                                  else
                                    IconButton(
                                      icon: Icon(
                                        Icons.flag_outlined,
                                        color: AppTheme.softGray,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('通報機能は準備中です'),
                                            backgroundColor: AppTheme.charcoal,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ],
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
      ),
    );
  }
}
