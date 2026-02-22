import 'package:flutter/material.dart';

class IntegrationScreen extends StatelessWidget {
  const IntegrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Integrasi AI'),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.api, color: Colors.purple),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Konfigurasi API Key (OpenAI / Gemini) untuk fitur AI Sahabat Guru dan Sahabat Belajar. Kunci yang disimpan di sini terenkripsi di Database.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              _buildApiConfigSection(
                'AI Sahabat Guru',
                'Digunakan untuk modul bantuan evaluasi nilai, saran pembelajaran, dan penyusunan modul di portal Guru.',
                'sk-guru-xxxxxxxxxxxxxxxxx',
              ),
              const SizedBox(height: 24),
              
              _buildApiConfigSection(
                'AI Sahabat Belajar',
                'Digunakan untuk asisten belajar interaktif siswa pada modul e-learning portal Parent/Siswa.',
                'sk-siswa-xxxxxxxxxxxxxxxxx',
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('API Keys berhasil diamankan dan disimpan ke Database (Mock)')),
                    );
                  },
                  child: const Text('Simpan Konfigurasi Integrasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApiConfigSection(String title, String description, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 12),
        TextField(
          obscureText: true, // Hide api key naturally
          decoration: InputDecoration(
            labelText: 'Secret API Key',
            hintText: placeholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.key),
            suffixIcon: const Icon(Icons.visibility_off),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Pilih Engine AI Utama',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.memory),
          ),
          value: 'OpenAI (GPT-4o)',
          items: const [
            DropdownMenuItem(value: 'OpenAI (GPT-4o)', child: Text('OpenAI (GPT-4o)')),
            DropdownMenuItem(value: 'Gemini (1.5 Pro)', child: Text('Gemini (1.5 Pro)')),
            DropdownMenuItem(value: 'Claude (3.5 Sonnet)', child: Text('Claude (3.5 Sonnet)')),
          ],
          onChanged: (val) {},
        ),
      ],
    );
  }
}
