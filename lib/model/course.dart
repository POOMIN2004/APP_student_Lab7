class Course {
  final String courseCode;
  final String courseName;
  final int credit;

  Course({
    required this.courseCode,
    required this.courseName,
    required this.credit,
  });

  // ส่วนของ name constructor ที่จะแปลง json string มาเป็น Course object
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseCode: json['course_code'],
      courseName: json['course_name'],
      credit: int.parse(json['credit']),
    );
  }
}
