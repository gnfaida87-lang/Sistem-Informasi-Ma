import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/providers/system_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/mixins/safe_async_mixin.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/network/d1_service.dart';
import '../models/system_settings_model.dart';

class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> with SafeAsync {
  final _schoolNameController = TextEditingController();
  final _appNameController = TextEditingController();
  final _headmasterNameController = TextEditingController();
  
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isOldPasswordObscure = true;
  bool _isNewPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;

  int _selectedSubMenu = 0; 
  
  String? _logoUrl;
  String? _faviconUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() async {
    final settingsAsync = ref.read(systemSettingsProvider);
    settingsAsync.whenData((settings) {
      setState(() {
        _schoolNameController.text = settings.schoolName;
        _appNameController.text = settings.appName;
        _headmasterNameController.text = settings.headmasterName;
        _logoUrl = settings.logoUrl;
        _faviconUrl = settings.faviconUrl;
      });
    });
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _appNameController.dispose();
    _headmasterNameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload(bool isLogo) async {
    final settings = ref.read(systemSettingsProvider).value;
    if (settings == null || settings.gdriveApiKey == null || settings.gdriveApiKey!.isEmpty) {
      context.showErrorSnackBar('Konfigurasi Google Drive (API Key) belum diatur di menu Integrasi.');
      return;
    }

    final result = await FilePicker.pickFiles(type: FileType.image, withData: true);

    if (result != null && result.files.first.bytes != null) {
      final file = result.files.first;
      
      await safeCall(
        context: context,
        action: () async {
          final service = ref.read(systemServiceProvider);
          final previewLink = await service.uploadBrandingFile(
            fileName: '${isLogo ? "logo" : "favicon"}_${DateTime.now().millisecondsSinceEpoch}.${file.extension}',
            fileBytes: file.bytes!,
            apiKey: settings.gdriveApiKey!,
            folderId: settings.gdriveFolderId ?? 'root',
          );

          if (previewLink != null) {
            setState(() {
              if (isLogo) _logoUrl = previewLink;
              else _faviconUrl = previewLink;
            });
          } else {
            throw 'Gagal mengunggah ke Google Drive.';
          }
        },
        successMessage: 'File berhasil diunggah!',
      );
    }
  }

  Future<void> _saveAllSettings() async {
    final currentSettings = ref.read(systemSettingsProvider).value;
    final settings = SystemSettings(
      schoolName: _schoolNameController.text,
      appName: _appNameController.text,
      headmasterName: _headmasterNameController.text,
      logoUrl: _logoUrl,
      faviconUrl: _faviconUrl,
      guruAiKeys: currentSettings?.guruAiKeys ?? [],
      guruAiEngine: currentSettings?.guruAiEngine,
      belajarAiKeys: currentSettings?.belajarAiKeys ?? [],
      belajarAiEngine: currentSettings?.belajarAiEngine,
      isMaintenance: currentSettings?.isMaintenance ?? false,
      gdriveApiKey: currentSettings?.gdriveApiKey,
      gdriveFolderId: currentSettings?.gdriveFolderId,
      sppNominalX: currentSettings?.sppNominalX ?? 250000,
      sppNominalXI: currentSettings?.sppNominalXI ?? 275000,
      sppNominalXII: currentSettings?.sppNominalXII ?? 300000,
      academicStartMonth: currentSettings?.academicStartMonth ?? 7,
    );

    await safeCall(
      context: context,
      action: () async {
        final service = ref.read(systemServiceProvider);
        await service.updateSettings(settings);
        ref.invalidate(systemSettingsProvider);
      },
      successMessage: 'Pengaturan berhasil disimpan!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(systemSettingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: Row(
        children: [
          Container(
            width: 200,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              border: const Border(right: BorderSide(color: Colors.black12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('PENGATURAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                ),
                _buildSubMenuItem(0, Icons.settings_outlined, 'Umum'),
                _buildSubMenuItem(1, Icons.lock_outline, 'Keamanan'),
              ],
            ),
          ),
          Expanded(
            child: settingsAsync.when(
              data: (settings) => SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedSubMenu == 0 ? 'Pengaturan Umum' : 'Ubah Password',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedSubMenu == 0 
                        ? 'Kelola informasi sekolah dan identitas visual sistem.' 
                        : 'Perbarui kata sandi akun administrator Anda.',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 32),
                    if (isLoading) const Padding(padding: EdgeInsets.only(bottom: 16.0), child: LinearProgressIndicator(color: Colors.orange)),
                    _buildCurrentContent(),
                  ],
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentContent() {
    switch (_selectedSubMenu) {
      case 0: return _buildGeneralSettings();
      case 1: return _buildSecuritySettings();
      default: return _buildGeneralSettings();
    }
  }

  Widget _buildSubMenuItem(int index, IconData icon, String title) {
    final isSelected = _selectedSubMenu == index;
    return InkWell(
      onTap: () => setState(() => _selectedSubMenu = index),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: isSelected ? Colors.orange.shade600 : Colors.transparent, width: 3)),
          color: isSelected ? Colors.orange.shade50.withOpacity(0.5) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.orange.shade700 : Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Colors.orange.shade700 : Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Column(
      children: [
        _buildSectionCard(
          title: 'Identitas Sekolah',
          children: [
            _buildTextField(label: 'Nama Sekolah', controller: _schoolNameController, hint: 'Contoh: MA Al-Falah'),
            const SizedBox(height: 20),
            _buildTextField(label: 'Nama Aplikasi', controller: _appNameController, hint: 'Contoh: Portal Akademik Madrasah'),
            const SizedBox(height: 20),
            _buildTextField(label: 'Kepala Sekolah', controller: _headmasterNameController, hint: 'Nama Lengkap + Gelar'),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionCard(
          title: 'Visual Branding',
          children: [
            Row(
              children: [
                Expanded(child: _buildUploadBox('Logo (Login)', _logoUrl, () => _pickAndUpload(true))),
                const SizedBox(width: 20),
                Expanded(child: _buildUploadBox('Ikon (Browser)', _faviconUrl, () => _pickAndUpload(false))),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSaveButton(),
      ],
    );
  }


  Widget _buildSecuritySettings() {
    return Column(
      children: [
        _buildSectionCard(
          title: 'Ganti Kata Sandi',
          children: [
            _buildTextField(label: 'Password Lama', controller: _oldPasswordController, hint: '••••••••', isObscure: _isOldPasswordObscure, onObscureToggle: () => setState(() => _isOldPasswordObscure = !_isOldPasswordObscure)),
            const SizedBox(height: 20),
            _buildTextField(label: 'Password Baru', controller: _newPasswordController, hint: 'Min. 8 Karakter', isObscure: _isNewPasswordObscure, onObscureToggle: () => setState(() => _isNewPasswordObscure = !_isNewPasswordObscure)),
            const SizedBox(height: 20),
            _buildTextField(label: 'Konfirmasi', controller: _confirmPasswordController, hint: 'Ulangi Password', isObscure: _isConfirmPasswordObscure, onObscureToggle: () => setState(() => _isConfirmPasswordObscure = !_isConfirmPasswordObscure)),
          ],
        ),
        const SizedBox(height: 32),
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
        const SizedBox(height: 20),
        ...children,
      ]),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, required String hint, bool isObscure = false, VoidCallback? onObscureToggle}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        obscureText: isObscure,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: onObscureToggle != null ? IconButton(icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, size: 18), onPressed: onObscureToggle) : null,
        ),
      ),
    ]);
  }

  Widget _buildUploadBox(String label, String? url, VoidCallback onTap) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      InkWell(
        onTap: onTap,
        child: Container(
          height: 100, width: double.infinity,
          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
          child: url != null ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(url, fit: BoxFit.contain)) : const Icon(Icons.add_photo_alternate_outlined, color: Colors.grey),
        ),
      ),
    ]);
  }

  Widget _buildSaveButton() {
    // Panggil fungsi yang tepat sesuai tab yang aktif
    final handler = _selectedSubMenu == 1 ? _saveSecuritySettings : _saveAllSettings;
    return ElevatedButton.icon(
      onPressed: isLoading ? null : handler,
      icon: const Icon(Icons.save_outlined),
      label: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700, foregroundColor: Colors.white, minimumSize: const Size(200, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );
  }

  /// Hashing SHA-256 untuk password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _saveSecuritySettings() async {
    final oldPass = _oldPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    // Validasi input
    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      context.showErrorSnackBar('Semua field password wajib diisi.');
      return;
    }
    if (newPass.length < 8) {
      context.showErrorSnackBar('Password baru minimal 8 karakter.');
      return;
    }
    if (newPass != confirmPass) {
      context.showErrorSnackBar('Konfirmasi password tidak cocok.');
      return;
    }

    final user = ref.read(authProvider).user;
    if (user == null) {
      context.showErrorSnackBar('Sesi tidak valid, silakan login ulang.');
      return;
    }

    await safeCall(
      context: context,
      action: () async {
        final d1 = D1Service();
        // Verifikasi password lama
        final oldHash = _hashPassword(oldPass);
        final result = await d1.query(
          'SELECT id FROM users WHERE id = ? AND password_hash = ? LIMIT 1',
          params: [user.id, oldHash],
        );
        if ((result as List).isEmpty) {
          throw 'Password lama tidak sesuai.';
        }
        // Update ke password baru
        final newHash = _hashPassword(newPass);
        await d1.query(
          'UPDATE users SET password_hash = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
          params: [newHash, user.id],
        );
        // Reset field setelah berhasil
        if (mounted) {
          _oldPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        }
        if (kDebugMode) debugPrint('Password berhasil diperbarui untuk user: ${user.id}');
      },
      successMessage: 'Password berhasil diperbarui!',
    );
  }
}
