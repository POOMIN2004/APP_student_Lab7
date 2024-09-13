import 'dart:convert';

import 'package:flutter/material.dart';
import '../model/course.dart';
import 'package:http/http.dart' as http;

class EditCourseScreen extends StatefulWidget {
  final Course? course;
  const EditCourseScreen({super.key, this.course});

  @override
  State<EditCourseScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditCourseScreen> {
  late Course course;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  int dropdownValue = 0;

  @override
  void initState() {
    super.initState();
    course = widget.course!;
    codeController.text = course.courseCode;
    nameController.text = course.courseName;
    dropdownValue = course.credit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Course"),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                final int responseCode = await updateCourse(Course(
                  courseCode: course.courseCode,
                  courseName: nameController.text,
                  credit: dropdownValue,
                ));
                if (responseCode == 200) {
                  Navigator.pop(context);
                } else {
                  _showErrorSnackbar(context, 'Failed to update course.');
                }
              } catch (e) {
                _showErrorSnackbar(context, 'An error occurred: $e');
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
              enabled: false,
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

Future<int> updateCourse(Course course) async {
  final response = await http.put(
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
