class TimeSlot {
  final String id;
  final String day;
  final int? slotNumber;
  final String startTime;
  final String endTime;
  final bool isBreak;
  final String? label;

  TimeSlot({
    required this.id,
    required this.day,
    this.slotNumber,
    required this.startTime,
    required this.endTime,
    required this.isBreak,
    this.label,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'],
      day: json['hari'],
      slotNumber: json['jam_ke'],
      startTime: json['waktu_mulai'],
      endTime: json['waktu_selesai'],
      isBreak: json['is_istirahat'] ?? false,
      label: json['label'],
    );
  }

  String get timeRange => '${startTime.substring(0, 5)} - ${endTime.substring(0, 5)}';
}

class ScheduleRow {
  final String id;
  final String semesterId;
  final String classId;
  final String timeSlotId;
  final String teacherId;
  final String subjectId;
  final String? teacherName;
  final String? subjectName;
  final String? day;
  final String? startTime;
  final String? endTime;
  final String? className;

  ScheduleRow({
    required this.id,
    required this.semesterId,
    required this.classId,
    required this.timeSlotId,
    required this.teacherId,
    required this.subjectId,
    this.teacherName,
    this.subjectName,
    this.day,
    this.startTime,
    this.endTime,
    this.className,
  });

  factory ScheduleRow.fromJson(Map<String, dynamic> json) {
    return ScheduleRow(
      id: json['id'],
      semesterId: json['semester_id'],
      classId: json['kelas_id'],
      timeSlotId: json['jam_pelajaran_id'],
      teacherId: json['guru_id'],
      subjectId: json['mapel_id'],
      teacherName: json['guru']?['nama'],
      subjectName: json['mapel']?['nama'],
      day: json['jam_pelajaran']?['hari'],
      startTime: json['jam_pelajaran']?['waktu_mulai'],
      endTime: json['jam_pelajaran']?['waktu_selesai'],
      className: json['kelas']?['nama'],
    );
  }
}
