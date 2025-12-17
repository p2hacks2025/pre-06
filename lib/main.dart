import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'routes.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'screens/start/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumina',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routes: appRoutes,
      home: const LoginPage(),
    );
  }
}

/// アプリ起動時の処理まとめページ
class BootPage extends StatefulWidget {
  const BootPage({super.key});

  @override
  State<BootPage> createState() => _BootPageState();
}

class _BootPageState extends State<BootPage> {
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    // ① 匿名ログイン（未ログインなら）
    await _auth.ensureAnonymousSignIn();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // ここに来ることはほぼ無いけど安全対策
      return;
    }

    // ② Firestore にプロフィールがあるか確認
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!mounted) return;

    // ③ 分岐
    if (!doc.exists) {
      // 🔰 初回起動 → 新規登録
      Navigator.pushReplacementNamed(context, '/profile/edit');
    } else {
      // 既存ユーザー → home
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
