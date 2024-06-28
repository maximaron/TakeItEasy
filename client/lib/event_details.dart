import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class EventDetailsPage extends StatefulWidget {
  final int eventId;

  EventDetailsPage({required this.eventId});

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();
  String event = '';
  String emotion = '';
  String details = '';
  DateTime? occurredAt;
  TimeOfDay? occurredTime = TimeOfDay.now(); // Инициализация текущим временем

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }

  Future<void> _loadEventDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('http://192.168.1.162:3000/event?token=$token&id=${widget.eventId}'),
    );

    if (response.statusCode == 200) {
      final eventDetails = jsonDecode(response.body);
      setState(() {
        event = eventDetails['event'];
        emotion = eventDetails['emotion'];
        details = eventDetails['details'];
        occurredAt = DateTime.parse(eventDetails['occurred_at']).toLocal();
        occurredTime = TimeOfDay.fromDateTime(occurredAt!);
      });
    }
  }

  Future<void> _updateEvent() async {
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
      ).toUtc();

      final response = await http.put(
        Uri.parse('http://192.168.1.162:3000/event'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'token': token!,
          'id': widget.eventId.toString(),
          'event': event,
          'emotion': emotion,
          'details': details,
          'occurred_at': dateTime.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Event updated successfully!')));
        setState(() {
          isEditing = false;
        });
        _loadEventDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update event')));
      }
    }
  }

  Future<void> _deleteEvent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse('http://192.168.1.162:3000/event'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token!,
        'id': widget.eventId.toString(),
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Event deleted successfully!')));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete event')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteEvent,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isEditing
            ? Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Event'),
                initialValue: event,
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
                initialValue: emotion,
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
                decoration: InputDecoration(labelText: 'Details'),
                initialValue: details,
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
                    initialDate: occurredAt ?? DateTime.now(),
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
                onPressed: _updateEvent,
                child: Text('Update Event'),
              ),
            ],
          ),
        )
            : ListView(
          children: [
            ListTile(
              title: Text('Event'),
              subtitle: Text(event),
            ),
            ListTile(
              title: Text('Emotion'),
              subtitle: Text(emotion),
            ),
            ListTile(
              title: Text('Details'),
              subtitle: Text(details),
            ),
            ListTile(
              title: Text('Occurred At'),
              subtitle: Text(occurredAt == null
                  ? ''
                  : '${dateFormat.format(occurredAt!)} at ${timeFormat.format(DateTime(occurredAt!.year, occurredAt!.month, occurredAt!.day, occurredTime!.hour, occurredTime!.minute))}'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
              child: Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }
}
