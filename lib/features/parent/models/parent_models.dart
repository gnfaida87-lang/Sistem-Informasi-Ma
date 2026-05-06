// lib/parent/models/parent_models.dart

class ChildSchedule {
  final String id;
  final String studentId;
  final String studentName;
  final String subjectName;
  final String className;
  final String day;
  final String startTime;
  final String endTime;

  ChildSchedule({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.subjectName,
    required this.className,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory ChildSchedule.fromJson(Map<String, dynamic> json) => ChildSchedule(
        id: json['id'],
        studentId: json['student_id'],
        studentName: json['students']?['name'] ?? '',
        subjectName: json['subjects']?['name'] ?? '',
        className: json['classes']?['name'] ?? '',
        day: json['day'] ?? json['day_of_week'] ?? '',
        startTime: json['start_time'],
        endTime: json['end_time'],
      );
}

class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime publishedAt;
  final String targetRole; // 'all' | 'guru' | 'ortu'

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedAt,
    required this.targetRole,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        publishedAt: DateTime.parse(json['published_at'] ?? json['created_at']),
        targetRole: json['target_role'] ?? 'all',
      );
}

class ParentChildProfile {
  final String parentId;
  final String parentName;
  final String childId;
  final String childName;
  final String childClass;
  final String classId;
  final String waliKelasName;
  final String? childNis;

  ParentChildProfile({
    required this.parentId,
    required this.parentName,
    required this.childId,
    required this.childName,
    required this.childClass,
    required this.classId,
    required this.waliKelasName,
    this.childNis,
  });

  factory ParentChildProfile.fromSupabase(Map<String, dynamic> data) {
    // Navigasi melalui join: orang_tua -> orang_tua_siswa -> siswa -> kelas -> guru (wali)
    final student = data['orang_tua_siswa'][0]['siswa'];
    final classroom = student['kelas'];
    final teacher = classroom != null ? classroom['guru'] : null;

    return ParentChildProfile(
      parentId: data['id'],
      parentName: data['nama'],
      childId: student['id'],
      childName: student['nama'],
      childNis: student['nis'],
      classId: classroom != null ? classroom['id'] : '',
      childClass: classroom != null ? classroom['nama'] : 'Belum ada kelas',
      waliKelasName: teacher != null ? teacher['nama'] : 'Belum ditentukan',
    );
  }
}

class ChildAttendanceSummary {
  final String status;
  final String time;
  final DateTime date;

  ChildAttendanceSummary({
    required this.status,
    required this.time,
    required this.date,
  });
}
