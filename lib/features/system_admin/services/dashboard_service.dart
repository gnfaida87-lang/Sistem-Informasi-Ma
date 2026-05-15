import '../../../core/network/d1_service.dart';
import 'package:flutter/foundation.dart';

class DashboardStats {
  final int totalStudents;
  final int totalTeachers;
  final double monthlyRevenue;
  final double serverUptime;

  DashboardStats({
    required this.totalStudents,
    required this.totalTeachers,
    required this.monthlyRevenue,
    required this.serverUptime,
  });
}

class DashboardService {
  final _d1Service = D1Service();

  Future<DashboardStats> fetchStats() async {
    try {
      // 1. Total Siswa
      final studentRes = await _d1Service.query("SELECT COUNT(*) as total FROM students WHERE is_active = 1");
      final totalStudents = studentRes.isNotEmpty ? (studentRes.first['total'] as num).toInt() : 0;

      // 2. Total Guru
      final teacherRes = await _d1Service.query("SELECT COUNT(*) as total FROM teachers WHERE is_active = 1");
      final totalTeachers = teacherRes.isNotEmpty ? (teacherRes.first['total'] as num).toInt() : 0;

      // 3. Pemasukan (Dummy for now as table doesn't exist)
      final monthlyRevenue = 0.0;

      // 4. Server Uptime (Mock/Dummy)
      final serverUptime = 99.9;

      return DashboardStats(
        totalStudents: totalStudents,
        totalTeachers: totalTeachers,
        monthlyRevenue: monthlyRevenue,
        serverUptime: serverUptime,
      );
    } catch (e) {
      debugPrint("Error fetching dashboard stats: $e");
      return DashboardStats(
        totalStudents: 0,
        totalTeachers: 0,
        monthlyRevenue: 0.0,
        serverUptime: 0.0,
      );
    }
  }
}
