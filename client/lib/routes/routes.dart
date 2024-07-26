import 'package:flutter/material.dart';
import '../home.dart';
import '../register.dart';
import '../login.dart';
import '../memories.dart';
import '../music_list.dart';
import '../event_details.dart';

Map<String, WidgetBuilder> getAppRoutes() {
  return {
    '/register': (context) => const RegisterPage(),
    '/login': (context) => const LoginPage(),
    '/home': (context) => const HomePage(),
    '/memories': (context) => const MemoriesPage(),
    '/music': (context) => const MusicListPage(),
  };
}

Route<dynamic>? generateRoute(RouteSettings settings) {
  if (settings.name == '/event-details') {
    final args = settings.arguments as int;
    return MaterialPageRoute(
      builder: (context) {
        return EventDetailsPage(eventId: args);
      },
    );
  }
  return null;
}
