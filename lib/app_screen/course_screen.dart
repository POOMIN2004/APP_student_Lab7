import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'edit_course_screen.dart';
import 'add_course_screen.dart';
import 'package:http/http.dart' as http;

import '../model/course.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<StatefulWidget> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  late Future<List<Course>> courses;

  @override
  void initState() {
    super.initState();
    courses = fetchCourses();
  }

  void _refreshData() {
    setState(() {
      courses = fetchCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddCourseScreen(),
                  ));
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Course>>(
          future: courses,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasData) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: Colors.teal.withAlpha(100),
                    ),
                    child: Row(
                      children: [
                        Text('Total ${snapshot.data!.length} items'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: snapshot.data!.isNotEmpty
                        ? ListView.separated(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(snapshot.data![index].courseName),
                                subtitle:
                                    Text(snapshot.data![index].courseCode),
                                trailing: Wrap(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        // Navigate to edit course screen
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditCourseScreen(
                                              course: snapshot.data![index],
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.edit),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        await showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title: const Text('Confirm Delete'),
                                            content: Text(
                                                "Do you want to delete: ${snapshot.data![index].courseCode}?"),
                                            actions: <Widget>[
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                ),
                                                onPressed: () async {
                                                  try {
                                                    await deleteCourse(
                                                        snapshot.data![index]);
                                                    _refreshData();
                                                    Navigator.pop(context);
                                                  } catch (e) {
                                                    // Show error snackbar
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            'Failed to delete course: $e'),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: const Text('Delete'),
                                              ),
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor:
                                                      Colors.blueGrey,
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Close'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.delete),
                                    ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(),
                          )
                        : const Center(child: Text('No items')),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

Future<List<Course>> fetchCourses() async {
  final response =
      await http.get(Uri.parse('http://192.168.149.209/api/course.php'));

  if (response.statusCode == 200) {
    return compute(parseCourses, response.body);
  } else {
    throw Exception('Failed to load courses');
  }
}

Future<void> deleteCourse(Course course) async {
  final response = await http.delete(
    Uri.parse(
        'http://192.168.149.209/api/course.php?course_code=${course.courseCode}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete course');
  }
}

Future<void> updateCourse(Course course) async {
  final response = await http.put(
    Uri.parse(
        'http://192.168.149.209/api/course.php?course_code=${course.courseCode}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'course_name': course.courseName,
      'credit': course.credit.toString(),
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update course');
  }
}

List<Course> parseCourses(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Course>((json) => Course.fromJson(json)).toList();
}
