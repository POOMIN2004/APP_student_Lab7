import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/exam_result.dart';
import '../model/student.dart';
import '../model/course.dart';
import 'package:http/http.dart' as http;

class EditExamResultScreen extends StatefulWidget {
  const EditExamResultScreen({super.key});

  @override
  State<EditExamResultScreen> createState() => _EditExamResultScreenState();
}

class _EditExamResultScreenState extends State<EditExamResultScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController pointController = TextEditingController();

  String? selectedStudentCode;
  String? selectedCourseCode;

  late Future<List<Student>> students;
  late Future<List<Course>> courses;

  @override
  void initState() {
    super.initState();
    students = fetchStudents();
    courses = fetchCourses();
  }

  @override
  void dispose() {
    pointController.dispose();
    super.dispose();
  }

  Future<List<Student>> fetchStudents() async {
    final response =
        await http.get(Uri.parse('http://192.168.149.209/api/student.php'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Student.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load students');
    }
  }

  Future<List<Course>> fetchCourses() async {
    final response =
        await http.get(Uri.parse('http://192.168.149.209/api/course.php'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Course.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load courses');
    }
  }

  Future<int> addExamResult(ExamResult examResult) async {
    final response = await http.post(
      Uri.parse('http://192.168.149.209/api/exam_result.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'student_code': examResult.studentCode,
        'course_code': examResult.courseCode,
        'point': examResult.point,
      }),
    );

    if (response.statusCode == 200) {
      return response.statusCode;
    } else {
      throw Exception('Failed to add exam result.');
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (selectedStudentCode != null && selectedCourseCode != null) {
        ExamResult newExamResult = ExamResult(
          studentCode: selectedStudentCode!,
          courseCode: selectedCourseCode!,
          point: double.parse(pointController.text),
        );

        int result = await addExamResult(newExamResult);

        if (result == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exam result added successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add exam result.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Exam Result'),
        actions: [
          IconButton(onPressed: _submitForm, icon: const Icon(Icons.save)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              FutureBuilder<List<Student>>(
                future: students,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No students available');
                  } else {
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Student',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedStudentCode,
                      onChanged: (String? value) {
                        setState(() {
                          selectedStudentCode = value;
                        });
                      },
                      items: snapshot.data!.map((Student student) {
                        return DropdownMenuItem<String>(
                          value: student.studentCode,
                          child: Text(student.studentCode),
                        );
                      }).toList(),
                      validator: (value) =>
                          value == null ? 'Please select a student' : null,
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<Course>>(
                future: courses,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No courses available');
                  } else {
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Course',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedCourseCode,
                      onChanged: (String? value) {
                        setState(() {
                          selectedCourseCode = value;
                        });
                      },
                      items: snapshot.data!.map((Course course) {
                        return DropdownMenuItem<String>(
                          value: course.courseCode,
                          child: Text(course.courseCode),
                        );
                      }).toList(),
                      validator: (value) =>
                          value == null ? 'Please select a course' : null,
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: pointController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Point',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the point';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
