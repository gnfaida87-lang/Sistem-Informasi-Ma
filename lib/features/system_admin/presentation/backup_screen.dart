import 'package:flutter/material.dart';

class BackupMaintenanceScreen extends StatefulWidget {
  const BackupMaintenanceScreen({super.key});

  @override
  State<BackupMaintenanceScreen> createState() => _BackupMaintenanceScreenState();
}

class _BackupMaintenanceScreenState extends State<BackupMaintenanceScreen> {
  bool _isMaintenanceMode = false;

  @override
  Widget build(BuildContext context) {
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Maintenance Mode Switch
              Container(
                decoration: BoxDecoration(
                  color: _isMaintenanceMode ? Colors.red.shade50 : Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _isMaintenanceMode ? Colors.red.shade200 : Colors.teal.shade200),
                ),
                child: SwitchListTile(
                  title: Text(
                    'Mode Maintenance (Pemeliharaan)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isMaintenanceMode ? Colors.red.shade800 : Colors.teal.shade900,
                    ),
                  ),
                  subtitle: const Text(
                    'Jika diaktifkan, semua user (kecuali Superadmin) tidak akan bisa login atau mengakses data.',
                  ),
                  value: _isMaintenanceMode,
                  activeColor: Colors.red.shade600,
                  onChanged: (bool value) {
                    setState(() {
                      _isMaintenanceMode = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(value ? 'Mode Maintenance Aktif' : 'Mode Maintenance Dimatikan')),
                    );
                  },
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
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.archive_outlined, color: Colors.teal),
                    title: Text('Backup_MD5_${DateTime.now().subtract(Duration(days: index)).toString().split(' ')[0]}.sql'),
                    subtitle: const Text('Size: 14.5 MB | Dibuat otomatis oleh Sistem'),
                    trailing: IconButton(
                      icon: const Icon(Icons.download, color: Colors.blue),
                      onPressed: () {},
                    ),
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),
            ],
          ),
        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, MaterialColor color, String subtitle) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title diklik (Mock)')));
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
