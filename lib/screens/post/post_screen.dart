import 'package:flutter/material.dart';
import '../../services/post_service.dart';
import '../../theme/app_theme.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});
  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen>
    with SingleTickerProviderStateMixin {
  final _post = PostService();
  final _controller = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool sending = false;
  String? error;

  static const maxChars = 200;

  bool get _hasText => _controller.text.trim().isNotEmpty;
  bool get _hasImage => _selectedImage != null;
  bool get _isPhotoDisabled => _hasText;

  // 送信ボタンの有効化条件（写真がある、または、文字がある）
  bool get _isReadyToSubmit => _hasImage || _hasText;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_isReadyToSubmit) return;

    setState(() {
      sending = true;
      error = null;
    });

    try {
      if (_selectedImage != null) {
        await _post.createPhotoPost(file: _selectedImage!);
      } else {
        await _post.createTextPost(text: _controller.text, maxChars: maxChars);
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/timeline');
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _controller.clear(); // 写真を選んだら文字を消す
        error = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final charCount = _controller.text.length;
    final remaining = maxChars - charCount;
    final percentage = charCount / maxChars;

    return Scaffold(
      appBar: AppBar(
        title: const Text('投稿'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    '今日の瞬間をひとこと',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      letterSpacing: 1.2,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // pohto post
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.softGray.withOpacity(0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: _selectedImage != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                // preview button
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                // photo delete button
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedImage = null),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 10,
                                            color: Colors.black12,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.red,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : TextField(
                              controller: _controller,
                              maxLength: maxChars,
                              maxLines: null,
                              autofocus: true,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontSize: 18, height: 1.8),
                              decoration: const InputDecoration(
                                hintText: 'ここに書いてください…',
                                border: InputBorder.none,
                                counterText: '',

                                //delete line
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 文字数カウンター（写真がない時だけ表示）
                  if (!_hasImage)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(
                                value: percentage,
                                strokeWidth: 2,
                                backgroundColor: AppTheme.warmBeige,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  percentage > 0.9
                                      ? AppTheme.terracotta
                                      : AppTheme.oliveGreen,
                                ),
                              ),
                            ),
                            Text(
                              '$remaining',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),

                  if (error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      error!,
                      style: TextStyle(color: AppTheme.terracotta),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // 投稿ボタン
                  Center(
                    child: ElevatedButton(
                      onPressed: sending || !_isReadyToSubmit ? null : _submit,
                      child: sending
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('投稿する'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 写真選択ボタン
                  if (!_hasImage) // 写真が未選択のときだけ表示
                    ElevatedButton.icon(
                      onPressed: _isPhotoDisabled ? null : _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('写真を選択'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.softGray.withOpacity(0.1),
                        foregroundColor: AppTheme.oliveGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
