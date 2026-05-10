import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ── Auth
import '../../features/auth/presentation/login_screen.dart';

// ── Dashboards
import '../../features/system_admin/presentation/superadmin_dashboard_screen.dart';
import '../../features/dashboard/headmaster_dashboard_screen.dart';
import '../../features/academic_config/wakakur_dashboard_screen.dart';
import '../../features/master_data/operator_dashboard_screen.dart';
import '../../features/finance/admin_finance_dashboard_screen.dart';
import '../../features/teacher/teacher_dashboard_screen.dart';
import '../../features/teacher/bimbel_dashboard_screen.dart';
import '../../features/parent/parent_dashboard_screen.dart';

// ── Shared Tools
import '../../features/shared_tools/quran_digital/quran_screen.dart';
import '../../features/shared_tools/quran_digital/surah_detail_screen.dart';
import '../../features/shared_tools/ai_assistant/ai_chat_screen.dart';

// ── Announcement
import '../../features/announcement/presentation/parent_announcement_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String login          = '/login';
  static const String superadmin     = '/superadmin';
  static const String kepala         = '/kepala-madrasah';
  static const String wakakur        = '/wakakur';
  static const String operator_      = '/operator';
  static const String keuangan       = '/keuangan';
  static const String guru           = '/guru';
  static const String guruWaliKelas  = '/guru/wali-kelas';
  static const String bimbel         = '/bimbel';
  static const String orangTua       = '/orang-tua';
  static const String quran          = '/quran';
  static const String quranDetail    = '/quran/:surahNumber';
  static const String aiGuru         = '/ai-guru';
  static const String aiBelajar      = '/ai-belajar';
  static const String announcementParent = '/announcement/parent';

  static String dashboardForRole(String role, {bool isWaliKelas = false}) {
    switch (role.toLowerCase()) {
      // ── Kode panjang (nama lengkap) ──────────────────────
      case 'superadmin':
      case 'super admin':
        return superadmin;

      case 'kepala':
      case 'kepala_madrasah':
        return kepala;

      case 'wakakur':
      case 'wakil_kurikulum':
        return wakakur;

      case 'operator':
      case 'operator_data':
        return operator_;

      case 'keuangan':
      case 'admin_keuangan':
        return keuangan;

      case 'guru':
      case 'guru_mapel':
        return isWaliKelas ? guruWaliKelas : guru;

      case 'bimbel':
      case 'guru_bimbel':
        return bimbel;

      case 'orang_tua':
      case 'parent':
        return orangTua;

      // ── Kode singkat dari database (SA, KM, WK, dst) ─────
      case 'sa': return superadmin;   // Super Admin
      case 'km': return kepala;       // Kepala Madrasah
      case 'wk': return wakakur;      // Wakil Kepala
      case 'op': return operator_;    // Operator
      case 'ak': return keuangan;     // Admin Keuangan
      case 'gm': return isWaliKelas ? guruWaliKelas : guru; // Guru Mapel
      case 'gb': return bimbel;       // Guru BK/Bimbel
      case 'ot': return orangTua;     // Orang Tua

      default:   return login;
    }
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  debugLogDiagnostics: kDebugMode,
  redirect: (BuildContext context, GoRouterState state) {
    return null;
  },
  routes: [
    GoRoute(path: AppRoutes.login,      builder: (context, state) => const LoginScreen()),
    GoRoute(path: AppRoutes.superadmin, builder: (context, state) => const SuperadminDashboardScreen()),
    GoRoute(path: AppRoutes.kepala,     builder: (context, state) => const HeadmasterDashboardScreen()),
    GoRoute(path: AppRoutes.wakakur,    builder: (context, state) => const WakakurDashboardScreen()),
    GoRoute(path: AppRoutes.operator_,  builder: (context, state) => const OperatorDashboardScreen()),
    GoRoute(path: AppRoutes.keuangan,   builder: (context, state) => const AdminFinanceDashboardScreen()),
    GoRoute(path: AppRoutes.guru,       builder: (context, state) => const TeacherDashboardScreen(isWaliKelas: false)),
    GoRoute(path: AppRoutes.guruWaliKelas, builder: (context, state) => const TeacherDashboardScreen(isWaliKelas: true)),
    GoRoute(path: AppRoutes.bimbel,     builder: (context, state) => const BimbelDashboardScreen()),
    GoRoute(path: AppRoutes.orangTua,   builder: (context, state) => const ParentDashboardScreen()),
    GoRoute(
      path: AppRoutes.quran,
      builder: (context, state) => const QuranDigitalScreen(),
      routes: [
        GoRoute(
          path: ':surahNumber',
          builder: (context, state) {
            final surahNumberStr = state.pathParameters['surahNumber'] ?? '1';
            final surahNumber = int.tryParse(surahNumberStr) ?? 1;
            final extra = state.extra as Map<String, dynamic>?;
            final surahName = extra?['surahName'] as String? ?? 'Al-Fatihah';
            return SurahDetailScreen(surahNumber: surahNumber, surahName: surahName);
          },
        ),
      ],
    ),
    GoRoute(path: AppRoutes.aiGuru,    builder: (context, state) => AIChatScreen(assistantName: 'Sahabat Guru', themeColor: Colors.indigo.shade700)),
    GoRoute(path: AppRoutes.aiBelajar, builder: (context, state) => AIChatScreen(assistantName: 'Sahabat Belajar', themeColor: Colors.indigo)),
    GoRoute(path: AppRoutes.announcementParent, builder: (context, state) => const ParentAnnouncementScreen()),
  ],
);
