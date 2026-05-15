import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/system_provider.dart';
import '../../../core/mixins/safe_async_mixin.dart';
import '../../../core/utils/context_extensions.dart';
import '../../system_admin/models/system_settings_model.dart';

class FinanceConfigScreen extends ConsumerStatefulWidget {
  const FinanceConfigScreen({super.key});

  @override
  ConsumerState<FinanceConfigScreen> createState() => _FinanceConfigScreenState();
}

class _FinanceConfigScreenState extends ConsumerState<FinanceConfigScreen> with SafeAsync {
  final _sppXController = TextEditingController();
  final _sppXIController = TextEditingController();
  final _sppXIIController = TextEditingController();
  int _startMonth = 7;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final settingsAsync = ref.read(systemSettingsProvider);
    settingsAsync.whenData((settings) {
      setState(() {
        _sppXController.text = settings.sppNominalX.toStringAsFixed(0);
        _sppXIController.text = settings.sppNominalXI.toStringAsFixed(0);
        _sppXIIController.text = settings.sppNominalXII.toStringAsFixed(0);
        _startMonth = settings.academicStartMonth;
      });
    });
  }

  @override
  void dispose() {
    _sppXController.dispose();
    _sppXIController.dispose();
    _sppXIIController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final currentSettings = ref.read(systemSettingsProvider).value;
    if (currentSettings == null) return;

    final settings = currentSettings.copyWith(
      sppNominalX: double.tryParse(_sppXController.text) ?? 250000,
      sppNominalXI: double.tryParse(_sppXIController.text) ?? 275000,
      sppNominalXII: double.tryParse(_sppXIIController.text) ?? 300000,
      academicStartMonth: _startMonth,
    );

    setState(() => _isLoading = true);
    await safeCall(
      context: context,
      action: () async {
        final service = ref.read(systemServiceProvider);
        await service.updateSettings(settings);
        ref.invalidate(systemSettingsProvider);
      },
      successMessage: 'Konfigurasi biaya berhasil disimpan!',
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Konfigurasi Keuangan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
          ),
          const SizedBox(height: 8),
          Text(
            'Atur nominal SPP per jenjang dan kalender akademik sekolah.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          if (_isLoading) const Padding(padding: EdgeInsets.only(bottom: 16.0), child: LinearProgressIndicator(color: Colors.green)),
          
          _buildSectionCard(
            title: 'Nominal SPP Per Jenjang',
            children: [
              Row(
                children: [
                  Expanded(child: _buildTextField(label: 'Kelas X (Rp)', controller: _sppXController, hint: '250000')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(label: 'Kelas XI (Rp)', controller: _sppXIController, hint: '275000')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(label: 'Kelas XII (Rp)', controller: _sppXIIController, hint: '300000')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionCard(
            title: 'Kalender Akademik',
            children: [
              const Text('Bulan Dimulainya Tahun Ajaran Baru', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _startMonth,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                ),
                items: List.generate(12, (index) {
                  final month = index + 1;
                  final monthNames = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
                  return DropdownMenuItem(value: month, child: Text(monthNames[index]));
                }),
                onChanged: (val) => setState(() => _startMonth = val!),
              ),
            ],
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveSettings,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Simpan Konfigurasi', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              minimumSize: const Size(220, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
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

  Widget _buildTextField({required String label, required TextEditingController controller, required String hint}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    ]);
  }
}
