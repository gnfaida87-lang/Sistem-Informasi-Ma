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
        studentId: json['student_id'],
        studentName: json['siswa']?['nama'],
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
        studentId: json['student_id'],
        studentName: json['siswa']?['nama'],
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

  /// Alias untuk nama jenis tagihan (digunakan di UI)
  String get type => name;

  /// Status lunas: true jika status == 'lunas'
  bool get isPaid => status == 'lunas';

  factory OtherFee.fromJson(Map<String, dynamic> json) => OtherFee(
        id: json['id'],
        name: json['name'],
        amount: (json['amount'] as num).toDouble(),
        studentId: json['student_id'],
        studentName: json['siswa']?['nama'],
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

  /// Alias: total pemasukan SPP
  double get totalSpp => totalSppIn;

  /// Alias: total pengeluaran operasional
  double get totalOperationalExpenses => totalExpenses;

  /// Net cash flow = (SPP + tagihan lain) - pengeluaran
  double get netIncome => totalSppIn + totalOtherFees - totalExpenses;
}

