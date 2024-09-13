import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/course.dart'; // Ensure the correct path to your model
import 'package:http/http.dart' as http;

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  int dropdownValue = 1; // Default value for the dropdown

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Course"),
        actions: [
          IconButton(
            onPressed: () async {
              // Validate input fields
              if (codeController.text.isNotEmpty &&
                  nameController.text.isNotEmpty) {
                try {
                  final int responseCode = await addCourse(Course(
                    courseCode: codeController.text,
                    courseName: nameController.text,
                    credit: dropdownValue,
                  ));
                  if (responseCode == 200) {
                    Navigator.pop(context);
                  } else {
                    _showErrorSnackbar(context, 'Failed to add course.');
                  }
                } catch (e) {
                  _showErrorSnackbar(context, 'An error occurred: $e');
                }
              } else {
                _showErrorSnackbar(context, 'Please fill all fields.');
              }
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Course Code',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Course Name',
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: dropdownValue,
              onChanged: (int? value) {
                setState(() {
                  dropdownValue = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Credit',
                border: OutlineInputBorder(),
              ),
              items: [1, 2, 3, 4, 5].map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<int> addCourse(Course course) async {
  final response = await http.post(
    Uri.parse('http://192.168.149.209/api/course.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'course_code': course.courseCode,
      'course_name': course.courseName,
      'credit': course.credit.toString(),
    }),
  );

  return response.statusCode;
}
