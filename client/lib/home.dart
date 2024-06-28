import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'memories.dart';
import 'event_details.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? name;
  List memories = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadMemories();
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('name');

    setState(() {
      name = userName;
    });
  }

  Future<void> _loadMemories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('http://192.168.1.162:3000/memories?token=$token&date=${DateTime.now().toIso8601String().split('T')[0]}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        memories = jsonDecode(response.body);
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onEventTapped(int eventId) {
    Navigator.pushNamed(
      context,
      '/event-details',
      arguments: eventId,
    ).then((value) {
      if (value == true) {
        _loadMemories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = <Widget>[
      Center(
        child: memories.isEmpty
            ? name == null
            ? CircularProgressIndicator()
            : Text('Hello, $name', style: Theme.of(context).textTheme.headlineMedium)
            : ListView.builder(
          itemCount: memories.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(memories[index]['event']),
              subtitle: Text(memories[index]['emotion']),
              onTap: () => _onEventTapped(memories[index]['id']),
            );
          },
        ),
      ),
      MemoriesPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              await prefs.remove('name');
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album),
            label: 'Memories',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
