import 'package:flutter/material.dart';
import '../../../core/network/d1_service.dart';

class DbDiagnosticScreen extends StatefulWidget {
  const DbDiagnosticScreen({super.key});

  @override
  State<DbDiagnosticScreen> createState() => _DbDiagnosticScreenState();
}

class _DbDiagnosticScreenState extends State<DbDiagnosticScreen> {
  final _d1Service = D1Service();
  bool _isLoading = false;
  List<Map<String, dynamic>> _tableStats = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkDatabase();
  }

  Future<void> _checkDatabase() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _tableStats = [];
    });

    try {
      // 1. Cek daftar tabel dari system sqlite_master
      final tables = await _d1Service.query(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE '_cf_%'"
      );

      List<Map<String, dynamic>> stats = [];
      
      for (var table in (tables as List)) {
        final tableName = table['name'];
        // 2. Cek jumlah baris untuk setiap tabel
        final countResult = await _d1Service.query("SELECT COUNT(*) as total FROM $tableName");
        final count = countResult.isNotEmpty ? countResult.first['total'] : 0;
        
        stats.add({
          'name': tableName,
          'count': count,
        });
      }

      setState(() {
        _tableStats = stats;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostik Database D1'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _checkDatabase,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _error != null
          ? _buildErrorState()
          : _tableStats.isEmpty
            ? _buildEmptyState()
            : _buildStatsList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Gagal Terhubung ke Database', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _checkDatabase, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storage, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Database Terhubung, tapi tidak ada tabel ditemukan.'),
        ],
      ),
    );
  }

  Widget _buildStatsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tableStats.length,
      itemBuilder: (context, index) {
        final stat = _tableStats[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.indigo.shade50,
              child: const Icon(Icons.table_chart, color: Colors.indigo),
            ),
            title: Text(stat['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.indigo.shade600,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${stat['count']} Baris',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}
