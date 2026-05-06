# PERBAIKAN_WAKAKUR.md
# Analisis & Perbaikan Modul Wakil Kurikulum — SI Madrasah
> Flutter + Supabase | Versi 1.0 | April 2026  
> **Instruksi untuk AI:** Baca dokumen ini secara berurutan. Setiap bagian berisi `STATUS`, `MASALAH`, `STRUKTUR FILE`, dan `PERBAIKAN KODE` yang harus dikerjakan. Jangan loncat section. Konfirmasi tiap perbaikan sebelum lanjut.

---

## RINGKASAN MASALAH WAKAKUR

| Menu | Status | Masalah Utama |
|---|---|---|
| Master Akademik | ⚠️ Perlu audit | Data belum terhubung ke Operator |
| Jadwal Pelajaran | ⚠️ Perlu audit | Belum ada validasi konflik jadwal |
| Jadwal Ujian | ❌ Belum sinkron | Data tidak real-time dari Supabase |
| Monitoring Akademik | ❌ Belum sinkron | Data tidak real-time dari Supabase |
| Rapor | ❌ Belum sinkron | Data nilai tidak terhubung ke jadwal/siswa |
| Kenaikan Kelas — Kriteria | ❌ Tombol nonaktif | `Perbarui Kebijakan Kriteria` tidak berfungsi |
| Kenaikan Kelas — Proses Naik | ❌ Banyak fitur nonaktif | Pilih kelas, Eksekusi Massal, tombol lain tidak aktif |
| Kenaikan Kelas — Arsip Alumni | ❌ Tombol nonaktif | `Lihat Riwayat` tidak berfungsi |

---

## REFERENSI STRUKTUR IDEAL

> **Instruksi untuk AI:** Semua file baru harus mengikuti struktur ini. Jangan taruh logika bisnis di dalam screen.

```
lib/academic_config/
├── models/
│   ├── academic_models.dart       ✅ sudah ada
│   ├── scheduling_models.dart     ✅ sudah ada
│   ├── school_models.dart         ✅ sudah ada
│   ├── exam_models.dart           ← BUAT BARU (Jadwal Ujian)
│   ├── monitoring_models.dart     ← BUAT BARU (Monitoring Akademik)
│   ├── report_models.dart         ← BUAT BARU (Rapor)
│   └── promotion_models.dart      ← BUAT BARU (Kenaikan Kelas)
├── services/
│   ├── academic_service.dart      ✅ sudah ada — tambah fungsi
│   ├── schedule_service.dart      ✅ sudah ada — tambah fungsi
│   ├── exam_service.dart          ← BUAT BARU
│   ├── monitoring_service.dart    ← BUAT BARU
│   ├── report_service.dart        ← BUAT BARU
│   └── promotion_service.dart     ← BUAT BARU
└── presentation/
    ├── wakakur_dashboard_screen.dart
    ├── wakakur_master_akademik.dart
    ├── wakakur_jadwal_mengajar.dart
    ├── wakakur_jadwal_ujian.dart          ← REFACTOR
    ├── wakakur_monitoring_akademik.dart   ← REFACTOR
    ├── wakakur_rapor.dart                 ← REFACTOR
    └── wakakur_kenaikan.dart              ← REFACTOR BESAR
```

---

## SECTION 1 — MASTER AKADEMIK

**STATUS:** ⚠️ PERLU AUDIT — data master belum terhubung ke tabel Operator

### Masalah

```
lib/academic_config/presentation/wakakur_master_akademik.dart
⚠️ Data siswa dan guru kemungkinan di-hardcode atau fetch tanpa join ke tabel master Operator
⚠️ Tidak ada invalidasi cache saat Operator update data master
```

### Struktur File

```
lib/academic_config/
├── models/
│   └── academic_models.dart     ← TAMBAH model AcademicMaster
└── services/
    └── academic_service.dart    ← TAMBAH fungsi fetch dari tabel master Operator
```

### Perbaikan — Tambah di `academic_models.dart`

```dart
// Tambahkan di lib/academic_config/models/academic_models.dart

class AcademicMaster {
  final String id;
  final String academicYear;   // contoh: '2025/2026'
  final String semester;       // 'Ganjil' | 'Genap'
  final bool isActive;
  final int totalStudents;
  final int totalTeachers;
  final int totalClasses;

  AcademicMaster({
    required this.id,
    required this.academicYear,
    required this.semester,
    required this.isActive,
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalClasses,
  });

  factory AcademicMaster.fromJson(Map<String, dynamic> json) => AcademicMaster(
        id: json['id'],
        academicYear: json['academic_year'],
        semester: json['semester'],
        isActive: json['is_active'] ?? false,
        totalStudents: json['total_students'] ?? 0,
        totalTeachers: json['total_teachers'] ?? 0,
        totalClasses: json['total_classes'] ?? 0,
      );
}
```

### Perbaikan — Tambah di `academic_service.dart`

```dart
// Tambahkan fungsi berikut di class AcademicService

// Fetch ringkasan master akademik aktif
Future<AcademicMaster> fetchActiveMasterAkademik() async {
  try {
    final year = await _supabase
        .from('academic_years')
        .select('id, academic_year, semester, is_active')
        .eq('is_active', true)
        .single();

    final totalStudents = await _supabase
        .from('students')
        .select('id', const FetchOptions(count: CountOption.exact, head: true))
        .eq('is_active', true);

    final totalTeachers = await _supabase
        .from('teachers')
        .select('id', const FetchOptions(count: CountOption.exact, head: true))
        .eq('is_active', true);

    final totalClasses = await _supabase
        .from('classes')
        .select('id', const FetchOptions(count: CountOption.exact, head: true))
        .eq('academic_year_id', year['id']);

    return AcademicMaster(
      id: year['id'],
      academicYear: year['academic_year'],
      semester: year['semester'],
      isActive: year['is_active'],
      totalStudents: totalStudents.count ?? 0,
      totalTeachers: totalTeachers.count ?? 0,
      totalClasses: totalClasses.count ?? 0,
    );
  } catch (e) {
    final err = handleSupabaseError(e);
    logError(err, context: 'fetchActiveMasterAkademik');
    throw err;
  }
}

// Fetch daftar siswa per kelas (untuk dropdown di fitur lain)
Future<List<Map<String, dynamic>>> fetchStudentsByClass(String classId) async {
  try {
    return await _supabase
        .from('students')
        .select('id, nis, name, class_id')
        .eq('class_id', classId)
        .eq('is_active', true)
        .order('name');
  } catch (e) {
    final err = handleSupabaseError(e);
    logError(err, context: 'fetchStudentsByClass');
    throw err;
  }
}
```

---

## SECTION 2 — JADWAL PELAJARAN

**STATUS:** ⚠️ PERLU AUDIT — belum ada validasi konflik jadwal

### Masalah

```
lib/academic_config/presentation/wakakur_jadwal_mengajar.dart
⚠️ Tidak ada pengecekan konflik: guru mengajar 2 kelas di waktu yang sama
⚠️ Tidak ada pengecekan konflik: 1 kelas dijadwalkan 2 mapel di waktu yang sama
⚠️ Perubahan jadwal tidak memicu notifikasi ke Guru (stream belum aktif)
```

### Struktur File

```
lib/academic_config/
├── models/
│   └── scheduling_models.dart   ← TAMBAH model ScheduleConflict
└── services/
    └── schedule_service.dart    ← TAMBAH fungsi validasi konflik
```

### Perbaikan — Tambah di `scheduling_models.dart`

```dart
// Tambahkan di lib/academic_config/models/scheduling_models.dart

class ScheduleConflict {
  final String conflictType;  // 'teacher' | 'class'
  final String day;
  final String startTime;
  final String endTime;
  final String involvedId;    // teacher_id atau class_id yang konflik
  final String description;

  ScheduleConflict({
    required this.conflictType,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.involvedId,
    required this.description,
  });
}
```

### Perbaikan — Tambah di `schedule_service.dart`

```dart
// Tambahkan di class ScheduleService

// Validasi konflik sebelum simpan jadwal baru
Future<List<ScheduleConflict>> checkScheduleConflict({
  required String teacherId,
  required String classId,
  required String day,
  required String startTime,
  required String endTime,
  String? excludeId, // ID jadwal yang sedang diedit (agar tidak konflik dengan dirinya sendiri)
}) async {
  try {
    final conflicts = <ScheduleConflict>[];

    // Cek konflik guru
    var teacherQuery = _supabase
        .from('teaching_schedules')
        .select('id, class_id, start_time, end_time, day')
        .eq('teacher_id', teacherId)
        .eq('day', day);

    if (excludeId != null) teacherQuery = teacherQuery.neq('id', excludeId);
    final teacherSchedules = await teacherQuery;

    for (final s in teacherSchedules) {
      if (_isTimeOverlap(startTime, endTime, s['start_time'], s['end_time'])) {
        conflicts.add(ScheduleConflict(
          conflictType: 'teacher',
          day: day,
          startTime: startTime,
          endTime: endTime,
          involvedId: teacherId,
          description: 'Guru sudah mengajar kelas lain pada waktu ini',
        ));
      }
    }

    // Cek konflik kelas
    var classQuery = _supabase
        .from('teaching_schedules')
        .select('id, teacher_id, start_time, end_time, day')
        .eq('class_id', classId)
        .eq('day', day);

    if (excludeId != null) classQuery = classQuery.neq('id', excludeId);
    final classSchedules = await classQuery;

    for (final s in classSchedules) {
      if (_isTimeOverlap(startTime, endTime, s['start_time'], s['end_time'])) {
        conflicts.add(ScheduleConflict(
          conflictType: 'class',
          day: day,
          startTime: startTime,
          endTime: endTime,
          involvedId: classId,
          description: 'Kelas sudah memiliki jadwal lain pada waktu ini',
        ));
      }
    }

    return conflicts;
  } catch (e) {
    final err = handleSupabaseError(e);
    logError(err, context: 'checkScheduleConflict');
    throw err;
  }
}

bool _isTimeOverlap(
    String newStart, String newEnd, String existStart, String existEnd) {
  // Format: 'HH:mm'
  final ns = _timeToMinutes(newStart);
  final ne = _timeToMinutes(newEnd);
  final es = _timeToMinutes(existStart);
  final ee = _timeToMinutes(existEnd);
  return ns < ee && ne > es;
}

int _timeToMinutes(String time) {
  final parts = time.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}
```

### Perbaikan — Cara pakai di screen sebelum simpan jadwal

```dart
// Di wakakur_jadwal_mengajar.dart, sebelum panggil addSchedule:
Future<void> _saveSchedule() async {
  final conflicts = await _scheduleService.checkScheduleConflict(
    teacherId: selectedTeacherId,
    classId: selectedClassId,
    day: selectedDay,
    startTime: startTime,
    endTime: endTime,
  );

  if (conflicts.isNotEmpty) {
    // Tampilkan dialog konflik — jangan izinkan simpan
    if (mounted) {
      context.showErrorDialog(
        conflicts.map((c) => c.description).join('\n'),
        title: 'Konflik Jadwal Ditemukan',
      );
    }
    return;
  }

  // Lanjut simpan jika tidak ada konflik
  safeCall(
    context: context,
    successMessage: 'Jadwal berhasil disimpan',
    action: () => _scheduleService.addSchedule(schedule),
  );
}
```

---

## SECTION 3 — JADWAL UJIAN

**STATUS:** ❌ BELUM SINKRON — data tidak real-time dari Supabase

### Masalah

```
lib/academic_config/presentation/wakakur_jadwal_ujian.dart
❌ Data jadwal ujian kemungkinan di-fetch sekali (Future) tanpa refresh
❌ Tidak ada sinkronisasi dengan data siswa dan kelas dari master Operator
❌ Belum ada validasi: ujian tidak boleh bentrok dengan jadwal pelajaran
❌ Tidak ada notifikasi ke Guru saat jadwal ujian dibuat/diubah
```

### Struktur File

```
lib/academic_config/
├── models/
│   └── exam_models.dart          ← BUAT BARU
└── services/
    └── exam_service.dart         ← BUAT BARU
```

### Perbaikan — Buat `exam_models.dart`

```dart
// lib/academic_config/models/exam_models.dart

enum ExamType { uts, uas, harian, praktik }

class ExamSchedule {
  final String id;
  final String subjectId;
  final String subjectName;
  final String classId;
  final String className;
  final String teacherId;
  final String teacherName;
  final ExamType examType;
  final DateTime examDate;
  final String startTime;
  final String endTime;
  final String room;
  final String academicYearId;

  ExamSchedule({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.classId,
    required this.className,
    required this.teacherId,
    required this.teacherName,
    required this.examType,
    required this.examDate,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.academicYearId,
  });

  factory ExamSchedule.fromJson(Map<String, dynamic> json) => ExamSchedule(
        id: json['id'],
        subjectId: json['subject_id'],
        subjectName: json['subjects']?['name'] ?? '',
        classId: json['class_id'],
        className: json['classes']?['name'] ?? '',
        teacherId: json['teacher_id'],
        teacherName: json['teachers']?['name'] ?? '',
        examType: ExamType.values.firstWhere(
          (e) => e.name == json['exam_type'],
          orElse: () => ExamType.harian,
        ),
        examDate: DateTime.parse(json['exam_date']),
        startTime: json['start_time'],
        endTime: json['end_time'],
        room: json['room'] ?? '',
        academicYearId: json['academic_year_id'],
      );

  Map<String, dynamic> toJson() => {
        'subject_id': subjectId,
        'class_id': classId,
        'teacher_id': teacherId,
        'exam_type': examType.name,
        'exam_date': examDate.toIso8601String().split('T').first,
        'start_time': startTime,
        'end_time': endTime,
        'room': room,
        'academic_year_id': academicYearId,
      };
}
```

### Perbaikan — Buat `exam_service.dart`

```dart
// lib/academic_config/services/exam_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exam_models.dart';
import '../../core/utils/error_handler.dart';

class ExamService {
  final _supabase = Supabase.instance.client;

  // One-shot fetch semua jadwal ujian
  Future<List<ExamSchedule>> fetchExamSchedules(String academicYearId) async {
    try {
      final response = await _supabase
          .from('exam_schedules')
          .select('''
            id, subject_id, class_id, teacher_id,
            exam_type, exam_date, start_time, end_time, room, academic_year_id,
            subjects(name),
            classes(name),
            teachers(name)
          ''')
          .eq('academic_year_id', academicYearId)
          .order('exam_date');
      return response.map((e) => ExamSchedule.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchExamSchedules');
      throw err;
    }
  }

  // Real-time stream — sinkron otomatis saat ada perubahan
  Stream<List<ExamSchedule>> streamExamSchedules(String academicYearId) {
    return _supabase
        .from('exam_schedules')
        .stream(primaryKey: ['id'])
        .eq('academic_year_id', academicYearId)
        .map((data) => data.map((e) => ExamSchedule.fromJson(e)).toList());
  }

  Future<void> addExamSchedule(ExamSchedule exam) async {
    try {
      await _supabase.from('exam_schedules').insert(exam.toJson());
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'addExamSchedule');
      throw err;
    }
  }

  Future<void> updateExamSchedule(String id, ExamSchedule exam) async {
    try {
      await _supabase
          .from('exam_schedules')
          .update(exam.toJson())
          .eq('id', id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'updateExamSchedule');
      throw err;
    }
  }

  Future<void> deleteExamSchedule(String id) async {
    try {
      await _supabase.from('exam_schedules').delete().eq('id', id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'deleteExamSchedule');
      throw err;
    }
  }
}
```

### Perbaikan — Refactor `wakakur_jadwal_ujian.dart`

```dart
// Pola yang harus dipakai di wakakur_jadwal_ujian.dart
// Ganti Future biasa dengan StreamBuilder agar data real-time

class _WakakurJadwalUjianState extends State<WakakurJadwalUjian>
    with SafeAsync {

  final _examService = ExamService();
  late Stream<List<ExamSchedule>> _examStream;
  String _activeAcademicYearId = '';

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  Future<void> _initStream() async {
    // Ambil tahun ajaran aktif dulu
    final academicService = AcademicService();
    final year = await academicService.fetchActiveAcademicYear();
    setState(() {
      _activeAcademicYearId = year.id;
      _examStream = _examService.streamExamSchedules(year.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ExamSchedule>>(
      stream: _examStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final exams = snapshot.data ?? [];
        // Render list jadwal ujian di sini
        return _buildExamList(exams);
      },
    );
  }
}
```

---

## SECTION 4 — MONITORING AKADEMIK

**STATUS:** ❌ BELUM SINKRON — data tidak real-time

### Masalah

```
lib/academic_config/presentation/wakakur_monitoring_akademik.dart
❌ Data kehadiran, nilai, dan progress belajar tidak diperbarui real-time
❌ Tidak ada filter per kelas atau per mata pelajaran
❌ Tidak ada indikator siswa yang berisiko (kehadiran < 85%, nilai tidak tuntas)
```

### Struktur File

```
lib/academic_config/
├── models/
│   └── monitoring_models.dart     ← BUAT BARU
└── services/
    └── monitoring_service.dart    ← BUAT BARU
```

### Perbaikan — Buat `monitoring_models.dart`

```dart
// lib/academic_config/models/monitoring_models.dart

class StudentMonitoring {
  final String studentId;
  final String studentName;
  final String className;
  final double attendancePercentage;
  final int failedSubjects;         // jumlah mapel tidak tuntas
  final String attitudeGrade;       // 'A' | 'B' | 'C' | 'D'
  final bool isAtRisk;              // true jika kehadiran < 85% atau failedSubjects >= 3

  StudentMonitoring({
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.attendancePercentage,
    required this.failedSubjects,
    required this.attitudeGrade,
    required this.isAtRisk,
  });

  factory StudentMonitoring.fromJson(Map<String, dynamic> json) {
    final attendance = (json['attendance_percentage'] as num?)?.toDouble() ?? 0.0;
    final failed = json['failed_subjects'] as int? ?? 0;
    return StudentMonitoring(
      studentId: json['student_id'],
      studentName: json['students']?['name'] ?? '',
      className: json['classes']?['name'] ?? '',
      attendancePercentage: attendance,
      failedSubjects: failed,
      attitudeGrade: json['attitude_grade'] ?? 'B',
      isAtRisk: attendance < 85.0 || failed >= 3,
    );
  }
}

class ClassMonitoringSummary {
  final String classId;
  final String className;
  final int totalStudents;
  final int atRiskCount;
  final double avgAttendance;
  final double avgScore;

  ClassMonitoringSummary({
    required this.classId,
    required this.className,
    required this.totalStudents,
    required this.atRiskCount,
    required this.avgAttendance,
    required this.avgScore,
  });

  factory ClassMonitoringSummary.fromJson(Map<String, dynamic> json) =>
      ClassMonitoringSummary(
        classId: json['class_id'],
        className: json['classes']?['name'] ?? '',
        totalStudents: json['total_students'] ?? 0,
        atRiskCount: json['at_risk_count'] ?? 0,
        avgAttendance: (json['avg_attendance'] as num?)?.toDouble() ?? 0.0,
        avgScore: (json['avg_score'] as num?)?.toDouble() ?? 0.0,
      );
}
```

### Perbaikan — Buat `monitoring_service.dart`

```dart
// lib/academic_config/services/monitoring_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/monitoring_models.dart';
import '../../core/utils/error_handler.dart';

class MonitoringService {
  final _supabase = Supabase.instance.client;

  // Real-time monitoring per kelas
  Stream<List<StudentMonitoring>> streamClassMonitoring(String classId) {
    return _supabase
        .from('student_monitoring')
        .stream(primaryKey: ['student_id'])
        .eq('class_id', classId)
        .map((data) => data
            .map((e) => StudentMonitoring.fromJson(e))
            .toList()
          ..sort((a, b) {
            // Tampilkan siswa berisiko di atas
            if (a.isAtRisk && !b.isAtRisk) return -1;
            if (!a.isAtRisk && b.isAtRisk) return 1;
            return a.studentName.compareTo(b.studentName);
          }));
  }

  // Ringkasan per kelas untuk dashboard
  Future<List<ClassMonitoringSummary>> fetchAllClassSummary(
      String academicYearId) async {
    try {
      final response = await _supabase
          .from('class_monitoring_summary')
          .select('''
            class_id, total_students, at_risk_count,
            avg_attendance, avg_score,
            classes(name)
          ''')
          .eq('academic_year_id', academicYearId);
      return response.map((e) => ClassMonitoringSummary.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchAllClassSummary');
      throw err;
    }
  }
}
```

### Perbaikan — Cara pakai di screen

```dart
// Di wakakur_monitoring_akademik.dart
// Gunakan StreamBuilder + filter dropdown kelas

StreamBuilder<List<StudentMonitoring>>(
  stream: _monitoringService.streamClassMonitoring(_selectedClassId),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return const CircularProgressIndicator();
    final students = snapshot.data!;
    final atRisk = students.where((s) => s.isAtRisk).toList();

    return Column(
      children: [
        // Badge siswa berisiko
        if (atRisk.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.red.shade50,
            child: Text(
              '⚠️ ${atRisk.length} siswa berisiko tidak naik kelas',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        // List semua siswa
        ...students.map((s) => _buildStudentMonitoringCard(s)),
      ],
    );
  },
)
```

---

## SECTION 5 — RAPOR

**STATUS:** ❌ BELUM SINKRON — data nilai tidak terhubung ke jadwal/siswa

### Masalah

```
lib/academic_config/presentation/wakakur_rapor.dart
❌ Data nilai tidak diambil dari tabel yang benar di Supabase
❌ Tidak ada mekanisme sinkronisasi nilai dari Guru ke rapor
❌ Tidak ada validasi: semua nilai harus lengkap sebelum rapor bisa dicetak
❌ Tidak ada pembeda antara rapor semester Ganjil dan Genap
```

### Struktur File

```
lib/academic_config/
├── models/
│   └── report_models.dart        ← BUAT BARU
└── services/
    └── report_service.dart       ← BUAT BARU
```

### Perbaikan — Buat `report_models.dart`

```dart
// lib/academic_config/models/report_models.dart

class SubjectGrade {
  final String subjectId;
  final String subjectName;
  final double knowledgeScore;    // Nilai Pengetahuan (0-100)
  final double skillScore;        // Nilai Keterampilan (0-100)
  final String attitudeGrade;     // 'A' | 'B' | 'C' | 'D'
  final String teacherNote;
  final bool isPassed;            // true jika >= KKM

  SubjectGrade({
    required this.subjectId,
    required this.subjectName,
    required this.knowledgeScore,
    required this.skillScore,
    required this.attitudeGrade,
    required this.teacherNote,
    required this.isPassed,
  });

  factory SubjectGrade.fromJson(Map<String, dynamic> json) => SubjectGrade(
        subjectId: json['subject_id'],
        subjectName: json['subjects']?['name'] ?? '',
        knowledgeScore: (json['knowledge_score'] as num?)?.toDouble() ?? 0,
        skillScore: (json['skill_score'] as num?)?.toDouble() ?? 0,
        attitudeGrade: json['attitude_grade'] ?? 'B',
        teacherNote: json['teacher_note'] ?? '',
        isPassed: (json['knowledge_score'] as num?)?.toDouble() >= 70,
      );
}

class StudentReport {
  final String studentId;
  final String studentName;
  final String nis;
  final String className;
  final String academicYear;
  final String semester;
  final List<SubjectGrade> grades;
  final double averageScore;
  final int rank;
  final int totalAbsent;
  final int totalSick;
  final int totalPermission;
  final bool isComplete;          // semua nilai sudah diisi guru

  StudentReport({
    required this.studentId,
    required this.studentName,
    required this.nis,
    required this.className,
    required this.academicYear,
    required this.semester,
    required this.grades,
    required this.averageScore,
    required this.rank,
    required this.totalAbsent,
    required this.totalSick,
    required this.totalPermission,
    required this.isComplete,
  });

  factory StudentReport.fromJson(Map<String, dynamic> json) {
    final grades = (json['grades'] as List<dynamic>? ?? [])
        .map((g) => SubjectGrade.fromJson(g))
        .toList();
    return StudentReport(
      studentId: json['student_id'],
      studentName: json['students']?['name'] ?? '',
      nis: json['students']?['nis'] ?? '',
      className: json['classes']?['name'] ?? '',
      academicYear: json['academic_year'] ?? '',
      semester: json['semester'] ?? '',
      grades: grades,
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0,
      rank: json['rank'] ?? 0,
      totalAbsent: json['total_absent'] ?? 0,
      totalSick: json['total_sick'] ?? 0,
      totalPermission: json['total_permission'] ?? 0,
      isComplete: grades.isNotEmpty &&
          grades.every((g) => g.knowledgeScore > 0),
    );
  }
}
```

### Perbaikan — Buat `report_service.dart`

```dart
// lib/academic_config/services/report_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report_models.dart';
import '../../core/utils/error_handler.dart';

class ReportService {
  final _supabase = Supabase.instance.client;

  // Fetch semua rapor per kelas
  Future<List<StudentReport>> fetchClassReports({
    required String classId,
    required String academicYearId,
    required String semester,
  }) async {
    try {
      final response = await _supabase
          .from('student_reports')
          .select('''
            student_id, average_score, rank,
            total_absent, total_sick, total_permission,
            academic_year, semester,
            students(name, nis),
            classes(name),
            grades:subject_grades(
              subject_id, knowledge_score, skill_score,
              attitude_grade, teacher_note,
              subjects(name)
            )
          ''')
          .eq('class_id', classId)
          .eq('academic_year_id', academicYearId)
          .eq('semester', semester)
          .order('rank');
      return response.map((e) => StudentReport.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchClassReports');
      throw err;
    }
  }

  // Cek kelengkapan nilai sebelum izinkan cetak rapor
  Future<Map<String, int>> checkReportCompleteness(String classId, String academicYearId) async {
    try {
      final reports = await fetchClassReports(
        classId: classId,
        academicYearId: academicYearId,
        semester: 'Ganjil',
      );
      final complete = reports.where((r) => r.isComplete).length;
      final incomplete = reports.length - complete;
      return {'complete': complete, 'incomplete': incomplete, 'total': reports.length};
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'checkReportCompleteness');
      throw err;
    }
  }
}
```

---

## SECTION 6 — KENAIKAN KELAS

**STATUS:** ❌ BANYAK FITUR TIDAK AKTIF

### Screenshot Kondisi Saat Ini

```
Tab: Kriteria Kenaikan
┌────────────────────────────────────────────────────────┐
│ Persentase Kehadiran Minimal              85%          │
│ Nilai Mapel Tidak Tuntas (Maksimal)       3 Mata Pelajaran │
│ Nilai Sikap Minimal                       B (Baik)     │
│ Mengikuti Program Tahfidz/Ekstra          Wajib        │
│                                                        │
│         [ Perbarui Kebijakan Kriteria ]  ← ❌ TIDAK AKTIF │
└────────────────────────────────────────────────────────┘

Tab: Proses Naik Kelas
❌ Tidak bisa pilih siswa per kelas
❌ Tombol "Eksekusi Kenaikan Massal" tidak aktif
❌ Tombol aksi per siswa tidak aktif

Tab: Arsip Alumni
❌ Tombol "Lihat Riwayat" tidak aktif
```

### Masalah Detail

```
lib/academic_config/presentation/wakakur_kenaikan.dart
❌ Tab 1 — onPressed: null pada tombol Perbarui Kebijakan Kriteria
❌ Tab 2 — Tidak ada query untuk fetch siswa per kelas
❌ Tab 2 — onPressed: null pada tombol Eksekusi Kenaikan Massal
❌ Tab 2 — onPressed: null pada tombol aksi per siswa (naik / tidak naik / tunda)
❌ Tab 3 — onPressed: null pada tombol Lihat Riwayat Alumni
❌ Tidak ada model dan service untuk kenaikan kelas
```

### Struktur File

```
lib/academic_config/
├── models/
│   └── promotion_models.dart     ← BUAT BARU
└── services/
    └── promotion_service.dart    ← BUAT BARU
```

### Perbaikan — Buat `promotion_models.dart`

```dart
// lib/academic_config/models/promotion_models.dart

enum PromotionStatus { naik, tidakNaik, tunda, belumDiproses }

class PromotionCriteria {
  final String id;
  final double minAttendancePercentage;   // default: 85.0
  final int maxFailedSubjects;            // default: 3
  final String minAttitudeGrade;          // default: 'B'
  final bool mustJoinExtracurricular;     // default: true
  final String academicYearId;

  PromotionCriteria({
    required this.id,
    required this.minAttendancePercentage,
    required this.maxFailedSubjects,
    required this.minAttitudeGrade,
    required this.mustJoinExtracurricular,
    required this.academicYearId,
  });

  factory PromotionCriteria.fromJson(Map<String, dynamic> json) =>
      PromotionCriteria(
        id: json['id'],
        minAttendancePercentage:
            (json['min_attendance_percentage'] as num?)?.toDouble() ?? 85.0,
        maxFailedSubjects: json['max_failed_subjects'] ?? 3,
        minAttitudeGrade: json['min_attitude_grade'] ?? 'B',
        mustJoinExtracurricular: json['must_join_extracurricular'] ?? true,
        academicYearId: json['academic_year_id'],
      );

  Map<String, dynamic> toJson() => {
        'min_attendance_percentage': minAttendancePercentage,
        'max_failed_subjects': maxFailedSubjects,
        'min_attitude_grade': minAttitudeGrade,
        'must_join_extracurricular': mustJoinExtracurricular,
        'academic_year_id': academicYearId,
      };
}

class StudentPromotionData {
  final String studentId;
  final String studentName;
  final String nis;
  final String currentClassId;
  final String currentClassName;
  final double attendancePercentage;
  final int failedSubjects;
  final String attitudeGrade;
  final bool joinedExtracurricular;
  PromotionStatus status;
  final String? note;

  StudentPromotionData({
    required this.studentId,
    required this.studentName,
    required this.nis,
    required this.currentClassId,
    required this.currentClassName,
    required this.attendancePercentage,
    required this.failedSubjects,
    required this.attitudeGrade,
    required this.joinedExtracurricular,
    this.status = PromotionStatus.belumDiproses,
    this.note,
  });

  // Otomatis tentukan status berdasarkan kriteria
  PromotionStatus evaluateStatus(PromotionCriteria criteria) {
    if (attendancePercentage >= criteria.minAttendancePercentage &&
        failedSubjects <= criteria.maxFailedSubjects &&
        _gradeValue(attitudeGrade) >= _gradeValue(criteria.minAttitudeGrade) &&
        (!criteria.mustJoinExtracurricular || joinedExtracurricular)) {
      return PromotionStatus.naik;
    }
    return PromotionStatus.tidakNaik;
  }

  int _gradeValue(String grade) {
    switch (grade) {
      case 'A': return 4;
      case 'B': return 3;
      case 'C': return 2;
      case 'D': return 1;
      default:  return 0;
    }
  }

  factory StudentPromotionData.fromJson(Map<String, dynamic> json) =>
      StudentPromotionData(
        studentId: json['student_id'],
        studentName: json['students']?['name'] ?? '',
        nis: json['students']?['nis'] ?? '',
        currentClassId: json['class_id'],
        currentClassName: json['classes']?['name'] ?? '',
        attendancePercentage:
            (json['attendance_percentage'] as num?)?.toDouble() ?? 0.0,
        failedSubjects: json['failed_subjects'] ?? 0,
        attitudeGrade: json['attitude_grade'] ?? 'C',
        joinedExtracurricular: json['joined_extracurricular'] ?? false,
        status: PromotionStatus.values.firstWhere(
          (s) => s.name == (json['promotion_status'] ?? 'belumDiproses'),
          orElse: () => PromotionStatus.belumDiproses,
        ),
        note: json['note'],
      );
}

class AlumniRecord {
  final String id;
  final String studentId;
  final String studentName;
  final String nis;
  final String graduationYear;
  final String lastClass;
  final String status; // 'lulus' | 'tidak lulus' | 'pindah'

  AlumniRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.nis,
    required this.graduationYear,
    required this.lastClass,
    required this.status,
  });

  factory AlumniRecord.fromJson(Map<String, dynamic> json) => AlumniRecord(
        id: json['id'],
        studentId: json['student_id'],
        studentName: json['students']?['name'] ?? '',
        nis: json['students']?['nis'] ?? '',
        graduationYear: json['graduation_year'],
        lastClass: json['last_class'] ?? '',
        status: json['status'] ?? 'lulus',
      );
}
```

### Perbaikan — Buat `promotion_service.dart`

```dart
// lib/academic_config/services/promotion_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/promotion_models.dart';
import '../../core/utils/error_handler.dart';

class PromotionService {
  final _supabase = Supabase.instance.client;

  // ── TAB 1: KRITERIA KENAIKAN ─────────────────────────────────────

  Future<PromotionCriteria> fetchCriteria(String academicYearId) async {
    try {
      final response = await _supabase
          .from('promotion_criteria')
          .select('''
            id, min_attendance_percentage, max_failed_subjects,
            min_attitude_grade, must_join_extracurricular, academic_year_id
          ''')
          .eq('academic_year_id', academicYearId)
          .single();
      return PromotionCriteria.fromJson(response);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchCriteria');
      throw err;
    }
  }

  // Fungsi untuk tombol "Perbarui Kebijakan Kriteria"
  Future<void> updateCriteria(PromotionCriteria criteria) async {
    try {
      await _supabase
          .from('promotion_criteria')
          .update(criteria.toJson())
          .eq('id', criteria.id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'updateCriteria');
      throw err;
    }
  }

  // ── TAB 2: PROSES NAIK KELAS ─────────────────────────────────────

  // Fetch siswa per kelas beserta data untuk evaluasi
  Future<List<StudentPromotionData>> fetchStudentsByClass(
      String classId, String academicYearId) async {
    try {
      final response = await _supabase
          .from('student_promotion_data')
          .select('''
            student_id, class_id, attendance_percentage,
            failed_subjects, attitude_grade, joined_extracurricular,
            promotion_status, note,
            students(name, nis),
            classes(name)
          ''')
          .eq('class_id', classId)
          .eq('academic_year_id', academicYearId)
          .order('students(name)');
      return response
          .map((e) => StudentPromotionData.fromJson(e))
          .toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchStudentsByClass');
      throw err;
    }
  }

  // Fungsi untuk tombol aksi per siswa (naik / tidak naik / tunda)
  Future<void> updateStudentPromotionStatus({
    required String studentId,
    required String academicYearId,
    required PromotionStatus status,
    String? note,
  }) async {
    try {
      await _supabase
          .from('student_promotion_data')
          .update({
            'promotion_status': status.name,
            'note': note,
            'processed_at': DateTime.now().toIso8601String(),
          })
          .eq('student_id', studentId)
          .eq('academic_year_id', academicYearId);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'updateStudentPromotionStatus');
      throw err;
    }
  }

  // Fungsi untuk tombol "Eksekusi Kenaikan Massal"
  Future<void> executeMassPromotion({
    required String classId,
    required String academicYearId,
    required PromotionCriteria criteria,
  }) async {
    try {
      final students = await fetchStudentsByClass(classId, academicYearId);

      final updates = students.map((s) {
        final status = s.evaluateStatus(criteria);
        return {
          'student_id': s.studentId,
          'promotion_status': status.name,
          'processed_at': DateTime.now().toIso8601String(),
        };
      }).toList();

      // Batch update semua siswa sekaligus
      for (final update in updates) {
        await _supabase
            .from('student_promotion_data')
            .update({'promotion_status': update['promotion_status'],
                     'processed_at': update['processed_at']})
            .eq('student_id', update['student_id']!)
            .eq('academic_year_id', academicYearId);
      }
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'executeMassPromotion');
      throw err;
    }
  }

  // ── TAB 3: ARSIP ALUMNI ──────────────────────────────────────────

  // Fungsi untuk tombol "Lihat Riwayat"
  Future<List<AlumniRecord>> fetchAlumniHistory({
    String? graduationYear,
  }) async {
    try {
      var query = _supabase
          .from('alumni_records')
          .select('''
            id, student_id, graduation_year, last_class, status,
            students(name, nis)
          ''');

      if (graduationYear != null) {
        query = query.eq('graduation_year', graduationYear);
      }

      final response = await query.order('graduation_year', ascending: false);
      return response.map((e) => AlumniRecord.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchAlumniHistory');
      throw err;
    }
  }
}
```

### Perbaikan — Refactor `wakakur_kenaikan.dart`

```dart
// lib/academic_config/presentation/wakakur_kenaikan.dart
// Perbaikan lengkap per tab

class _WakakurKenaikanState extends State<WakakurKenaikan>
    with SafeAsync, SingleTickerProviderStateMixin {

  late TabController _tabController;
  final _promotionService = PromotionService();

  PromotionCriteria? _criteria;
  List<StudentPromotionData> _students = [];
  List<AlumniRecord> _alumni = [];
  String? _selectedClassId;
  bool _isMassProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCriteria();
  }

  // ── TAB 1: Kriteria Kenaikan ─────────────────────────────────────

  void _loadCriteria() {
    safeCall(
      context: context,
      action: () async {
        final academicService = AcademicService();
        final year = await academicService.fetchActiveAcademicYear();
        final criteria = await _promotionService.fetchCriteria(year.id);
        setState(() => _criteria = criteria);
      },
    );
  }

  // PERBAIKAN: Tombol "Perbarui Kebijakan Kriteria" — sebelumnya onPressed: null
  void _updateCriteria() {
    if (_criteria == null) return;
    safeCall(
      context: context,
      successMessage: 'Kebijakan kriteria berhasil diperbarui',
      action: () => _promotionService.updateCriteria(_criteria!),
    );
  }

  // ── TAB 2: Proses Naik Kelas ─────────────────────────────────────

  // PERBAIKAN: Pilih kelas — trigger fetch siswa
  void _onClassSelected(String classId) {
    setState(() {
      _selectedClassId = classId;
      _students = [];
    });
    _loadStudentsForPromotion(classId);
  }

  void _loadStudentsForPromotion(String classId) {
    safeCall(
      context: context,
      action: () async {
        final academicService = AcademicService();
        final year = await academicService.fetchActiveAcademicYear();
        final students =
            await _promotionService.fetchStudentsByClass(classId, year.id);
        setState(() => _students = students);
      },
    );
  }

  // PERBAIKAN: Tombol aksi per siswa — sebelumnya onPressed: null
  void _updateStudentStatus(StudentPromotionData student, PromotionStatus status) {
    safeCall(
      context: context,
      successMessage: 'Status siswa berhasil diperbarui',
      action: () async {
        final academicService = AcademicService();
        final year = await academicService.fetchActiveAcademicYear();
        await _promotionService.updateStudentPromotionStatus(
          studentId: student.studentId,
          academicYearId: year.id,
          status: status,
        );
        _loadStudentsForPromotion(_selectedClassId!);
      },
    );
  }

  // PERBAIKAN: Tombol "Eksekusi Kenaikan Massal" — sebelumnya onPressed: null
  void _executeMassPromotion() {
    if (_selectedClassId == null || _criteria == null) {
      context.showErrorSnackBar('Pilih kelas dan pastikan kriteria sudah dimuat');
      return;
    }

    // Konfirmasi dulu sebelum eksekusi massal
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Kenaikan Massal'),
        content: const Text(
            'Sistem akan mengevaluasi semua siswa di kelas ini berdasarkan kriteria yang berlaku. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              safeCall(
                context: context,
                successMessage: 'Kenaikan massal berhasil dieksekusi',
                action: () async {
                  final academicService = AcademicService();
                  final year = await academicService.fetchActiveAcademicYear();
                  await _promotionService.executeMassPromotion(
                    classId: _selectedClassId!,
                    academicYearId: year.id,
                    criteria: _criteria!,
                  );
                  _loadStudentsForPromotion(_selectedClassId!);
                },
              );
            },
            child: const Text('Eksekusi'),
          ),
        ],
      ),
    );
  }

  // ── TAB 3: Arsip Alumni ──────────────────────────────────────────

  // PERBAIKAN: Tombol "Lihat Riwayat" — sebelumnya onPressed: null
  void _loadAlumniHistory({String? year}) {
    safeCall(
      context: context,
      action: () async {
        final alumni =
            await _promotionService.fetchAlumniHistory(graduationYear: year);
        setState(() => _alumni = alumni);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Kenaikan Kelas & Kelulusan'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Kriteria Kenaikan'),
            Tab(text: 'Proses Naik Kelas'),
            Tab(text: 'Arsip Alumni'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildKriteriaTab(),
          _buildProsesNaikTab(),
          _buildArsipAlumniTab(),
        ],
      ),
    );
  }

  Widget _buildKriteriaTab() {
    if (_criteria == null) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        _CriteriaItem(
          icon: Icons.calendar_today,
          label: 'Persentase Kehadiran Minimal',
          value: '${_criteria!.minAttendancePercentage.toStringAsFixed(0)}%',
          onEdit: (val) => setState(() =>
              _criteria = PromotionCriteria(
                id: _criteria!.id,
                minAttendancePercentage: double.tryParse(val) ?? 85,
                maxFailedSubjects: _criteria!.maxFailedSubjects,
                minAttitudeGrade: _criteria!.minAttitudeGrade,
                mustJoinExtracurricular: _criteria!.mustJoinExtracurricular,
                academicYearId: _criteria!.academicYearId,
              )),
        ),
        _CriteriaItem(
          icon: Icons.book,
          label: 'Nilai Mapel Tidak Tuntas (Maksimal)',
          value: '${_criteria!.maxFailedSubjects} Mata Pelajaran',
          onEdit: (val) => setState(() =>
              _criteria = PromotionCriteria(
                id: _criteria!.id,
                minAttendancePercentage: _criteria!.minAttendancePercentage,
                maxFailedSubjects: int.tryParse(val) ?? 3,
                minAttitudeGrade: _criteria!.minAttitudeGrade,
                mustJoinExtracurricular: _criteria!.mustJoinExtracurricular,
                academicYearId: _criteria!.academicYearId,
              )),
        ),
        // ... item lainnya

        const Spacer(),

        // PERBAIKAN: Tombol aktif dengan handler yang benar
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _updateCriteria,   // ✅ bukan null
            icon: isLoading
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh),
            label: const Text('Perbarui Kebijakan Kriteria'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProsesNaikTab() {
    return Column(
      children: [
        // Dropdown pilih kelas — PERBAIKAN: fetch dan tampilkan data siswa
        Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<String>(
            value: _selectedClassId,
            decoration: const InputDecoration(
              labelText: 'Pilih Kelas',
              border: OutlineInputBorder(),
            ),
            items: const [], // isi dari fetchAllClasses()
            onChanged: (val) {
              if (val != null) _onClassSelected(val); // ✅ bukan null
            },
          ),
        ),

        if (_students.isNotEmpty) ...[
          // Tombol Eksekusi Massal — PERBAIKAN: aktif dengan konfirmasi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _executeMassPromotion, // ✅ bukan null
              icon: const Icon(Icons.play_arrow),
              label: const Text('Eksekusi Kenaikan Massal'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.green,
              ),
            ),
          ),

          // List siswa dengan tombol aksi per siswa
          Expanded(
            child: ListView.builder(
              itemCount: _students.length,
              itemBuilder: (ctx, i) {
                final s = _students[i];
                return ListTile(
                  title: Text(s.studentName),
                  subtitle: Text(
                      'Kehadiran: ${s.attendancePercentage.toStringAsFixed(1)}% | '
                      'Tidak Tuntas: ${s.failedSubjects} mapel'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // PERBAIKAN: Tombol Naik — aktif
                      IconButton(
                        icon: const Icon(Icons.arrow_upward, color: Colors.green),
                        tooltip: 'Naik Kelas',
                        onPressed: () => _updateStudentStatus(s, PromotionStatus.naik), // ✅
                      ),
                      // PERBAIKAN: Tombol Tidak Naik — aktif
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        tooltip: 'Tidak Naik',
                        onPressed: () => _updateStudentStatus(s, PromotionStatus.tidakNaik), // ✅
                      ),
                      // PERBAIKAN: Tombol Tunda — aktif
                      IconButton(
                        icon: const Icon(Icons.pause, color: Colors.orange),
                        tooltip: 'Tunda',
                        onPressed: () => _updateStudentStatus(s, PromotionStatus.tunda), // ✅
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildArsipAlumniTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            // PERBAIKAN: Tombol Lihat Riwayat — aktif
            onPressed: isLoading ? null : () => _loadAlumniHistory(), // ✅ bukan null
            icon: const Icon(Icons.history),
            label: const Text('Lihat Riwayat'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),

        if (_alumni.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: _alumni.length,
              itemBuilder: (ctx, i) {
                final a = _alumni[i];
                return ListTile(
                  leading: const Icon(Icons.school),
                  title: Text(a.studentName),
                  subtitle: Text('NIS: ${a.nis} | Kelas: ${a.lastClass}'),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(a.graduationYear,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(a.status,
                          style: TextStyle(
                              color: a.status == 'lulus'
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
```

---

## SKEMA DATABASE SUPABASE YANG DIPERLUKAN

> **Instruksi untuk AI:** Jalankan SQL ini di Supabase Dashboard > SQL Editor jika tabel belum ada.

```sql
-- Tabel jadwal ujian
CREATE TABLE IF NOT EXISTS exam_schedules (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_id        UUID REFERENCES subjects(id),
  class_id          UUID REFERENCES classes(id),
  teacher_id        UUID REFERENCES teachers(id),
  academic_year_id  UUID REFERENCES academic_years(id),
  exam_type         TEXT CHECK (exam_type IN ('uts','uas','harian','praktik')),
  exam_date         DATE NOT NULL,
  start_time        TIME NOT NULL,
  end_time          TIME NOT NULL,
  room              TEXT,
  created_at        TIMESTAMPTZ DEFAULT NOW()
);

-- Tabel kriteria kenaikan kelas
CREATE TABLE IF NOT EXISTS promotion_criteria (
  id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  academic_year_id            UUID REFERENCES academic_years(id) UNIQUE,
  min_attendance_percentage   NUMERIC DEFAULT 85.0,
  max_failed_subjects         INT     DEFAULT 3,
  min_attitude_grade          TEXT    DEFAULT 'B',
  must_join_extracurricular   BOOLEAN DEFAULT TRUE,
  updated_at                  TIMESTAMPTZ DEFAULT NOW()
);

-- Tabel data promosi per siswa
CREATE TABLE IF NOT EXISTS student_promotion_data (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id              UUID REFERENCES students(id),
  class_id                UUID REFERENCES classes(id),
  academic_year_id        UUID REFERENCES academic_years(id),
  attendance_percentage   NUMERIC DEFAULT 0,
  failed_subjects         INT     DEFAULT 0,
  attitude_grade          TEXT    DEFAULT 'B',
  joined_extracurricular  BOOLEAN DEFAULT FALSE,
  promotion_status        TEXT    DEFAULT 'belumDiproses'
                          CHECK (promotion_status IN ('naik','tidakNaik','tunda','belumDiproses')),
  note                    TEXT,
  processed_at            TIMESTAMPTZ,
  UNIQUE (student_id, academic_year_id)
);

-- Tabel arsip alumni
CREATE TABLE IF NOT EXISTS alumni_records (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id       UUID REFERENCES students(id),
  graduation_year  TEXT NOT NULL,
  last_class       TEXT,
  status           TEXT DEFAULT 'lulus'
                   CHECK (status IN ('lulus','tidak lulus','pindah')),
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

-- Aktifkan RLS
ALTER TABLE exam_schedules          ENABLE ROW LEVEL SECURITY;
ALTER TABLE promotion_criteria      ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_promotion_data  ENABLE ROW LEVEL SECURITY;
ALTER TABLE alumni_records          ENABLE ROW LEVEL SECURITY;

-- Policy Wakakur bisa akses semua
CREATE POLICY "wakakur_full_access_exam" ON exam_schedules
  FOR ALL TO authenticated
  USING (auth.jwt() ->> 'role' IN ('wakakur', 'superadmin'));

CREATE POLICY "wakakur_full_access_criteria" ON promotion_criteria
  FOR ALL TO authenticated
  USING (auth.jwt() ->> 'role' IN ('wakakur', 'superadmin'));

CREATE POLICY "wakakur_full_access_promotion" ON student_promotion_data
  FOR ALL TO authenticated
  USING (auth.jwt() ->> 'role' IN ('wakakur', 'superadmin'));

-- Guru dan Orang Tua hanya bisa baca
CREATE POLICY "all_read_exam_schedule" ON exam_schedules
  FOR SELECT TO authenticated
  USING (true);
```

---

## CHECKLIST PERBAIKAN WAKAKUR

> Centang satu per satu saat dikerjakan. Jangan tandai selesai sebelum diuji.

### Fase 1 — Model & Service (kerjakan dulu)
- [ ] Buat `exam_models.dart`
- [ ] Buat `exam_service.dart`
- [ ] Buat `monitoring_models.dart`
- [ ] Buat `monitoring_service.dart`
- [ ] Buat `report_models.dart`
- [ ] Buat `report_service.dart`
- [ ] Buat `promotion_models.dart`
- [ ] Buat `promotion_service.dart`
- [ ] Tambah fungsi di `academic_service.dart`
- [ ] Tambah fungsi di `schedule_service.dart`

### Fase 2 — Sinkronisasi Screen
- [ ] Refactor `wakakur_jadwal_ujian.dart` — gunakan StreamBuilder
- [ ] Refactor `wakakur_monitoring_akademik.dart` — gunakan StreamBuilder
- [ ] Refactor `wakakur_rapor.dart` — sinkron dengan data guru

### Fase 3 — Aktivasi Tombol Kenaikan Kelas
- [ ] Tab Kriteria: Tombol `Perbarui Kebijakan Kriteria` aktif
- [ ] Tab Proses: Dropdown pilih kelas — fetch siswa
- [ ] Tab Proses: Tombol `Eksekusi Kenaikan Massal` aktif + konfirmasi dialog
- [ ] Tab Proses: Tombol per siswa (Naik / Tidak Naik / Tunda) aktif
- [ ] Tab Arsip: Tombol `Lihat Riwayat` aktif + filter tahun

### Fase 4 — Database
- [ ] Jalankan SQL buat tabel di Supabase
- [ ] Aktifkan RLS semua tabel baru
- [ ] Uji policy dengan login sebagai Wakakur, Guru, dan Orang Tua

### Fase 5 — Pengujian End-to-End
- [ ] Buat jadwal ujian → tampil di screen Guru real-time
- [ ] Perbarui kriteria kenaikan → tersimpan di Supabase
- [ ] Pilih kelas → muncul daftar siswa
- [ ] Eksekusi kenaikan massal → status siswa terupdate
- [ ] Aksi per siswa (Naik/Tidak Naik/Tunda) → tersimpan
- [ ] Lihat Riwayat Alumni → data muncul

---

*Dokumen ini dibuat untuk dibaca oleh AI coding assistant. Kerjakan secara berurutan mengikuti checklist. Setiap perbaikan sudah disertai struktur folder, model, service, dan kode screen lengkap.*
