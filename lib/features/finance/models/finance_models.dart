// lib/finance/models/finance_models.dart

class SppRecord {
  final String id;
  final String studentId;
  final String? studentName;
  final double amount;
  final DateTime paidAt;
  final String status; // 'lunas' | 'belum' | 'cicilan'
  final String? month;
  final String? year;

  SppRecord({
    required this.id,
    required this.studentId,
    this.studentName,
    required this.amount,
    required this.paidAt,
    required this.status,
    this.month,
    this.year,
  });

  factory SppRecord.fromJson(Map<String, dynamic> json) => SppRecord(
        id: json['id'],
        studentId: json['siswa_id'] ?? json['student_id'] ?? '',
        studentName: json['student_name'] ?? json['siswa']?['nama'],
        amount: ((json['amount'] ?? json['jumlah'] ?? 0) as num).toDouble(),
        paidAt: DateTime.parse(json['tanggal_bayar'] ?? json['paid_at'] ?? DateTime.now().toIso8601String()),
        status: json['status'] ?? 'lunas',
        month: json['bulan'] ?? json['month'],
        year: json['tahun'] ?? json['year'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'siswa_id': studentId,
        'amount': amount,
        'tanggal_bayar': paidAt.toIso8601String(),
        'status': status,
        'bulan': month,
        'tahun': year,
      };
}

class Savings {
  final String id;
  final String studentId;
  final String? studentName;
  final double amount;
  final DateTime savedAt;
  final String type; // 'setor' | 'tarik'

  Savings({
    required this.id,
    required this.studentId,
    this.studentName,
    required this.amount,
    required this.savedAt,
    required this.type,
  });

  factory Savings.fromJson(Map<String, dynamic> json) => Savings(
        id: json['id'],
        studentId: json['siswa_id'] ?? json['student_id'] ?? '',
        studentName: json['student_name'] ?? json['siswa']?['nama'],
        amount: ((json['amount'] ?? json['jumlah'] ?? 0) as num).toDouble(),
        savedAt: DateTime.parse(json['tanggal'] ?? json['saved_at'] ?? DateTime.now().toIso8601String()),
        type: json['type'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'siswa_id': studentId,
        'amount': amount,
        'tanggal': savedAt.toIso8601String(),
        'type': type,
      };
}

class OtherFee {
  final String id;
  final String name;
  final double amount;
  final String studentId;
  final String? studentName;
  final DateTime dueDate;
  final String status;

  OtherFee({
    required this.id,
    required this.name,
    required this.amount,
    required this.studentId,
    this.studentName,
    required this.dueDate,
    required this.status,
  });

  String get type => name;
  bool get isPaid => status == 'lunas';

  factory OtherFee.fromJson(Map<String, dynamic> json) => OtherFee(
        id: json['id'],
        name: json['name'],
        amount: ((json['amount'] ?? json['jumlah'] ?? 0) as num).toDouble(),
        studentId: json['siswa_id'] ?? json['student_id'] ?? '',
        studentName: json['student_name'] ?? json['siswa']?['nama'],
        dueDate: DateTime.parse(json['tenggat_waktu'] ?? json['due_date'] ?? DateTime.now().toIso8601String()),
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
        description: json['keterangan'] ?? json['description'] ?? '',
        amount: ((json['amount'] ?? json['jumlah'] ?? 0) as num).toDouble(),
        date: DateTime.parse(json['tanggal'] ?? json['date'] ?? DateTime.now().toIso8601String()),
        category: json['kategori'] ?? json['category'] ?? 'Umum',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'keterangan': description,
        'amount': amount,
        'tanggal': date.toIso8601String(),
        'kategori': category,
      };

  OperationalExpense copyWith({
    String? id,
    String? description,
    double? amount,
    DateTime? date,
    String? category,
  }) {
    return OperationalExpense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }
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

  double get totalSpp => totalSppIn;
  double get totalOperationalExpenses => totalExpenses;
  double get netIncome => totalSppIn + totalOtherFees - totalExpenses;
}
