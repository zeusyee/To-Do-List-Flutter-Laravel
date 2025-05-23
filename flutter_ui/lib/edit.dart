import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EditTodoPage extends StatefulWidget {
  final Map todo;
    final int id;
  const EditTodoPage({super.key, required this.todo, required this.id});
  @override
  State<EditTodoPage> createState() => _EditTodoPageState();
}

class _EditTodoPageState extends State<EditTodoPage> {
  late TextEditingController listController;
  late TextEditingController dateController;
  late TextEditingController descriptionController;
  late String status;


  @override
  void initState() {
    super.initState();
    listController = TextEditingController(text: widget.todo['list']);
    dateController = TextEditingController(text: widget.todo['tanggal']);
    descriptionController = TextEditingController(text: widget.todo['deskripsi']);
    status = widget.todo['status'];
  }

  Future<void> updateTodo() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User belum login')),
    );
    return;
  }

    final response = await http.put(
    Uri.parse('http://127.0.0.1:8000/api/edit/${widget.id}'),
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
    }),
    );

  if (response.statusCode == 200) {
    Navigator.pop(context, true);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gagal mengedit to-do')),
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
                'Edit List',
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
                onPressed: updateTodo,
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
