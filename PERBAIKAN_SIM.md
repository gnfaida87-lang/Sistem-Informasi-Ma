# PERBAIKAN_SIM.md
# Dokumen Perbaikan & Konektivitas User — Sistem Informasi Madrasah
> Flutter + Supabase | Versi 1.0 | April 2026  
> **Instruksi untuk AI:** Baca dokumen ini secara berurutan. Setiap bagian berisi `STATUS`, `STRUKTUR`, `MASALAH`, dan `PERBAIKAN` yang harus dikerjakan. Jangan loncat fase. Konfirmasi setiap perbaikan sebelum lanjut ke item berikutnya.

---

## RINGKASAN EKSEKUTIF

| Aspek | Kondisi Saat Ini | Target |
|---|---|---|
| Struktur kode | Tidak konsisten — `finance/`, `master_data/`, `teacher/`, `parent/` belum punya `services/` & `models/` | Semua modul ikuti pola `academic_config/` |
| Fitur | Banyak yang belum jalan | Semua fitur per role berjalan end-to-end |
| Keamanan | RLS Supabase belum dikonfigurasi | RLS aktif di setiap tabel |
| Konektivitas user | 5 pasang user belum terhubung | Semua alur data antar role berjalan |
| Hosting | Belum di-deploy | Live di Firebase Hosting / Vercel / Netlify |

**Statistik proyek:**
- 7 user role
- ~70 file Dart
- 4 fase perbaikan
- 5 koneksi antar user yang hilang
- 26 item checklist total

---

## REFERENSI STRUKTUR IDEAL

> **Instruksi untuk AI:** Gunakan struktur `academic_config/` ini sebagai patokan untuk semua perbaikan di bawah. Setiap modul lain harus mengikuti pola yang sama persis.

```
lib/
└── academic_config/              ✅ REFERENSI — SUDAH BENAR
    ├── models/
    │   ├── academic_models.dart
    │   ├── scheduling_models.dart
    │   └── school_models.dart
    ├── services/
    │   ├── academic_service.dart
    │   └── schedule_service.dart
    └── presentation/
        ├── wakakur_dashboard_screen.dart
        ├── wakakur_jadwal_mengajar.dart
        ├── wakakur_jadwal_ujian.dart
        ├── wakakur_rapor.dart
        ├── wakakur_kenaikan.dart
        ├── wakakur_monitoring_akademik.dart
        └── wakakur_laporan_bimbel.dart
```

**Aturan wajib yang berlaku untuk semua modul:**
- Semua query Supabase → **hanya** di dalam file `*_service.dart`
- Semua class data/model → **hanya** di dalam file `*_models.dart`
- Screen hanya boleh **memanggil service**, tidak boleh import Supabase langsung
- Setiap fungsi service wajib ada `try/catch`
- Hindari `select('*')` — selalu sebutkan kolom secara eksplisit

---

## FASE 1 — PERBAIKAN FONDASI KODE
> **Prioritas: WAJIB SELESAI SEBELUM FASE LAIN**  
> **Instruksi untuk AI:** Kerjakan semua item Fase 1 terlebih dahulu. Jangan mulai Fase 2 sebelum seluruh item di sini selesai.

---

### 1.1 Pemisahan Layer — `finance/`

**STATUS:** ❌ BELUM ADA `models/` dan `services/`

**STRUKTUR SAAT INI (SALAH):**
```
lib/finance/
├── admin_finance_dashboard_screen.dart   ⚠️ logika bisnis campur di sini
├── finance_spp_payment.dart              ⚠️ query Supabase langsung di screen
├── finance_student_savings.dart          ⚠️ query Supabase langsung di screen
├── finance_other_fees.dart               ⚠️ query Supabase langsung di screen
├── finance_operational_expenses.dart     ⚠️ query Supabase langsung di screen
└── finance_reports.dart                  ⚠️ query Supabase langsung di screen
```

**STRUKTUR TARGET (BENAR):**
```
lib/finance/
├── models/
│   └── finance_models.dart              ← BUAT BARU
├── services/
│   └── finance_service.dart             ← BUAT BARU
└── presentation/
    ├── admin_finance_dashboard_screen.dart
    ├── finance_spp_payment.dart
    ├── finance_student_savings.dart
    ├── finance_other_fees.dart
    ├── finance_operational_expenses.dart
    └── finance_reports.dart
```

**PERBAIKAN — Buat `lib/finance/models/finance_models.dart`:**
```dart
// lib/finance/models/finance_models.dart

class SppRecord {
  final String id;
  final String studentId;
  final double amount;
  final DateTime paidAt;
  final String status; // 'lunas' | 'belum' | 'cicilan'
  final String? month;
  final String? year;

  SppRecord({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.paidAt,
    required this.status,
    this.month,
    this.year,
  });

  factory SppRecord.fromJson(Map<String, dynamic> json) => SppRecord(
        id: json['id'],
        studentId: json['student_id'],
        amount: (json['amount'] as num).toDouble(),
        paidAt: DateTime.parse(json['paid_at']),
        status: json['status'],
        month: json['month'],
        year: json['year'],
      );

  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'amount': amount,
        'paid_at': paidAt.toIso8601String(),
        'status': status,
        'month': month,
        'year': year,
      };
}

class Savings {
  final String id;
  final String studentId;
  final double amount;
  final DateTime savedAt;
  final String type; // 'setor' | 'tarik'

  Savings({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.savedAt,
    required this.type,
  });

  factory Savings.fromJson(Map<String, dynamic> json) => Savings(
        id: json['id'],
        studentId: json['student_id'],
        amount: (json['amount'] as num).toDouble(),
        savedAt: DateTime.parse(json['saved_at']),
        type: json['type'],
      );

  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'amount': amount,
        'saved_at': savedAt.toIso8601String(),
        'type': type,
      };
}

class OtherFee {
  final String id;
  final String name;
  final double amount;
  final String studentId;
  final DateTime dueDate;
  final String status;

  OtherFee({
    required this.id,
    required this.name,
    required this.amount,
    required this.studentId,
    required this.dueDate,
    required this.status,
  });

  factory OtherFee.fromJson(Map<String, dynamic> json) => OtherFee(
        id: json['id'],
        name: json['name'],
        amount: (json['amount'] as num).toDouble(),
        studentId: json['student_id'],
        dueDate: DateTime.parse(json['due_date']),
        status: json['status'],
      );
}

class OperationalExpense {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String category;

  OperationalExpense({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
  });

  factory OperationalExpense.fromJson(Map<String, dynamic> json) =>
      OperationalExpense(
        id: json['id'],
        description: json['description'],
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date']),
        category: json['category'],
      );

  Map<String, dynamic> toJson() => {
        'description': description,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category,
      };
}

class FinanceReport {
  final double totalSppIn;
  final double totalSavings;
  final double totalOtherFees;
  final double totalExpenses;
  final String month;
  final String year;

  FinanceReport({
    required this.totalSppIn,
    required this.totalSavings,
    required this.totalOtherFees,
    required this.totalExpenses,
    required this.month,
    required this.year,
  });
}
```

**PERBAIKAN — Buat `lib/finance/services/finance_service.dart`:**
```dart
// lib/finance/services/finance_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/finance_models.dart';
import '../../core/utils/error_handler.dart';

class FinanceService {
  final _supabase = Supabase.instance.client;

  Future<List<SppRecord>> fetchSppByStudent(String studentId) async {
    try {
      final response = await _supabase
          .from('spp_records')
          .select('id, student_id, amount, paid_at, status, month, year')
          .eq('student_id', studentId)
          .order('paid_at', ascending: false);
      return response.map((e) => SppRecord.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchSppByStudent');
      throw err;
    }
  }

  Future<void> addSppPayment(SppRecord record) async {
    try {
      await _supabase.from('spp_records').insert(record.toJson());
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'addSppPayment');
      throw err;
    }
  }

  Future<List<Savings>> fetchSavingsByStudent(String studentId) async {
    try {
      final response = await _supabase
          .from('savings')
          .select('id, student_id, amount, saved_at, type')
          .eq('student_id', studentId)
          .order('saved_at', ascending: false);
      return response.map((e) => Savings.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchSavingsByStudent');
      throw err;
    }
  }

  Future<void> addSavings(Savings savings) async {
    try {
      await _supabase.from('savings').insert(savings.toJson());
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'addSavings');
      throw err;
    }
  }

  Future<List<OperationalExpense>> fetchExpenses() async {
    try {
      final response = await _supabase
          .from('operational_expenses')
          .select('id, description, amount, date, category')
          .order('date', ascending: false);
      return response.map((e) => OperationalExpense.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchExpenses');
      throw err;
    }
  }

  Future<void> addExpense(OperationalExpense expense) async {
    try {
      await _supabase.from('operational_expenses').insert(expense.toJson());
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'addExpense');
      throw err;
    }
  }
}
```

---

### 1.2 Pemisahan Layer — `master_data/`

**STATUS:** ❌ BELUM ADA `models/` dan `services/`

**STRUKTUR SAAT INI (SALAH):**
```
lib/master_data/
├── operator_dashboard_screen.dart        ⚠️ 10 file screen tanpa subfolder
├── operator_master_siswa.dart            ⚠️ query Supabase langsung di screen
├── operator_master_guru.dart             ⚠️ query Supabase langsung di screen
├── operator_master_kelas.dart            ⚠️ query Supabase langsung di screen
├── operator_master_mapel.dart            ⚠️ query Supabase langsung di screen
├── operator_master_jurusan.dart          ⚠️ query Supabase langsung di screen
├── operator_master_tahun_ajaran.dart     ⚠️ query Supabase langsung di screen
├── operator_master_ekskul.dart           ⚠️ query Supabase langsung di screen
├── operator_master_bimbel.dart           ⚠️ query Supabase langsung di screen
└── operator_peserta_bimbel.dart          ⚠️ query Supabase langsung di screen
```

**STRUKTUR TARGET (BENAR):**
```
lib/master_data/
├── models/
│   └── master_models.dart               ← BUAT BARU
├── services/
│   └── master_service.dart              ← BUAT BARU
└── presentation/
    ├── operator_dashboard_screen.dart
    ├── operator_master_siswa.dart
    ├── operator_master_guru.dart
    ├── operator_master_kelas.dart
    ├── operator_master_mapel.dart
    ├── operator_master_jurusan.dart
    ├── operator_master_tahun_ajaran.dart
    ├── operator_master_ekskul.dart
    ├── operator_master_bimbel.dart
    └── operator_peserta_bimbel.dart
```

**PERBAIKAN — Buat `lib/master_data/models/master_models.dart`:**
```dart
// lib/master_data/models/master_models.dart

class Student {
  final String id;
  final String nis;
  final String name;
  final String classId;
  final String majorId;
  final bool isActive;

  Student({
    required this.id,
    required this.nis,
    required this.name,
    required this.classId,
    required this.majorId,
    required this.isActive,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'],
        nis: json['nis'],
        name: json['name'],
        classId: json['class_id'],
        majorId: json['major_id'],
        isActive: json['is_active'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'nis': nis,
        'name': name,
        'class_id': classId,
        'major_id': majorId,
        'is_active': isActive,
      };
}

class Teacher {
  final String id;
  final String nip;
  final String name;
  final String subject;
  final bool isActive;

  Teacher({
    required this.id,
    required this.nip,
    required this.name,
    required this.subject,
    required this.isActive,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) => Teacher(
        id: json['id'],
        nip: json['nip'],
        name: json['name'],
        subject: json['subject'],
        isActive: json['is_active'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'nip': nip,
        'name': name,
        'subject': subject,
        'is_active': isActive,
      };
}

class ClassRoom {
  final String id;
  final String name;
  final String majorId;
  final String academicYearId;

  ClassRoom({
    required this.id,
    required this.name,
    required this.majorId,
    required this.academicYearId,
  });

  factory ClassRoom.fromJson(Map<String, dynamic> json) => ClassRoom(
        id: json['id'],
        name: json['name'],
        majorId: json['major_id'],
        academicYearId: json['academic_year_id'],
      );
}

class Subject {
  final String id;
  final String code;
  final String name;
  final int hoursPerWeek;

  Subject({
    required this.id,
    required this.code,
    required this.name,
    required this.hoursPerWeek,
  });

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json['id'],
        code: json['code'],
        name: json['name'],
        hoursPerWeek: json['hours_per_week'],
      );
}

class AcademicYear {
  final String id;
  final String year;
  final String semester;
  final bool isActive;

  AcademicYear({
    required this.id,
    required this.year,
    required this.semester,
    required this.isActive,
  });

  factory AcademicYear.fromJson(Map<String, dynamic> json) => AcademicYear(
        id: json['id'],
        year: json['year'],
        semester: json['semester'],
        isActive: json['is_active'] ?? false,
      );
}
```

**PERBAIKAN — Buat `lib/master_data/services/master_service.dart`:**
```dart
// lib/master_data/services/master_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/master_models.dart';
import '../../core/utils/error_handler.dart';

class MasterService {
  final _supabase = Supabase.instance.client;

  // ── SISWA ──────────────────────────────────────────────
  Future<List<Student>> fetchAllStudents() async {
    try {
      final response = await _supabase
          .from('students')
          .select('id, nis, name, class_id, major_id, is_active')
          .eq('is_active', true)
          .order('name');
      return response.map((e) => Student.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchAllStudents');
      throw err;
    }
  }

  Future<void> addStudent(Student student) async {
    try {
      await _supabase.from('students').insert(student.toJson());
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'addStudent');
      throw err;
    }
  }

  Future<void> updateStudent(Student student) async {
    try {
      await _supabase
          .from('students')
          .update(student.toJson())
          .eq('id', student.id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'updateStudent');
      throw err;
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      await _supabase.from('students').delete().eq('id', id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'deleteStudent');
      throw err;
    }
  }

  // ── GURU ──────────────────────────────────────────────
  Future<List<Teacher>> fetchAllTeachers() async {
    try {
      final response = await _supabase
          .from('teachers')
          .select('id, nip, name, subject, is_active')
          .eq('is_active', true)
          .order('name');
      return response.map((e) => Teacher.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchAllTeachers');
      throw err;
    }
  }

  Future<void> addTeacher(Teacher teacher) async {
    try {
      await _supabase.from('teachers').insert(teacher.toJson());
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'addTeacher');
      throw err;
    }
  }

  // ── KELAS, MAPEL, TAHUN AJARAN ─────────────────────────
  Future<List<ClassRoom>> fetchAllClasses() async {
    try {
      final response = await _supabase
          .from('classes')
          .select('id, name, major_id, academic_year_id')
          .order('name');
      return response.map((e) => ClassRoom.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchAllClasses');
      throw err;
    }
  }

  Future<List<Subject>> fetchAllSubjects() async {
    try {
      final response = await _supabase
          .from('subjects')
          .select('id, code, name, hours_per_week')
          .order('name');
      return response.map((e) => Subject.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchAllSubjects');
      throw err;
    }
  }

  Future<AcademicYear> fetchActiveAcademicYear() async {
    try {
      final response = await _supabase
          .from('academic_years')
          .select('id, year, semester, is_active')
          .eq('is_active', true)
          .single();
      return AcademicYear.fromJson(response);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchActiveAcademicYear');
      throw err;
    }
  }
}
```

---

### 1.3 Pemisahan Layer — `teacher/`

**STATUS:** ❌ BELUM ADA `models/` dan `services/`

**STRUKTUR SAAT INI (SALAH):**
```
lib/teacher/
├── teacher_dashboard_screen.dart         ⚠️ query Supabase langsung di screen
├── bimbel_dashboard_screen.dart          ⚠️ query Supabase langsung di screen
├── bimbel_submenus_screen.dart           ⚠️ query Supabase langsung di screen
└── presentation/
    └── teacher_jadwal_widget.dart        ⚠️ query Supabase langsung di widget
```

**STRUKTUR TARGET (BENAR):**
```
lib/teacher/
├── models/
│   └── teacher_models.dart              ← BUAT BARU
├── services/
│   └── teacher_service.dart             ← BUAT BARU
└── presentation/
    ├── teacher_dashboard_screen.dart
    ├── bimbel_dashboard_screen.dart
    ├── bimbel_submenus_screen.dart
    └── teacher_jadwal_widget.dart
```

**PERBAIKAN — Buat `lib/teacher/models/teacher_models.dart`:**
```dart
// lib/teacher/models/teacher_models.dart

class TeachingSchedule {
  final String id;
  final String teacherId;
  final String subjectId;
  final String classId;
  final String day;        // 'Senin' | 'Selasa' | dst.
  final String startTime;
  final String endTime;

  TeachingSchedule({
    required this.id,
    required this.teacherId,
    required this.subjectId,
    required this.classId,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory TeachingSchedule.fromJson(Map<String, dynamic> json) =>
      TeachingSchedule(
        id: json['id'],
        teacherId: json['teacher_id'],
        subjectId: json['subject_id'],
        classId: json['class_id'],
        day: json['day'],
        startTime: json['start_time'],
        endTime: json['end_time'],
      );
}

class BimbelSession {
  final String id;
  final String teacherId;
  final String topic;
  final DateTime sessionDate;
  final int durationMinutes;

  BimbelSession({
    required this.id,
    required this.teacherId,
    required this.topic,
    required this.sessionDate,
    required this.durationMinutes,
  });

  factory BimbelSession.fromJson(Map<String, dynamic> json) => BimbelSession(
        id: json['id'],
        teacherId: json['teacher_id'],
        topic: json['topic'],
        sessionDate: DateTime.parse(json['session_date']),
        durationMinutes: json['duration_minutes'],
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
        'session_id': sessionId,
        'student_id': studentId,
        'notes': notes,
        'score': score,
      };
}
```

**PERBAIKAN — Buat `lib/teacher/services/teacher_service.dart`:**
```dart
// lib/teacher/services/teacher_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/teacher_models.dart';
import '../../core/utils/error_handler.dart';

class TeacherService {
  final _supabase = Supabase.instance.client;

  Future<List<TeachingSchedule>> fetchScheduleByTeacher(String teacherId) async {
    try {
      final response = await _supabase
          .from('teaching_schedules')
          .select('id, teacher_id, subject_id, class_id, day, start_time, end_time')
          .eq('teacher_id', teacherId)
          .order('day');
      return response.map((e) => TeachingSchedule.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchScheduleByTeacher');
      throw err;
    }
  }

  // Real-time: notif otomatis jika jadwal berubah
  Stream<List<TeachingSchedule>> streamScheduleByTeacher(String teacherId) {
    return _supabase
        .from('teaching_schedules')
        .stream(primaryKey: ['id'])
        .eq('teacher_id', teacherId)
        .map((data) => data.map((e) => TeachingSchedule.fromJson(e)).toList());
  }

  Future<List<BimbelSession>> fetchBimbelSessions(String teacherId) async {
    try {
      final response = await _supabase
          .from('bimbel_sessions')
          .select('id, teacher_id, topic, session_date, duration_minutes')
          .eq('teacher_id', teacherId)
          .order('session_date', ascending: false);
      return response.map((e) => BimbelSession.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchBimbelSessions');
      throw err;
    }
  }

  Future<void> updateBimbelProgress(BimbelProgress progress) async {
    try {
      await _supabase
          .from('bimbel_progress')
          .upsert(progress.toJson());
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'updateBimbelProgress');
      throw err;
    }
  }
}
```

---

### 1.4 Pemisahan Layer — `parent/`

**STATUS:** ❌ BELUM ADA `models/` dan `services/`

**STRUKTUR SAAT INI (SALAH):**
```
lib/parent/
├── parent_dashboard_screen.dart          ⚠️ query Supabase langsung di screen
├── parent_submenus_screen.dart           ⚠️ query Supabase langsung di screen
├── presentation/
│   └── parent_jadwal_widget.dart         ⚠️ query Supabase langsung di widget
└── ── (announcement ada di folder lain!) ⚠️ inkonsistensi lokasi file
```

**STRUKTUR TARGET (BENAR):**
```
lib/parent/
├── models/
│   └── parent_models.dart               ← BUAT BARU
├── services/
│   └── parent_service.dart              ← BUAT BARU
└── presentation/
    ├── parent_dashboard_screen.dart
    ├── parent_submenus_screen.dart
    ├── parent_jadwal_widget.dart
    └── parent_announcement_screen.dart  ← PINDAHKAN dari announcement/
```

**PERBAIKAN — Buat `lib/parent/models/parent_models.dart`:**
```dart
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
        studentName: json['students']['name'],
        subjectName: json['subjects']['name'],
        className: json['classes']['name'],
        day: json['day'],
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
        publishedAt: DateTime.parse(json['published_at']),
        targetRole: json['target_role'] ?? 'all',
      );
}
```

**PERBAIKAN — Buat `lib/parent/services/parent_service.dart`:**
```dart
// lib/parent/services/parent_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/parent_models.dart';
import '../../core/utils/error_handler.dart';

class ParentService {
  final _supabase = Supabase.instance.client;

  Future<List<ChildSchedule>> fetchChildSchedule(String studentId) async {
    try {
      final response = await _supabase
          .from('teaching_schedules')
          .select('''
            id, day, start_time, end_time, student_id,
            students(name),
            subjects(name),
            classes(name)
          ''')
          .eq('student_id', studentId)
          .order('day');
      return response.map((e) => ChildSchedule.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchChildSchedule');
      throw err;
    }
  }

  // Real-time: pengumuman baru langsung muncul tanpa refresh
  Stream<List<Announcement>> streamAnnouncements() {
    return _supabase
        .from('announcements')
        .stream(primaryKey: ['id'])
        .order('published_at', ascending: false)
        .map((data) => data.map((e) => Announcement.fromJson(e)).toList());
  }
}
```

---

### 1.5 Error Handling Terpusat

**STATUS:** ❌ BELUM ADA — error handling tersebar dan tidak konsisten

**STRUKTUR YANG HARUS DIBUAT:**
```
lib/core/
├── utils/
│   ├── error_handler.dart               ← BUAT BARU
│   └── context_extensions.dart          ← BUAT BARU
└── mixins/
    └── safe_async_mixin.dart            ← BUAT BARU
```

**PERBAIKAN — Buat `lib/core/utils/error_handler.dart`:**
```dart
// lib/core/utils/error_handler.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AppErrorType { network, auth, notFound, validation, server, unknown }

class AppException implements Exception {
  final String message;
  final AppErrorType type;
  final dynamic originalError;

  AppException({
    required this.message,
    required this.type,
    this.originalError,
  });

  String get userMessage {
    switch (type) {
      case AppErrorType.network:
        return 'Periksa koneksi internet Anda dan coba lagi.';
      case AppErrorType.auth:
        return 'Sesi Anda berakhir. Silakan login ulang.';
      case AppErrorType.notFound:
        return 'Data yang dicari tidak ditemukan.';
      case AppErrorType.validation:
        return message;
      case AppErrorType.server:
        return 'Terjadi kesalahan pada server. Coba beberapa saat lagi.';
      case AppErrorType.unknown:
      default:
        return 'Terjadi kesalahan tak terduga. Coba beberapa saat lagi.';
    }
  }
}

AppException handleSupabaseError(dynamic error) {
  if (error is AppException) return error;
  if (error is PostgrestException) {
    switch (error.code) {
      case '23505':
        return AppException(message: 'Data sudah ada, tidak bisa duplikat.',
            type: AppErrorType.validation, originalError: error);
      case '23503':
        return AppException(message: 'Data terkait tidak ditemukan.',
            type: AppErrorType.notFound, originalError: error);
      case '42501':
        return AppException(message: 'Anda tidak punya akses ke data ini.',
            type: AppErrorType.auth, originalError: error);
      default:
        return AppException(message: error.message,
            type: AppErrorType.server, originalError: error);
    }
  }
  if (error is AuthException) {
    return AppException(message: 'Sesi berakhir, silakan login ulang.',
        type: AppErrorType.auth, originalError: error);
  }
  if (error is SocketException) {
    return AppException(message: 'Tidak ada koneksi internet.',
        type: AppErrorType.network, originalError: error);
  }
  return AppException(message: error.toString(),
      type: AppErrorType.unknown, originalError: error);
}

void logError(AppException e, {String? context}) {
  final ctx = context != null ? '[$context]' : '';
  // ignore: avoid_print
  print('[ERROR]$ctx ${e.message} | type: ${e.type} | original: ${e.originalError}');
}
```

**PERBAIKAN — Buat `lib/core/utils/context_extensions.dart`:**
```dart
// lib/core/utils/context_extensions.dart
import 'package:flutter/material.dart';
import 'error_handler.dart';

extension ContextExtensions on BuildContext {
  void showErrorSnackBar(String message, {AppErrorType? type}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Tutup',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(this).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> showErrorDialog(String message,
      {String? title, VoidCallback? onRetry}) {
    return showDialog(
      context: this,
      builder: (ctx) => AlertDialog(
        title: Text(title ?? 'Terjadi Kesalahan'),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(onPressed: () { Navigator.pop(ctx); onRetry(); },
                child: const Text('Coba Lagi')),
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup')),
        ],
      ),
    );
  }
}
```

**PERBAIKAN — Buat `lib/core/mixins/safe_async_mixin.dart`:**
```dart
// lib/core/mixins/safe_async_mixin.dart
import 'package:flutter/material.dart';
import '../utils/error_handler.dart';
import '../utils/context_extensions.dart';

mixin SafeAsync<T extends StatefulWidget> on State<T> {
  bool isLoading = false;

  Future<void> safeCall({
    required Future<void> Function() action,
    required BuildContext context,
    String? successMessage,
    bool showLoading = true,
    bool useDialog = false,
    VoidCallback? onRetry,
  }) async {
    if (showLoading) setState(() => isLoading = true);
    try {
      await action();
      if (successMessage != null && mounted) {
        context.showSuccessSnackBar(successMessage);
      }
    } catch (e) {
      final err = e is AppException ? e : handleSupabaseError(e);
      logError(err);
      if (mounted) {
        if (useDialog) {
          context.showErrorDialog(err.userMessage, onRetry: onRetry);
        } else {
          context.showErrorSnackBar(err.userMessage);
        }
      }
    } finally {
      if (showLoading && mounted) setState(() => isLoading = false);
    }
  }
}
```

---

### 1.6 Keamanan Kredensial

**STATUS:** ❌ BERPOTENSI HARDCODED di kode

**MASALAH:**
```dart
// ❌ SALAH — jangan lakukan ini
final supabase = SupabaseClient(
  'https://xyzxyz.supabase.co',        // hardcoded!
  'eyJhbGciOiJIUzI1NiIsInR5cCI6...',   // hardcoded!
);
```

**PERBAIKAN — Gunakan `--dart-define` saat build:**
```dart
// ✅ BENAR — baca dari environment
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
```

```bash
# Build dengan environment variable
flutter build web --release \
  --dart-define=SUPABASE_URL=https://xyzxyz.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGci...
```

---

### 1.7 Konsistensi Penamaan

**STATUS:** ⚠️ PERLU AUDIT

**ATURAN WAJIB:**

| Konteks | Aturan | Contoh Benar |
|---|---|---|
| Nama file | `snake_case` | `finance_service.dart` |
| Nama class | `PascalCase` | `FinanceService` |
| Nama fungsi & variabel | `camelCase` | `fetchAllSiswa()` |
| Kolom tabel Supabase | `snake_case` | `tahun_ajaran`, `nama_siswa` |
| Nama tabel Supabase | `snake_case` plural | `students`, `spp_records` |

---

## FASE 2 — PENYELESAIAN & PENGUJIAN FITUR

> **Instruksi untuk AI:** Kerjakan sesuai urutan tabel. Operator wajib selesai dulu sebelum mengerjakan role lain.

| # | Role | Fitur yang harus diselesaikan | Alasan |
|---|---|---|---|
| 1 | Operator | CRUD Master Siswa, Guru, Kelas, Mapel, Jurusan, Ekskul, Bimbel, Tahun Ajaran | Sumber data seluruh sistem |
| 2 | Waka Kurikulum | Jadwal mengajar, jadwal ujian, rapor, kenaikan kelas, monitoring akademik | Bergantung pada data Operator |
| 3 | Admin Keuangan | Pembayaran SPP, tabungan siswa, biaya lain, laporan keuangan | Bergantung pada data siswa dari Operator |
| 4 | Guru / Bimbel | Dashboard mengajar, jadwal, progress bimbel | Bergantung pada jadwal dari Wakakur |
| 5 | Kepala Sekolah | Dashboard eksekutif, laporan akademik & keuangan, pengumuman | Consumer semua laporan |
| 6 | Orang Tua | Jadwal anak, pengumuman | Consumer data akhir |
| 7 | Super Admin | Manajemen user, role, backup, monitoring, konfigurasi | Sistem-level, bisa paralel |

**Checklist pengujian end-to-end:**
- [ ] Login sebagai setiap role → pastikan redirect ke dashboard yang benar
- [ ] CRUD di setiap fitur → buat, baca, ubah, hapus data
- [ ] Data tersimpan benar di tabel Supabase
- [ ] Data yang diinput satu role tampil benar di role yang mengonsumsinya
- [ ] Uji skenario error: input kosong, format salah, koneksi lambat

---

## FASE 3 — KEAMANAN & PERFORMA

### 3.1 Row Level Security (RLS)

> **PERINGATAN:** Jangan deploy ke publik sebelum RLS aktif. Tanpa RLS, semua data bisa diakses siapapun yang tahu URL Supabase.

**Jalankan SQL berikut di Supabase Dashboard > SQL Editor:**

```sql
-- Aktifkan RLS di semua tabel
ALTER TABLE students        ENABLE ROW LEVEL SECURITY;
ALTER TABLE teachers        ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes         ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects        ENABLE ROW LEVEL SECURITY;
ALTER TABLE spp_records     ENABLE ROW LEVEL SECURITY;
ALTER TABLE savings         ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements   ENABLE ROW LEVEL SECURITY;
ALTER TABLE teaching_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE bimbel_sessions ENABLE ROW LEVEL SECURITY;

-- Policy: Operator bisa CRUD tabel master
CREATE POLICY "operator_crud_students" ON students
  FOR ALL TO authenticated
  USING (auth.jwt() ->> 'role' = 'operator');

-- Policy: Guru hanya bisa baca jadwal miliknya
CREATE POLICY "teacher_read_own_schedule" ON teaching_schedules
  FOR SELECT TO authenticated
  USING (teacher_id = auth.uid());

-- Policy: Admin Keuangan hanya akses tabel keuangan
CREATE POLICY "finance_access_spp" ON spp_records
  FOR ALL TO authenticated
  USING (auth.jwt() ->> 'role' = 'admin_keuangan');

-- Policy: Orang Tua hanya lihat data anak mereka
CREATE POLICY "parent_read_child_schedule" ON teaching_schedules
  FOR SELECT TO authenticated
  USING (
    student_id IN (
      SELECT id FROM students WHERE parent_id = auth.uid()
    )
  );

-- Policy: Semua user bisa baca pengumuman
CREATE POLICY "all_read_announcements" ON announcements
  FOR SELECT TO authenticated
  USING (true);
```

### 3.2 Autentikasi Berbasis Role

```dart
// Simpan role di Supabase profiles table setelah login
// Redirect berdasarkan role
Future<void> redirectByRole(BuildContext context) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    Navigator.pushReplacementNamed(context, '/login');
    return;
  }
  final profile = await Supabase.instance.client
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single();

  switch (profile['role']) {
    case 'superadmin':      Navigator.pushReplacementNamed(context, '/superadmin'); break;
    case 'operator':        Navigator.pushReplacementNamed(context, '/operator'); break;
    case 'wakakur':         Navigator.pushReplacementNamed(context, '/wakakur'); break;
    case 'admin_keuangan':  Navigator.pushReplacementNamed(context, '/keuangan'); break;
    case 'guru':            Navigator.pushReplacementNamed(context, '/guru'); break;
    case 'kepala_sekolah':  Navigator.pushReplacementNamed(context, '/kepala'); break;
    case 'orang_tua':       Navigator.pushReplacementNamed(context, '/ortu'); break;
    default: Navigator.pushReplacementNamed(context, '/login');
  }
}
```

### 3.3 Strategi Sinkronisasi

| Tipe Data | Mekanisme | Contoh |
|---|---|---|
| Data statis / jarang berubah | `Future` + cache lokal | Master siswa, jadwal, rapor |
| Data real-time | `supabase.stream()` | Pengumuman baru, monitoring log |
| Aksi user (submit form) | `Future` async/await | Input pembayaran, simpan jadwal |
| Status live | `Stream` | Verifikasi pembayaran SPP |

---

## FASE 4 — BUILD & HOSTING WEB

```bash
# 1. Build release
flutter build web --release \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...

# 2. Test lokal sebelum deploy
cd build/web && python3 -m http.server 8080

# 3. Deploy ke Firebase Hosting
firebase init hosting   # pilih folder: build/web
firebase deploy

# 4. Atau deploy ke Netlify/Vercel
# Drag & drop folder build/web/ ke dashboard
```

**Checklist pasca-deploy:**
- [ ] Tambahkan domain hosting ke CORS Supabase: Settings > API > CORS
- [ ] Pastikan HTTPS aktif (Supabase tolak HTTP)
- [ ] Uji semua fitur utama di URL live
- [ ] Setup Supabase Logs atau Sentry untuk monitoring error produksi

---

## ANALISIS KONEKTIVITAS ANTAR USER

> **Instruksi untuk AI:** 5 pasang berikut adalah koneksi data yang hilang. Kerjakan setelah Fase 1 selesai, mulai dari yang berlabel KRITIS.

### KRITIS: Operator → Waka Kurikulum

**MASALAH:** Data master siswa/guru/kelas dari Operator belum tersedia sebagai referensi di screen Wakakur.

**FILE YANG HARUS DIUBAH:** `academic_config/services/academic_service.dart`

```dart
// Tambahkan fungsi berikut di AcademicService
Future<List<Student>> fetchStudentsForDropdown() async {
  try {
    final response = await _supabase
        .from('students')
        .select('id, nis, name, class_id')
        .eq('is_active', true)
        .order('name');
    return response.map((e) => Student.fromJson(e)).toList();
  } catch (e) {
    final err = handleSupabaseError(e);
    logError(err, context: 'fetchStudentsForDropdown');
    throw err;
  }
}

Future<List<Teacher>> fetchTeachersForDropdown() async {
  try {
    final response = await _supabase
        .from('teachers')
        .select('id, nip, name, subject')
        .eq('is_active', true)
        .order('name');
    return response.map((e) => Teacher.fromJson(e)).toList();
  } catch (e) {
    final err = handleSupabaseError(e);
    logError(err, context: 'fetchTeachersForDropdown');
    throw err;
  }
}
```

---

### KRITIS: Operator → Admin Keuangan

**MASALAH:** Form input SPP di Keuangan belum bisa memilih siswa dari data master Operator.

**FILE YANG HARUS DIUBAH:** `finance/services/finance_service.dart`

```dart
// Tambahkan fungsi berikut di FinanceService
Future<List<Student>> fetchActiveStudentsForPayment() async {
  try {
    final response = await _supabase
        .from('students')
        .select('id, nis, name, class_id')
        .eq('is_active', true)
        .order('name');
    return response.map((e) => Student.fromJson(e)).toList();
  } catch (e) {
    final err = handleSupabaseError(e);
    logError(err, context: 'fetchActiveStudentsForPayment');
    throw err;
  }
}
```

---

### PENTING: Waka Kurikulum → Guru

**MASALAH:** `teacher_dashboard_screen.dart` tidak fetch jadwal dari tabel yang diisi Wakakur.

**FILE YANG HARUS DIUBAH:** `teacher/presentation/teacher_dashboard_screen.dart`

```dart
// Tambahkan di _TeacherDashboardScreenState
final _teacherService = TeacherService();
List<TeachingSchedule> _schedules = [];

@override
void initState() {
  super.initState();
  _loadSchedule();
}

void _loadSchedule() {
  safeCall(
    context: context,
    action: () async {
      final teacherId = Supabase.instance.client.auth.currentUser!.id;
      final data = await _teacherService.fetchScheduleByTeacher(teacherId);
      setState(() => _schedules = data);
    },
  );
}
```

---

### PENTING: Waka Kurikulum → Orang Tua

**MASALAH:** `parent_jadwal_widget.dart` tidak terhubung ke tabel jadwal yang diisi Wakakur.

**FILE YANG HARUS DIUBAH:** `parent/presentation/parent_jadwal_widget.dart`

```dart
// Tambahkan di ParentJadwalWidget
final _parentService = ParentService();
List<ChildSchedule> _schedules = [];

void _loadChildSchedule(String studentId) {
  safeCall(
    context: context,
    action: () async {
      final data = await _parentService.fetchChildSchedule(studentId);
      setState(() => _schedules = data);
    },
  );
}
```

---

### PENTING: Kepala Sekolah → Semua User (Pengumuman)

**MASALAH:** `announcement_screen.dart` ada di folder terpisah dan tidak real-time ke Guru & Orang Tua.

**FILE YANG HARUS DIPINDAH:** `announcement/presentation/parent_announcement_screen.dart` → `parent/presentation/parent_announcement_screen.dart`

**PERBAIKAN di semua dashboard yang perlu terima pengumuman:**
```dart
// Tambahkan stream pengumuman di setiap dashboard (guru, ortu)
final _parentService = ParentService();
late Stream<List<Announcement>> _announcementStream;

@override
void initState() {
  super.initState();
  _announcementStream = _parentService.streamAnnouncements();
}

// Di build():
StreamBuilder<List<Announcement>>(
  stream: _announcementStream,
  builder: (context, snapshot) {
    if (!snapshot.hasData) return const SizedBox();
    final announcements = snapshot.data!;
    // Tampilkan badge jika ada pengumuman baru
    return Badge(
      count: announcements.length,
      child: const Icon(Icons.notifications),
    );
  },
)
```

---

## MATRIKS I/O & SINKRONISASI

| Role | Input (Baca dari) | Output (Tulis ke) | Sinkronisasi |
|---|---|---|---|
| Operator | — | Siswa, Guru, Kelas, Mapel, Jurusan, Ekskul, Bimbel, Tahun Ajaran | `Future` (CRUD) |
| Waka Kurikulum | Data Siswa/Guru (dari Operator) | Jadwal Mengajar, Jadwal Ujian, Rapor, Laporan Akademik | `Future` (CRUD) + `Stream` (monitoring) |
| Admin Keuangan | Data Siswa (dari Operator) | Pembayaran SPP, Tabungan, Laporan Keuangan | `Future` (CRUD) + `Stream` (status bayar) |
| Kepala Sekolah | Laporan Akademik, Laporan Keuangan | Pengumuman (ke semua) | `Stream` (dashboard) + `Future` (laporan) |
| Guru / Bimbel | Jadwal (dari Wakakur), Data Kelas | Progress Bimbel | `Future` (jadwal) + `Stream` (notif) |
| Orang Tua | Jadwal Anak, Pengumuman | — | `Future` (jadwal) + `Stream` (pengumuman) |
| Super Admin | Log Monitoring | User & Role, Konfigurasi, Backup | `Stream` (log) + `Future` (config) |

---

## REKOMENDASI PRIORITAS PENGERJAAN

```
1. [SEKARANG]   Selesaikan Fase 1 — fondasi kode (services/, models/, error handling)
2. [SETELAH 1]  Hubungkan Operator → Wakakur dan Operator → Keuangan
3. [SETELAH 2]  Hubungkan Wakakur → Guru dan Wakakur → Orang Tua
4. [PARALEL 3]  Aktifkan RLS Supabase di semua tabel
5. [SETELAH 3]  Hubungkan pengumuman Kepala Sekolah ke semua dashboard
6. [TERAKHIR]   Build flutter web --release dan deploy ke hosting staging
```

---

*Dokumen ini dibuat untuk dibaca oleh AI coding assistant. Setiap perbaikan sudah disertai struktur folder, kode contoh, dan urutan pengerjaan yang eksplisit. Kerjakan secara berurutan dan konfirmasi setiap item sebelum lanjut.*
