import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/error_handler.dart';

class WaliKelasService {
  final _supabase = Supabase.instance.client;

  // ── MANAJEMEN KELAS PERWALIAN ─────────────────────────────
  
  Future<String?> getTeacherIdByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('guru')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();
      return response?['id'];
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchWaliKelasClass(String teacherId) async {
    try {
      final response = await _supabase
          .from('kelas')
          .select('id, nama')
          .eq('wali_kelas_id', teacherId)
          .maybeSingle();
      
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchStudentsWithParents(String classId) async {
    try {
      final response = await _supabase
          .from('siswa')
          .select('*, orang_tua_siswa(orang_tua(nama, no_hp))')
          .eq('kelas_id', classId)
          .order('nama');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchStudentsWithParents');
      throw err;
    }
  }

  // ── AGREGASI & REKAP ─────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchClassGradesRecap(String classId) async {
    try {
      final response = await _supabase
          .from('nilai')
          .select('skor, mapel(nama), siswa!inner(kelas_id)')
          .eq('siswa.kelas_id', classId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchClassAttendanceRecap(String classId) async {
    try {
      final response = await _supabase
          .from('absensi')
          .select('status, siswa!inner(kelas_id, nama)')
          .eq('siswa.kelas_id', classId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchClassNotes(String classId) async {
    try {
      final response = await _supabase
          .from('catatan_perkembangan')
          .select('*, guru(nama)')
          .eq('kelas_id', classId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // ── CATATAN PERKEMBANGAN ──────────────────────────────────

  Future<void> addClassNote(String classId, String teacherId, String category, String note) async {
    try {
      await _supabase.from('catatan_perkembangan').insert({
        'kelas_id': classId,
        'guru_id': teacherId,
        'kategori': category,
        'catatan': note,
      });
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'addClassNote');
      throw err;
    }
  }
}
