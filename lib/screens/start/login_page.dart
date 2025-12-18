import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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

              const _Label(text: 'ユーザー名'),
              const _InputField(),

              const SizedBox(height: 16),

              const _Label(text: 'パスワード'),
              const _InputField(obscureText: true),

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
                  onPressed: () {},
                  child: const Text(
                    'ログイン',
                    style: TextStyle(
                      color: Color(0xFF3E4A78),
                      fontSize: 16,
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
  const _InputField({this.obscureText = false});

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
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
