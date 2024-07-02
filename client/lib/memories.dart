import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class MemoriesPage extends StatefulWidget {
  @override
  _MemoriesPageState createState() => _MemoriesPageState();
}

class _MemoriesPageState extends State<MemoriesPage> {
  final _formKey = GlobalKey<FormState>();
  String event = '';
  String emotion = '';
  String details = '';
  DateTime? occurredAt;
  TimeOfDay? occurredTime = TimeOfDay.now();

  Future<void> _addMemory() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (occurredAt == null || occurredTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select date and time')));
        return;
      }

      final dateTime = DateTime(
        occurredAt!.year,
        occurredAt!.month,
        occurredAt!.day,
        occurredTime!.hour,
        occurredTime!.minute,
      );

      final response = await http.post(
        Uri.parse('http://192.168.5.153:3000/memories'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'token': token!,
          'event': event,
          'emotion': emotion,
          'details': details,
          'occurred_at': dateTime.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Memory added successfully!')));
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add memory')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Memory'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Event'),
                onChanged: (value) {
                  setState(() {
                    event = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Emotion'),
                onChanged: (value) {
                  setState(() {
                    emotion = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your emotion';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Details (optional)'),
                onChanged: (value) {
                  setState(() {
                    details = value;
                  });
                },
              ),
              TextButton(
                child: Text(occurredAt == null ? 'Select Date' : dateFormat.format(occurredAt!)),
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      occurredAt = pickedDate;
                    });
                  }
                },
              ),
              TextButton(
                child: Text(occurredTime == null ? timeFormat.format(DateTime.now()) : occurredTime!.format(context)),
                onPressed: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      occurredTime = pickedTime;
                    });
                  }
                },
              ),
              ElevatedButton(
                onPressed: _addMemory,
                child: Text('Add Memory'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
