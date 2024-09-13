import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/student.dart'; // Make sure this path is correct
import 'package:http/http.dart' as http;

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  String dropdownValue = "F"; // Default value for the dropdown

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Student"),
        actions: [
          IconButton(
            onPressed: () async {
              // Check if the fields are not empty
              if (codeController.text.isNotEmpty &&
                  nameController.text.isNotEmpty) {
                int rt = await addStudent(Student(
                  studentCode: codeController.text,
                  studentName: nameController.text,
                  gender: dropdownValue,
                ));
                if (rt == 200) {
                  // Check if the status code is 200 OK
                  Navigator.pop(context);
                }
              } else {
                // Show a message if fields are empty
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please fill all fields."),
                  ),
                );
              }
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Student Code',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Student Name',
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: dropdownValue,
              onChanged: (String? value) {
                setState(() {
                  dropdownValue = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              items: [
                'F',
                'M',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Text(value),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

Future<int> addStudent(Student student) async {
  final response = await http.post(
    Uri.parse('http://192.168.149.209/api/student.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'student_code': student.studentCode,
      'student_name': student.studentName,
      'gender': student.gender,
    }),
  );

  if (response.statusCode == 200) {
    return response.statusCode;
  } else {
    throw Exception('Failed to add student.');
  }
}
