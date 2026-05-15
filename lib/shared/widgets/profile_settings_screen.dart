import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/system_provider.dart';
import '../../core/network/d1_service.dart';
import '../../core/utils/context_extensions.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  late TextEditingController _usernameController;
  final _passwordController = TextEditingController();
  bool _isObscure = true;
  String? _profileUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _usernameController = TextEditingController(text: user?.fullName ?? '');
    _profileUrl = user?.profileUrl;
  }

  Future<void> _pickAndUploadPhoto() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.first.bytes != null) {
      setState(() => _isLoading = true);
      final file = result.files.first;
      
      try {
        final d1 = D1Service();
        final uploadResult = await d1.uploadFile(
          file.bytes!,
          'profile_${ref.read(authProvider).user?.id}_${DateTime.now().millisecondsSinceEpoch}.${file.extension}',
        );

        if (uploadResult['success'] == true) {
          setState(() {
            _profileUrl = uploadResult['fileUrl'];
          });
          if (mounted) context.showSuccessSnackBar('Foto profil berhasil diunggah!');
        } else {
          if (mounted) context.showErrorSnackBar('Gagal mengunggah: ${uploadResult['message']}');
        }
      } catch (e) {
        if (mounted) context.showErrorSnackBar('Gagal mengunggah: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authProvider).user;
      if (user == null) return;

      final d1Service = D1Service();
      await d1Service.query(
        "UPDATE users SET full_name = ?, profile_url = ? WHERE id = ?",
        params: [_usernameController.text, _profileUrl, user.id],
      );

      // Invalidate auth provider to refresh user data if necessary
      // Or just show success
      if (mounted) {
        context.showSuccessSnackBar('Profil berhasil diperbarui!');
        Navigator.pop(context);
      }
    } catch (e) {
      context.showErrorSnackBar('Gagal menyimpan perubahan: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('Pengaturan Profil', style: TextStyle(color: Color(0xFF2B3674), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text(
                    'Ubah Profil & Keamanan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
                  ),
                ),
                const SizedBox(height: 32),

                // AREA UPLOAD FOTO PROFIL
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                          image: _profileUrl != null 
                            ? DecorationImage(image: NetworkImage(_profileUrl!), fit: BoxFit.cover)
                            : null,
                        ),
                        child: _profileUrl == null 
                          ? Icon(Icons.person, size: 50, color: Colors.grey.shade400)
                          : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _isLoading ? null : _pickAndUploadPhoto,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text('Format yang didukung: JPG, PNG. Max 2MB.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ),
                const SizedBox(height: 32),

                // KONTROL USERNAME
                const Text('Username Panggilan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan username baru',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 24),

                // KONTROL PASSWORD BARU
                const Text('Password Baru', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    hintText: 'Biarkan kosong jika tidak ingin mengubah',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey.shade500, size: 20),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // TOMBOL SIMPAN KEMBALI
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveChanges,
                    icon: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save),
                    label: const Text('Simpan Perubahan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
