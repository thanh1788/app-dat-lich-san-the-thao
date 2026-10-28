import 'package:flutter/material.dart';
import 'core/mock/mock_data.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/services/auth_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/my_bookings/screens/my_bookings_screen.dart';
import 'features/owner_dashboard/screens/owner_dashboard_screen.dart';
import 'features/profile/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);
  await MockData.loadBookingsFromStorage();
  await MockData.debugPrintStorage();
  runApp(const SportBookingApp());
}

class SportBookingApp extends StatelessWidget {
  const SportBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sport6h50 - Đặt Lịch Sân Thể Thao',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: AuthService.instance.isLoggedIn
          ? const MainNavigationScreen()
          : const LoginScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentTabIndex = 0;
  bool _isOwnerMode = false;

  void _toggleOwnerMode(bool enable) {
    setState(() {
      _isOwnerMode = enable;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enable
              ? 'Đã chuyển sang chế độ Quản lý Chủ Sân'
              : 'Đã quay lại chế độ Khách Đặt Sân',
        ),
        backgroundColor: AppColors.primaryDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isOwnerMode) {
      return OwnerDashboardScreen(
        onSwitchToCustomerMode: () => _toggleOwnerMode(false),
      );
    }

    final screens = [
      HomeScreen(
        onSwitchToOwnerMode: () => _toggleOwnerMode(true),
      ),
      const MyBookingsScreen(),
      ProfileScreen(
        isOwnerMode: _isOwnerMode,
        onToggleOwnerMode: _toggleOwnerMode,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentTabIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border:
          const Border(top: BorderSide(color: AppColors.border, width: 1)),
          boxShadow: AppColors.softShadow,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: (index) {
            setState(() {
              _currentTabIndex = index;
            });
          },
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          unselectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Khám phá',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Lịch đặt',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Tài khoản',
            ),
          ],
        ),
      ),
    );
  }
}