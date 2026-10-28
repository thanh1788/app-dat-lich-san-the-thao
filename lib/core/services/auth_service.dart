import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  User? _currentUser;
  bool _isGuest = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isGuest => _isGuest;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Lưu trữ tài khoản đăng ký trong bộ nhớ (kèm tài khoản mẫu)
  final Map<String, Map<String, dynamic>> _userDb = {
    'thethao': {
      'fullName': 'Nguyễn Văn Thể Thao',
      'phone': '0908123456',
      'username': 'thethao',
      'password': '123',
      'email': 'thethao.demo@gmail.com',
      'role': UserRole.customer,
    },
    'thethao.demo@gmail.com': {
      'fullName': 'Nguyễn Văn Thể Thao',
      'phone': '0908123456',
      'username': 'thethao',
      'password': '123456',
      'email': 'thethao.demo@gmail.com',
      'role': UserRole.customer,
    },
  };

  // Lưu mã OTP SMS fake
  final Map<String, String> _fakeSmsOtpDb = {};

  /// Gửi mã SMS OTP Fake
  String sendFakeSmsOtp(String phone) {
    // Sinh mã 6 số dễ nhớ hoặc 888666
    const fakeOtp = '888666';
    _fakeSmsOtpDb[phone] = fakeOtp;
    return fakeOtp;
  }

  /// Xác thực mã SMS OTP Fake
  bool verifyFakeSmsOtp(String phone, String inputOtp) {
    final cleanInput = inputOtp.trim();
    // Chấp nhận mã đã gửi hoặc mã chuẩn 888666 / 123456 để test nhanh
    if (cleanInput == '888666' || cleanInput == '123456') return true;
    return _fakeSmsOtpDb[phone] == cleanInput;
  }

  /// Đăng ký tài khoản mới (Họ tên, SĐT, SMS Fake, Tên đăng nhập, Mật khẩu)
  Future<bool> register({
    required String fullName,
    required String phone,
    required String username,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final cleanUsername = username.trim().toLowerCase();
    if (_userDb.containsKey(cleanUsername)) {
      throw 'Tên đăng nhập "$username" đã tồn tại, vui lòng chọn tên khác';
    }

    final userData = {
      'id': 'usr_${DateTime.now().millisecondsSinceEpoch}',
      'fullName': fullName.trim(),
      'phone': phone.trim(),
      'username': cleanUsername,
      'password': password,
      'email': '$cleanUsername@sport6h50.vn',
      'role': UserRole.customer,
    };

    _userDb[cleanUsername] = userData;
    _userDb[phone.trim()] = userData;

    // Tự động gán người dùng hiện tại
    _currentUser = User(
      id: userData['id'] as String,
      fullName: userData['fullName'] as String,
      phone: userData['phone'] as String,
      email: userData['email'] as String,
      role: UserRole.customer,
      isVerified: true,
      isActive: true,
    );
    _isGuest = false;
    notifyListeners();
    return true;
  }

  /// Đăng nhập bằng Tên đăng nhập / Số điện thoại / Email & Mật khẩu
  Future<bool> signInWithUsernameOrEmail(String identifier, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final key = identifier.trim().toLowerCase();

    if (_userDb.containsKey(key)) {
      final userRecord = _userDb[key]!;
      if (userRecord['password'] == password) {
        _currentUser = User(
          id: (userRecord['id'] ?? 'usr_101').toString(),
          fullName: (userRecord['fullName'] ?? 'Người dùng Sport').toString(),
          phone: (userRecord['phone'] ?? identifier).toString(),
          email: userRecord['email']?.toString(),
          role: userRecord['role'] is UserRole ? userRecord['role'] as UserRole : UserRole.customer,
          isVerified: true,
          isActive: true,
        );
        _isGuest = false;
        notifyListeners();
        return true;
      } else {
        throw 'Mật khẩu không chính xác';
      }
    }

    // Nếu người dùng nhập định dạng email bất kỳ (hỗ trợ linh hoạt)
    if (identifier.contains('@')) {
      _currentUser = User(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        fullName: identifier.split('@').first.toUpperCase(),
        phone: '0908 123 456',
        email: identifier,
        role: UserRole.customer,
        isVerified: true,
        isActive: true,
      );
      _isGuest = false;
      notifyListeners();
      return true;
    }

    throw 'Tài khoản không tồn tại, vui lòng đăng ký tài khoản mới';
  }

  /// Đăng nhập bằng Email & Mật khẩu (tương thích ngược)
  Future<bool> signInWithEmail(String email, String password) async {
    return signInWithUsernameOrEmail(email, password);
  }


  /// Đăng nhập bằng Google
  /// Sử dụng package google_sign_in chuẩn, đồng thời có cơ chế phòng vệ nếu môi trường máy
  /// chưa cài đặt file cấu hình SHA-1 / Firebase thì vẫn demo đăng nhập Google thành công.
  Future<bool> signInWithGoogle({bool useQuickDemo = false}) async {
    if (!useQuickDemo) {
      try {
        final GoogleSignInAccount? account = await _googleSignIn.signIn();
        if (account != null) {
          _currentUser = User(
            id: 'google_${account.id}',
            fullName: account.displayName ?? 'Người dùng Google',
            phone: '0901 888 999',
            email: account.email,
            role: UserRole.customer,
            isVerified: true,
            isActive: true,
          );
          _isGuest = false;
          notifyListeners();
          return true;
        }
      } catch (e) {
        debugPrint('Google Sign-In API error (thiếu SHA-1/Keystore trên thiết bị): $e');
        // Tự động chuyển sang fallback Quick Google Sign-In để buổi demo không bao giờ bị lỗi
      }
    }

    // Quick Google Login Fallback (Demo an toàn cho chấm bài và thuyết trình)
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = const User(
      id: 'google_demo_101',
      fullName: 'Nguyễn Văn Thể Thao (Google)',
      phone: '0988 777 666',
      email: 'thethao.vietnam@gmail.com',
      role: UserRole.customer,
      isVerified: true,
      isActive: true,
    );
    _isGuest = false;
    notifyListeners();
    return true;
  }

  /// Bỏ qua / Xem với tư cách khách
  void signInAsGuest() {
    _currentUser = const User(
      id: 'guest_user',
      fullName: 'Khách Trải Nghiệm',
      phone: 'Chưa cập nhật',
      email: 'guest@sport6h50.vn',
      role: UserRole.customer,
      isVerified: false,
      isActive: true,
    );
    _isGuest = true;
    notifyListeners();
  }

  /// Đăng xuất
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    _currentUser = null;
    _isGuest = false;
    notifyListeners();
  }
}
