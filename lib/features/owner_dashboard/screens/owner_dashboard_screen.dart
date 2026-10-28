import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/models/booking.dart';
import '../../../../core/models/court.dart';
import '../../../../core/models/time_slot.dart';
import '../../../../core/models/venue.dart';
import '../../../../core/services/court_api_service.dart';
import '../../../../core/theme/app_colors.dart';

class OwnerDashboardScreen extends StatefulWidget {
  final VoidCallback onSwitchToCustomerMode;

  const OwnerDashboardScreen({super.key, required this.onSwitchToCustomerMode});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String get _currentOwnerId => MockData.currentOwnerId;

  List<Court> _apiCourts = [];
  bool _isLoadingApiCourts = false;

  final List<String> _timeLabels = [
    '06:00', '07:00', '08:00', '09:00', '10:00', '11:00',
    '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadApiCourts();
  }

  Future<void> _loadApiCourts() async {
    setState(() => _isLoadingApiCourts = true);
    try {
      final courts = await CourtApiService.instance.fetchCourts();
      if (mounted) {
        setState(() {
          _apiCourts = courts;
          _isLoadingApiCourts = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingApiCourts = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MockData.checkAndExpirePendingBookings();
    final ownerVenues = MockData.venues
        .where((v) => v.ownerId == _currentOwnerId)
        .toList();
    final venue = ownerVenues.isNotEmpty
        ? ownerVenues.first
        : MockData.venues.first;

    final pendingBookings =
    MockData.getPendingBookingsForOwner(_currentOwnerId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quản Lý Chủ Sân',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            Text(
              venue.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: widget.onSwitchToCustomerMode,
              icon: const Icon(Icons.person_outline,
                  size: 16, color: AppColors.primaryDark),
              label: const Text(
                'Khách đặt',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle:
          const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: [
            const Tab(text: 'Tổng quan'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Flexible(
                    child: Text(
                      'Chờ duyệt',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (pendingBookings.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${pendingBookings.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Sân API REST'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(venue),
          _buildPendingTab(pendingBookings),
          _buildApiCourtsTab(),
        ],
      ),
    );
  }

  // ==================== TAB 1: TỔNG QUAN ====================
  Widget _buildOverviewTab(Venue venue) {
    final now = DateTime.now();
    final todayBookings = MockData.userBookings.where((b) {
      final isSameVenue = b.venue.id == venue.id;
      final isSameDay = b.bookingDate.year == now.year &&
          b.bookingDate.month == now.month &&
          b.bookingDate.day == now.day;
      return isSameVenue && isSameDay;
    }).toList();

    final currencyFormat = NumberFormat('#,###', 'vi_VN');

    // Doanh thu hôm nay (chỉ tính đơn sắp diễn ra hoặc đã hoàn thành)
    final confirmedBookings = todayBookings.where((b) =>
        b.status == BookingStatus.upcoming || b.status == BookingStatus.completed);
    final todayRevenue = confirmedBookings.fold<double>(
        0, (sum, b) => sum + b.finalAmount);
    final todayBookingsCount = confirmedBookings.length;

    // Tỷ lệ lấp đầy sân hôm nay
    final totalSlots = venue.subCourts.length * _timeLabels.length;
    final activeBookings = todayBookings.where((b) =>
        b.isSlotOccupying || b.status == BookingStatus.completed);
    int bookedSlotsCount = 0;
    for (final b in activeBookings) {
      bookedSlotsCount += b.selectedSlots.length;
    }
    if (bookedSlotsCount > totalSlots) bookedSlotsCount = totalSlots;
    final occupancyPercent = totalSlots > 0
        ? ((bookedSlotsCount / totalSlots) * 100).round()
        : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF90CAF9)),
            ),
            child: const Row(
              children: [
                Icon(Icons.admin_panel_settings,
                    color: Color(0xFF1976D2), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bạn đang xem chế độ Chủ Sân (Quản lý lịch & nhận khách)',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D47A1)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Doanh thu hôm nay',
                  '${currencyFormat.format(todayRevenue)} đ',
                  '$todayBookingsCount lượt đặt hôm nay',
                  Icons.payments_outlined,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Tỷ lệ lấp đầy sân',
                  '$occupancyPercent%',
                  '$bookedSlotsCount/$totalSlots slot đã đặt',
                  Icons.pie_chart_outline,
                  const Color(0xFF00B4D8),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Timeline Lịch Đặt Hôm Nay',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  _showAddOfflineBookingDialog(context, venue);
                },
                icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                label: const Text(
                  'Đặt chỗ offline',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: AppColors.softShadow,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _buildStatusDot('Chờ duyệt', AppColors.peakHour),
                      _buildStatusDot('Đã đặt App', AppColors.primary),
                      _buildStatusDot(
                          'Đặt qua Phone', const Color(0xFF00B4D8)),
                      _buildStatusDot('Đã check-in', AppColors.textMuted),
                      _buildStatusDot('Còn trống', AppColors.border),
                    ],
                  ),
                ),
                const Divider(color: AppColors.divider, height: 1),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 80),
                            ..._timeLabels.map(
                                  (time) => Container(
                                width: 60,
                                alignment: Alignment.center,
                                child: Text(
                                  time,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...venue.subCourts.map((court) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    court.name,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                ..._timeLabels.asMap().entries.map((entry) {
                                  final timeStr = entry.value;

                                  // Tìm booking thực tế cho slot này
                                  Booking? slotBooking;
                                  for (final b in todayBookings) {
                                    if (b.subCourt.id == court.id &&
                                        b.selectedSlots.any((s) => s.startTime == timeStr)) {
                                      if (b.isSlotOccupying ||
                                          b.status == BookingStatus.completed ||
                                          b.status == BookingStatus.noShow) {
                                        slotBooking = b;
                                        break;
                                      }
                                    }
                                  }

                                  Color slotColor;
                                  String label;

                                  if (slotBooking == null) {
                                    slotColor = AppColors.background;
                                    label = '';
                                  } else if (slotBooking.status == BookingStatus.pending) {
                                    slotColor = AppColors.peakHour;
                                    label = 'Chờ';
                                  } else if (slotBooking.status == BookingStatus.completed) {
                                    slotColor = AppColors.textMuted;
                                    label = 'Đã đến';
                                  } else if (slotBooking.status == BookingStatus.noShow) {
                                    slotColor = AppColors.error;
                                    label = 'Vắng';
                                  } else if (slotBooking.isOffline) {
                                    slotColor = const Color(0xFF00B4D8);
                                    label = 'Phone';
                                  } else {
                                    slotColor = AppColors.primary;
                                    label = 'App';
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      if (slotBooking == null) {
                                        _showAddOfflineBookingDialog(
                                          context,
                                          venue,
                                          subCourt: court,
                                          time: timeStr,
                                        );
                                      } else {
                                        _showBookingActionDialog(context, slotBooking);
                                      }
                                    },
                                    child: Container(
                                      width: 54,
                                      height: 38,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 3),
                                      decoration: BoxDecoration(
                                        color: slotColor,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: slotColor ==
                                              AppColors.background
                                              ? AppColors.border
                                              : Colors.transparent,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          label,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: slotColor ==
                                                AppColors.background
                                                ? AppColors.textMuted
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: () {
              _showQrCheckInDialog(context, venue);
            },
            icon: const Icon(Icons.qr_code_scanner, size: 20),
            label: const Text('Quét mã nhận sân của khách',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 2: CHỜ DUYỆT ====================
  Widget _buildPendingTab(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 72, color: AppColors.textMuted),
            const SizedBox(height: 16),
            const Text(
              'Không có booking nào chờ duyệt',
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    final currencyFormat = NumberFormat('#,###', 'vi_VN');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.peakHour, width: 1.5),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(booking.venue.sportType.icon,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        booking.id,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.peakHourLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Chờ duyệt',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.peakHour),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(Icons.person,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      booking.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.phone,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    booking.customerPhone,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Text(
                booking.venue.name,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                booking.subCourt.name,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(Icons.calendar_month,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(booking.bookingDate),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.access_time,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      booking.selectedSlots
                          .map((s) => s.timeRange)
                          .join(', '),
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Tổng: ${currencyFormat.format(booking.finalAmount)} đ',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: AppColors.divider, height: 1),
              ),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleReject(booking),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Từ chối'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleApprove(booking),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Duyệt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== ACTIONS ====================
  Future<void> _handleApprove(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Duyệt booking?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(
          'Bạn xác nhận duyệt booking ${booking.id} của ${booking.customerName}?',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Hủy',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Duyệt'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final ok = MockData.approveBooking(booking.id);
    if (!mounted) return;

    if (ok) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã duyệt booking thành công'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _handleReject(Booking booking) async {
    String? reason = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => _RejectDialog(booking: booking),
    );

    if (reason == null) return;

    final ok = MockData.rejectBooking(booking.id, reason);
    if (!mounted) return;

    if (ok) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã từ chối booking'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleCheckIn(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận Check-in',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(
          'Xác nhận khách ${booking.customerName} đã đến nhận sân (${booking.subCourt.name} lúc ${booking.selectedSlots.map((s) => s.startTime).join(", ")})?',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Hủy',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Check-in ngay'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final ok = MockData.checkInBooking(booking.id);
    if (!mounted) return;

    if (ok) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Khách ${booking.customerName} đã nhận sân thành công!'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _handleNoShow(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Báo vắng mặt (No-show)?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(
          'Xác nhận khách ${booking.customerName} không đến nhận sân (${booking.subCourt.name} lúc ${booking.selectedSlots.map((s) => s.startTime).join(", ")})?',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Quay lại',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xác nhận vắng mặt'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final ok = MockData.reportNoShow(booking.id);
    if (!mounted) return;

    if (ok) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã ghi nhận khách vắng mặt (No-show)'),
          backgroundColor: AppColors.peakHour,
        ),
      );
    }
  }

  // ==================== WIDGETS ====================
  Widget _buildMetricCard(String title, String value, String subValue,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 4),
          Text(subValue,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStatusDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  void _showBookingActionDialog(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Text(booking.venue.sportType.icon,
                style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Lịch: ${booking.id}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                const Icon(Icons.person,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(booking.customerName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.phone,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(booking.customerPhone,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.sports_tennis,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${booking.subCourt.name} (${booking.selectedSlots.map((s) => s.timeRange).join(", ")})',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.payment,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  '${NumberFormat('#,###', 'vi_VN').format(booking.finalAmount)} đ (${booking.paymentMethod})',
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: booking.status == BookingStatus.pending
                    ? AppColors.peakHourLight
                    : (booking.status == BookingStatus.upcoming
                        ? AppColors.primaryLight
                        : (booking.status == BookingStatus.completed
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFEBEE))),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Trạng thái: ${booking.status.label}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: booking.status == BookingStatus.pending
                      ? AppColors.peakHour
                      : (booking.status == BookingStatus.upcoming
                          ? AppColors.primaryDark
                          : (booking.status == BookingStatus.completed
                              ? const Color(0xFF2E7D32)
                              : AppColors.error)),
                ),
              ),
            ),
          ],
        ),
      ),
      actionsOverflowButtonSpacing: 8,
      actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
          if (booking.status == BookingStatus.pending) ...[
            OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _handleReject(booking);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              child: const Text('Từ chối'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _handleApprove(booking);
              },
              child: const Text('Duyệt ngay'),
            ),
          ],
          if (booking.status == BookingStatus.upcoming) ...[
            OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _handleNoShow(booking);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              child: const Text('Báo vắng mặt'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _handleCheckIn(booking);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Check-in'),
            ),
          ],
        ],
      ),
    );
  }

  void _showQrCheckInDialog(BuildContext context, Venue venue) {
    final codeController = TextEditingController();
    final now = DateTime.now();
    final todayBookings = MockData.userBookings.where((b) {
      final isSameVenue = b.venue.id == venue.id;
      final isSameDay = b.bookingDate.year == now.year &&
          b.bookingDate.month == now.month &&
          b.bookingDate.day == now.day;
      return isSameVenue && isSameDay && b.status == BookingStatus.upcoming;
    }).toList();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Quét mã QR Check-in',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.qr_code_scanner_rounded,
                    size: 64, color: AppColors.primary),
                const SizedBox(height: 10),
                const Text(
                  'Nhập mã booking hoặc mã QR của khách:',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: codeController,
                  decoration: InputDecoration(
                    hintText: 'VD: BK-89321',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => codeController.clear(),
                    ),
                  ),
                ),
                if (todayBookings.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Khách sắp nhận sân hôm nay:',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 140),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: todayBookings.length,
                      separatorBuilder: (c, i) => const Divider(height: 1),
                      itemBuilder: (c, i) {
                        final b = todayBookings[i];
                        return ListTile(
                          dense: true,
                          title: Text('${b.customerName} (${b.id})',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                          subtitle: Text(
                              '${b.subCourt.name} - ${b.selectedSlots.map((s) => s.startTime).join(", ")}',
                              style: const TextStyle(fontSize: 11)),
                          trailing: ElevatedButton(
                            onPressed: () {
                              codeController.text = b.id;
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Chọn',
                                style: TextStyle(fontSize: 11)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Đóng'),
            ),
            ElevatedButton(
              onPressed: () {
                final query = codeController.text.trim().toUpperCase();
                if (query.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập hoặc chọn mã booking'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                final foundIndex = MockData.userBookings.indexWhere((b) =>
                    b.id.toUpperCase() == query ||
                    b.qrCodeData.toUpperCase().contains(query));

                if (foundIndex == -1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Không tìm thấy booking hợp lệ với mã này'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                final targetBooking = MockData.userBookings[foundIndex];
                if (targetBooking.status == BookingStatus.completed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking này đã được check-in trước đó'),
                      backgroundColor: AppColors.peakHour,
                    ),
                  );
                  return;
                }

                if (targetBooking.status == BookingStatus.pending) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Booking này đang chờ duyệt, chưa thể check-in'),
                      backgroundColor: AppColors.peakHour,
                    ),
                  );
                  return;
                }

                if (targetBooking.status == BookingStatus.cancelled ||
                    targetBooking.status == BookingStatus.rejected) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking này đã bị hủy hoặc từ chối'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                MockData.checkInBooking(targetBooking.id);
                Navigator.pop(dialogCtx);
                if (mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Check-in thành công cho khách ${targetBooking.customerName}!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              },
              child: const Text('Xác nhận Check-in'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOfflineBookingDialog(
    BuildContext context,
    Venue venue, {
    SubCourt? subCourt,
    String? time,
  }) {
    SubCourt selectedSubCourt = subCourt ??
        (venue.subCourts.isNotEmpty
            ? venue.subCourts.first
            : venue.subCourts[0]);
    String selectedTime = time ?? _timeLabels.first;
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Nhận đặt sân qua điện thoại',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<SubCourt>(
                  initialValue: selectedSubCourt,
                  decoration: const InputDecoration(
                    labelText: 'Chọn sân con',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: venue.subCourts
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c.name)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedSubCourt = val);
                    }
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: selectedTime,
                  decoration: const InputDecoration(
                    labelText: 'Khung giờ bắt đầu',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: _timeLabels
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedTime = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên người đặt',
                    hintText: 'VD: Anh Tuấn (Cầu lông)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    hintText: '090xxxxxxx',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final customerName = nameController.text.trim();
                final customerPhone = phoneController.text.trim();
                if (customerName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập tên người đặt'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                if (customerPhone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập số điện thoại'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                final parts = selectedTime.split(':');
                final startHour = int.parse(parts[0]);
                final endHour = (startHour + 1).toString().padLeft(2, '0');
                final endTime = '$endHour:${parts[1]}';
                final slot = TimeSlot(
                  id: 'slot_offline_${selectedSubCourt.id}_$selectedTime',
                  subCourtId: selectedSubCourt.id,
                  startTime: selectedTime,
                  endTime: endTime,
                  price: selectedSubCourt.basePrice,
                  isPeakHour: (startHour >= 17 && startHour <= 21),
                );

                final now = DateTime.now();
                final bookingDate = DateTime(now.year, now.month, now.day);

                final newBooking = await MockData.createOfflineBooking(
                  venue: venue,
                  subCourt: selectedSubCourt,
                  bookingDate: bookingDate,
                  slot: slot,
                  customerName: customerName,
                  customerPhone: customerPhone,
                );

                if (!dialogCtx.mounted) return;
                Navigator.pop(dialogCtx);

                if (!mounted) return;
                if (newBooking == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Khung giờ này đã có người đặt trước!'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                } else {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Đã đặt lịch thành công cho $customerName lúc $selectedTime!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              },
              child: const Text('Lưu lịch'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TAB 3: QUẢN LÝ SÂN API REST ====================
  Widget _buildApiCourtsTab() {
    final currencyFormat = NumberFormat('#,###', 'vi_VN');

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadApiCourts,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color:
                              AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.cloud_sync_rounded,
                                color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'REST API Server',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'ONLINE',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Endpoint: https://api-app-stt.onrender.com/api/courts',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddCourtDialog(),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Thêm Sân Mới (POST)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _loadApiCourts,
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        tooltip: 'Tải lại danh sách (GET)',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Danh sách sân từ API (${_apiCourts.length})',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                if (_isLoadingApiCourts)
                  const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 12),

            if (_apiCourts.isEmpty && !_isLoadingApiCourts)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.inbox_outlined,
                        size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    const Text('Chưa có sân nào trên API',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextButton(
                        onPressed: _showAddCourtDialog,
                        child:
                        const Text('Bấm vào đây để thêm sân đầu tiên')),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _apiCourts.length,
                separatorBuilder: (context, index) =>
                const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final court = _apiCourts[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text('#${court.id}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryDark,
                                        fontSize: 13)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    court.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 3),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondary
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                          BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          court.sportType,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.secondary),
                                        ),
                                      ),

                                      Text(
                                        '${currencyFormat.format(court.pricePerHour)} đ/giờ',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primaryDark),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                court.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 18, color: AppColors.divider),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showEditCourtDialog(court),
                              icon: const Icon(Icons.edit_outlined,
                                  size: 16, color: AppColors.primary),
                              label: const Text('Sửa (PUT)',
                                  style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _confirmDeleteCourt(court),
                              icon: const Icon(Icons.delete_outline,
                                  size: 16, color: AppColors.error),
                              label: const Text('Xóa (DELETE)',
                                  style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showAddCourtDialog() {
    final nameController = TextEditingController(text: 'Sân Cầu Lông Số 5');
    final sportController = TextEditingController(text: 'Badminton');
    final priceController = TextEditingController(text: '150000');
    final addressController =
    TextEditingController(text: 'Quận 10, TP. Hồ Chí Minh');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Thêm Sân Mới (POST /api/courts)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: 'Tên sân thể thao',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: sportController,
                decoration: const InputDecoration(
                    labelText: 'Môn thể thao (Badminton, Football...)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Giá thuê / Giờ (VNĐ)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                    labelText: 'Địa chỉ sân', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final sport = sportController.text.trim();
              final price =
                  double.tryParse(priceController.text.trim()) ?? 120000;
              final addr = addressController.text.trim();
              if (name.isEmpty) return;

              Navigator.pop(ctx);
              final created = await CourtApiService.instance.createCourt(
                name: name,
                sportType: sport,
                pricePerHour: price,
                address: addr,
              );
              if (created != null) {
                _loadApiCourts();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Đã thêm sân "${created.name}" thành công!'),
                        backgroundColor: AppColors.primary),
                  );
                }
              }
            },
            style:
            ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Thêm mới'),
          ),
        ],
      ),
    );
  }

  void _showEditCourtDialog(Court court) {
    final nameController = TextEditingController(text: court.name);
    final sportController = TextEditingController(text: court.sportType);
    final priceController =
    TextEditingController(text: court.pricePerHour.toInt().toString());
    final addressController = TextEditingController(text: court.address);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Sửa sân #${court.id} (PUT /api/courts/${court.id})',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: 'Tên sân thể thao',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: sportController,
                decoration: const InputDecoration(
                    labelText: 'Môn thể thao',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Giá thuê / Giờ (VNĐ)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                    labelText: 'Địa chỉ', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final sport = sportController.text.trim();
              final price = double.tryParse(priceController.text.trim()) ??
                  court.pricePerHour;
              final addr = addressController.text.trim();

              Navigator.pop(ctx);
              final success = await CourtApiService.instance.updateCourt(
                id: court.id,
                name: name,
                sportType: sport,
                pricePerHour: price,
                address: addr,
              );
              if (success) {
                _loadApiCourts();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Đã cập nhật sân #${court.id} thành công!'),
                        backgroundColor: AppColors.primary),
                  );
                }
              }
            },
            style:
            ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCourt(Court court) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa sân',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(
            'Bạn có chắc chắn muốn xóa sân "${court.name}" (DELETE /api/courts/${court.id})?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await CourtApiService.instance.deleteCourt(court.id);
              _loadApiCourts();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Đã xóa sân "${court.name}" thành công!'),
                      backgroundColor: AppColors.error),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xác nhận xóa'),
          ),
        ],
      ),
    );
  }
}

// ==================== DIALOG TỪ CHỐI ====================
class _RejectDialog extends StatefulWidget {
  final Booking booking;
  const _RejectDialog({required this.booking});

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Từ chối booking',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking ${widget.booking.id} của ${widget.booking.customerName}',
              style:
              const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            const Text(
              'Lý do từ chối:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'VD: Khách quen đã đặt trước khung giờ này...',
                hintStyle:
                TextStyle(fontSize: 12, color: AppColors.textMuted),
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            final reason = _reasonController.text.trim();
            if (reason.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vui lòng nhập lý do từ chối'),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }
            Navigator.pop(context, reason);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Xác nhận từ chối'),
        ),
      ],
    );
  }
}