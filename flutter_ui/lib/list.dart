import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'create.dart';
import 'edit.dart';
import 'signin_page.dart'; // Pastikan ada halaman SignInPage

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List todos = [];
  bool isLoading = false;

  Future<void> fetchTodos() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      print('Token tidak ditemukan, user belum login.');
      if (!mounted) return;
      setState(() => isLoading = false);
      return;
    }

    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/todos'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      if (!mounted) return;
      setState(() => todos = jsonDecode(response.body));
    } else {
      print('Gagal fetch todos: ${response.statusCode} - ${response.body}');
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> deleteTodo(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      print('Token tidak ditemukan, user belum login.');
      return;
    }

    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/api/todos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('DELETE status: ${response.statusCode}');
    print('DELETE response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      if (!mounted) return;
      fetchTodos();
    } else {
      print('Gagal menghapus: ${response.statusCode}');
    }
  }

  Future<void> toggleIsDone(int id, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      print('Token tidak ditemukan, user belum login.');
      return;
    }

    final response = await http.put(
      Uri.parse('http://127.0.0.1:8000/api/edit/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'selesai': value}),
    );
    print('Update response status: ${response.statusCode}');
    print('Update response body: ${response.body}');
    if (response.statusCode == 200) {
      if (!mounted) return;
      fetchTodos(); // Refresh data
    } else {
      print('Gagal update is_done: ${response.body}');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignInPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF102C57),
      appBar: AppBar(
        backgroundColor: const Color(0xFF102C57),
        title: const Text('To-Do List', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (_, i) {
                final item = todos[i];
                return Card(
                  color: const Color(0xFF1C3A6F),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Checkbox(
                      value: item['selesai'] == 1 || item['selesai'] == true,
                      onChanged: (val) {
                        if (val != null) {
                          toggleIsDone(item['id_todo'], val);
                        }
                      },
                      activeColor: Colors.white,
                      checkColor: const Color(0xFF102C57),
                    ),
                    title: Text(
                    '${item['list'] ?? ''} | ${item['status'] ?? ''}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                    ),
                    ),
                    subtitle: Text(
                      item['tanggal'],
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditTodoPage(
                                  todo: item,
                                  id: item['id_todo'],
                                ),
                              ),
                            );
                            if (updated == true) fetchTodos();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () => deleteTodo(item['id_todo']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1C3A6F),
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateTodoPage(),
            ),
          );
          if (created == true) fetchTodos();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
