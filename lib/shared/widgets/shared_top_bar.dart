import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/system_provider.dart';
import '../../core/router/app_router.dart';
import 'profile_settings_screen.dart';

class SharedTopBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showDrawer;
  final bool showLogout;

  const SharedTopBar({
    super.key,
    required this.title,
    this.showDrawer = true,
    this.showLogout = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final systemSettings = ref.watch(systemSettingsProvider).value;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (!isDesktop && showDrawer)
            IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF2B3674)),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B3674),
            ),
          ),
          
          const Spacer(),
          
          // Profil Dropdown
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileSettingsScreen()));
              } else if (value == 'logout') {
                ref.read(authProvider.notifier).logout();
                context.go(AppRoutes.login);
              }
            },
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      user?.fullName ?? user?.username ?? 'User',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF2B3674),
                      ),
                    ),
                    Text(
                      _getRoleName(user?.roleCode),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFFF4F7FE),
                      backgroundImage: user?.profileUrl != null ? NetworkImage(user!.profileUrl!) : null,
                      child: user?.profileUrl == null ? const Icon(Icons.person, size: 20, color: Color(0xFF2B3674)) : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
              ],
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 20, color: Colors.grey.shade700),
                    const SizedBox(width: 12),
                    const Text('Pengaturan Profil'),
                  ],
                ),
              ),
              if (showLogout)
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: Colors.red.shade400),
                      const SizedBox(width: 12),
                      const Text('Keluar Aplikasi', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getRoleName(String? code) {
    switch (code?.toUpperCase()) {
      case 'SA': return 'Super Admin';
      case 'KM': return 'Kepala Madrasah';
      case 'WK': return 'Wakil Kurikulum';
      case 'OP': return 'Operator Data';
      case 'AK': return 'Admin Keuangan';
      case 'GM': return 'Guru Mapel';
      case 'GB': return 'Guru Bimbel';
      case 'OT': return 'Orang Tua';
      default: return 'User';
    }
  }
}
