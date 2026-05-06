// lib/features/master_data/models/master_models.dart

class Student {
  final String id;
  final String nis;
  final String name;
  final String? classId;
  final String? status; // 'active', 'alumni', 'mutasi'
  final bool isActive;
  final String? parentName;

  Student({
    required this.id,
    required this.nis,
    required this.name,
    this.classId,
    this.status,
    required this.isActive,
    this.parentName,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    String? pName;
    if (json['orang_tua_siswa'] != null && (json['orang_tua_siswa'] as List).isNotEmpty) {
      final ot = json['orang_tua_siswa'][0]['orang_tua'];
      if (ot != null) {
        pName = ot['nama_ayah'] ?? ot['nama_ibu'] ?? ot['nama'];
      }
    }

    return Student(
        id: json['id'],
        nis: json['nis'] ?? '',
        name: json['nama'] ?? json['name'] ?? '',
        classId: json['kelas_id'] ?? json['class_id'],
        status: json['status'],
        isActive: json['status'] == 'active' || (json['is_active'] ?? true),
        parentName: pName,
      );
  }

  Map<String, dynamic> toJson() => {
        'nis': nis,
        'nama': name,
        'kelas_id': classId,
        'status': isActive ? 'active' : 'inactive',
      };
}

class Teacher {
  final String id;
  final String? nip;
  final String name;
  final bool isWaliKelas;
  final bool isActive;

  Teacher({
    required this.id,
    this.nip,
    required this.name,
    this.isWaliKelas = false,
    this.isActive = true,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) => Teacher(
        id: json['id'],
        nip: json['nip'],
        name: json['nama'] ?? json['name'] ?? '',
        isWaliKelas: json['is_wali_kelas'] ?? false,
        isActive: json['is_active'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'nip': nip,
        'nama': name,
        'is_wali_kelas': isWaliKelas,
      };
}

class ClassRoom {
  final String id;
  final String name;
  final String? waliKelasId;
  final int kapasitas;

  ClassRoom({
    required this.id,
    required this.name,
    this.waliKelasId,
    this.kapasitas = 35,
  });

  factory ClassRoom.fromJson(Map<String, dynamic> json) => ClassRoom(
        id: json['id'],
        name: json['nama'] ?? json['name'] ?? '',
        waliKelasId: json['wali_kelas_id'],
        kapasitas: json['kapasitas'] ?? 35,
      );

  Map<String, dynamic> toJson() => {
        'nama': name,
        'wali_kelas_id': waliKelasId,
        'kapasitas': kapasitas,
      };
}

class Subject {
  final String id;
  final String? code;
  final String name;
  final int kkm;

  Subject({
    required this.id,
    this.code,
    required this.name,
    this.kkm = 75,
  });

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json['id'],
        code: json['kode'] ?? json['code'],
        name: json['nama'] ?? json['name'] ?? '',
        kkm: json['kkm'] ?? 75,
      );

  Map<String, dynamic> toJson() => {
        'nama': name,
        'kode': code,
        'kkm': kkm,
      };
}

class AcademicYear {
  final String id;
  final String year;
  final bool isActive;

  AcademicYear({
    required this.id,
    required this.year,
    required this.isActive,
  });

  factory AcademicYear.fromJson(Map<String, dynamic> json) => AcademicYear(
        id: json['id'],
        year: json['tahun'] ?? json['year'] ?? '',
        isActive: json['is_active'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'tahun': year,
        'is_active': isActive,
      };
}

class Major {
  final String id;
  final String code;
  final String name;

  Major({
    required this.id,
    required this.code,
    required this.name,
  });

  factory Major.fromJson(Map<String, dynamic> json) => Major(
        id: json['id'],
        code: json['kode'] ?? '',
        name: json['nama'] ?? json['name'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'kode': code,
        'nama': name,
      };
}

class Extracurricular {
  final String id;
  final String name;
  final String? coach;

  Extracurricular({
    required this.id,
    required this.name,
    this.coach,
  });

  factory Extracurricular.fromJson(Map<String, dynamic> json) => Extracurricular(
        id: json['id'],
        name: json['nama'] ?? json['name'] ?? '',
        coach: json['pembina'] ?? json['coach'],
      );

  Map<String, dynamic> toJson() => {
        'nama': name,
        'pembina': coach,
      };
}

class Tutoring {
  final String id;
  final String name;
  final String? teacherId;

  Tutoring({
    required this.id,
    required this.name,
    this.teacherId,
  });

  factory Tutoring.fromJson(Map<String, dynamic> json) => Tutoring(
        id: json['id'],
        name: json['nama'] ?? json['name'] ?? '',
        teacherId: json['guru_id'] ?? json['teacher_id'],
      );

  Map<String, dynamic> toJson() => {
        'nama': name,
        'guru_id': teacherId,
      };
}

class BimbelParticipant {
  final String id;
  final String programId;
  final String studentId;
  final Student? student;

  BimbelParticipant({
    required this.id,
    required this.programId,
    required this.studentId,
    this.student,
  });

  factory BimbelParticipant.fromJson(Map<String, dynamic> json) => BimbelParticipant(
        id: json['id'],
        programId: json['program_id'] ?? json['bimbel_id'],
        studentId: json['siswa_id'],
        student: json['siswa'] != null ? Student.fromJson(json['siswa']) : null,
      );

  Map<String, dynamic> toJson() => {
        'program_id': programId,
        'siswa_id': studentId,
      };
}

class EkskulParticipant {
  final String id;
  final String ekskulId;
  final String studentId;
  final Student? student;

  EkskulParticipant({
    required this.id,
    required this.ekskulId,
    required this.studentId,
    this.student,
  });

  factory EkskulParticipant.fromJson(Map<String, dynamic> json) => EkskulParticipant(
        id: json['id'],
        ekskulId: json['ekskul_id'],
        studentId: json['siswa_id'],
        student: json['siswa'] != null ? Student.fromJson(json['siswa']) : null,
      );

  Map<String, dynamic> toJson() => {
        'ekskul_id': ekskulId,
        'siswa_id': studentId,
      };
}

