import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'services/memories_service.dart';
import 'memories.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? name;
  List memories = [];
  final AuthService _authService = AuthService();
  final MemoriesService _memoriesService = MemoriesService();
  int _selectedIndex = 0;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadAllMemories();
  }

  Future<void> _loadUserInfo() async {
    String? userName = await _authService.getName();
    setState(() {
      name = userName;
    });
  }

  Future<void> _loadAllMemories() async {
    final memoryList = await _memoriesService.getAllMemories();
    setState(() {
      memories = memoryList;
    });
  }

  Future<void> _loadMemoriesByDate(String date) async {
    final memoryList = await _memoriesService.getMemoriesByDate(date);
    setState(() {
      memories = memoryList;
    });
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
        _loadAllMemories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = <Widget>[
      Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  final date = DateFormat('yyyy-MM-dd').format(pickedDate);
                  setState(() {
                    selectedDate = pickedDate;
                  });
                  _loadMemoriesByDate(date);
                }
              },
              child: Text(selectedDate == null ? 'Select Date' : DateFormat('yyyy-MM-dd').format(selectedDate!)),
            ),
            Expanded(
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
          ],
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
              await _authService.logout();
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
