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
import 'db_diagnostic_screen.dart';
import '../../auth/presentation/login_screen.dart';
import '../../../shared/widgets/shared_top_bar.dart';
import '../../../shared/widgets/shared_sidebar.dart';

class SuperadminDashboardScreen extends StatefulWidget {
  const SuperadminDashboardScreen({super.key});

  @override
  State<SuperadminDashboardScreen> createState() => _SuperadminDashboardScreenState();
}

class _SuperadminDashboardScreenState extends State<SuperadminDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const SystemDashboardScreen(),
    const UserManagementScreen(),
    const RoleAccessScreen(),
    const MonitoringScreen(),
    const BackupMaintenanceScreen(),
    const IntegrationScreen(),
    const AppSettingsScreen(),
    const DbDiagnosticScreen(),
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Dashboard', 'icon': Icons.grid_view_outlined},
    {'title': 'Manajemen User', 'icon': Icons.people_outline},
    {'title': 'Role & Akses', 'icon': Icons.admin_panel_settings_outlined},
    {'title': 'Monitoring', 'icon': Icons.auto_graph_outlined},
    {'title': 'Backup Data', 'icon': Icons.cloud_outlined},
    {'title': 'Integrasi AI', 'icon': Icons.memory_outlined},
    {'title': 'Pengaturan', 'icon': Icons.settings_outlined},
    {'title': 'Diagnostik DB', 'icon': Icons.analytics_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: Row(
        children: [
          if (isDesktop) 
            SharedSidebar(
              selectedIndex: _selectedIndex,
              menuItems: _menuItems,
              onItemSelected: (index) => setState(() => _selectedIndex = index),
              accentColor: Colors.orange.shade700,
            ),

          Expanded(
            child: Column(
              children: [
                SharedTopBar(
                  title: _menuItems[_selectedIndex]['title'],
                ),

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
      drawer: !isDesktop ? Drawer(
        child: SharedSidebar(
          selectedIndex: _selectedIndex,
          menuItems: _menuItems,
          onItemSelected: (index) => setState(() => _selectedIndex = index),
          accentColor: Colors.orange.shade700,
        ),
      ) : null,
    );
  }
}
