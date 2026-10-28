import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/models/booking.dart';
import '../../../../core/theme/app_colors.dart';
import '../../booking/screens/slot_booking_screen.dart';
import 'booking_detail_qr_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ============================================================
  // HỦY BOOKING
  // ============================================================
  Future<void> _handleCancelBooking(Booking booking) async {
    if (!MockData.canCancelBooking(booking)) {
      _showCannotCancelSnackBar();
      return;
    }

    final isPending = booking.status == BookingStatus.pending;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isPending ? 'Hủy yêu cầu đặt sân?' : 'Hủy lịch đặt sân?',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Text(
          isPending
              ? 'Bạn chắc chắn muốn hủy yêu cầu đặt sân ${booking.id} tại ${booking.venue.name}?\n\nKhung giờ này sẽ được mở lại cho người khác.'
              : 'Bạn chắc chắn muốn hủy lịch ${booking.id} tại ${booking.venue.name}?\n\n'
                  'Lưu ý: Hủy nhiều lần có thể ảnh hưởng đến trải nghiệm đặt sân của bạn.',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Giữ lịch',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Xác nhận hủy',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final resultCode = MockData.cancelBooking(booking.id);

    if (!mounted) return;

    switch (resultCode) {
      case 0:
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy lịch đặt sân thành công'),
            backgroundColor: AppColors.primaryDark,
          ),
        );
        break;
      case 3:
        _showCannotCancelSnackBar();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể hủy lịch này'),
            backgroundColor: AppColors.error,
          ),
        );
    }
  }

  void _showCannotCancelSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Không thể hủy. Chỉ hủy được trước 3 tiếng so với giờ chơi.',
        ),
        backgroundColor: AppColors.error,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _handleRebook(Booking booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SlotBookingScreen(venue: booking.venue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###', 'vi_VN');

    // Tự động quét và đánh dấu quá hạn duyệt các đơn pending đã qua giờ chơi
    MockData.checkAndExpirePendingBookings();

    // Lấy user hiện tại (nếu null → fallback user_1)
    final currentUserId = MockData.currentUser?.id ?? 'user_1';
    final customerBookings = MockData.getBookingsForCustomer(currentUserId);

    // Tab "Sắp diễn ra": pending + upcoming
    final upcomingBookings = customerBookings
        .where((b) =>
    b.status == BookingStatus.pending ||
        b.status == BookingStatus.upcoming)
        .toList();

    // Tab "Lịch sử": completed + cancelled + rejected + noShow
    final pastBookings = customerBookings
        .where((b) =>
    b.status != BookingStatus.pending &&
        b.status != BookingStatus.upcoming)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lịch Đặt Sân Của Tôi'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle:
          const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          unselectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          tabs: [
            Tab(text: 'Sắp diễn ra (${upcomingBookings.length})'),
            Tab(text: 'Lịch sử (${pastBookings.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList(upcomingBookings, currencyFormat,
              isUpcoming: true),
          _buildBookingList(pastBookings, currencyFormat, isUpcoming: false),
        ],
      ),
    );
  }

  Widget _buildBookingList(
      List<Booking> bookings,
      NumberFormat currencyFormat, {
        required bool isUpcoming,
      }) {
    if (bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Center(
              child: Column(
                children: [
                  Icon(
                    isUpcoming
                        ? Icons.event_available_outlined
                        : Icons.history_outlined,
                    size: 72,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isUpcoming
                        ? 'Bạn chưa có lịch đặt sân nào sắp tới'
                        : 'Chưa có lịch sử đặt sân nào',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isUpcoming
                        ? 'Khám phá các sân thể thao gần bạn ngay!'
                        : 'Các lịch đã hoàn thành, bị từ chối hoặc đã hủy sẽ xuất hiện ở đây.',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingCard(booking, currencyFormat,
              isUpcoming: isUpcoming);
        },
      ),
    );
  }

  Widget _buildBookingCard(
      Booking booking,
      NumberFormat currencyFormat, {
        required bool isUpcoming,
      }) {
    final statusColor = _getStatusColor(booking.status);
    final statusBg = _getStatusBgColor(booking.status);
    final canCancel = MockData.canCancelBooking(booking);
    final isPending = booking.status == BookingStatus.pending;
    final isRejected = booking.status == BookingStatus.rejected;
    final isNoShow = booking.status == BookingStatus.noShow;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Sport icon + ID + Status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(booking.venue.sportType.icon,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          booking.id,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    booking.status.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Venue + subCourt
            Text(
              booking.venue.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              booking.subCourt.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: AppColors.divider, height: 1),
            ),

            // Date + Time
            Row(
              children: [
                const Icon(Icons.calendar_month,
                    size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  DateFormat('dd/MM/yyyy').format(booking.bookingDate),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 14),
                const Icon(Icons.access_time,
                    size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    booking.selectedSlots.map((s) => s.startTime).join(', '),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Lý do từ chối (nếu có)
            if (isRejected && booking.rejectReason != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16, color: AppColors.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Lý do từ chối: ${booking.rejectReason}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Cảnh báo no-show
            if (isNoShow) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber,
                        size: 16, color: AppColors.peakHour),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Bạn đã không đến nhận sân. Tài khoản đã ghi nhận vi phạm.',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.peakHour),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Price + Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${currencyFormat.format(booking.finalAmount)} đ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _buildActionButtons(
                    booking,
                    isUpcoming: isUpcoming,
                    canCancel: canCancel,
                    isPending: isPending,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      Booking booking, {
        required bool isUpcoming,
        required bool canCancel,
        required bool isPending,
      }) {
    // Tab "Sắp diễn ra"
    if (isUpcoming) {
      // Booking pending → hiển thị badge "Đang chờ duyệt" + Nút Hủy yêu cầu
      if (isPending) {
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.peakHourLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.hourglass_top, size: 14, color: AppColors.peakHour),
                  SizedBox(width: 4),
                  Text(
                    'Chờ chủ sân duyệt',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.peakHour,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () => _handleCancelBooking(booking),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Hủy yêu cầu',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      }

      // Booking upcoming → Hủy + QR
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          canCancel
              ? OutlinedButton(
            onPressed: () => _handleCancelBooking(booking),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Hủy lịch',
              style:
              TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          )
              : OutlinedButton.icon(
            onPressed: _showCannotCancelSnackBar,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textMuted,
              side: const BorderSide(color: AppColors.border),
              backgroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.lock_outline, size: 13),
            label: const Text(
              'Không thể hủy',
              style:
              TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingDetailQrScreen(booking: booking),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.qr_code_rounded, size: 15),
            label: const Text('Mã QR',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      );
    }

    // Tab "Lịch sử" → chỉ có nút "Đặt lại"
    return ElevatedButton.icon(
      onPressed: () => _handleRebook(booking),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.primaryDark,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.refresh_rounded, size: 15),
      label: const Text('Đặt lại',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  // ============================================================
  // MÀU THEO STATUS (đủ 6 case, không lỗi)
  // ============================================================
  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.peakHour;
      case BookingStatus.upcoming:
        return AppColors.primaryDark;
      case BookingStatus.completed:
        return const Color(0xFF1976D2);
      case BookingStatus.cancelled:
        return AppColors.textSecondary;
      case BookingStatus.rejected:
        return AppColors.error;
      case BookingStatus.noShow:
        return AppColors.peakHour;
    }
  }

  Color _getStatusBgColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.peakHourLight;
      case BookingStatus.upcoming:
        return AppColors.primaryLight;
      case BookingStatus.completed:
        return const Color(0xFFE3F2FD);
      case BookingStatus.cancelled:
        return AppColors.background;
      case BookingStatus.rejected:
        return const Color(0xFFFFEBEE);
      case BookingStatus.noShow:
        return const Color(0xFFFFF3E0);
    }
  }
}