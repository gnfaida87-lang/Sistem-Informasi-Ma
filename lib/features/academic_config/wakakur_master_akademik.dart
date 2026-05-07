import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/academic_provider.dart';
import '../../../core/providers/auth_provider.dart';
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
    final user = ref.read(authProvider).user;
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
    final user = ref.read(authProvider).user;
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
                label: const Text('Validasi Massal'),
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

          _buildCard(
            title: 'Daftar Periode & Semester',
            child: semestersAsync.when(
              data: (semesters) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Tahun Ajaran')),
                    DataColumn(label: Text('Semester')),
                    DataColumn(label: Text('KKM')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Aksi')),
                  ],
                  rows: semesters.map((s) => _buildSemesterRow(s)).toList(),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
          
          const SizedBox(height: 24),

          _buildCard(
            title: 'Daftar Jurusan',
            child: departmentsAsync.when(
              data: (departments) => ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: departments.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final d = departments[index];
                  return ListTile(
                    title: Text(d.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Kode: ${d.code}'),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
        DataCell(Text(s.isActive ? 'Aktif' : 'Tutup', style: TextStyle(color: s.isActive ? Colors.green : Colors.grey))),
        DataCell(
          s.isValidated
            ? const Icon(Icons.verified, color: Colors.blue)
            : IconButton(
                icon: const Icon(Icons.check_circle_outline, color: Colors.teal), 
                onPressed: () => _handleValidate(s)
              ),
        ),
      ],
    );
  }
}
