import 'package:flutter/material.dart';
import '../../../core/network/d1_service.dart';
import '../../../shared/models/app_user.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _d1Service = D1Service();
  List<AppUser> _allUsers = [];
  List<AppUser> _filteredUsers = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _selectedRoleFilter = 'Semua Role';
  final List<String> _roles = ['Semua Role', 'SA', 'KM', 'WK', 'OP', 'AK', 'GM', 'GB', 'OT'];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _d1Service.query(
        """
        SELECT u.*, r.code as role_code, r.nama as role_name 
        FROM users u
        LEFT JOIN user_roles ur ON u.id = ur.user_id AND ur.is_primary = 1
        LEFT JOIN roles r ON ur.role_id = r.id
        ORDER BY u.created_at DESC
        """
      );

      _allUsers = (data as List).map((json) => AppUser.fromJson({
        ...json,
        'role_code': json['role_code'],
        'role_name': json['role_name'],
      })).toList();
      
      _applyFilter();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredUsers = _allUsers.where((u) {
        final matchesRole = _selectedRoleFilter == 'Semua Role' || u.roleCode == _selectedRoleFilter;
        final matchesSearch = _searchQuery.isEmpty || 
                              u.username.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                              u.email.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesRole && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: const Color(0xFF2B3674),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Manajemen User', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white),
                    onPressed: () => _showAddUserModal(context),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        _searchQuery = value;
                        _applyFilter();
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari nama, email, atau ID...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildRoleFilterDropdown(),
                ],
              ),
            ),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : _buildUserList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRoleFilter,
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _selectedRoleFilter = newValue);
              _applyFilter();
            }
          },
          items: _roles.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value == 'Semua Role' ? value : _getFullRoleName(value)),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getFullRoleName(String code) {
    const roleNames = {
      'SA': 'Super Admin',
      'KM': 'Kepala Madrasah',
      'WK': 'Wakil Kepala',
      'OP': 'Operator',
      'AK': 'Admin Keuangan',
      'GM': 'Guru Mapel',
      'GB': 'Guru BK',
      'OT': 'Orang Tua',
    };
    return roleNames[code] ?? code;
  }

  Widget _buildUserList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredUsers.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: user.isActive ? Colors.green.shade50 : Colors.red.shade50,
            child: Icon(user.isActive ? Icons.person : Icons.person_off, color: user.isActive ? Colors.green : Colors.red),
          ),
          title: Text(user.username, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("${user.email} • ${user.roleName ?? 'Tanpa Role'}"),
          trailing: PopupMenuButton<String>(
            onSelected: (action) => _handleUserAction(context, action, user),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'reset_pass', child: Text('Reset Password')),
              PopupMenuItem(value: 'toggle_status', child: Text(user.isActive ? 'Nonaktifkan' : 'Aktifkan')),
            ],
          ),
        );
      },
    );
  }

  void _showAddUserModal(BuildContext context) {
    // Implementasi D1 insert untuk user baru
    context.showErrorSnackBar('Gunakan fitur registrasi atau hubungi Admin sistem.');
  }

  void _handleUserAction(BuildContext context, String action, AppUser user) {
    if (action == 'reset_pass') {
      _resetPassword(user);
    } else if (action == 'toggle_status') {
      _toggleUserStatus(user);
    }
  }

  Future<void> _toggleUserStatus(AppUser user) async {
    try {
      await _d1Service.query(
        "UPDATE users SET is_active = ? WHERE id = ?",
        params: [user.isActive ? 0 : 1, user.id],
      );
      _fetchUsers();
    } catch (e) {
      context.showErrorSnackBar('Gagal update status: $e');
    }
  }

  Future<void> _resetPassword(AppUser user) async {
    try {
      await _d1Service.query(
        "UPDATE users SET password_hash = ? WHERE id = ?",
        params: ['12345678', user.id],
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password direset ke default: 12345678')));
    } catch (e) {
      context.showErrorSnackBar('Gagal reset password: $e');
    }
  }
}
