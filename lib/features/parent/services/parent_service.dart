import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/parent_models.dart';
import '../../../core/utils/error_handler.dart';

class ParentService {
  final _supabase = Supabase.instance.client;

  /// Mengambil profil orang tua beserta data anak
  Future<ParentChildProfile?> getParentDashboardProfile(String userId) async {
    try {
      final response = await _supabase
          .from('orang_tua')
          .select('*, orang_tua_siswa(siswa(*, kelas(*, guru(nama))))')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null && response['orang_tua_siswa'] != null && (response['orang_tua_siswa'] as List).isNotEmpty) {
        return ParentChildProfile.fromSupabase(response);
      }
      return null;
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'getParentDashboardProfile');
      return null;
    }
  }

  /// Mengambil status kehadiran anak hari ini
  Future<ChildAttendanceSummary?> getChildAttendanceToday(String studentId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final response = await _supabase
          .from('absensi')
          .select('*')
          .eq('siswa_id', studentId)
          .eq('tanggal', today)
          .maybeSingle();

      if (response != null) {
        return ChildAttendanceSummary(
          status: response['status']?.toUpperCase() ?? 'HADIR',
          time: response['jam_masuk'] ?? '--:--',
          date: DateTime.parse(response['tanggal']),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Mengambil riwayat nilai akademik anak
  Future<List<Map<String, dynamic>>> getStudentGrades(String studentId) async {
    try {
      final response = await _supabase
          .from('nilai')
          .select('*, mapel(nama)')
          .eq('siswa_id', studentId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// Mengambil program bimbel yang diikuti anak
  Future<List<Map<String, dynamic>>> getStudentBimbelPrograms(String studentId) async {
    try {
      final response = await _supabase
          .from('peserta_bimbel')
          .select('*, program_bimbel(*, guru(nama))')
          .eq('siswa_id', studentId)
          .eq('status', 'active');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// Mengambil data keuangan anak (Tagihan SPP)
  Future<List<Map<String, dynamic>>> getStudentFinances(String studentId) async {
    try {
      final response = await _supabase
          .from('pembayaran_spp')
          .select('*')
          .eq('siswa_id', studentId)
          .eq('status', 'belum_lunas')
          .order('bulan', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// Mengambil saldo tabungan anak
  Future<double> getStudentSavings(String studentId) async {
    try {
      final response = await _supabase
          .from('tabungan_siswa')
          .select('saldo')
          .eq('siswa_id', studentId)
          .maybeSingle();
      
      return (response?['saldo'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Mengambil jadwal pelajaran anak (Sinkron dengan Wakakur)
  Future<List<Map<String, dynamic>>> fetchChildSchedule(String studentId) async {
    try {
      // Ambil kelas_id siswa terlebih dahulu
      final studentRes = await _supabase
          .from('siswa')
          .select('kelas_id')
          .eq('id', studentId)
          .single();
      
      final classId = studentRes['kelas_id'];

      // Ambil jadwal berdasarkan kelas tersebut
      final response = await _supabase
          .from('jadwal_pelajaran')
          .select('*, mapel(nama), guru(nama), jam_pelajaran(*)')
          .eq('kelas_id', classId);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchChildSchedule');
      return [];
    }
  }

  /// Real-time: Pengumuman baru langsung muncul (Kepala Sekolah -> Ortu)
  Stream<List<Map<String, dynamic>>> streamAnnouncements() {
    return _supabase
        .from('pengumuman')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.where((e) => e['target_role'] == 'all' || e['target_role'] == 'orang_tua').toList());
  }
}
