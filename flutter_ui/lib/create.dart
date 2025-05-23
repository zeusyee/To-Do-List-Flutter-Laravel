import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'helperss/helper_token.dart';

class CreateTodoPage extends StatefulWidget {
  const CreateTodoPage({super.key});

  @override
  State<CreateTodoPage> createState() => _CreateTodoPageState();
}

class _CreateTodoPageState extends State<CreateTodoPage> {
  final listController = TextEditingController();
  final dateController = TextEditingController();
  final descriptionController = TextEditingController();
  int? userId; // nullable int
  String status = 'low';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId'); // null jika belum login
    });
  }

  Future<void> createTodo() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User belum login')),
    );
    return;
  }

 final response = await http.post(
  Uri.parse('http://127.0.0.1:8000/api/todos'),
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  },
  body: jsonEncode({
    'list': listController.text,
    'tanggal': dateController.text,
    'deskripsi': descriptionController.text,
    'status': status,
    'id_users': userId,
  }),
);

print('Status Code: ${response.statusCode}');
print('Response Body: ${response.body}');

if (response.statusCode == 201) {
  Navigator.pop(context, true);
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Gagal: ${response.body}')),
  );
}
  }


 @override
    Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF0D47A1),
        appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
        ),
        ),
        body: Center(
        child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                ],
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                const Text(
                    'Tambahkan List',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                ),
                const SizedBox(height: 24),
                TextField(
                    controller: listController,
                    decoration: InputDecoration(
                    labelText: 'List',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                ),
                const SizedBox(height: 16),
                TextField(
                    controller: dateController,
                    readOnly: true,
                    onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                        String formattedDate = pickedDate.toIso8601String().split('T')[0];
                        setState(() {
                        dateController.text = formattedDate;
                        });
                    }
                    },
                    decoration: InputDecoration(
                    labelText: 'Tanggal',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                ),
                const SizedBox(height: 16),
                TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                ),
                const SizedBox(height: 16),
                const Text('Prioritas', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButton<String>(
                    value: status,
                    isExpanded: true,
                    underline: Container(),
                    onChanged: (val) => setState(() => status = val!),
                    items: ['low', 'medium', 'high']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: createTodo,
                    child: const Text('Update', style: TextStyle(fontSize: 16)),
                ),
                ],
            ),
            ),
        ),
        ),
    );
    }
}

