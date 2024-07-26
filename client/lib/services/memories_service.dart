import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MemoriesService {
  final String baseUrl = 'http://192.168.5.209:3000';

  Future<List> getAllMemories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/memories?token=$token'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }

  Future<List> getMemoriesByDate(String date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/memories?token=$token&date=$date'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }

  Future<bool> addMemory(String event, String emotion, String details, DateTime occurredAt) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/memories'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token!,
        'event': event,
        'emotion': emotion,
        'details': details,
        'occurred_at': occurredAt.toIso8601String(),
      }),
    );

    return response.statusCode == 201;
  }

  Future<Map<String, dynamic>?> getMemoryById(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/event?token=$token&id=$id'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  Future<bool> updateMemory(int id, String event, String emotion, String details, DateTime occurredAt) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.put(
      Uri.parse('$baseUrl/event'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token!,
        'id': id.toString(),
        'event': event,
        'emotion': emotion,
        'details': details,
        'occurred_at': occurredAt.toIso8601String(),
      }),
    );

    return response.statusCode == 200;
  }

  Future<bool> deleteMemory(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse('$baseUrl/event'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token!,
        'id': id.toString(),
      }),
    );

    return response.statusCode == 200;
  }
}
