import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'edit_student_screen.dart';
import 'add_student_screen.dart';
import 'package:http/http.dart' as http;

import '../model/student.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _StudentScreenState();
  }
}

class _StudentScreenState extends State<StudentScreen> {
  // กำนหดตัวแปรข้อมูล students
  late Future<List<Student>> students;

  @override
  void initState() {
    print("initState"); // สำหรับทดสอบ
    super.initState();
    students = fetchStudents();
  }

  void _refreshData() {
    setState(() {
      print("setState"); // สำหรับทดสอบ
      students = fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    print("build"); // สำหรับทดสอบ
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddStudentScreen(),
                    ));
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Student>>(
          // ชนิดของข้อมูล
          future: students, // ข้อมูล Future
          builder: (context, snapshot) {
            print("builder"); // สำหรับทดสอบ
            print(snapshot.connectionState); // สำหรับทดสอบ
            // กรณีสถานะเป็น waiting ยังไม่มีข้อมูล แสดงตัว loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasData) {
              // กรณีมีข้อมูล
              return Column(
                children: [
                  Container(
                    // สร้างส่วน header ของลิสรายการ
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: Colors.teal.withAlpha(100),
                    ),
                    child: Row(
                      children: [
                        Text(
                            'Total ${snapshot.data!.length} items'), // แสดงจำนวนรายการ
                      ],
                    ),
                  ),
                  Expanded(
                    // ส่วนของลิสรายการ
                    child: snapshot.data!.isNotEmpty // กำหนดเงื่อนไขตรงนี้
                        ? ListView.separated(
                            // กรณีมีรายการ แสดงปกติ
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(snapshot.data![index].studentName),
                                subtitle:
                                    Text(snapshot.data![index].studentCode),
                                trailing: Wrap(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditStudentScreen(
                                                        student: snapshot
                                                            .data![index]),
                                              ));
                                        },
                                        icon: const Icon(Icons.edit)),
                                    IconButton(
                                        onPressed: () async {
                                          await showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  AlertDialog(
                                                    title: const Text(
                                                        'Confirm Delete'),
                                                    content: Expanded(
                                                      child: Text(
                                                          "Do you want to delete: ${snapshot.data![index].studentCode}"),
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        style: TextButton
                                                            .styleFrom(
                                                          foregroundColor:
                                                              Colors.white,
                                                          backgroundColor:
                                                              Colors.redAccent,
                                                        ),
                                                        onPressed: () async {
                                                          await deleteStudent(
                                                              snapshot.data![
                                                                  index]);
                                                          setState(() {
                                                            students =
                                                                fetchStudents();
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            'Delete'),
                                                      ),
                                                      TextButton(
                                                        style: TextButton
                                                            .styleFrom(
                                                          foregroundColor:
                                                              Colors.white,
                                                          backgroundColor:
                                                              Colors.blueGrey,
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child:
                                                            const Text('Close'),
                                                      ),
                                                    ],
                                                  ));
                                        },
                                        icon: const Icon(Icons.delete)),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(),
                          )
                        : const Center(
                            child: Text('No items')), // กรณีไม่มีรายการ
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              // กรณี error
              return Text('${snapshot.error}');
            }
            // กรณีสถานะเป็น waiting ยังไม่มีข้อมูล แสดงตัว loading
            return const CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // ปุ่มทดสอบสำหรับดึงข้อมูลซ้ำ
        onPressed: _refreshData,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

// สรัางฟังก์ชั่นดึงข้อมูล คืนค่ากลับมาเป็นข้อมูล Future ประเภท List ของ Student
Future<List<Student>> fetchStudents() async {
  // ทำการดึงข้อมูลจาก server ตาม url ที่กำหนด
  final response =
      await http.get(Uri.parse('http://192.168.84.209/api/student.php'));

  // เมื่อมีข้อมูลกลับมา
  if (response.statusCode == 200) {
    // ส่งข้อมูลที่เป็น JSON String data ไปทำการแปลง เป็นข้อมูล List<Student
    // โดยใช้คำสั่ง compute ทำงานเบื้องหลัง เรียกใช้ฟังก์ชั่นชื่อ parsestudents
    // ส่งข้อมูล JSON String data ผ่านตัวแปร response.body
    return compute(parsestudents, response.body);
  } else {
    // กรณี error
    throw Exception('Failed to load Student');
  }
}

Future<int> deleteStudent(Student student) async {
  final response = await http.delete(
    Uri.parse(
        'http://192.168.84.209/api/student.php?student_code=${student.studentCode}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return response.statusCode;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to update student.');
  }
}

// ฟังก์ชั่นแปลงข้อมูล JSON String data เป็น เป็นข้อมูล List<Student>
List<Student> parsestudents(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Student>((json) => Student.fromJson(json)).toList();
}
