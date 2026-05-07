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
        id: json['id']?.toString() ?? '',
        studentId: json['student_id']?.toString() ?? '',
        studentName: json['student_name'] ?? '',
        subjectName: json['subject_name'] ?? '',
        className: json['class_name'] ?? '',
        day: json['day'] ?? json['day_of_week'] ?? '',
        startTime: json['start_time'] ?? '',
        endTime: json['end_time'] ?? '',
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

  factory ParentChildProfile.fromMap(Map<String, dynamic> data) {
    return ParentChildProfile(
      parentId: data['id']?.toString() ?? '',
      parentName: data['name'] ?? data['nama'] ?? '',
      childId: data['student_id']?.toString() ?? '',
      childName: data['student_name'] ?? '',
      childClass: data['class_name'] ?? 'Belum ada kelas',
      classId: data['class_id']?.toString() ?? '',
      waliKelasName: data['teacher_name'] ?? 'Belum ditentukan',
      childNis: data['nis'],
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
