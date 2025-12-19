import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:muku/services/user_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

//controller
class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3E4A78),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Lumina',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF5B7D2),
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 40),

              const _Label(text: 'メールアドレス'), // Firebase Auth用に一旦メールとして扱います
              _InputField(controller: _emailController),

              const SizedBox(height: 16),

              const _Label(text: 'パスワード'),
              _InputField(controller: _passwordController, obscureText: true),

              const SizedBox(height: 32),

              SizedBox(
                width: 220,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFAD1E8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    //login process
                    try {
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                      );
                      //go timeline screen
                      if (mounted)
                        Navigator.pushReplacementNamed(context, '/timeline');
                    } catch (e) {
                      //error review
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('ログイン失敗: $e')));
                    }
                  },

                  child: const Text(
                    'ログイン',
                    style: TextStyle(
                      color: Color(0xFF3E4A78),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/profile/edit');
                },
                child: const Text(
                  '新規登録',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ===== ここから下が重要 ===== */

class _InputField extends StatelessWidget {
  final bool obscureText;
  final TextEditingController controller;
  const _InputField({required this.controller, this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEA),
        borderRadius: BorderRadius.circular(21),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}
