import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final TextEditingController? controller;
  final bool obscureText;

  const InputField({
    super.key,
    this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 44,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Center(
        child: SizedBox(
          height: 22, // ← カーソル位置を安定させる
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            cursorColor: const Color.fromARGB(221, 234, 155, 155),

            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),

            style: const TextStyle(
              fontSize: 14,
              height: 1.3, // ← 行高を固定
            ),
          ),
        ),
      ),
    );
  }
}
