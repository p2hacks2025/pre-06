import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'routes.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //firebase
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'muku',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routes: appRoutes,
      home: const BootPage(),
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
    await _auth.ensureAnonymousSignIn();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
