// lib/teacher/models/teacher_models.dart

class TeachingSchedule {
  final String id;
  final String teacherId;
  final String subjectId;
  final String classId;
  final String day;        
  final String startTime;
  final String endTime;
  final String? className;
  final String? subjectName;

  TeachingSchedule({
    required this.id,
    required this.teacherId,
    required this.subjectId,
    required this.classId,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.className,
    this.subjectName,
  });

  factory TeachingSchedule.fromJson(Map<String, dynamic> json) {
    // Handle data dari join table jam_pelajaran
    final jamData = json['jam_pelajaran'];
    
    return TeachingSchedule(
      id: json['id']?.toString() ?? '',
      teacherId: json['guru_id']?.toString() ?? '',
      subjectId: json['mapel_id']?.toString() ?? '',
      classId: json['kelas_id']?.toString() ?? '',
      day: jamData != null ? (jamData['hari'] ?? '') : (json['day'] ?? ''),
      startTime: jamData != null ? (jamData['waktu_mulai'] ?? '') : (json['start_time'] ?? ''),
      endTime: jamData != null ? (jamData['waktu_selesai'] ?? '') : (json['end_time'] ?? ''),
      className: json['kelas']?['nama'],
      subjectName: json['mapel']?['nama'],
    );
  }
}

class BimbelSession {
  final String id;
  final String? programId;
  final String? programName;
  final String teacherId;
  final String topic;
  final DateTime sessionDate;
  final int durationMinutes;

  BimbelSession({
    required this.id,
    this.programId,
    this.programName,
    required this.teacherId,
    required this.topic,
    required this.sessionDate,
    required this.durationMinutes,
  });

  factory BimbelSession.fromJson(Map<String, dynamic> json) => BimbelSession(
        id: json['id'],
        programId: json['program_id'],
        programName: json['program_bimbel']?['nama'],
        teacherId: json['teacher_id'],
        topic: json['topic'] ?? '',
        sessionDate: DateTime.parse(json['session_date']),
        durationMinutes: json['duration_minutes'] ?? 0,
      );
}

class BimbelProgress {
  final String id;
  final String sessionId;
  final String studentId;
  final String notes;
  final int score;

  BimbelProgress({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.notes,
    required this.score,
  });

  Map<String, dynamic> toJson() => {
        if (id.isNotEmpty) 'id': id,
        'session_id': sessionId,
        'student_id': studentId,
        'notes': notes,
        'score': score,
      };
}
