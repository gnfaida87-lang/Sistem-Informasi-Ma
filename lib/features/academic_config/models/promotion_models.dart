// lib/features/academic_config/models/promotion_models.dart

class PromotionCriteria {
  final String? id;
  final String title;
  final String value;
  final String category;
  final double? minThreshold;

  PromotionCriteria({
    this.id,
    required this.title,
    required this.value,
    required this.category,
    this.minThreshold,
  });

  factory PromotionCriteria.fromJson(Map<String, dynamic> json) {
    return PromotionCriteria(
      id: json['id'],
      title: json['title'] ?? '',
      value: json['value'] ?? '',
      category: json['category'] ?? '',
      minThreshold: (json['min_threshold'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'value': value,
    'category': category,
    'min_threshold': minThreshold,
  };
}

class Alumni {
  final String id;
  final String studentName;
  final String studentNis;
  final int graduationYear;
  final String lastClassName;

  Alumni({
    required this.id,
    required this.studentName,
    required this.studentNis,
    required this.graduationYear,
    required this.lastClassName,
  });

  factory Alumni.fromJson(Map<String, dynamic> json) {
    return Alumni(
      id: json['id'],
      studentName: json['students']?['name'] ?? 'Unknown',
      studentNis: json['students']?['nis'] ?? '-',
      graduationYear: json['graduation_year'] ?? 0,
      lastClassName: json['last_class_name'] ?? '-',
    );
  }
}

class PromotionHistory {
  final String id;
  final String studentId;
  final String? oldClassId;
  final String? newClassId;
  final String status;
  final String academicYearId;
  final DateTime processedAt;

  PromotionHistory({
    required this.id,
    required this.studentId,
    this.oldClassId,
    this.newClassId,
    required this.status,
    required this.academicYearId,
    required this.processedAt,
  });

  factory PromotionHistory.fromJson(Map<String, dynamic> json) {
    return PromotionHistory(
      id: json['id'],
      studentId: json['student_id'],
      oldClassId: json['old_class_id'],
      newClassId: json['new_class_id'],
      status: json['status'],
      academicYearId: json['academic_year_id'],
      processedAt: DateTime.parse(json['processed_at']),
    );
  }
}
