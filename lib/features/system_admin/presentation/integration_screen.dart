import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/system_provider.dart';
import '../../../core/mixins/safe_async_mixin.dart';
import '../../../core/utils/context_extensions.dart';
import '../models/system_settings_model.dart';

class IntegrationScreen extends ConsumerStatefulWidget {
  const IntegrationScreen({super.key});

  @override
  ConsumerState<IntegrationScreen> createState() => _IntegrationScreenState();
}

class _IntegrationScreenState extends ConsumerState<IntegrationScreen> with SafeAsync {
  final List<TextEditingController> _guruKeyControllers = [];
  final List<TextEditingController> _belajarKeyControllers = [];
  
  final _guruEngineController = TextEditingController();
  final _belajarEngineController = TextEditingController();
  
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Default placeholders if data is slow
    _guruKeyControllers.add(TextEditingController());
    _belajarKeyControllers.add(TextEditingController());
  }

  void _initializeWithData(SystemSettings settings) {
    if (_isInitialized) return;
    
    setState(() {
      _guruKeyControllers.clear();
      for (var key in settings.guruAiKeys) {
        _guruKeyControllers.add(TextEditingController(text: key));
      }
      if (_guruKeyControllers.isEmpty) _guruKeyControllers.add(TextEditingController());

      _belajarKeyControllers.clear();
      for (var key in settings.belajarAiKeys) {
        _belajarKeyControllers.add(TextEditingController(text: key));
      }
      if (_belajarKeyControllers.isEmpty) _belajarKeyControllers.add(TextEditingController());

      _guruEngineController.text = settings.guruAiEngine ?? 'OpenAI (GPT-4o)';
      _belajarEngineController.text = settings.belajarAiEngine ?? 'Gemini (1.5 Pro)';
      
      _isInitialized = true;
    });
  }

  void _addKeyField(List<TextEditingController> controllers) {
    setState(() {
      controllers.add(TextEditingController());
    });
  }

  void _removeKeyField(List<TextEditingController> controllers, int index) {
    if (controllers.length > 1) {
      setState(() {
        controllers[index].dispose();
        controllers.removeAt(index);
      });
    } else {
      setState(() {
        controllers[0].clear();
      });
    }
  }

  @override
  void dispose() {
    for (var c in _guruKeyControllers) {
      c.dispose();
    }
    for (var c in _belajarKeyControllers) {
      c.dispose();
    }
    _guruEngineController.dispose();
    _belajarEngineController.dispose();
    super.dispose();
  }

  Future<void> _saveAiSettings() async {
    final currentSettings = ref.read(systemSettingsProvider).value;
    if (currentSettings == null) {
      context.showErrorSnackBar('Gagal sinkron: Data dasar belum dimuat.');
      return;
    }

    final guruKeys = _guruKeyControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    final belajarKeys = _belajarKeyControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

    final newSettings = SystemSettings(
      schoolName: currentSettings.schoolName,
      headmasterName: currentSettings.headmasterName,
      logoUrl: currentSettings.logoUrl,
      faviconUrl: currentSettings.faviconUrl,
      guruAiKeys: guruKeys,
      guruAiEngine: _guruEngineController.text.trim(),
      belajarAiKeys: belajarKeys,
      belajarAiEngine: _belajarEngineController.text.trim(),
    );

    await safeCall(
      context: context,
      action: () async {
        final service = ref.read(systemServiceProvider);
        await service.updateSettings(newSettings);
        
        // Penting: Invalidate agar data terbaru di-fetch ulang
        ref.invalidate(systemSettingsProvider);
      },
      successMessage: 'Konfigurasi AI berhasil disimpan dan disinkronkan ke seluruh sistem!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(systemSettingsProvider);

    // Re-sync controllers when data arrives for the first time
    settingsAsync.whenData((settings) => _initializeWithData(settings));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: Colors.purple.shade800,
              child: const Text('Pengaturan Integrasi AI', 
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: settingsAsync.when(
                data: (settings) => SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(),
                      const SizedBox(height: 24),
                      
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: LinearProgressIndicator(color: Colors.purple),
                        ),

                      _buildApiConfigSection(
                        'AI Sahabat Guru',
                        'Digunakan oleh Guru. Masukkan nama engine secara manual (contoh: GPT-4, Claude 3.5, dll).',
                        _guruKeyControllers,
                        _guruEngineController,
                      ),
                      const SizedBox(height: 32),
                      
                      _buildApiConfigSection(
                        'AI Sahabat Belajar',
                        'Digunakan oleh Siswa. Masukkan nama engine secara manual.',
                        _belajarKeyControllers,
                        _belajarEngineController,
                      ),
                      
                      const SizedBox(height: 40),
                      _buildSaveButton(),
                    ],
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.sync_alt_rounded, color: Colors.purple),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tombol Simpan di bawah akan menyinkronkan seluruh kunci AI ke Database pusat agar dapat digunakan oleh semua Guru dan Siswa.',
              style: TextStyle(fontSize: 13, color: Color(0xFF2B3674)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiConfigSection(
    String title, 
    String description, 
    List<TextEditingController> keyControllers,
    TextEditingController engineController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _addKeyField(keyControllers),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah Key', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade50,
                foregroundColor: Colors.purple.shade700,
                elevation: 0,
                side: BorderSide(color: Colors.purple.shade100),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        ...keyControllers.asMap().entries.map((entry) {
          int idx = entry.key;
          var controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Secret API Key #${idx + 1}',
                      hintText: 'sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxx',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                      prefixIcon: const Icon(Icons.key, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removeKeyField(keyControllers, idx),
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  tooltip: 'Hapus Key',
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 12),
        TextField(
          controller: engineController,
          decoration: InputDecoration(
            labelText: 'Nama Engine AI Utama (Manual)',
            hintText: 'Contoh: OpenAI GPT-4o, Gemini 1.5 Pro, Claude 3.5 Sonnet',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            prefixIcon: const Icon(Icons.psychology, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: isLoading ? null : _saveAiSettings,
        child: isLoading 
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save_rounded),
                SizedBox(width: 12),
                Text('Simpan & Sinkronkan Konfigurasi AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
      ),
    );
  }
}
