import 'package:flutter/material.dart';

// Import semua dashboard yang sudah dibuat
import '../../system_admin/presentation/superadmin_dashboard_screen.dart';
import '../../dashboard/headmaster_dashboard_screen.dart';
import '../../academic_config/wakakur_dashboard_screen.dart';
import '../../master_data/operator_dashboard_screen.dart';
import '../../finance/admin_finance_dashboard_screen.dart';
import '../../teacher/teacher_dashboard_screen.dart';
import '../../teacher/bimbel_dashboard_screen.dart';
import '../../parent/parent_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true; // Status Mata (Tampil/Sembunyi Password)

  void _handleLogin() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showError('Username dan Password tidak boleh kosong!');
      return;
    }

    // LIST AKUN PALSU (DUMMY)
    if (username == 'admin' && password == 'admin123') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SuperadminDashboardScreen()));
    } else if (username == 'kepala' && password == 'sekolah123') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HeadmasterDashboardScreen()));
    } else if (username == 'kurikulum' && password == 'waka123') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WakakurDashboardScreen()));
    } else if (username == 'operator' && password == 'data123') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OperatorDashboardScreen()));
    } else if (username == 'keuangan' && password == 'uang123') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminFinanceDashboardScreen()));
    } else if (username == 'guru' && password == 'guru123') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TeacherDashboardScreen(isWaliKelas: false)));
    } else if (username == 'walikelas' && password == 'wali123') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TeacherDashboardScreen(isWaliKelas: true)));
    } else if (username == 'bimbel' && password == 'bimbel123') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BimbelDashboardScreen()));
    } else if (username == 'ortu' && password == 'ortu123') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ParentDashboardScreen()));
    } else {
      _showError('Username atau Password salah!');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 450),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // PLACEHOLDER LOGO SEKOLAH (Dapat dikonfigurasi Superadmin nanti)
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue.shade100, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined, size: 36, color: Colors.blue.shade300),
                        const SizedBox(height: 4),
                        Text('Logo\nSekolah', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.blue.shade400, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // TEKS SAMBUTAN
                const Text(
                  'Selamat Datang di Informasi Akademik Sekolah',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B3674),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan masuk menggunakan akun Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 40),

                // KOLOM USERNAME
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon: Icon(Icons.person_outline, color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    // Deteksi tombol enter
                    onSubmitted: (_) => _handleLogin(),
                  ),
                ),
                const SizedBox(height: 16),

                // KOLOM PASSWORD (Dengan ikon mata)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _isObscure,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade400),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: _isObscure ? Colors.grey.shade400 : Colors.blue.shade600,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure; // Toggle status mata
                          });
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    onSubmitted: (_) => _handleLogin(),
                  ),
                ),
                const SizedBox(height: 32),

                // TOMBOL MASUK DENGAN DESAIN MODERN
                ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                
                const SizedBox(height: 24),
                // Petunjuk singkat untuk Anda saat uji coba
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Text('Akun Testing (Dummy):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange.shade800)),
                      const SizedBox(height: 8),
                      _dummyAccountText('Superadmin:', 'admin', 'admin123'),
                      _dummyAccountText('Kepsek:', 'kepala', 'sekolah123'),
                      _dummyAccountText('Wakakur:', 'kurikulum', 'waka123'),
                      _dummyAccountText('Operator:', 'operator', 'data123'),
                      _dummyAccountText('Keuangan:', 'keuangan', 'uang123'),
                      _dummyAccountText('Guru:', 'guru', 'guru123'),
                      _dummyAccountText('Wali Kelas:', 'walikelas', 'wali123'),
                      _dummyAccountText('Guru Bimbel:', 'bimbel', 'bimbel123'),
                      _dummyAccountText('Orang Tua:', 'ortu', 'ortu123'),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dummyAccountText(String label, String username, String pass) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$label ', style: TextStyle(fontSize: 11, color: Colors.orange.shade800)),
          Text(username, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
          Text(' / ', style: TextStyle(fontSize: 11, color: Colors.orange.shade800)),
          Text(pass, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
        ],
      ),
    );
  }
}

