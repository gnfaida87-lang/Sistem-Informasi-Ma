import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_settings.dart';
import '../../../core/providers/system_provider.dart';
import '../../../core/mixins/safe_async_mixin.dart';
import '../../../core/utils/context_extensions.dart';
import '../models/system_settings_model.dart';

class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> with SafeAsync {
  final _schoolNameController = TextEditingController();
  final _headmasterNameController = TextEditingController();
  
  // Password controllers
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isOldPasswordObscure = true;
  bool _isNewPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;

  int _selectedSubMenu = 0; // 0: Umum, 1: Ubah Password
  
  String? _logoUrl;
  String? _faviconUrl;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() async {
    final settingsAsync = ref.read(systemSettingsProvider);
    settingsAsync.whenData((settings) {
      setState(() {
        _schoolNameController.text = settings.schoolName;
        _headmasterNameController.text = settings.headmasterName;
        _logoUrl = settings.logoUrl;
        _faviconUrl = settings.faviconUrl;
      });
    });
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _headmasterNameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload(bool isLogo) async {
    // In some versions of file_picker, it's pickFiles directly on the class
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.first.bytes != null) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${result.files.first.name}';
      final fileBytes = result.files.first.bytes!;

      await safeCall(
        context: context,
        action: () async {
          final service = ref.read(systemServiceProvider);
          final url = await service.uploadBrandingFile(fileName, fileBytes, 'branding');
          
          if (url != null) {
            setState(() {
              if (isLogo) {
                _logoUrl = url;
              } else {
                _faviconUrl = url;
              }
            });
          }
        },
        successMessage: 'File berhasil diunggah!',
      );
    }
  }

  Future<void> _saveGeneralSettings() async {
    final currentSettings = ref.read(systemSettingsProvider).value;
    final settings = SystemSettings(
      schoolName: _schoolNameController.text,
      headmasterName: _headmasterNameController.text,
      logoUrl: _logoUrl,
      faviconUrl: _faviconUrl,
      guruAiKeys: currentSettings?.guruAiKeys ?? [],
      belajarAiKeys: currentSettings?.belajarAiKeys ?? [],
    );

    await safeCall(
      context: context,
      action: () async {
        final service = ref.read(systemServiceProvider);
        await service.updateSettings(settings);
        
        // Update local appConfig for instant feedback across the app
        appConfig.schoolName = settings.schoolName;
        appConfig.headmasterName = settings.headmasterName;
        appConfig.logoPath = settings.logoUrl ?? "";
        appConfig.iconPath = settings.faviconUrl ?? "";
        
        // Refresh provider
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-sidebar for Settings
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
                  child: Text(
                    'PENGATURAN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildSubMenuItem(0, Icons.settings_outlined, 'Umum'),
                _buildSubMenuItem(1, Icons.lock_outline, 'Keamanan'),
              ],
            ),
          ),
          
          // Main Settings Content
          Expanded(
            child: settingsAsync.when(
              data: (settings) => SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedSubMenu == 0 ? 'Pengaturan Umum' : 'Ubah Password',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B3674),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedSubMenu == 0 
                        ? 'Kelola informasi sekolah dan identitas visual sistem.' 
                        : 'Perbarui kata sandi akun administrator Anda secara berkala.',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 32),
                    
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: LinearProgressIndicator(color: Colors.orange),
                      ),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _selectedSubMenu == 0 ? _buildGeneralSettings() : _buildSecuritySettings(),
                    ),
                  ],
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubMenuItem(int index, IconData icon, String title) {
    final isSelected = _selectedSubMenu == index;
    return InkWell(
      onTap: () => setState(() => _selectedSubMenu = index),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: isSelected ? Colors.orange.shade600 : Colors.transparent,
              width: 3,
            ),
          ),
          color: isSelected ? Colors.orange.shade50.withOpacity(0.5) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.orange.shade700 : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.orange.shade700 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Identitas Sekolah',
          children: [
            _buildTextField(
              label: 'Nama Sekolah (Sync SI Madrasah)',
              controller: _schoolNameController,
              hint: 'Masukkan nama resmi sekolah',
            ),
            const SizedBox(height: 24),
            _buildTextField(
              label: 'Nama Kepala Sekolah (Sync Rapot)',
              controller: _headmasterNameController,
              hint: 'Masukkan nama lengkap beserta gelar',
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionCard(
          title: 'Visual & Branding',
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildImageUploadTile(
                    label: 'Logo Utama (Login)',
                    description: 'Akan tampil pada halaman masuk sistem.',
                    icon: Icons.business,
                    imageUrl: _logoUrl,
                    onUpload: () => _pickAndUpload(true),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildImageUploadTile(
                    label: 'Ikon Sistem (Favicon)',
                    description: 'Akan tampil pada sidebar dan tab browser.',
                    icon: Icons.grid_view_rounded,
                    imageUrl: _faviconUrl,
                    onUpload: () => _pickAndUpload(false),
                  ),
                ),
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
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Kredensial Akun',
          children: [
            _buildTextField(
              label: 'Password Lama',
              controller: _oldPasswordController,
              hint: 'Masukkan password saat ini',
              isObscure: _isOldPasswordObscure,
              onObscureToggle: () => setState(() => _isOldPasswordObscure = !_isOldPasswordObscure),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              label: 'Password Baru',
              controller: _newPasswordController,
              hint: 'Masukkan password baru minimal 8 karakter',
              isObscure: _isNewPasswordObscure,
              onObscureToggle: () => setState(() => _isNewPasswordObscure = !_isNewPasswordObscure),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              label: 'Konfirmasi Password Baru',
              controller: _confirmPasswordController,
              hint: 'Ulangi password baru Anda',
              isObscure: _isConfirmPasswordObscure,
              onObscureToggle: () => setState(() => _isConfirmPasswordObscure = !_isConfirmPasswordObscure),
            ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B3674),
            ),
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool isObscure = false,
    VoidCallback? onObscureToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.orange)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: onObscureToggle != null
                ? IconButton(
                    icon: Icon(isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: Colors.grey),
                    onPressed: onObscureToggle,
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadTile({
    required String label, 
    required String description, 
    required IconData icon,
    String? imageUrl,
    VoidCallback? onUpload,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              image: imageUrl != null && imageUrl.isNotEmpty
                ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                : null,
            ),
            child: imageUrl == null || imageUrl.isEmpty 
              ? Icon(icon, color: Colors.orange.shade300, size: 30)
              : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Upload', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: 200,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : () {
          if (_selectedSubMenu == 1) {
            _saveSecuritySettings();
          } else {
            _saveGeneralSettings();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.shade600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: isLoading 
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save_outlined, size: 20),
                SizedBox(width: 8),
                Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
      ),
    );
  }

  Future<void> _saveSecuritySettings() async {
    if (_newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      context.showErrorSnackBar('Password baru tidak boleh kosong!');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      context.showErrorSnackBar('Konfirmasi password tidak cocok!');
      return;
    }

    await safeCall(
      context: context,
      action: () async {
        // Update user password in Supabase Auth
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(password: _newPasswordController.text),
        );
        
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      },
      successMessage: 'Password berhasil diperbarui!',
    );
  }
}
