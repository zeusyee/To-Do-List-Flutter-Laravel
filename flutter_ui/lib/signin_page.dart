import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'signup_page.dart';
import 'list.dart';

const String apiBaseUrl = 'http://127.0.0.1:8000/api';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();


  bool loading = false;
  String error = '';

  Future<void> signin() async {
    setState(() {
      loading = true;
      error = '';
    });

    final response = await http.post(
      Uri.parse('$apiBaseUrl/signin'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    setState(() {
      loading = false;
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Response body: $data');

      final userId = data['user']?['id'];
      final token = data['token'];

      if (userId != null && token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('id', userId);
        await prefs.setString('token', token);
        await prefs.setString('token', data['token']);
      } else {
        print('User ID atau token tidak ditemukan');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login berhasil')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TodoListPage()),
      );
    } else {
      final data = jsonDecode(response.body);
      setState(() {
        error = data['message'] ?? 'Login gagal';
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF102C57), // Biru tua gelap
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (error.isNotEmpty)
                Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF1C3A6F),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF1C3A6F),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              loading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : ElevatedButton(
                      onPressed: signin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C3A6F),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(fontSize: 16, color: Colors.white),

                      ),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpPage()),
                  );
                },
                child: const Text(
                  'Belum punya akun? Daftar',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

