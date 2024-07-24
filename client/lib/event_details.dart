import 'package:flutter/material.dart';
import 'services/memories_service.dart';
import 'package:intl/intl.dart';

class EventDetailsPage extends StatefulWidget {
  final int eventId;

  const EventDetailsPage({super.key, required this.eventId});

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
  final MemoriesService _memoriesService = MemoriesService();

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }

  Future<void> _loadEventDetails() async {
    final eventDetails = await _memoriesService.getMemoryById(widget.eventId);
    if (eventDetails != null) {
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
      if (occurredAt == null || occurredTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select date and time')));
        return;
      }

      final dateTime = DateTime(
        occurredAt!.year,
        occurredAt!.month,
        occurredAt!.day,
        occurredTime!.hour,
        occurredTime!.minute,
      ).toUtc();

      bool success = await _memoriesService.updateMemory(widget.eventId, event, emotion, details, dateTime);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event updated successfully!')));
        setState(() {
          isEditing = false;
        });
        _loadEventDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update event')));
      }
    }
  }

  Future<void> _deleteEvent() async {
    bool success = await _memoriesService.deleteMemory(widget.eventId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event deleted successfully!')));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete event')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
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
                decoration: const InputDecoration(labelText: 'Event'),
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
                decoration: const InputDecoration(labelText: 'Emotion'),
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
                decoration: const InputDecoration(labelText: 'Details'),
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
                child: const Text('Update Event'),
              ),
            ],
          ),
        )
            : ListView(
          children: [
            ListTile(
              title: const Text('Event'),
              subtitle: Text(event),
            ),
            ListTile(
              title: const Text('Emotion'),
              subtitle: Text(emotion),
            ),
            ListTile(
              title: const Text('Details'),
              subtitle: Text(details),
            ),
            ListTile(
              title: const Text('Occurred At'),
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
              child: const Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }
}
