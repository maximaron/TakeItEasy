import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  DateTime? birthDate;
  String? gender = 'Male';
  String password = '';

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('http://<YOUR_SERVER_IP>:3000/register'), // Измените на ваш IP-адрес
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'birth_date': birthDate?.toIso8601String() ?? '',
          'gender': gender ?? 'Male',
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User registered successfully!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to register user')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: gender,
                decoration: InputDecoration(labelText: 'Gender'),
                items: <String>['Male', 'Female', 'Other']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    gender = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
              TextButton(
                child: Text(birthDate == null ? 'Select Birth Date' : birthDate!.toLocal().toString().split(' ')[0]),
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != birthDate) {
                    setState(() {
                      birthDate = picked;
                    });
                  }
                },
              ),
              ElevatedButton(
                onPressed: _register,
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
