import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/favorite_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/screens/login_screen.dart';
import 'favorite_sports_screen.dart';
import 'voucher_screen.dart';
import 'payment_history_screen.dart';
import 'customer_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isOwnerMode;
  final ValueChanged<bool> onToggleOwnerMode;

  const ProfileScreen({
    super.key,
    required this.isOwnerMode,
    required this.onToggleOwnerMode,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final isGoogleUser =
        user?.email?.toLowerCase().contains('gmail') ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tài Khoản Cá Nhân'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildUserCard(user, isGoogleUser),
            const SizedBox(height: 16),
            _buildOwnerModeTile(),
            const SizedBox(height: 16),
            _buildMenuList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(dynamic user, bool isGoogleUser) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: isGoogleUser
                    ? const Color(0xFFE8F0FE)
                    : AppColors.primaryLight,
                child: Text(
                  user != null && user.fullName.isNotEmpty
                      ? user.fullName.substring(0, 1).toUpperCase()
                      : 'K',
                  style: TextStyle(
                    color: isGoogleUser
                        ? const Color(0xFF1967D2)
                        : AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
              ),
              if (isGoogleUser)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      'G',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? 'Khách Trải Nghiệm',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  user?.email ??
                      (user?.phone.isNotEmpty == true
                          ? user!.phone
                          : 'Chưa đăng nhập'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                if (isGoogleUser) ...[
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '✓ Đã liên kết Google',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF1967D2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerModeTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border:
        Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.store_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chế độ Chủ Sân / Quản lý',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  'Xem doanh thu & timeline lịch đặt',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: widget.isOwnerMode,
            activeThumbColor: AppColors.primary,
            onChanged: widget.onToggleOwnerMode,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: FavoriteService.instance,
            builder: (context, _) {
              final count = FavoriteService.instance.favoriteIds.length;
              return _menuTile(
                icon: Icons.favorite_border_rounded,
                title: 'Sân thể thao yêu thích',
                trailing: count > 0 ? '$count sân' : '',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FavoriteSportsScreen(),
                    ),
                  );
                },
              );
            },
          ),
          const Divider(color: AppColors.divider, height: 1),
          _menuTile(
            icon: Icons.discount_outlined,
            title: 'Kho voucher & khuyến mãi',
            trailing: '2 mã khả dụng',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VoucherScreen()),
              );
            },
          ),
          const Divider(color: AppColors.divider, height: 1),
          _menuTile(
            icon: Icons.history_toggle_off_rounded,
            title: 'Lịch sử thanh toán',
            trailing: '',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PaymentHistoryScreen()),
              );
            },
          ),
          const Divider(color: AppColors.divider, height: 1),
          _menuTile(
            icon: Icons.headset_mic_outlined,
            title: 'Hỗ trợ khách hàng 24/7',
            trailing: 'Hotline 1900 6868',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CustomerSupportScreen()),
              );
            },
          ),
          const Divider(color: AppColors.divider, height: 1),
          _buildLogoutTile(context),
        ],
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing.isNotEmpty)
            Flexible(
              child: Text(
                trailing,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right,
              size: 18, color: AppColors.textSecondary),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    final isLoggedIn =
        AuthService.instance.isLoggedIn && !AuthService.instance.isGuest;

    return ListTile(
      leading: Icon(
        isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
        color: isLoggedIn ? AppColors.error : AppColors.primary,
        size: 22,
      ),
      title: Text(
        isLoggedIn ? 'Đăng xuất' : 'Đăng nhập tài khoản',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isLoggedIn ? AppColors.error : AppColors.primary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right,
          size: 18, color: AppColors.textSecondary),
      onTap: () async {
        if (isLoggedIn) {
          await AuthService.instance.signOut();
        }
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      },
    );
  }
}