import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_settings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/providers/auth_provider.dart';

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
    print("DEBUG UI: Tombol Masuk diklik!");
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
      context.go(AppRoutes.dashboardForRole(role));
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

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: sizes.isMobile ? 0 : 24,
              vertical: sizes.isMobile ? 0 : 40,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: sizes.cardMaxWidth,
              ),
              child: Container(
                width: double.infinity,
                margin: sizes.cardMargin,
                padding: sizes.cardPadding,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(sizes.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: sizes.isMobile ? 10 : 20,
                      offset: Offset(0, sizes.isMobile ? 5 : 10),
                    )
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildLogo(sizes),
                      SizedBox(height: sizes.spacing),
                      _buildWelcomeText(sizes),
                      SizedBox(height: sizes.extraLargeSpacing),
                      _buildUsernameInput(sizes),
                      SizedBox(height: sizes.spacing),
                      _buildPasswordInput(sizes),
                      SizedBox(height: sizes.largeSpacing),
                      _buildLoginButton(sizes, authState.isLoading),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(_ResponsiveSizes sizes) {
    return Center(
      child: Container(
        width: sizes.logoSize,
        height: sizes.logoSize,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blue.shade100, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: sizes.logoIconSize, color: Colors.blue.shade400),
            Text(
              appConfig.schoolName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: sizes.logoTextSize,
                color: Colors.blue.shade400,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeText(_ResponsiveSizes sizes) {
    return Column(
      children: [
        Text(
          'Selamat Datang di Informasi Akademik Sekolah',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: sizes.titleFontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2B3674),
          ),
        ),
        Text(
          'Silakan masuk menggunakan akun Anda',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: sizes.subtitleFontSize,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameInput(_ResponsiveSizes sizes) {
    return TextField(
      controller: _usernameController,
      decoration: InputDecoration(
        hintText: 'Username',
        prefixIcon: const Icon(Icons.person_outline),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(sizes.inputBorderRadius)),
      ),
    );
  }

  Widget _buildPasswordInput(_ResponsiveSizes sizes) {
    return TextField(
      controller: _passwordController,
      obscureText: _isObscure,
      decoration: InputDecoration(
        hintText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          onPressed: () => setState(() => _isObscure = !_isObscure),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(sizes.inputBorderRadius)),
      ),
    );
  }

  Widget _buildLoginButton(_ResponsiveSizes sizes, bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo.shade600,
        padding: EdgeInsets.symmetric(vertical: sizes.buttonPadding),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sizes.inputBorderRadius)),
      ),
      child: isLoading 
        ? const CircularProgressIndicator(color: Colors.white)
        : const Text('Masuk', style: TextStyle(fontWeight: FontWeight.bold)),
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
