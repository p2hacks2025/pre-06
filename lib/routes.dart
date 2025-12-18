import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';
import 'screens/post/post_screen.dart';
import 'screens/timeline/timeline_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/profile_edit_page.dart';


final Map<String, WidgetBuilder> appRoutes = {
  '/home': (_) => const HomeScreen(),
  '/post': (_) => const PostScreen(),
  '/timeline': (_) => const TimelineScreen(),
  '/profile': (_) => const ProfileScreen(),
  '/profile/edit': (context) => const ProfileEditPage(),
};

