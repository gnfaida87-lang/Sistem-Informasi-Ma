class AcademicYear {
  final String id;
  final String year;
  final bool isActive;

  AcademicYear({
    required this.id,
    required this.year,
    required this.isActive,
  });

  factory AcademicYear.fromJson(Map<String, dynamic> json) {
    return AcademicYear(
      id: json['id'],
      year: json['tahun'],
      isActive: json['is_active'] ?? false,
    );
  }
}

class Semester {
  final String id;
  final String yearId;
  final String nama;
  final bool isActive;
  final int kkmDefault;
  final bool isValidated;
  final String? validatedBy;
  final String? yearName;

  Semester({
    required this.id,
    required this.yearId,
    required this.nama,
    required this.isActive,
    required this.kkmDefault,
    required this.isValidated,
    this.validatedBy,
    this.yearName,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: json['id'],
      yearId: json['tahun_ajaran_id'],
      nama: json['nama'],
      isActive: json['is_active'] ?? false,
      kkmDefault: json['kkm_default'] ?? 75,
      isValidated: json['is_validated'] ?? false,
      validatedBy: json['validated_by'],
      yearName: json['tahun_ajaran']?['tahun'],
    );
  }
}

class Department {
  final String id;
  final String code;
  final String nama;

  Department({
    required this.id,
    required this.code,
    required this.nama,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      code: json['kode'],
      nama: json['nama'],
    );
  }
}
