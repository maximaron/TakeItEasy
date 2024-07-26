import 'package:flutter/material.dart';
import 'services/auth_check.dart';
import 'routes/routes.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Demo',
      theme: AppTheme.theme,
      home: const AuthCheckPage(),
      routes: getAppRoutes(),
      onGenerateRoute: generateRoute,
    );
  }
}
