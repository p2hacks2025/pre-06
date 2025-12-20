import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _passController.dispose();
    _snsController.dispose();
    super.dispose();
  }

  /// 📸 プロフィール写真選択
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  /// 📤 プロフィール写真アップロード
  Future<String?> _uploadProfileImage(String uid) async {
    if (_selectedImage == null) return null;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$uid.jpg');

      await ref.putFile(_selectedImage!);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('画像アップロード失敗: $e');
      return null;
    }
  }

  /// 🔐 新規登録完了 → Firestore保存
  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('入力してください')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final uid = user.uid;

      // プロフィール写真アップロード
      final photoUrl = await _uploadProfileImage(uid);

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'nickname': _nameController.text.trim(),
        'sns': _snsController.text.trim(),
        'visibility': 'public',
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // ✅ 登録完了 → home
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
                const SizedBox(height: 88),

                // アイコン（タップで写真選択）
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: const Color(0xFFFFFBEA),
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : null,
                        child: _selectedImage == null
                            ? const Icon(Icons.person,
                                size: 45, color: Color(0xFFF5B7D2))
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFAD1E8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Color(0xFF3E4A78),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 56),

                // ユーザー名
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      const FormLabel(text: 'ユーザー名*'),
                      const SizedBox(height: 10),
                      InputField(controller: _nameController),

                      const SizedBox(height: 20),

                      const FormLabel(text: 'パスワード*'),
                      const SizedBox(height: 10),
                      InputField(controller: _passController),

                      const SizedBox(height: 20),

                      const FormLabel(text: 'SNS（任意）'),
                      const SizedBox(height: 10),
                      InputField(controller: _snsController),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // 保存ボタン
                SizedBox(
                  width: 220,
                  height: 40, // ← 少し余裕を持たせる
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFAD1E8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.zero, // ← これ重要
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: const Center(
                      child: Text(
                        'はじめる',
                        style: TextStyle(
                          color: Color(0xFF3E4A78),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.2, // ← 行高を固定
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
