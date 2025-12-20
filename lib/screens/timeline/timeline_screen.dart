import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/timeline_service.dart';
import '../../services/post_service.dart';
import '../../models/post_model.dart';
import '../../theme/app_theme.dart';
import 'dart:io'; //file class
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

  //user profiel popup
  void _showUserProfile(BuildContext context, Post p) {
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
              mainAxisSize: MainAxisSize.min, // 内容の大きさに合わせる
              children: [
                // 1. アイコン（投稿と同じ色と一文字目を使用）
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(p.userColor),
                  child: Text(
                    p.userName.isNotEmpty ? p.userName[0] : '?',
                    style: const TextStyle(fontSize: 32, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. なまえ
                Text(
                  p.userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // 3. SNSユーザーネーム（例: @username）
                // ※ まだデータがない場合はダミーを表示
                Text(
                  (p.sns != null && p.sns!.isNotEmpty) ? '@${p.sns}' : '@未設定',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),

                const SizedBox(height: 24),

                // 閉じるボタン
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('とじる'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final uid = currentUser?.uid ?? 'anonymous';
    final timeline = TimelineService();
    final postService = PostService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('みんなの投稿'),
        /*右上のアイコンボタンのため削除
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.person_outline),
          ),
        ],
        */
      ),
      bottomNavigationBar: const BottomNav(
        currentIndex: 1, // ◇ Timeline
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
                  Text('·', style: TextStyle(color: AppTheme.softGray)),
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
                  if (snap.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red),
                          SizedBox(height: 16),
                          Text('エラー: ${snap.error}'),
                        ],
                      ),
                    );
                  }
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
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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

                        //show profiel
                        child: GestureDetector(
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

                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //add Icon
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Color(p.userColor),
                                  child: Text(
                                    p.userName.isNotEmpty ? p.userName[0] : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 16),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      //user name & post time & button
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            p.userName, //user name
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "${p.createdAt.hour.toString().padLeft(2, '0')}:${p.createdAt.minute.toString().padLeft(2, '0')}",
                                            style: TextStyle(
                                              color: AppTheme.softGray,
                                              fontSize: 12,
                                            ),
                                          ),

                                          //action button
                                          const Spacer(),

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
                                                    content: const Text(
                                                      '本当に削除しますか？',
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              false,
                                                            ),
                                                        child: const Text(
                                                          'キャンセル',
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              true,
                                                            ),
                                                        child: Text(
                                                          '削除',
                                                          style: TextStyle(
                                                            color: AppTheme
                                                                .terracotta,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirm == true) {
                                                  await postService.deletePost(
                                                    p.id,
                                                  );
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
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: const Text(
                                                      '通報機能は準備中です',
                                                    ),
                                                    backgroundColor:
                                                        AppTheme.charcoal,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Post content
                                      //photo display
                                      if (p.type == PostType.photo &&
                                          p.photoUrl != null) ...[
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child:
                                              p.photoUrl!.startsWith(
                                                'http',
                                              ) //バック出来たら変更
                                              ? Image.network(
                                                  p.photoUrl!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  //photo loading placefolder
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    }
                                                    return AspectRatio(
                                                      aspectRatio: 16 / 9,
                                                      child: Center(
                                                        child: CircularProgressIndicator(
                                                          value:
                                                              loadingProgress
                                                                      .expectedTotalBytes !=
                                                                  null
                                                              ? loadingProgress
                                                                        .cumulativeBytesLoaded /
                                                                    loadingProgress
                                                                        .expectedTotalBytes!
                                                              : null,
                                                          color: AppTheme
                                                              .oliveGreen,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )
                                              //バック出来たら変更
                                              : Image.file(
                                                  File(p.photoUrl!),
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => const AspectRatio(
                                                        aspectRatio: 16 / 9,
                                                        child: Center(
                                                          child: Icon(
                                                            Icons.broken_image,
                                                          ),
                                                        ),
                                                      ),
                                                ),
                                        ),
                                        //ここまで
                                        const SizedBox(height: 12),
                                      ],

                                      //expression text
                                      if (p.text != null && p.text!.isNotEmpty)
                                        Text(
                                          p.text!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontSize: 16,
                                                height: 1.7,
                                              ),
                                        ),

                                      const SizedBox(height: 16),

                                      // Footer with actions
                                      Row(
                                        children: [
                                          // Day indicator
                                          /*日付表示のため削除
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.warmBeige
                                                .withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            p.dayKey,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ),

                                        const Spacer(),
                                        */
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
