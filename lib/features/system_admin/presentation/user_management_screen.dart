import 'package:flutter/material.dart';
import '../../../core/network/supabase_service.dart';
import '../../../shared/models/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  // State untuk data ril
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
      final response = await SupabaseService().client
          .from('users')
          .select('*, user_roles(is_primary, roles(*))')
          .order('created_at', ascending: false);

      final List<dynamic> data = response;
      _allUsers = data.map((json) => AppUser.fromJson(json)).toList();
      _applyFilter();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data: $e';
          _isLoading = false;
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
            // Custom Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: Colors.green.shade800,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Manajemen User', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white),
                    tooltip: 'Tambah User Baru',
                    onPressed: () {
                      _showAddUserModal(context);
                    },
                  ),
                ],
              ),
            ),
            // Search & Filter Section
            Container(
              color: Colors.green.shade50,
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
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.green.shade200),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildRoleFilterDropdown(),
                ],
              ),
            ),
            
            // User List Section
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                  ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _fetchUsers, child: const Text('Coba Lagi'))
                      ],
                    ))
                  : _filteredUsers.isEmpty
                    ? const Center(child: Text('Tidak ada data user found.'))
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
        border: Border.all(color: Colors.green.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRoleFilter,
          icon: const Icon(Icons.filter_list, size: 20),
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          onChanged: (String? newValue) {
            if (newValue != null) {
              _selectedRoleFilter = newValue;
              _applyFilter();
            }
          },
          items: _roles.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(_getFullRoleName(value)),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getFullRoleName(String code) {
    if (code == 'Semua Role') return code;
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
      separatorBuilder: (context, index) => const Divider(height: 16),
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        final isActive = user.isActive;
        final role = user.roleName ?? 'Tanpa Role';
        
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: isActive ? Colors.green.shade100 : Colors.red.shade50,
                  foregroundColor: isActive ? Colors.green.shade700 : Colors.red.shade400,
                  child: Icon(isActive ? Icons.person : Icons.person_off),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            user.username,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildStatusBadge(isActive),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Action Menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (action) {
                    _handleUserAction(context, action, user);
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit_role',
                      child: ListTile(
                        leading: Icon(Icons.manage_accounts, size: 20),
                        title: Text('Atur Role'),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'reset_pass',
                      child: ListTile(
                        leading: Icon(Icons.lock_reset, size: 20),
                        title: Text('Reset Password'),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: isActive ? 'deactivate' : 'activate',
                      child: ListTile(
                        leading: Icon(isActive ? Icons.block : Icons.check_circle_outline, size: 20, color: isActive ? Colors.red : Colors.green),
                        title: Text(isActive ? 'Nonaktifkan' : 'Aktifkan', style: TextStyle(color: isActive ? Colors.red : Colors.green)),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? Colors.green.shade200 : Colors.red.shade200),
      ),
      child: Text(
        isActive ? 'Aktif' : 'Nonaktif',
        style: TextStyle(
          fontSize: 10,
          color: isActive ? Colors.green.shade700 : Colors.red.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // --- Modals & Dialogs ---

  void _showAddUserModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tambah User Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle_outlined),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Pilih Role Terdaptar',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shield_outlined),
                ),
                items: _roles.where((r) => r != 'Semua Role').map((role) {
                  return DropdownMenuItem(value: role, child: Text(_getFullRoleName(role)));
                }).toList(),
                onChanged: (val) {},
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User berhasil ditambahkan (Mock)')));
                  },
                  child: const Text('Simpan User Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _handleUserAction(BuildContext context, String action, AppUser user) {
    if (action == 'reset_pass') {
      _showResetPasswordConfirm(context, user);
    } else if (action == 'edit_role') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Buka form Atur Role (Mock)')));
    } else if (action == 'deactivate' || action == 'activate') {
      _toggleUserStatus(user);
    }
  }

  Future<void> _toggleUserStatus(AppUser user) async {
    try {
      await SupabaseService().client.from('users').update({
        'is_active': !user.isActive
      }).eq('id', user.id);
      
      _fetchUsers(); // Refresh
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status ${user.username} diperbarui.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal ubah status: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _showResetPasswordConfirm(BuildContext context, AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password?'),
        content: const Text('Anda yakin ingin mereset password ke default untuk user ini? \n\nHal ini akan memutus sesi login mereka saat ini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password direset (Mock)')));
            },
            child: const Text('Ya, Reset Password', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
