import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_footer.dart';
import '../../../data/repositories/auth_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _activeTab = 'info'; // 'info' or 'password'
  bool _isLoading = false;
  bool _hasChanges = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _displayNameController.text = user?.displayName ?? '';
    _usernameController.text = user?.username ?? '';

    _displayNameController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    final user = context.read<AuthProvider>().user;
    setState(() {
      _hasChanges =
          _displayNameController.text.trim() != (user?.displayName ?? '');
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: Text(
          title,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text(
              'Xác nhận',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _saveProfileInfo() async {
    if (!_formKey.currentState!.validate()) return;

    // Hiển thị dialog xác nhận
    final confirmed = await _showConfirmationDialog(
      title: 'Xác nhận cập nhật',
      message: 'Bạn có chắc chắn muốn cập nhật thông tin cá nhân?',
    );

    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      await AuthRepository().updateUserProfile(
        displayName: _displayNameController.text.trim(),
      );

      final user = context.read<AuthProvider>().user;
      if (user != null && mounted) {
        final updatedUser = user.copyWith(
          displayName: _displayNameController.text.trim(),
        );
        context.read<AuthProvider>().setUser(updatedUser);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin thành công'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 1),
          ),
        );
        setState(() => _hasChanges = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập mật khẩu hiện tại'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu mới không khớp'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu phải có ít nhất 8 ký tự'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    // Hiển thị dialog xác nhận
    final confirmed = await _showConfirmationDialog(
      title: 'Xác nhận đổi mật khẩu',
      message: 'Bạn có chắc chắn muốn đổi mật khẩu?',
    );

    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      await AuthRepository().changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đổi mật khẩu thành công'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Yêu cầu đăng nhập để truy cập hồ sơ
    if (authProvider.user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Vui lòng đăng nhập để xem tài khoản',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
                      ),
                      child: const Text('Đăng nhập'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 200,
                    ),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        padding: const EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            const Text(
                              'Tài Khoản',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Tabs
                            _buildTabs(),
                            const SizedBox(height: 32),

                            // Content with IndexedStack to prevent jumping
                            IndexedStack(
                              index: _activeTab == 'info' ? 0 : 1,
                              children: [_buildInfoTab(), _buildPasswordTab()],
                            ),

                            const SizedBox(height: 48),

                            // Danger Zone
                            _buildDangerZone(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const AppFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          _buildTab('Thông Tin', 'info'),
          const SizedBox(width: 32),
          _buildTab('Mật Khẩu', 'password'),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String value) {
    final isActive = _activeTab == value;

    return GestureDetector(
      onTap: () => setState(() => _activeTab = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grid layout for form fields
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Tên Hiển Thị',
                        controller: _displayNameController,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildReadOnlyTextField(
                        label: 'Tên Đăng Nhập',
                        controller: _usernameController,
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildTextField(
                      label: 'Tên Hiển Thị',
                      controller: _displayNameController,
                    ),
                    const SizedBox(height: 24),
                    _buildReadOnlyTextField(
                      label: 'Tên Đăng Nhập',
                      controller: _usernameController,
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 24),

          // Update button aligned right
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: (_hasChanges && !_isLoading)
                    ? _saveProfileInfo
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  disabledBackgroundColor: AppColors.backgroundCard,
                  disabledForegroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textPrimary,
                        ),
                      )
                    : const Text(
                        'Cập Nhật',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đổi Mật Khẩu',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),

        // Current Password field
        _buildPasswordField(
          label: 'Mật Khẩu Hiện Tại',
          controller: _currentPasswordController,
          obscureText: _obscureCurrentPassword,
          onToggle: () => setState(
            () => _obscureCurrentPassword = !_obscureCurrentPassword,
          ),
        ),
        const SizedBox(height: 24),

        // Password fields in grid
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildPasswordField(
                      label: 'Mật Khẩu Mới',
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      onToggle: () => setState(
                        () => _obscureNewPassword = !_obscureNewPassword,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildPasswordField(
                      label: 'Xác Nhận Mật Khẩu',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      onToggle: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildPasswordField(
                    label: 'Mật Khẩu Mới',
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    onToggle: () => setState(
                      () => _obscureNewPassword = !_obscureNewPassword,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildPasswordField(
                    label: 'Xác Nhận Mật Khẩu',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    onToggle: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                  ),
                ],
              );
            }
          },
        ),
        const SizedBox(height: 16),

        // Password hint
        const Text(
          'Mật khẩu phải có ít nhất 8 ký tự và chứa nhiều loại ký tự khác nhau.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 24),

        // Confirm button aligned right
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed:
                  (!_isLoading &&
                      _currentPasswordController.text.isNotEmpty &&
                      _newPasswordController.text.isNotEmpty &&
                      _confirmPasswordController.text.isNotEmpty)
                  ? _changePassword
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                disabledBackgroundColor: AppColors.backgroundCard,
                disabledForegroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textPrimary,
                      ),
                    )
                  : const Text(
                      'Xác Nhận',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.backgroundCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: false,
          style: const TextStyle(color: AppColors.textSecondary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.backgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.backgroundCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vùng Nguy Hiểm',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Xóa tài khoản sẽ xóa vĩnh viễn tất cả dữ liệu của bạn bao gồm lịch sử học tập, từ vựng đã lưu, và danh sách yêu thích. Hành động này không thể hoàn tác.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _confirmDeleteAccount,
            icon: const Icon(Icons.delete_forever),
            label: const Text('Xóa Tài Khoản'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    // First dialog: Xác nhận lần 1
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Xóa tài khoản?',
          style: TextStyle(color: AppColors.error),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tài khoản? Tất cả dữ liệu của bạn sẽ bị xóa vĩnh viễn và không thể khôi phục.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(
              'Tiếp tục',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (firstConfirm != true) return;

    // Second dialog: Nhập mật khẩu để xác nhận
    final passwordController = TextEditingController();
    final secondConfirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Xác nhận mật khẩu',
          style: TextStyle(color: AppColors.error),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập mật khẩu của bạn để xác nhận xóa tài khoản:',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Mật khẩu',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              passwordController.dispose();
              Navigator.pop(context, false);
            },
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (passwordController.text.isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(
              'Xóa Tài Khoản',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (secondConfirm != true || passwordController.text.isEmpty) {
      passwordController.dispose();
      return;
    }

    // Thực hiện xóa tài khoản
    setState(() => _isLoading = true);

    try {
      final authRepo = AuthRepository();
      await authRepo.deleteAccount(currentPassword: passwordController.text);
      passwordController.dispose();

      if (mounted) {
        // Đăng xuất và chuyển về trang login
        await context.read<AuthProvider>().signOut();
        context.go('/login');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tài khoản đã được xóa thành công'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      passwordController.dispose();
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }
}
