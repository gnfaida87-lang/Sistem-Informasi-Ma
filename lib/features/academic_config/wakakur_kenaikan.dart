import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/promotion_provider.dart';
import '../../core/providers/master_provider.dart';
import '../../core/providers/academic_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../master_data/models/master_models.dart';
import 'models/promotion_models.dart';

class WakakurKenaikanKelas extends ConsumerStatefulWidget {
  const WakakurKenaikanKelas({super.key});

  @override
  ConsumerState<WakakurKenaikanKelas> createState() => _WakakurKenaikanKelasState();
}

class _WakakurKenaikanKelasState extends ConsumerState<WakakurKenaikanKelas> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // State for Tab 2
  String? _selectedFromClassId;
  String? _selectedToClassId;
  List<Map<String, dynamic>> _evaluations = [];
  bool _isLoadingEvaluations = false;

  // State for Tab 3
  String _alumniSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // HEADER & TABBAR
        Container(
          padding: const EdgeInsets.all(24),
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manajemen Kenaikan Kelas & Kelulusan',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
              const SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                labelColor: Colors.indigo.shade700,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.indigo.shade700,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Kriteria Kenaikan'),
                  Tab(text: 'Proses Naik Kelas'),
                  Tab(text: 'Arsip Alumni'),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildKriteriaTab(),
              _buildProsesTab(),
              _buildAlumniTab(),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 1: KRITERIA KENAIKAN
  // ==========================================
  Widget _buildKriteriaTab() {
    final criteriaAsync = ref.watch(promotionCriteriaProvider);

    return criteriaAsync.when(
      data: (list) {
        if (list.isEmpty) return _buildFallbackKriteria();
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            ...list.map((c) => _buildKriteriaItem(
                  c.title,
                  c.value,
                  _getIconForCategory(c.category),
                )),
            const SizedBox(height: 24),
            _buildUpdateBtn(),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => _buildFallbackKriteria(error: err.toString()),
    );
  }

  Widget _buildFallbackKriteria({String? error}) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (error != null)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 16),
            color: Colors.amber.shade50,
            child: Text('Note: Menggunakan data default (Database belum siap)', 
              style: TextStyle(color: Colors.amber.shade900, fontSize: 12)),
          ),
        _buildKriteriaItem('Persentase Kehadiran Minimal', '85%', Icons.calendar_today),
        _buildKriteriaItem('Nilai Mapel Tidak Tuntas (Maksimal)', '3 Mata Pelajaran', Icons.book_outlined),
        _buildKriteriaItem('Nilai Sikap Minimal', 'B (Baik)', Icons.stars_outlined),
        _buildKriteriaItem('Mengikuti Program Tahfidz/Ekstra', 'Wajib', Icons.check_circle_outline),
        const SizedBox(height: 24),
        _buildUpdateBtn(),
      ],
    );
  }

  Widget _buildUpdateBtn() {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: () => _showEditCriteriaDialog(),
        icon: const Icon(Icons.edit_note, size: 18),
        label: const Text('Perbarui Kebijakan Kriteria'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade600, foregroundColor: Colors.white),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'attendance': return Icons.calendar_today;
      case 'grades': return Icons.book_outlined;
      case 'attitude': return Icons.stars_outlined;
      default: return Icons.check_circle_outline;
    }
  }

  void _showEditCriteriaDialog() {
    final criteriaAsync = ref.read(promotionCriteriaProvider);
    if (criteriaAsync.value == null) return;

    final criteriaList = criteriaAsync.value!;
    final titleControllers = <String, TextEditingController>{};
    final valueControllers = <String, TextEditingController>{};
    
    for (var c in criteriaList) {
      titleControllers[c.id!] = TextEditingController(text: c.title);
      valueControllers[c.id!] = TextEditingController(text: c.value);
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Manajemen Kriteria Kenaikan'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...criteriaList.map((c) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: titleControllers[c.id],
                                  decoration: const InputDecoration(labelText: 'Judul Kriteria', isDense: true),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await _showDeleteConfirm(c.title);
                                  if (confirm) {
                                    await _deleteCriteria(c.id!);
                                    Navigator.pop(context); // Close and reopen to refresh
                                    _showEditCriteriaDialog();
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: valueControllers[c.id],
                            decoration: const InputDecoration(labelText: 'Nilai/Syarat', isDense: true),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _showAddCriteriaDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Kriteria Baru'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _saveCriteria(criteriaList, titleControllers, valueControllers);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              child: const Text('Simpan Semua Perubahan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirm(String title) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kriteria?'),
        content: Text('Apakah Anda yakin ingin menghapus kriteria "$title"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;
  }

  Future<void> _deleteCriteria(String id) async {
    try {
      await ref.read(promotionServiceProvider).deleteCriteria(id);
      ref.invalidate(promotionCriteriaProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal hapus: $e')));
    }
  }

  void _showAddCriteriaDialog() {
    final titleController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kriteria Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Judul (Contoh: Mengikuti Program Ekstra)')),
            const SizedBox(height: 12),
            TextField(controller: valueController, decoration: const InputDecoration(labelText: 'Nilai/Syarat (Contoh: Wajib)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty) return;
              Navigator.pop(context);
              Navigator.pop(context); // Close management dialog
              
              await ref.read(promotionServiceProvider).addCriteria(PromotionCriteria(
                title: titleController.text,
                value: valueController.text,
                category: 'extra',
              ));
              
              ref.invalidate(promotionCriteriaProvider);
              _showEditCriteriaDialog(); // Reopen
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCriteria(
    List<PromotionCriteria> list, 
    Map<String, TextEditingController> titleControllers,
    Map<String, TextEditingController> valueControllers,
  ) async {
    try {
      final service = ref.read(promotionServiceProvider);
      for (var c in list) {
        final newTitle = titleControllers[c.id]!.text;
        final newValue = valueControllers[c.id]!.text;
        
        if (newTitle != c.title || newValue != c.value) {
          await service.updateCriteria(PromotionCriteria(
            id: c.id,
            title: newTitle,
            value: newValue,
            category: c.category,
            minThreshold: c.minThreshold,
          ));
        }
      }
      
      ref.invalidate(promotionCriteriaProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kebijakan berhasil diperbarui!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildKriteriaItem(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade700)),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: PROSES NAIK KELAS
  // ==========================================
  Widget _buildProsesTab() {
    final classesAsync = ref.watch(allClassesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              classesAsync.when(
                data: (classes) => DropdownButton<String>(
                  hint: const Text('Filter Dari Kelas'),
                  value: _selectedFromClassId,
                  items: classes.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
                  onChanged: (val) {
                    setState(() => _selectedFromClassId = val);
                    _loadEvaluations();
                  },
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error load kelas'),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.arrow_forward_rounded, color: Colors.grey),
              const SizedBox(width: 16),
              classesAsync.when(
                data: (classes) => DropdownButton<String>(
                  hint: const Text('Tujuan Ke'),
                  value: _selectedToClassId,
                  items: [
                    const DropdownMenuItem(value: 'GRADUATE', child: Text('Lulus (Alumni)')),
                    ...classes.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))),
                  ],
                  onChanged: (val) => setState(() => _selectedToClassId = val),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: (_evaluations.isEmpty || _isLoadingEvaluations) ? null : () => _executePromotion(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white),
                child: _isLoadingEvaluations 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Eksekusi Kenaikan Massal'),
              ),
            ],
          ),
        ),
        if (_isLoadingEvaluations)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_evaluations.isEmpty)
          const Expanded(child: Center(child: Text('Pilih kelas asal untuk melihat daftar evaluasi siswa.')))
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _evaluations.length,
              itemBuilder: (context, index) {
                final eval = _evaluations[index];
                final isRecommended = eval['is_recommended'] as bool;
                
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isRecommended ? Colors.green.shade50 : Colors.red.shade50, 
                      child: Icon(isRecommended ? Icons.check : Icons.warning_amber_rounded, color: isRecommended ? Colors.green : Colors.red),
                    ),
                    title: Text(eval['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Kehadiran: ${eval['attendance_pct']}% • Mapel Gagal: ${eval['failing_subjects']} • Rekomendasi: ${isRecommended ? 'NAIK' : 'TINGGAL'}'),
                    trailing: Switch(
                      value: eval['manual_status'], 
                      onChanged: (v) => setState(() => eval['manual_status'] = v),
                      activeColor: Colors.green,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _loadEvaluations() async {
    if (_selectedFromClassId == null) return;
    setState(() => _isLoadingEvaluations = true);
    
    try {
      final service = ref.read(promotionServiceProvider);
      final results = await service.fetchPromotionEvaluations(_selectedFromClassId!);
      setState(() {
        _evaluations = results;
        _isLoadingEvaluations = false;
      });
    } catch (e) {
      setState(() => _isLoadingEvaluations = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _executePromotion() async {
    if (_selectedToClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih kelas tujuan atau status Lulus terlebih dahulu.')));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Eksekusi'),
        content: Text('Apakah Anda yakin ingin memproses ${_evaluations.length} siswa? Tindakan ini akan memperbarui data kelas siswa secara permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya, Eksekusi')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoadingEvaluations = true);
    try {
      final service = ref.read(promotionServiceProvider);
      final auth = ref.read(authProvider); // Assume authProvider gives current user
      final activeSemester = ref.read(activeSemesterProvider).value;

      await service.executeMassPromotion(
        evaluations: _evaluations,
        targetClassId: _selectedToClassId == 'GRADUATE' ? null : _selectedToClassId,
        academicYearId: activeSemester?.yearId ?? '',
        userId: auth.session?.user.id ?? '',
      );

      setState(() {
        _evaluations = [];
        _selectedFromClassId = null;
        _isLoadingEvaluations = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proses kenaikan kelas berhasil diselesaikan!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      setState(() => _isLoadingEvaluations = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal eksekusi: $e'), backgroundColor: Colors.red));
      }
    }
  }

  // ==========================================
  // TAB 3: ARSIP ALUMNI
  // ==========================================
  Widget _buildAlumniTab() {
    final alumniAsync = ref.watch(alumniProvider(_alumniSearchQuery));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: TextField(
            onChanged: (val) => setState(() => _alumniSearchQuery = val),
            decoration: InputDecoration(
              hintText: 'Cari Alumni (Nama/Tahun Lulus)...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: alumniAsync.when(
            data: (list) {
              if (list.isEmpty) return const Center(child: Text('Tidak ada data alumni ditemukan.'));
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final alumni = list[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5)],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 25, child: Icon(Icons.school_outlined)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(alumni.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Lulus Tahun: ${alumni.graduationYear} • Terakhir di: ${alumni.lastClassName}', 
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Detail riwayat bisa dikembangkan lebih lanjut
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade50, foregroundColor: Colors.blue.shade800, elevation: 0),
                          child: const Text('Lihat Riwayat'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, __) => Center(child: Text('Gagal memuat alumni: $err')),
          ),
        ),
      ],
    );
  }
}
