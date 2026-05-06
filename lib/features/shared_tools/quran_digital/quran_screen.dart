import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'dart:convert';
import '../../../../core/router/app_router.dart';


class QuranDigitalScreen extends StatefulWidget {
  const QuranDigitalScreen({super.key});

  @override
  State<QuranDigitalScreen> createState() => _QuranDigitalScreenState();
}

class _QuranDigitalScreenState extends State<QuranDigitalScreen> {
  List<dynamic> _surahs = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchSurahs();
  }

  Future<void> _fetchSurahs() async {
    try {
      final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _surahs = data['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data (Status: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan koneksi: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/'); // Fallback ke home jika tidak ada stack
            }
          },
        ),
        title: const Text('Al-Qur’an Digital', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = '';
              });
              _fetchSurahs();
            },
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal.shade50,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari Surah (contoh: Al-Fatihah)...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                // Future improvement: implement local filtering
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text(_errorMessage, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchSurahs,
                              child: const Text('Coba Lagi'),
                            )
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _surahs.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final surah = _surahs[index];
                          return ListTile(
                            leading: Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.teal.shade200),
                              ),
                              child: Text(
                                surah['number'].toString(),
                                style: TextStyle(color: Colors.teal.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            title: Text(surah['englishName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${surah['englishNameTranslation']} • ${surah['numberOfAyahs']} Ayat'),
                            trailing: Text(
                              surah['name'], // Arabic Name
                              style: const TextStyle(fontSize: 18, fontFamily: 'Arabic', fontWeight: FontWeight.bold, color: Colors.teal),
                            ),
                            onTap: () {
                              context.go(
                                '${AppRoutes.quran}/${surah['number']}',
                                extra: {'surahName': surah['englishName']},
                              );
                            },

                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
