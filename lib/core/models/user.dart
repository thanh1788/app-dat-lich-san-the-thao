enum UserRole {
  customer('Khách đặt sân', '👤'),
  owner('Chủ sân', '🏟️'),
  admin('Quản trị viên', '👑');

  final String label;
  final String icon;
  const UserRole(this.label, this.icon);
}

class User {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final UserRole role;

  /// Danh sách ID sân mà user này quản lý (chỉ áp dụng cho role = owner)
  final List<String> venueIds;

  /// Trạng thái tài khoản
  final bool isVerified;
  final bool isActive;

  const User({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    required this.role,
    this.venueIds = const [],
    this.isVerified = true,
    this.isActive = true,
  });

  User copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
    UserRole? role,
    List<String>? venueIds,
    bool? isVerified,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      venueIds: venueIds ?? this.venueIds,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
    );
  }
}