import 'package:flutter/material.dart';
import '../../services/post_service.dart';
import '../../services/prompt_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _post = PostService();
  final _prompt = PromptService();

  String promptText = '';
  bool loading = true;
  bool hasPostedToday = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _load();
  }

  Future<void> _load() async {
    final p = await _prompt.getTodayPrompt();
    final posted = await _post.hasPostedToday();
    if (!mounted) return;

    setState(() {
      promptText = p.text;
      loading = false;
      hasPostedToday = posted;
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.terracotta,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('今日のお題'),
        backgroundColor: Colors.transparent,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),

                  // Decorative top element
                  Center(
                    child: Container(
                      width: 60,
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.terracotta.withOpacity(0.3),
                            AppTheme.oliveGreen.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Prompt text - large and centered
                  Text(
                    promptText,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Decorative bottom element
                  Center(
                    child: Container(
                      width: 60,
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.oliveGreen.withOpacity(0.3),
                            AppTheme.terracotta.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Subtitle text
                  Text(
                    '投稿するとみんなの投稿が見れます',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      letterSpacing: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '翌朝5時まで',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 2),

                  // Post button with gradient background
                  Center(
                    child: hasPostedToday
                        ? const Text(
                            '今日はもう投稿済みです',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.terracotta.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/post'),
                              child: const Text('投稿する'),
                            ),
                          ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }
}
