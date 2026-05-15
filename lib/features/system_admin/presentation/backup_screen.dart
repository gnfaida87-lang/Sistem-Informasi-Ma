import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/system_provider.dart';
import '../../../core/utils/context_extensions.dart';
import '../models/system_settings_model.dart';

class BackupMaintenanceScreen extends ConsumerStatefulWidget {
  const BackupMaintenanceScreen({super.key});

  @override
  ConsumerState<BackupMaintenanceScreen> createState() => _BackupMaintenanceScreenState();
}

class _BackupMaintenanceScreenState extends ConsumerState<BackupMaintenanceScreen> {
  bool _isLoading = false;

  Future<void> _toggleMaintenance(bool value, SystemSettings currentSettings) async {
    setState(() => _isLoading = true);
    try {
      final newSettings = SystemSettings(
        schoolName: currentSettings.schoolName,
        appName: currentSettings.appName,
        headmasterName: currentSettings.headmasterName,
        logoUrl: currentSettings.logoUrl,
        faviconUrl: currentSettings.faviconUrl,
        guruAiKeys: currentSettings.guruAiKeys,
        guruAiEngine: currentSettings.guruAiEngine,
        belajarAiKeys: currentSettings.belajarAiKeys,
        belajarAiEngine: currentSettings.belajarAiEngine,
        isMaintenance: value,
        gdriveApiKey: currentSettings.gdriveApiKey,
        gdriveFolderId: currentSettings.gdriveFolderId,
      );

      final service = ref.read(systemServiceProvider);
      await service.updateSettings(newSettings);
      
      ref.invalidate(systemSettingsProvider);
      
      if (mounted) {
        context.showSuccessSnackBar(value ? 'Mode Maintenance Aktif' : 'Mode Maintenance Dimatikan');
      }
    } catch (e) {
      if (mounted) context.showErrorSnackBar('Gagal mengubah mode: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(systemSettingsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: Colors.teal.shade800,
              child: const Text('Backup & Maintenance', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            if (_isLoading) const LinearProgressIndicator(color: Colors.orange),
            Expanded(
              child: settingsAsync.when(
                data: (settings) => SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Maintenance Mode Switch
                      Container(
                        decoration: BoxDecoration(
                          color: settings.isMaintenance ? Colors.red.shade50 : Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: settings.isMaintenance ? Colors.red.shade200 : Colors.teal.shade200),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            'Mode Maintenance (Pemeliharaan)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: settings.isMaintenance ? Colors.red.shade800 : Colors.teal.shade900,
                            ),
                          ),
                          subtitle: const Text(
                            'Jika diaktifkan, semua user (kecuali Superadmin) tidak akan bisa login atau mengakses data.',
                          ),
                          value: settings.isMaintenance,
                          activeColor: Colors.red.shade600,
                          onChanged: _isLoading ? null : (bool value) => _toggleMaintenance(value, settings),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      const Text(
                        'Manajemen Database Harian',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              context,
                              'Backup Database (Dump)',
                              Icons.cloud_download_outlined,
                              Colors.blue,
                              'Unduh salinan SQL Server',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionCard(
                              context,
                              'Restore Data',
                              Icons.settings_backup_restore,
                              Colors.orange,
                              'Unggah file Backup SQL',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                      const Text(
                        'Riwayat Backup Terakhir',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      
                      // Dummy History List
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text('Belum ada riwayat backup database.', style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error loading settings: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, MaterialColor color, String subtitle) {
    final isBackup = title.contains('Backup');
    
    return InkWell(
      onTap: () async {
        if (isBackup) {
          setState(() => _isLoading = true);
          try {
            await ref.read(systemServiceProvider).downloadBackup();
            if (mounted) context.showSuccessSnackBar('Backup berhasil dimulai!');
          } catch (e) {
            if (mounted) context.showErrorSnackBar('Gagal backup: $e');
          } finally {
            if (mounted) setState(() => _isLoading = false);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title (Segera Hadir)')));
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.shade200),
          color: color.shade50,
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color.shade700),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color.shade900), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 11, color: color.shade700), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
