class Student {
  final String studentCode;
  final String studentName;
  final String gender;
 
  Student({
    required this.studentCode,
    required this.studentName,
    required this.gender,
  });
 
  // ส่วนของ name constructor ที่จะแปลง json string มาเป็น Student object
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentCode: json['student_code'],
      studentName: json['student_name'],
      gender: json['gender'],
    );
  }
}