import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_design_system.dart';
import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithUsername() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authRepo = AuthRepository();
      final user = await authRepo.signInWithUsername(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        context.read<AuthProvider>().setUser(user);
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();

        // Dịch các lỗi Firebase phổ biến sang tiếng Việt
        if (errorMessage.contains('auth credential is incorrect') ||
            errorMessage.contains('wrong-password') ||
            errorMessage.contains('invalid-credential')) {
          errorMessage = 'Tên đăng nhập hoặc mật khẩu không đúng';
        } else if (errorMessage.contains('user-not-found')) {
          errorMessage = 'Không tìm thấy tài khoản';
        } else if (errorMessage.contains('too-many-requests')) {
          errorMessage = 'Quá nhiều lần thử. Vui lòng thử lại sau';
        } else if (errorMessage.contains('network-request-failed')) {
          errorMessage = 'Lỗi kết nối mạng';
        } else {
          // Loại bỏ "Exception: " khỏi thông báo
          errorMessage = errorMessage.replaceAll('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final authRepo = AuthRepository();
      final user = await authRepo.signInWithGoogle();

      if (mounted) {
        context.read<AuthProvider>().setUser(user);
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        errorMessage = errorMessage.replaceAll('Exception: ', '');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background - try image first, fallback to gradient
          Image.network(
            'https://images.unsplash.com/photo-1557683316-973673baf926?w=1920&q=80',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback gradient if image fails
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF001233),
                      Color(0xFF003d6b),
                      Color(0xFF0066a1),
                      Color(0xFF004d7a),
                      Color(0xFF001a33),
                    ],
                    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                  ),
                ),
              );
            },
          ),
          // Lớp phủ tối
          Container(color: Colors.black.withValues(alpha: 0.35)),
          // Nội dung
          SafeArea(
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 1200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Phía trái - Văn bản chào mừng
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HỌC TIẾNG ANH',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -1.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    offset: Offset(0, 4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'QUA PHIM ẢNH',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                height: 1.1,
                                letterSpacing: -1.5,
                                shadows: [
                                  Shadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.5,
                                    ),
                                    offset: Offset(0, 4),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: AppSpacing.xl),
                            Text(
                              'Trải nghiệm cách học tiếng anh hiệu quả và thú vị nhất',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.95),
                                height: 1.6,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: AppSpacing.xl),

                    // Phía phải - Form đăng nhập
                    Expanded(
                      flex: 1,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 450),
                        padding: AppSpacing.paddingXL,
                        child: Container(
                          padding: AppSpacing.paddingXL,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: AppRadius.radiusXL,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Logo
                                Image.network(
                                  'logo.png',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                                AppSpacing.gapMD,

                                // Title
                                Text(
                                  'Học và Thư giãn',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.0,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                AppSpacing.gapXS,
                                Text(
                                  'Đăng nhập để tiếp tục',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                        letterSpacing: 0.5,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                AppSpacing.gapLG,

                                // Trường tên đăng nhập
                                TextFormField(
                                  controller: _usernameController,
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập tên đăng nhập';
                                    }
                                    if (value.length < 3) {
                                      return 'Tên đăng nhập phải có ít nhất 3 ký tự';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Tên đăng nhập',
                                    prefixIcon: const Icon(
                                      Icons.person_outline_rounded,
                                    ),
                                  ),
                                ),
                                AppSpacing.gapMD,

                                // Trường mật khẩu
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  validator: Validators.validatePassword,
                                  onFieldSubmitted: (_) {
                                    if (!_isLoading) {
                                      _signInWithUsername();
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Mật khẩu',
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_rounded
                                            : Icons.visibility_off_rounded,
                                      ),
                                      onPressed: () {
                                        setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                AppSpacing.gapSM,

                                // Quên mật khẩu
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      // Chức năng quên mật khẩu - sẽ implement sau
                                    },
                                    child: Text(
                                      'Quên mật khẩu?',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                AppSpacing.gapXL,

                                // Nút đăng nhập
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : _signInWithUsername,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: AppSpacing.md,
                                      ),
                                      elevation: 0,
                                      shadowColor: AppColors.primary.withAlpha(
                                        128,
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Đăng nhập',
                                            style: TextStyle(
                                              fontSize: AppFontSizes.lg,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                ),
                                AppSpacing.gapMD,

                                // Đường phân cách
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: AppColors.textSecondary
                                            .withAlpha(51),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                      ),
                                      child: Text(
                                        'Hoặc',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: AppFontSizes.sm,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: AppColors.textSecondary
                                            .withAlpha(51),
                                      ),
                                    ),
                                  ],
                                ),
                                AppSpacing.gapMD,

                                // Nút đăng nhập Google
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : _signInWithGoogle,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: BorderSide(
                                        color: AppColors.textSecondary
                                            .withAlpha(51),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: AppSpacing.md,
                                        horizontal: AppSpacing.md,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.g_mobiledata_rounded,
                                          size: 28,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Đăng nhập với Google',
                                          style: TextStyle(
                                            fontSize: AppFontSizes.lg,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                AppSpacing.gapXXL,

                                // Liên kết đăng ký
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Chưa có tài khoản? ",
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: AppFontSizes.md,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.go('/register');
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: AppSpacing.xs,
                                        ),
                                      ),
                                      child: Text(
                                        'Đăng ký',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: AppFontSizes.md,
                                        ),
                                      ),
                                    ),
                                  ], // Row children
                                ), // Row
                              ], // Column children
                            ), // Column
                          ), // Form
                        ), // Container (form box)
                      ), // Container (right side)
                    ), // Expanded (right side)
                  ], // Row children
                ), // Row
              ), // Container (max width)
            ), // Center
          ), // SafeArea
        ], // Stack children
      ), // Stack
    ); // Scaffold
  }
}
