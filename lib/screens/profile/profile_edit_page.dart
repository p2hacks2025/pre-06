import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widgets/label.dart';
import 'widgets/input_field.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _snsController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _passController.dispose();
    _snsController.dispose();
    super.dispose();
  }

  /// 新規登録完了（Auth作成） → Firestore保存
  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final password = _passController.text.trim();
    final sns = _snsController.text.trim();

    if (name.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ユーザー名とパスワードを入力してください')));
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('パスワードは6文字以上必要です')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 匿名ログインに変更（これならreCAPTCHAで止まりません！）
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      final uid = userCredential.user!.uid;

      // Firestoreにデータを保存
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'nickname': _nameController.text.trim(),
        'sns': _snsController.text.trim(),
        'userColor': 0xFFF5B7D2, // 好きなデフォルト色
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      //  登録完了 → home
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存に失敗しました: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF3E4A78),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // アイコン（今は仮）
                const CircleAvatar(
                  radius: 45,
                  backgroundColor: Color(0xFFFFFBEA),
                  child: Icon(Icons.person, size: 45, color: Color(0xFFF5B7D2)),
                ),

                const SizedBox(height: 40),

                // ユーザー名
                const FormLabel(text: 'ユーザー名*'),
                InputField(controller: _nameController),

                const SizedBox(height: 16),
                //パスワード
                const FormLabel(text: 'パスワード*'),
                InputField(controller: _passController),

                const SizedBox(height: 16),

                // SNS
                const FormLabel(text: 'SNS（任意）'),
                InputField(controller: _snsController),

                const SizedBox(height: 32),

                // 保存ボタン
                SizedBox(
                  width: 220,
                  height: 52, // ← 少し余裕を持たせる
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFAD1E8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.zero, // ← これ重要
                    ),
                    onPressed: _isSaving ? null : _saveProfile,
                    child: Center(
                      child: _isSaving
                          ? const CircularProgressIndicator(
                              color: Color(0xFF3E4A78),
                            ) // 保存中のぐるぐる
                          : const Text(
                              'はじめる',
                              style: TextStyle(
                                color: Color(0xFF3E4A78),
                                fontSize: 16,
                                fontWeight: FontWeight.bold, // ← 行高を固定
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
