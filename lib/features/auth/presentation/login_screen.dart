import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import '../../../core/router/app_router.dart';
import 'package:flutter/foundation.dart';
import '../../../core/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import '../../../core/providers/system_provider.dart';
import 'package:flutter/foundation.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true; 
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleLogin() async {
    debugPrint("DEBUG UI: Tombol Masuk diklik!");
    final identifier = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      _showError('Username dan Password tidak boleh kosong');
      return;
    }

    // Panggil provider untuk login
    await ref.read(authProvider.notifier).signIn(identifier, password);
    
    final authState = ref.read(authProvider);
    
    if (authState.user != null) {
      if (!mounted) return;
      // Navigasi berdasarkan role dari AppUser
      final role = authState.user!.roleCode ?? '';
      final isWaliKelas = authState.user!.isWaliKelas;
      context.go(AppRoutes.dashboardForRole(role, isWaliKelas: isWaliKelas));
    } else if (authState.errorMessage != null) {
      _showError(authState.errorMessage!);
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
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  _ResponsiveSizes _getResponsiveSizes(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    bool isDesktop = screenWidth >= 1024;

    return _ResponsiveSizes(
      isMobile: isMobile,
      isTablet: isTablet,
      isDesktop: isDesktop,
      cardMaxWidth: isMobile ? double.infinity : (isTablet ? 500 : 450),
      cardMargin: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 16 : 40,
      ),
      cardPadding: EdgeInsets.all(isMobile ? 20 : 40),
      logoSize: isMobile ? 80 : 100,
      logoIconSize: isMobile ? 28 : 36,
      logoTextSize: isMobile ? 9 : 10,
      titleFontSize: isMobile ? 16 : 20,
      subtitleFontSize: isMobile ? 12 : 14,
      inputFontSize: isMobile ? 13 : 14,
      buttonFontSize: isMobile ? 14 : 16,
      buttonPadding: isMobile ? 14 : 18,
      spacing: isMobile ? 12 : 16,
      largeSpacing: isMobile ? 20 : 32,
      extraLargeSpacing: isMobile ? 24 : 40,
      borderRadius: isMobile ? 16 : 24,
      inputBorderRadius: isMobile ? 10 : 12,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizes = _getResponsiveSizes(context);
    final authState = ref.watch(authProvider);
    final settingsAsync = ref.watch(systemSettingsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // SISI KIRI: DEKORATIF (Hanya tampil di Tablet/Desktop)
          if (!sizes.isMobile)
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Elemen Kapsul Dekoratif (Meniru gambar)
                    _buildFloatingShape(top: 100, left: 50, width: 200, height: 60, rotation: -0.5),
                    _buildFloatingShape(top: 250, left: 150, width: 300, height: 80, rotation: -0.5),
                    _buildFloatingShape(bottom: 100, right: 100, width: 250, height: 70, rotation: -0.5),
                    _buildFloatingShape(top: 400, left: 100, width: 150, height: 50, rotation: -0.5),
                    
                    Center(
                      child: settingsAsync.when(
                        data: (s) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (s.logoUrl != null)
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  image: DecorationImage(image: NetworkImage(s.logoUrl!), fit: BoxFit.contain),
                                ),
                              ),
                            const SizedBox(height: 24),
                            Text(
                              s.schoolName,
                              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        loading: () => const CircularProgressIndicator(color: Colors.white),
                        error: (_, __) => const Icon(Icons.school, size: 80, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // SISI KANAN: FORM LOGIN
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: sizes.isMobile ? 32 : 64),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (sizes.isMobile) ...[
                          settingsAsync.when(
                            data: (s) => _buildLogo(sizes, s.schoolName, s.logoUrl),
                            loading: () => _buildLogo(sizes, 'SI Madrasah', null),
                            error: (_, __) => _buildLogo(sizes, 'SI Madrasah', null),
                          ),
                          const SizedBox(height: 24),
                        ],
                        const Text(
                          'USER LOGIN',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A11CB),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        settingsAsync.when(
                          data: (s) => Text(
                            s.appName,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                          ),
                          loading: () => Text(
                            'Selamat Datang di Informasi Akademik Sekolah',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                          ),
                          error: (_, __) => Text(
                            'Selamat Datang di Informasi Akademik Sekolah',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 48),
                        
                        // Username Field (Pill-shaped)
                        _buildModernInput(
                          controller: _usernameController,
                          hint: 'Username',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 20),
                        
                        // Password Field (Pill-shaped)
                        _buildModernInput(
                          controller: _passwordController,
                          hint: 'Password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle, size: 18, color: const Color(0xFF6A11CB).withOpacity(0.7)),
                                const SizedBox(width: 8),
                                Text('Remember', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                              ],
                            ),
                            Text('Forgot password?', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                          ],
                        ),
                        
                        const SizedBox(height: 48),
                        _buildModernLoginButton(sizes, authState.isLoading),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingShape({double? top, double? left, double? right, double? bottom, required double width, required double height, required double rotation}) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.05)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernInput({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF6A11CB).withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _isObscure,
        onSubmitted: (_) => _handleLogin(),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: const Color(0xFF6A11CB).withOpacity(0.4)),
          prefixIcon: Icon(icon, color: const Color(0xFF6A11CB).withOpacity(0.6)),
          suffixIcon: isPassword ? IconButton(
            icon: Icon(_isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
            onPressed: () => setState(() => _isObscure = !_isObscure),
          ) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildModernLoginButton(_ResponsiveSizes sizes, bool isLoading) {
    return Container(
      width: 180,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          colors: [Color(0xFFB830D1), Color(0xFF6A11CB)],
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF6A11CB).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: isLoading ? null : _handleLogin,
          child: Center(
            child: isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text(
                    'LOGIN',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(_ResponsiveSizes sizes, String schoolName, String? logoUrl) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF6A11CB).withOpacity(0.1),
        shape: BoxShape.circle,
        image: logoUrl != null ? DecorationImage(image: NetworkImage(logoUrl), fit: BoxFit.contain) : null,
      ),
      child: logoUrl == null ? const Icon(Icons.school, color: Color(0xFF6A11CB), size: 40) : null,
    );
  }
}

class _ResponsiveSizes {
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final double cardMaxWidth;
  final EdgeInsets cardMargin;
  final EdgeInsets cardPadding;
  final double logoSize;
  final double logoIconSize;
  final double logoTextSize;
  final double titleFontSize;
  final double subtitleFontSize;
  final double inputFontSize;
  final double buttonFontSize;
  final double buttonPadding;
  final double spacing;
  final double largeSpacing;
  final double extraLargeSpacing;
  final double borderRadius;
  final double inputBorderRadius;

  _ResponsiveSizes({
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.cardMaxWidth,
    required this.cardMargin,
    required this.cardPadding,
    required this.logoSize,
    required this.logoIconSize,
    required this.logoTextSize,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.inputFontSize,
    required this.buttonFontSize,
    required this.buttonPadding,
    required this.spacing,
    required this.largeSpacing,
    required this.extraLargeSpacing,
    required this.borderRadius,
    required this.inputBorderRadius,
  });
}
