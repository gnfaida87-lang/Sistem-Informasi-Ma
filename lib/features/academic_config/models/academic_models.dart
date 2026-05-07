// lib/features/academic_config/models/academic_models.dart

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
      id: json['id']?.toString() ?? '',
      year: json['year_name'] ?? json['tahun'] ?? '',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
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

  /// Untuk hasil JOIN tabel semesters + academic_years
  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: json['id']?.toString() ?? '',
      yearId: json['academic_year_id']?.toString() ?? json['tahun_ajaran_id']?.toString() ?? '',
      nama: json['name'] ?? json['nama'] ?? json['year_name'] ?? '',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      kkmDefault: json['kkm_default'] ?? 75,
      isValidated: json['is_validated'] == 1 || json['is_validated'] == true,
      validatedBy: json['validated_by']?.toString(),
      yearName: json['tahun_ajaran_nama'] ?? json['year_name'],
    );
  }

  /// Fallback: untuk hasil query langsung dari tabel academic_years
  factory Semester.fromFlatJson(Map<String, dynamic> json) {
    return Semester(
      id: json['id']?.toString() ?? '',
      yearId: json['id']?.toString() ?? '',
      nama: json['nama'] ?? json['year_name'] ?? '',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      kkmDefault: json['kkm_default'] ?? 75,
      isValidated: json['is_validated'] == 1 || json['is_validated'] == true,
      validatedBy: json['validated_by']?.toString(),
      yearName: json['tahun_ajaran_nama'] ?? json['nama'],
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
      id: json['id']?.toString() ?? '',
      code: json['kode'] ?? json['code'] ?? '',
      nama: json['nama'] ?? json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'kode': code,
    'nama': nama,
  };
}
