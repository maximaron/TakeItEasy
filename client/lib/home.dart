import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'services/memories_service.dart';
import 'memories.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
    _loadSavedDateAndMemories();
  }

  Future<void> _loadUserInfo() async {
    String? userName = await _authService.getName();
    setState(() {
      name = userName;
    });
  }

  Future<void> _loadSavedDateAndMemories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? date = prefs.getString('selectedDate');
    if (date != null) {
      selectedDate = DateFormat('yyyy-MM-dd').parse(date);
    } else {
      selectedDate = DateTime.now();
      await _saveSelectedDate(selectedDate!);
    }
    _loadMemoriesByDate(DateFormat('yyyy-MM-dd').format(selectedDate!));
  }

  Future<void> _loadMemoriesByDate(String date) async {
    final memoryList = await _memoriesService.getMemoriesByDate(date);
    setState(() {
      memories = memoryList;
    });
  }

  Future<void> _saveSelectedDate(DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedDate', DateFormat('yyyy-MM-dd').format(date));
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
        _loadMemoriesByDate(DateFormat('yyyy-MM-dd').format(selectedDate!));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = <Widget>[
      Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await _authService.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            )
          ],
        ),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    final date = DateFormat('yyyy-MM-dd').format(pickedDate);
                    setState(() {
                      selectedDate = pickedDate;
                    });
                    await _saveSelectedDate(pickedDate);
                    _loadMemoriesByDate(date);
                  }
                },
                child: Text(selectedDate == null ? 'Select Date' : DateFormat('yyyy-MM-dd').format(selectedDate!)),
              ),
              Expanded(
                child: memories.isEmpty
                    ? name == null
                    ? const CircularProgressIndicator()
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
      ),
      const MemoriesPage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
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
