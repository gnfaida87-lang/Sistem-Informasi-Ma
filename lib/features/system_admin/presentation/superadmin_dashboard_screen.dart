import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import 'system_dashboard_screen.dart';
import 'user_management_screen.dart';
import 'role_access_screen.dart';
import 'monitoring_screen.dart';
import 'backup_screen.dart';
import 'integration_screen.dart';
import 'app_settings_screen.dart';
import '../../auth/presentation/login_screen.dart';
import '../../../shared/widgets/profile_settings_screen.dart';
import '../../../core/constants/app_settings.dart';

class SuperadminDashboardScreen extends StatefulWidget {
  const SuperadminDashboardScreen({super.key});

  @override
  State<SuperadminDashboardScreen> createState() => _SuperadminDashboardScreenState();
}

class _SuperadminDashboardScreenState extends State<SuperadminDashboardScreen> {
  int _selectedIndex = 0;

  // Layar yang akan ditampilkan sesuai menu yang dipilih
  final List<Widget> _screens = [
    const SystemDashboardScreen(),
    const UserManagementScreen(), // Layar lainnya belum diedit tanpa appBar, tapi tetap bisa ditampilkan
    const RoleAccessScreen(),
    const MonitoringScreen(),
    const BackupMaintenanceScreen(),
    const IntegrationScreen(),
    const AppSettingsScreen(),
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Dashboard', 'icon': Icons.grid_view_outlined},
    {'title': 'Manajemen User', 'icon': Icons.people_outline},
    {'title': 'Role & Akses', 'icon': Icons.admin_panel_settings_outlined},
    {'title': 'Monitoring', 'icon': Icons.auto_graph_outlined},
    {'title': 'Backup Data', 'icon': Icons.cloud_outlined},
    {'title': 'Integrasi AI', 'icon': Icons.memory_outlined},
    {'title': 'Pengaturan', 'icon': Icons.settings_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE), // Warna background abu-abu terang mirip referensi
      body: Row(
        children: [
          // SIDEBAR (Hanya tampil di Desktop)
          if (isDesktop) _buildSidebar(),

          // MAIN CONTENT AREA
          Expanded(
            child: Column(
              children: [
                // TOP BAR (Mirip referensi gambar)
                _buildTopBar(isDesktop),

                // CONTENT SCREEN
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                    ),
                    child: Container(
                      color: const Color(0xFFF4F7FE),
                      child: _screens[_selectedIndex],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // DRAWER UNTUK MOBILE
      drawer: !isDesktop ? Drawer(child: _buildSidebar()) : null,
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          // Logo Area
          Container(
            height: 70,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  appConfig.schoolName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B3674),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 16),
          // Menu Items
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                      if (MediaQuery.of(context).size.width <= 800) {
                        Navigator.pop(context); // Tutup drawer jika di mobile
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange.shade50 : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            _menuItems[index]['icon'],
                            color: isSelected ? Colors.orange.shade600 : Colors.grey.shade500,
                            size: 22,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            _menuItems[index]['title'],
                            style: TextStyle(
                              color: isSelected ? Colors.orange.shade700 : Colors.grey.shade600,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isDesktop) {
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (!isDesktop) // Tombol hamburger untuk mobile
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.grey),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          
          if (isDesktop)
            IconButton(
              icon: const Icon(Icons.menu_open, color: Colors.grey),
              onPressed: () {},
            ),

          const SizedBox(width: 16),
          
          // Search Bar (seperti di referensi)
          Container(
            width: 250,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: double.infinity,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.search, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Ikon kanan atas (Notifikasi & Profil)
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.grey),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('2', style: TextStyle(fontSize: 8, color: Colors.white)),
                ),
              )
            ],
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileSettingsScreen()));
              } else if (value == 'logout') {
                context.go(AppRoutes.login);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings, size: 20),
                  title: Text('Pengaturan Profil', style: TextStyle(fontSize: 14)),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, size: 20, color: Colors.red),
                  title: Text('Keluar (Logout)', style: TextStyle(fontSize: 14, color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
            child: const CircleAvatar(
              backgroundColor: Colors.blueGrey,
              radius: 16,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
