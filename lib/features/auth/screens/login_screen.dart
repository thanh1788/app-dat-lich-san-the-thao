import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Tab: 0 = Đăng Nhập, 1 = Đăng Ký
  int _selectedTab = 0;

  // Controllers cho Đăng Nhập
  final _loginFormKey = GlobalKey<FormState>();
  final _loginIdentifierController = TextEditingController(text: 'thethao');
  final _loginPasswordController = TextEditingController(text: '123');
  bool _obscureLoginPassword = true;

  // Controllers cho Đăng Ký
  final _regFormKey = GlobalKey<FormState>();
  final _regFullNameController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regOtpController = TextEditingController();
  final _regUsernameController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();
  bool _obscureRegPassword = true;
  bool _obscureRegConfirmPassword = true;
  String? _sentOtpCode;
  bool _isSendingOtp = false;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _loginIdentifierController.dispose();
    _loginPasswordController.dispose();
    _regFullNameController.dispose();
    _regPhoneController.dispose();
    _regOtpController.dispose();
    _regUsernameController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  // Gửi mã SMS OTP Fake
  void _handleSendFakeOtp() {
    final phone = _regPhoneController.text.trim();
    if (phone.isEmpty || phone.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số điện thoại hợp lệ trước khi nhận OTP'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSendingOtp = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final fakeOtp = AuthService.instance.sendFakeSmsOtp(phone);
      setState(() {
        _sentOtpCode = fakeOtp;
        _regOtpController.text = fakeOtp; // Tự động điền để người dùng test tiện lợi
        _isSendingOtp = false;
      });

      // Hiển thị thông báo tin nhắn SMS mô phỏng cực kỳ trực quan
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: const [
              Icon(Icons.sms_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Tin nhắn SMS (Mô phỏng)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gửi tới: $phone',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Sport6h50: Ma xac thuc OTP cua ban la: $fakeOtp. Vui long khong chia se ma nay.',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '✓ Hệ thống đã tự động điền mã OTP vào ô nhập giúp bạn.',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Đã hiểu'),
            ),
          ],
        ),
      );
    });
  }

  // Xử lý Đăng Nhập
  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await AuthService.instance.signInWithUsernameOrEmail(
        _loginIdentifierController.text.trim(),
        _loginPasswordController.text.trim(),
      );

      if (mounted && success) {
        _navigateToHome();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Xử lý Đăng Ký
  Future<void> _handleRegister() async {
    if (!_regFormKey.currentState!.validate()) return;

    final phone = _regPhoneController.text.trim();
    final otp = _regOtpController.text.trim();

    // Kiểm tra OTP SMS
    if (!AuthService.instance.verifyFakeSmsOtp(phone, otp)) {
      setState(() {
        _errorMessage = 'Mã xác thực OTP không đúng. Vui lòng bấm "Gửi mã SMS" để lấy mã mới.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await AuthService.instance.register(
        fullName: _regFullNameController.text.trim(),
        phone: phone,
        username: _regUsernameController.text.trim(),
        password: _regPasswordController.text.trim(),
      );

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Đăng ký thành công! Chào mừng ${_regFullNameController.text.trim()}!'),
            backgroundColor: AppColors.primaryDark,
          ),
        );
        _navigateToHome();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Xử lý Google Sign-In
  Future<void> _handleGoogleLogin({bool quickDemo = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await AuthService.instance.signInWithGoogle(useQuickDemo: quickDemo);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chào mừng ${AuthService.instance.currentUser?.fullName ?? 'bạn'}!'),
            backgroundColor: AppColors.primaryDark,
          ),
        );
        _navigateToHome();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi đăng nhập Google: $e';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleGuestMode() {
    AuthService.instance.signInAsGuest();
    _navigateToHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo & Header
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    boxShadow: AppColors.floatingShadow,
                  ),
                  child: const Center(
                    child: Text('⚡', style: TextStyle(fontSize: 34)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sport6h50',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Đặt sân thể thao thông minh & Kết nối cộng đồng',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),

                // Main Auth Card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tab Bar Selector (Đăng Nhập / Đăng Ký)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedTab = 0;
                                    _errorMessage = null;
                                  });
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 0 ? AppColors.surface : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: _selectedTab == 0 ? AppColors.softShadow : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Đăng Nhập',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: _selectedTab == 0 ? FontWeight.w700 : FontWeight.w500,
                                        color: _selectedTab == 0 ? AppColors.primaryDark : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedTab = 1;
                                    _errorMessage = null;
                                  });
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 1 ? AppColors.surface : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: _selectedTab == 1 ? AppColors.softShadow : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Đăng Ký Mới',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: _selectedTab == 1 ? FontWeight.w700 : FontWeight.w500,
                                        color: _selectedTab == 1 ? AppColors.primaryDark : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Thông báo lỗi nếu có
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ==================== FORM 1: ĐĂNG NHẬP ====================
                      if (_selectedTab == 0) ...[
                        Form(
                          key: _loginFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Tên đăng nhập / SĐT / Email
                              TextFormField(
                                controller: _loginIdentifierController,
                                decoration: InputDecoration(
                                  labelText: 'Tên đăng nhập / Email / SĐT',
                                  hintText: 'Nhập tên đăng nhập hoặc SĐT...',
                                  prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: AppColors.border),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.background,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Vui lòng nhập tên đăng nhập hoặc email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Mật khẩu
                              TextFormField(
                                controller: _loginPasswordController,
                                obscureText: _obscureLoginPassword,
                                decoration: InputDecoration(
                                  labelText: 'Mật khẩu',
                                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureLoginPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () {
                                      setState(() => _obscureLoginPassword = !_obscureLoginPassword);
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: AppColors.border),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.background,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Vui lòng nhập mật khẩu';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),

                              // Nút Đăng Nhập
                              ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Text('Đăng Nhập', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Expanded(child: Divider(color: AppColors.border)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text('HOẶC', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                            ),
                            const Expanded(child: Divider(color: AppColors.border)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Google Sign-In Button
                        OutlinedButton(
                          onPressed: _isLoading ? null : () => _handleGoogleLogin(quickDemo: false),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.border, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('G', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF4285F4))),
                              SizedBox(width: 10),
                              Text('Đăng nhập bằng Google', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Quick 1-Click Demo Button
                        TextButton.icon(
                          onPressed: _isLoading ? null : () => _handleGoogleLogin(quickDemo: true),
                          icon: const Icon(Icons.flash_on_rounded, size: 16, color: AppColors.secondary),
                          label: const Text(
                            'Demo nhanh với Google (1-Click)',
                            style: TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],

                      // ==================== FORM 2: ĐĂNG KÝ ====================
                      if (_selectedTab == 1) ...[
                        Form(
                          key: _regFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 1. Họ và tên
                              TextFormField(
                                controller: _regFullNameController,
                                decoration: InputDecoration(
                                  labelText: 'Họ và tên *',
                                  hintText: 'VD: Nguyễn Văn Thể Thao',
                                  prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.textSecondary),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                  filled: true,
                                  fillColor: AppColors.background,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Vui lòng nhập họ và tên';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // 2. Số điện thoại & nút gửi Fake SMS
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: TextFormField(
                                      controller: _regPhoneController,
                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                        labelText: 'Số điện thoại *',
                                        hintText: 'VD: 0908123456',
                                        prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textSecondary),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                        filled: true,
                                        fillColor: AppColors.background,
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) return 'Nhập số điện thoại';
                                        if (val.trim().length < 9) return 'SĐT chưa đúng';
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: _isSendingOtp ? null : _handleSendFakeOtp,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryLight,
                                          foregroundColor: AppColors.primaryDark,
                                          elevation: 0,
                                          side: const BorderSide(color: AppColors.primary),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                        ),
                                        child: _isSendingOtp
                                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                            : const FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text('Gửi SMS OTP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // 3. Nhập mã OTP SMS Fake
                              TextFormField(
                                controller: _regOtpController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Mã xác thực OTP (SMS fake) *',
                                  hintText: _sentOtpCode != null ? 'Đã điền mã: $_sentOtpCode' : 'Bấm "Gửi SMS OTP" để lấy mã',
                                  prefixIcon: const Icon(Icons.mark_email_read_outlined, color: AppColors.textSecondary),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                  filled: true,
                                  fillColor: AppColors.background,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Vui lòng nhập mã OTP SMS';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // 4. Tên đăng nhập
                              TextFormField(
                                controller: _regUsernameController,
                                decoration: InputDecoration(
                                  labelText: 'Tên đăng nhập *',
                                  hintText: 'VD: thethao_vn',
                                  prefixIcon: const Icon(Icons.account_circle_outlined, color: AppColors.textSecondary),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                  filled: true,
                                  fillColor: AppColors.background,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Vui lòng nhập tên đăng nhập';
                                  if (val.trim().length < 3) return 'Tối thiểu 3 ký tự';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // 5. Mật khẩu
                              TextFormField(
                                controller: _regPasswordController,
                                obscureText: _obscureRegPassword,
                                decoration: InputDecoration(
                                  labelText: 'Mật khẩu *',
                                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureRegPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                    onPressed: () => setState(() => _obscureRegPassword = !_obscureRegPassword),
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                  filled: true,
                                  fillColor: AppColors.background,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Vui lòng nhập mật khẩu';
                                  if (val.length < 4) return 'Mật khẩu tối thiểu 4 ký tự';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // 6. Nhập lại mật khẩu
                              TextFormField(
                                controller: _regConfirmPasswordController,
                                obscureText: _obscureRegConfirmPassword,
                                decoration: InputDecoration(
                                  labelText: 'Nhập lại mật khẩu *',
                                  prefixIcon: const Icon(Icons.lock_reset_outlined, color: AppColors.textSecondary),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureRegConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                    onPressed: () => setState(() => _obscureRegConfirmPassword = !_obscureRegConfirmPassword),
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                  filled: true,
                                  fillColor: AppColors.background,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Vui lòng xác nhận mật khẩu';
                                  if (val != _regPasswordController.text) return 'Mật khẩu xác nhận không trùng khớp';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),

                              // Nút Đăng Ký Tài Khoản
                              ElevatedButton(
                                onPressed: _isLoading ? null : _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Text('Đăng Ký Tài Khoản', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Guest Mode Skip Button
                TextButton(
                  onPressed: _handleGuestMode,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Flexible(
                        child: Text(
                          'Bỏ qua & Xem với tư cách khách',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
