import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/app_screen/course_screen.dart';
import 'package:flutter_application_1/app_screen/exam_result_screen.dart';
import 'package:flutter_application_1/app_screen/student_screen.dart';
// import 'package:flutter_application_1/model/student.dart';

import '../model/course.dart';
import 'package:http/http.dart' as http;

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
        backgroundColor: Colors.greenAccent,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  TextButton(
                    child: const Column(
                      children: [
                        Icon(
                          Icons.person_rounded,
                          size: 100.0,
                          color: Colors.blueAccent,
                        ),
                        Text('Student')
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StudentScreen(),
                          ));
                    },
                  ),
                  TextButton(
                    child: const Column(
                      children: [
                        Icon(
                          Icons.import_contacts,
                          size: 100.0,
                          color: Colors.redAccent,
                        ),
                        Text('Course')
                      ],
                    ),
                    onPressed: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CourseScreen(),
                          ));
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    child: const Column(
                      children: [
                        Icon(
                          Icons.grading,
                          size: 100.0,
                          color: Colors.yellowAccent,
                        ),
                        Text('Exan Result')
                      ],
                    ),
                    onPressed: () async {
                      List<Course> courses = await fetchCourses();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExamResultScreen(
                              courses: courses,
                            ),
                          ));
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// สรัางฟังก์ชั่นดึงข้อมูล คืนค่ากลับมาเป็นข้อมูล Future ประเภท List ของ Course
Future<List<Course>> fetchCourses() async {
  // ทำการดึงข้อมูลจาก server ตาม url ที่กำหนด
  final response =
      await http.get(Uri.parse('http://192.168.84.209/api/course.php'));

  // เมื่อมีข้อมูลกลับมา
  if (response.statusCode == 200) {
    // ส่งข้อมูลที่เป็น JSON String data ไปทำการแปลง เป็นข้อมูล List<Course
    // โดยใช้คำสั่ง compute ทำงานเบื้องหลัง เรียกใช้ฟังก์ชั่นชื่อ parsecourses
    // ส่งข้อมูล JSON String data ผ่านตัวแปร response.body
    return compute(parseCourses, response.body);
  } else {
    // กรณี error
    throw Exception('Failed to load Course');
  }
}

// ฟังก์ชั่นแปลงข้อมูล JSON String data เป็น เป็นข้อมูล List<Course>
List<Course> parseCourses(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Course>((json) => Course.fromJson(json)).toList();
}
