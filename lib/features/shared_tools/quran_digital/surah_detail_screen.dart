import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html; 

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const SurahDetailScreen({
    super.key, 
    required this.surahNumber, 
    required this.surahName
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  List<dynamic> _ayahs = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _playingAyahIndex;
  html.AudioElement? _webAudioPlayer;

  @override
  void initState() {
    super.initState();
    _fetchAyahs();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _webAudioPlayer?.pause();
    super.dispose();
  }

  Future<void> _fetchAyahs() async {
    try {
      final url = Uri.https('api.alquran.cloud', '/v1/surah/${widget.surahNumber}/ar.alafasy');
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _ayahs = data['data']['ayahs'];
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Server merespon dengan status: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data. Mohon pastikan internet aktif.\n(Error: $e)';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _playAudio(String url, int index) async {
    // FALLBACK KHUSUS WEB: Jika plugin macet, gunakan HTML5 Audio
    if (kIsWeb) {
      try {
        if (_playingAyahIndex == index) {
          _webAudioPlayer?.pause();
          setState(() => _playingAyahIndex = null);
        } else {
          _webAudioPlayer?.pause();
          _webAudioPlayer = html.AudioElement(url);
          _webAudioPlayer!.play();
          setState(() => _playingAyahIndex = index);
          _webAudioPlayer!.onEnded.listen((_) {
            if (mounted) setState(() => _playingAyahIndex = null);
          });
        }
        return; 
      } catch (e) {
        debugPrint('Web Native Audio Error: $e');
      }
    }

    // PRIORITAS MOBILE/DESKTOP: Menggunakan Audioplayers Plugin
    try {
      if (_playingAyahIndex == index) {
        await _audioPlayer.pause();
        setState(() => _playingAyahIndex = null);
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(url));
        setState(() => _playingAyahIndex = index);
        _audioPlayer.onPlayerComplete.listen((_) {
          if (mounted) setState(() => _playingAyahIndex = null);
        });
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('MissingPluginException')) {
        errorMsg = 'KONEKSI PLUGIN GAGAL: Mohon aktifkan "Developer Mode" di Windows Anda lalu Restart aplikasi.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red.shade900),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Detail biasanya di-push, jadi pop cukup
          },
        ),
        title: Text(widget.surahName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : _errorMessage.isNotEmpty
              ? Center(child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(_errorMessage, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _fetchAyahs, child: const Text('Coba Lagi'))
                  ],

                ),
              ))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ayahs.length,
                  itemBuilder: (context, index) {
                    final ayah = _ayahs[index];
                    final isPlaying = _playingAyahIndex == index;
                    
                    // Logic untuk menghilangkan Bismillah di awal ayat pertama (kecuali Al-Fatihah)
                    String displayAyaText = ayah['text'];
                    if (widget.surahNumber != 1 && ayah['numberInSurah'] == 1) {
                      const String basmala = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
                      if (displayAyaText.startsWith(basmala)) {
                        displayAyaText = displayAyaText.replaceFirst(basmala, '').trim();
                      }
                    }

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isPlaying ? Colors.teal.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isPlaying ? Colors.teal.shade200 : Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade700,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  '${widget.surahNumber}:${ayah['numberInSurah']}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                  color: Colors.teal.shade700,
                                  size: 40,
                                ),
                                onPressed: () => _playAudio(ayah['audio'], index),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            displayAyaText, // Menggunakan teks yang sudah dibersihkan
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 30,
                              fontFamily: 'Traditional Arabic',
                              height: 2.0,
                              color: Color(0xFF1A1A1A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );

                  },
                ),
    );
  }
}
