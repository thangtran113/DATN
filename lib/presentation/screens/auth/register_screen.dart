import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_design_system.dart';
import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _acceptTerms = false;
  String? _usernameError;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _checkUsernameAvailability() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty || username.length < 3) return;

    try {
      final authRepo = AuthRepository();
      final isAvailable = await authRepo.isUsernameAvailable(username);

      setState(() {
        _usernameError = isAvailable ? null : 'Tên đăng nhập đã được sử dụng';
      });
    } catch (e) {
      // Bỏ qua lỗi, sẽ được bắt trong quá trình đăng ký
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_usernameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_usernameError!),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chấp nhận Điều khoản và Điều kiện'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = AuthRepository();
      await authRepo.registerWithEmailAndPassword(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo tài khoản thành công! Vui lòng đăng nhập.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to login screen
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();

        // Dịch các lỗi Firebase phổ biến sang tiếng Việt
        if (errorMessage.contains('email-already-in-use')) {
          errorMessage = 'Email đã được sử dụng';
        } else if (errorMessage.contains('invalid-email')) {
          errorMessage = 'Email không hợp lệ';
        } else if (errorMessage.contains('weak-password')) {
          errorMessage = 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
        } else if (errorMessage.contains('Username')) {
          // Giữ nguyên message về username
        } else if (errorMessage.contains('network-request-failed')) {
          errorMessage = 'Lỗi kết nối mạng';
        } else if (errorMessage.contains('permission-denied')) {
          errorMessage = 'Lỗi quyền truy cập. Vui lòng thử lại';
        } else if (errorMessage.contains('FirebaseAuthException')) {
          // Extract error message from FirebaseAuthException
          final match = RegExp(r'\] (.+)$').firstMatch(errorMessage);
          if (match != null) {
            errorMessage = match.group(1) ?? 'Đăng ký thất bại';
          } else {
            errorMessage = 'Đăng ký thất bại';
          }
        } else {
          // Loại bỏ "Exception: " khỏi thông báo
          errorMessage = errorMessage.replaceAll('Exception: ', '');
          errorMessage = errorMessage
              .replaceAll('[cloud_firestore/', '')
              .replaceAll(']', '');
        }

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
          // Background Image
          Image.network(
            'https://images.unsplash.com/photo-1557683316-973673baf926?w=1920&q=80',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
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
                              'Trải nghiệm cách học tiếng Anh hiệu quả và thú vị nhất',
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

                    // Phía phải - Form đăng ký
                    Expanded(
                      flex: 1,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 450),
                        padding: AppSpacing.paddingXL,
                        child: SingleChildScrollView(
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
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.contain,
                                  ),
                                  AppSpacing.gapXL,

                                  // Title
                                  Text(
                                    'Tạo Tài Khoản',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.2,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  AppSpacing.gapSM,
                                  Text(
                                    'Tham gia CineChill ngay hôm nay',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  AppSpacing.gapXL,

                                  // Trường tên
                                  TextFormField(
                                    controller: _nameController,
                                    validator: Validators.validateName,
                                    decoration: const InputDecoration(
                                      labelText: 'Họ và Tên',
                                      prefixIcon: Icon(Icons.person_outlined),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Username Field
                                  TextFormField(
                                    controller: _usernameController,
                                    keyboardType: TextInputType.text,
                                    onChanged: (_) {
                                      setState(() => _usernameError = null);
                                    },
                                    onEditingComplete:
                                        _checkUsernameAvailability,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Vui lòng nhập tên đăng nhập';
                                      }
                                      if (value.length < 3) {
                                        return 'Tên đăng nhập phải có ít nhất 3 ký tự';
                                      }
                                      if (!RegExp(
                                        r'^[a-zA-Z0-9_]+$',
                                      ).hasMatch(value)) {
                                        return 'Tên đăng nhập chỉ được chứa chữ cái, số và gạch dưới';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Tên đăng nhập',
                                      prefixIcon: const Icon(
                                        Icons.alternate_email,
                                      ),
                                      errorText: _usernameError,
                                      suffixIcon:
                                          _usernameError == null &&
                                              _usernameController.text.length >=
                                                  3
                                          ? const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                            )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Trường email
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: Validators.validateEmail,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon: Icon(Icons.email_outlined),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Trường mật khẩu
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    validator: Validators.validatePassword,
                                    decoration: InputDecoration(
                                      labelText: 'Mật khẩu',
                                      prefixIcon: const Icon(
                                        Icons.lock_outlined,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
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
                                  const SizedBox(height: 16),

                                  // Trường xác nhận mật khẩu
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: _obscureConfirmPassword,
                                    validator: (value) =>
                                        Validators.validateConfirmPassword(
                                          value,
                                          _passwordController.text,
                                        ),
                                    decoration: InputDecoration(
                                      labelText: 'Xác nhận mật khẩu',
                                      prefixIcon: const Icon(
                                        Icons.lock_outlined,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                        onPressed: () {
                                          setState(
                                            () => _obscureConfirmPassword =
                                                !_obscureConfirmPassword,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Checkbox điều khoản và điều kiện
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _acceptTerms,
                                        onChanged: (value) {
                                          setState(
                                            () => _acceptTerms = value ?? false,
                                          );
                                        },
                                        activeColor: AppColors.primary,
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(
                                              () =>
                                                  _acceptTerms = !_acceptTerms,
                                            );
                                          },
                                          child: Text.rich(
                                            TextSpan(
                                              text: 'Tôi đồng ý với ',
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text:
                                                      'Điều khoản và Điều kiện',
                                                  style: TextStyle(
                                                    color: AppColors.primary,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Register Button
                                  ElevatedButton(
                                    onPressed: _isLoading ? null : _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
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
                                            'Tạo tài khoản',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 32),

                                  // Liên kết đăng nhập
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Đã có tài khoản? ',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context.go('/login');
                                        },
                                        child: Text(
                                          'Đăng nhập',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
