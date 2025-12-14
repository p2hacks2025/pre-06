import 'package:flutter/material.dart';
import '../../services/post_service.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});
  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _post = PostService();
  final _controller = TextEditingController();
  bool sending = false;
  String? error;

  static const maxChars = 200;

  Future<void> _submit() async {
    setState(() {
      sending = true;
      error = null;
    });
    try {
      await _post.createTextPost(text: _controller.text, maxChars: maxChars);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/timeline');
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('投稿')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLength: maxChars,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: '今日の瞬間をひとこと…',
                border: OutlineInputBorder(),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error!, style: const TextStyle(color: Colors.red)),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: sending ? null : _submit,
              child: sending ? const CircularProgressIndicator() : const Text('投稿する'),
            ),
          ],
        ),
      ),
    );
  }
}
