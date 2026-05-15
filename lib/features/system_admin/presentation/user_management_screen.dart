import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '../../../core/network/d1_service.dart';
import '../../../core/utils/context_extensions.dart';
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

  // ── HELPER: SHA-256 HASHING ──
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _d1Service.query(
        """
        SELECT u.*, r.code as role_code, r.nama as role_name, t.is_wali_kelas
        FROM users u
        LEFT JOIN user_roles ur ON u.id = ur.user_id AND ur.is_primary = 1
        LEFT JOIN roles r ON ur.role_id = r.id
        LEFT JOIN teachers t ON u.id = t.user_id
        ORDER BY u.created_at DESC
        """
      );

      _allUsers = (data as List).map((json) => AppUser.fromJson({
        ...json,
        'role_code': json['role_code'],
        'role_name': json['role_name'],
        'is_wali_kelas': json['is_wali_kelas'],
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
                              u.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                              u.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                              (u.nisNip?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
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
      'GB': 'Guru Bimbel',
      'OT': 'Orang Tua',
    };
    return roleNames[code] ?? code;
  }

  Widget _buildUserList() {
    if (_filteredUsers.isEmpty) {
      return const Center(child: Text('Tidak ada user ditemukan.'));
    }
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
          title: Text(user.fullName.isNotEmpty ? user.fullName : user.username, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("${user.email}${user.nisNip != null ? ' • ${user.nisNip}' : ''} • ${user.roleName ?? 'Tanpa Role'}"),
          trailing: PopupMenuButton<String>(
            onSelected: (action) => _handleUserAction(context, action, user),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'reset_pass', child: Text('Reset Password')),
              const PopupMenuItem(value: 'edit_role', child: Text('Ubah Role')),
              PopupMenuItem(value: 'toggle_status', child: Text(user.isActive ? 'Nonaktifkan' : 'Aktifkan')),
            ],
          ),
        );
      },
    );
  }

  void _showAddUserModal(BuildContext context) {
    final usernameController = TextEditingController();
    final fullNameController = TextEditingController();
    final nisNipController = TextEditingController();
    final emailController = TextEditingController();
    final passController = TextEditingController();
    String selectedRole = 'GM'; // Default Guru Mapel
    bool isWaliKelas = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Tambah User Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModalTextField(fullNameController, 'Nama Lengkap'),
                _buildModalTextField(nisNipController, 'NIS / NIP'),
                _buildModalTextField(usernameController, 'Username'),
                _buildModalTextField(emailController, 'Email'),
                _buildModalTextField(passController, 'Password', isObscure: true),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role Akses',
                    border: OutlineInputBorder(),
                  ),
                  items: _roles.where((r) => r != 'Semua Role').map((r) => DropdownMenuItem(value: r, child: Text(_getFullRoleName(r)))).toList(),
                  onChanged: (v) {
                    setModalState(() {
                      selectedRole = v!;
                      // Jika bukan Guru, matikan checkbox wali kelas
                      if (selectedRole != 'GM' && selectedRole != 'GB') {
                        isWaliKelas = false;
                      }
                    });
                  },
                ),
                if (selectedRole == 'GM' || selectedRole == 'GB') ...[
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('Tugaskan sebagai Wali Kelas?', style: TextStyle(fontSize: 14)),
                    value: isWaliKelas,
                    onChanged: (v) => setModalState(() => isWaliKelas = v!),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (usernameController.text.isEmpty || passController.text.isEmpty || fullNameController.text.isEmpty) {
                  context.showErrorSnackBar('Nama Lengkap, Username, dan Password wajib diisi');
                  return;
                }
                
                final id = "u_${DateTime.now().millisecondsSinceEpoch}";
                final hash = _hashPassword(passController.text);
                
                try {
                  // 1. Simpan ke tabel users
                  await _d1Service.query(
                    "INSERT INTO users (id, username, full_name, nis_nip, email, password_hash, is_active) VALUES (?, ?, ?, ?, ?, ?, 1)",
                    params: [
                      id, 
                      usernameController.text, 
                      fullNameController.text, 
                      nisNipController.text.isEmpty ? null : nisNipController.text,
                      emailController.text, 
                      hash
                    ],
                  );
                  
                  // 2. Hubungkan ke Role
                  final roleRes = await _d1Service.query("SELECT id FROM roles WHERE code = ? LIMIT 1", params: [selectedRole]);
                  if ((roleRes as List).isNotEmpty) {
                    final roleId = roleRes.first['id'];
                    await _d1Service.query(
                      "INSERT INTO user_roles (user_id, role_id, is_primary) VALUES (?, ?, 1)",
                      params: [id, roleId],
                    );
                  }

                  // 3. Jika Guru, simpan ke tabel teachers
                  if (selectedRole == 'GM' || selectedRole == 'GB') {
                    await _d1Service.query(
                      "INSERT INTO teachers (user_id, is_wali_kelas) VALUES (?, ?)",
                      params: [id, isWaliKelas ? 1 : 0],
                    );
                  }
                  
                  if (mounted) {
                    Navigator.pop(context);
                    _fetchUsers();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User berhasil ditambahkan!')));
                  }
                } catch (e) {
                  context.showErrorSnackBar('Gagal: $e');
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalTextField(TextEditingController controller, String label, {bool isObscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  void _handleUserAction(BuildContext context, String action, AppUser user) {
    if (action == 'reset_pass') {
      _showResetPasswordDialog(user);
    } else if (action == 'edit_role') {
      _showEditRoleDialog(user);
    } else if (action == 'toggle_status') {
      _toggleUserStatus(user);
    }
  }

  void _showEditRoleDialog(AppUser user) {
    String currentRole = user.roleCode ?? 'GM';
    bool isWaliKelas = user.isWaliKelas;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('Ubah Role: ${user.username}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: currentRole,
                decoration: const InputDecoration(labelText: 'Role Akses', border: OutlineInputBorder()),
                items: _roles.where((r) => r != 'Semua Role').map((r) => DropdownMenuItem(value: r, child: Text(_getFullRoleName(r)))).toList(),
                onChanged: (v) => setModalState(() {
                  currentRole = v!;
                  if (currentRole != 'GM' && currentRole != 'GB') isWaliKelas = false;
                }),
              ),
              if (currentRole == 'GM' || currentRole == 'GB') ...[
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Wali Kelas?', style: TextStyle(fontSize: 14)),
                  value: isWaliKelas,
                  onChanged: (v) => setModalState(() => isWaliKelas = v!),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                try {
                  // 1. Update primary role
                  final roleRes = await _d1Service.query("SELECT id FROM roles WHERE code = ? LIMIT 1", params: [currentRole]);
                  if ((roleRes as List).isNotEmpty) {
                    final roleId = roleRes.first['id'];
                    await _d1Service.query(
                      "UPDATE user_roles SET role_id = ? WHERE user_id = ? AND is_primary = 1",
                      params: [roleId, user.id],
                    );
                  }

                  // 2. Update/Insert teacher status
                  if (currentRole == 'GM' || currentRole == 'GB') {
                    await _d1Service.query(
                      "INSERT INTO teachers (user_id, is_wali_kelas) VALUES (?, ?) ON CONFLICT(user_id) DO UPDATE SET is_wali_kelas = excluded.is_wali_kelas",
                      params: [user.id, isWaliKelas ? 1 : 0],
                    );
                  } else {
                    // Hapus jika bukan guru lagi? Atau biarkan saja.
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    _fetchUsers();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Role berhasil diperbarui!')));
                  }
                } catch (e) {
                  context.showErrorSnackBar('Gagal update role: $e');
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetPasswordDialog(AppUser user) {
    final passController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password: ${user.username}'),
        content: TextField(controller: passController, decoration: const InputDecoration(labelText: 'Password Baru'), obscureText: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (passController.text.isEmpty) return;
              final hash = _hashPassword(passController.text);
              try {
                await _d1Service.query("UPDATE users SET password_hash = ? WHERE id = ?", params: [hash, user.id]);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil diupdate!')));
                }
              } catch (e) {
                context.showErrorSnackBar('Gagal: $e');
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
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
}
