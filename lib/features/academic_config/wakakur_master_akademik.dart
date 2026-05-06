import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/academic_provider.dart';
import '../../../core/mixins/safe_async_mixin.dart';
import '../../../core/utils/context_extensions.dart';
import 'models/academic_models.dart';

class WakakurMasterAkademik extends ConsumerStatefulWidget {
  const WakakurMasterAkademik({super.key});

  @override
  ConsumerState<WakakurMasterAkademik> createState() => _WakakurMasterAkademikState();
}

class _WakakurMasterAkademikState extends ConsumerState<WakakurMasterAkademik> with SafeAsync {
  
  Future<void> _handleValidate(Semester semester) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await safeCall(
      context: context,
      action: () async {
        final service = ref.read(academicServiceProvider);
        await service.validateSemester(semester.id, user.id);
        ref.invalidate(semestersProvider);
      },
      successMessage: 'Semester ${semester.nama} ${semester.yearName} berhasil divalidasi',
    );
  }

  Future<void> _handleMassValidate() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await safeCall(
      context: context,
      action: () async {
        final service = ref.read(academicServiceProvider);
        await service.validateAllActiveSemesters(user.id);
        ref.invalidate(semestersProvider);
      },
      successMessage: 'Semua semester aktif berhasil divalidasi secara massal',
    );
  }

  @override
  Widget build(BuildContext context) {
    final semestersAsync = ref.watch(semestersProvider);
    final departmentsAsync = ref.watch(departmentsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Master Akademik',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B3674),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: isLoading ? null : _handleMassValidate,
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('Validasi Massal KKM'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: LinearProgressIndicator(color: Colors.teal),
            ),

          // TABEL TAHUN AJARAN & SEMESTER
          _buildCard(
            title: 'Daftar Periode & KKM Standar',
            child: semestersAsync.when(
              data: (semesters) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Colors.teal.shade50),
                  columns: const [
                    DataColumn(label: Text('Tahun Ajaran', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Semester', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('KKM Umum', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: semesters.map((s) => _buildSemesterRow(s)).toList(),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
          
          const SizedBox(height: 24),

          // TABEL JURUSAN
          _buildCard(
            title: 'Daftar Jurusan (Info)',
            child: departmentsAsync.when(
              data: (departments) => ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: departments.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final d = departments[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade50,
                      child: Text(d.code[0], style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(d.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2B3674))),
                    subtitle: Text('Kode: ${d.code}', style: const TextStyle(fontSize: 12)),
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  DataRow _buildSemesterRow(Semester s) {
    return DataRow(
      cells: [
        DataCell(Text(s.yearName ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(s.nama)),
        DataCell(Text(s.kkmDefault.toString())),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: s.isActive ? Colors.green.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            s.isActive ? 'Aktif' : 'Tutup',
            style: TextStyle(color: s.isActive ? Colors.green.shade700 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        )),
        DataCell(
          Row(
            children: [
              if (!s.isValidated)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: Colors.teal, size: 18), 
                  tooltip: 'Validasi', 
                  onPressed: () => _handleValidate(s)
                )
              else
                const Row(
                  children: [
                    Icon(Icons.verified, color: Colors.blue, size: 16),
                    SizedBox(width: 4),
                    Text('Valid', style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
