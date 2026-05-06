import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_settings.dart';
import '../../../core/router/app_router.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true; 
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleLogin() async {
    final identifier = _usernameController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty) {
      _showError('Username tidak boleh kosong');
      return;
    }

    setState(() => _isLoading = true);

    // ── MODE DEMO — hanya aktif saat debug, TIDAK masuk production ──
    // ignore: do_not_use_environment
    const bool isRelease = bool.fromEnvironment('dart.vm.product');
    if (!isRelease) {
      final mockRoles = {
        'superadmin@madrasah.id': AppRoutes.superadmin,
        'kamad@madrasah.id': AppRoutes.kepala,
        'wakakur@madrasah.id': AppRoutes.wakakur,
        'operator@madrasah.id': AppRoutes.operator_,
        'keuangan@madrasah.id': AppRoutes.keuangan,
        'guru@madrasah.id': AppRoutes.guru,
        'bimbel@madrasah.id': AppRoutes.bimbel,
        'ortu@madrasah.id': AppRoutes.orangTua,
      };
      if (mockRoles.containsKey(identifier)) {
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        context.go(mockRoles[identifier]!);
        setState(() => _isLoading = false);
        return;
      }
    }
    // ─────────────────────────────────────────────────────────────

    try {
      final response = await _authService.signIn(identifier, password);
      final user = response.user;
      
      if (user != null) {
        final roleCode = await _authService.getUserRole(user.id);
        if (!mounted) return;

        switch (roleCode) {
          case 'SA': context.go(AppRoutes.superadmin); break;
          case 'KM': context.go(AppRoutes.kepala); break;
          case 'WK': context.go(AppRoutes.wakakur); break;
          case 'OP': context.go(AppRoutes.operator_); break;
          case 'AK': context.go(AppRoutes.keuangan); break;
          case 'GM':
            context.go(AppRoutes.guru);
            break;
          case 'GB': context.go(AppRoutes.bimbel); break;
          case 'OT': context.go(AppRoutes.orangTua); break;
          default:
            _showError('Role tidak dikenali atau akses ditolak');
            await _authService.signOut();
        }
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  // Responsive sizing helper
  _ResponsiveSizes _getResponsiveSizes(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Breakpoint definitions
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
    final isMobile = sizes.isMobile;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 0 : 24,
              vertical: isMobile ? 0 : 40,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: sizes.cardMaxWidth,
                minHeight: MediaQuery.of(context).size.height - 
                  (isMobile ? 0 : 80),
              ),
              child: IntrinsicHeight(
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
                        blurRadius: isMobile ? 10 : 20,
                        offset: Offset(0, isMobile ? 5 : 10),
                      )
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // LOGO SEKOLAH
                        _buildLogo(sizes),
                        SizedBox(height: sizes.spacing),

                        // TEKS SAMBUTAN
                        _buildWelcomeText(sizes),
                        SizedBox(height: sizes.extraLargeSpacing),

                        // FORM INPUT
                        _buildUsernameInput(sizes),
                        SizedBox(height: sizes.spacing),
                        _buildPasswordInput(sizes),
                        SizedBox(height: sizes.largeSpacing),

                        // TOMBOL MASUK
                        _buildLoginButton(sizes),
                      ],
                    ),
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
            Icon(
              Icons.school_outlined,
              size: sizes.logoIconSize,
              color: Colors.blue.shade400,
            ),
            SizedBox(height: 2),
            Text(
              appConfig.schoolName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: sizes.logoTextSize,
                color: Colors.blue.shade400,
                fontWeight: FontWeight.bold,
                height: 1.2,
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
            height: 1.3,
          ),
        ),
        SizedBox(height: sizes.spacing / 2),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(sizes.inputBorderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: _usernameController,
        textInputAction: TextInputAction.next,
        style: TextStyle(fontSize: sizes.inputFontSize),
        decoration: InputDecoration(
          hintText: 'Username',
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: sizes.inputFontSize,
          ),
          prefixIcon: Icon(Icons.person_outline, color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: sizes.isMobile ? 12 : 16,
            vertical: sizes.isMobile ? 12 : 16,
          ),
        ),
        onSubmitted: (_) => _handleLogin(),
      ),
    );
  }

  Widget _buildPasswordInput(_ResponsiveSizes sizes) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(sizes.inputBorderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _isObscure,
        textInputAction: TextInputAction.done,
        style: TextStyle(fontSize: sizes.inputFontSize),
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: sizes.inputFontSize,
          ),
          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade400),
          suffixIcon: IconButton(
            icon: Icon(
              _isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: _isObscure ? Colors.grey.shade400 : Colors.blue.shade600,
            ),
            onPressed: () {
              setState(() {
                _isObscure = !_isObscure;
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: sizes.isMobile ? 12 : 16,
            vertical: sizes.isMobile ? 12 : 16,
          ),
        ),
        onSubmitted: (_) => _handleLogin(),
      ),
    );
  }

  Widget _buildLoginButton(_ResponsiveSizes sizes) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: sizes.buttonPadding),
        elevation: 2,
        shadowColor: Colors.indigo.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sizes.inputBorderRadius),
        ),
      ),
      child: _isLoading 
        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login_rounded, size: sizes.buttonFontSize),
              const SizedBox(width: 8),
              Text(
                'Masuk',
                style: TextStyle(
                  fontSize: sizes.buttonFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
    );
  }
}

// Helper class untuk responsive sizing
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
