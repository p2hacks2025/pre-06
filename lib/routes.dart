import 'package:flutter/material.dart';

import 'screens/boot/boot_page.dart';
import 'screens/home/home_screen.dart';
import 'screens/post/post_screen.dart';
import 'screens/timeline/timeline_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/profile_edit_page.dart';
import 'screens/start/login_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const BootPage(),
  '/home': (context) => const HomeScreen(),
  '/post': (context) => const PostScreen(),
  '/timeline': (context) => const TimelineScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/profile/edit': (context) => const ProfileEditPage(),
  '/login': (context) => const LoginPage(),
};
