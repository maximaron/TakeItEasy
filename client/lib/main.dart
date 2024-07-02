import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register.dart';
import 'login.dart';
import 'home.dart';
import 'memories.dart';
import 'event_details.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthCheckPage(),
      routes: {
        '/register': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/memories': (context) => MemoriesPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/event-details') {
          final args = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) {
              return EventDetailsPage(eventId: args);
            },
          );
        }
        return null;
      },
    );
  }
}

class AuthCheckPage extends StatefulWidget {
  @override
  _AuthCheckPageState createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
