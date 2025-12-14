import 'package:flutter/material.dart';
import '../../services/post_service.dart';
import '../../services/prompt_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _post = PostService();
  final _prompt = PromptService();

  String promptText = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await _prompt.getTodayPrompt();
    final posted = await _post.hasPostedToday();
    if (!mounted) return;

    setState(() {
      promptText = p.text;
      loading = false;
    });

    if (posted) {
      Navigator.pushReplacementNamed(context, '/timeline');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('今日のお題')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(promptText, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 16),
            const Text('投稿するとみんなの投稿が見れます（翌朝5時まで）'),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/post'),
              child: const Text('投稿する'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              child: const Text('プロフィール（自分の投稿履歴）'),
            ),
          ],
        ),
      ),
    );
  }
}

