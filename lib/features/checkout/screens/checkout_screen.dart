import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/models/booking.dart';
import '../../../../core/models/time_slot.dart';
import '../../../../core/models/venue.dart';
import '../../../../core/theme/app_colors.dart';
import '../../my_bookings/screens/booking_detail_qr_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Venue venue;
  final SubCourt subCourt;
  final DateTime bookingDate;
  final List<TimeSlot> selectedSlots;
  final double totalPrice;

  const CheckoutScreen({
    super.key,
    required this.venue,
    required this.subCourt,
    required this.bookingDate,
    required this.selectedSlots,
    required this.totalPrice,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _couponController = TextEditingController();
  double _discountAmount = 0;
  String? _appliedCoupon;
  String _selectedPaymentMethod = 'cash';
  bool _isProcessing = false;

  void _applyCoupon() {
    final code = _couponController.text.trim().toUpperCase();
    if (code == 'SPORT6H50') {
      setState(() {
        _discountAmount = widget.totalPrice * 0.10;
        _appliedCoupon = code;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Áp dụng mã SPORT6H50 thành công! Giảm 10%'),
          backgroundColor: AppColors.primary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mã giảm giá không hợp lệ (Thử: SPORT6H50)'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handlePayment() async {
    // ==== CHECK GIỜ QUÁ HẠN ====
    final now = DateTime.now();
    final isToday = widget.bookingDate.year == now.year &&
        widget.bookingDate.month == now.month &&
        widget.bookingDate.day == now.day;
    final hasPastSlot = isToday &&
        widget.selectedSlots.any((s) {
          final parts = s.startTime.split(':');
          if (parts.length < 2) return false;
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;
          final slotTime = DateTime(now.year, now.month, now.day, hour, minute);
          return slotTime.isBefore(now);
        });

    if (hasPastSlot) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Có khung giờ đã qua thời gian bắt đầu. Vui lòng chọn lại.'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // ==== CHECK TRÙNG SLOT ====
    final hasConflict = widget.selectedSlots.any((newSlot) =>
        MockData.isSlotOccupied(
          subCourtId: newSlot.subCourtId,
          date: widget.bookingDate,
          startTime: newSlot.startTime,
        ));

    if (hasConflict) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Khung giờ này đã có người đặt. Vui lòng chọn giờ khác.'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    final currentUser = MockData.currentUser;

    final bookingId =
        'BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final newBooking = Booking(
      id: bookingId,
      venue: widget.venue,
      subCourt: widget.subCourt,
      bookingDate: widget.bookingDate,
      selectedSlots: widget.selectedSlots,
      totalPrice: widget.totalPrice,
      discountAmount: _discountAmount,
      finalAmount: widget.totalPrice - _discountAmount,
      paymentMethod: _selectedPaymentMethod == 'cash'
          ? 'Thanh toán tại sân'
          : (_selectedPaymentMethod == 'vnpay'
          ? 'VNPay-QR'
          : 'Chuyển khoản VietQR'),
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
      qrCodeData:
      'SPORT6H50_CHECKIN_${bookingId}_${widget.subCourt.id}_VERIFIED',
      customerId: currentUser?.id ?? 'user_1',
      customerName: currentUser?.fullName ?? 'Nguyễn Văn A',
      customerPhone: currentUser?.phone ?? '0909 123 456',
      ownerId: widget.venue.ownerId,
    );

    MockData.userBookings.insert(0, newBooking);
    await MockData.persistBookings();

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailQrScreen(booking: newBooking),
      ),
    );
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###', 'vi_VN');
    final finalPrice = widget.totalPrice - _discountAmount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Xác nhận & Thanh toán'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // VENUE SUMMARY
            Container(
              padding: const EdgeInsets.all(16),
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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(widget.venue.sportType.icon,
                            style: const TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.venue.name,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.subCourt.name,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: AppColors.divider, height: 1),
                  ),
                  _buildSummaryRow(
                    Icons.calendar_today,
                    'Ngày thi đấu',
                    DateFormat('EEEE, dd/MM/yyyy', 'vi')
                        .format(widget.bookingDate),
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    Icons.access_time_rounded,
                    'Khung giờ (${widget.selectedSlots.length} slot)',
                    widget.selectedSlots.map((s) => s.timeRange).join(', '),
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    Icons.place_outlined,
                    'Địa chỉ',
                    '${widget.venue.address}, ${widget.venue.district}',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // CUSTOMER INFO
            Builder(
              builder: (context) {
                final user = MockData.currentUser;
                if (user == null) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin người đặt',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.person,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(user.fullName,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.phone,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(user.phone,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            // COUPON
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mã ưu đãi / Khuyến mãi',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: TextField(
                            controller: _couponController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              hintText: 'Nhập mã (Gợi ý: SPORT6H50)',
                              hintStyle: TextStyle(
                                  fontSize: 12, color: AppColors.textMuted),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _applyCoupon,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.primaryDark,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Áp dụng',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ],
                  ),
                  if (_appliedCoupon != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Đã áp dụng mã $_appliedCoupon (-10%)',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // PAYMENT METHOD
            const Text(
              'Phương thức thanh toán',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildPaymentRadio(
                    'cash',
                    'Thanh toán tại sân (Khuyến nghị)',
                    'Trả tiền mặt/chuyển khoản sau khi chơi xong',
                    '💵',
                  ),
                  const Divider(color: AppColors.divider, height: 1),
                  _buildPaymentRadio(
                    'vnpay',
                    'Cổng Thanh Toán VNPay',
                    'Hỗ trợ thẻ ATM & 40+ ngân hàng',
                    '🔵',
                  ),
                  const Divider(color: AppColors.divider, height: 1),
                  _buildPaymentRadio(
                    'vietqr',
                    'Chuyển Khoản Nhanh VietQR',
                    'Quét mã QR chuyển khoản tự động 24/7',
                    '🟢',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // PRICE BREAKDOWN
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildPriceRow('Tạm tính tiền sân',
                      '${currencyFormat.format(widget.totalPrice)} đ'),
                  const SizedBox(height: 8),
                  _buildPriceRow('Phí dịch vụ đặt sân', 'Miễn phí'),
                  if (_discountAmount > 0) ...[
                    const SizedBox(height: 8),
                    _buildPriceRow(
                      'Giảm giá khuyến mãi',
                      '-${currencyFormat.format(_discountAmount)} đ',
                      isDiscount: true,
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: AppColors.divider, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng thanh toán',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${currencyFormat.format(finalPrice)} đ',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // NOTICE
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.peakHourLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.peakHour.withValues(alpha: 0.3)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppColors.peakHour),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sau khi đặt, chủ sân sẽ xem và xác nhận lịch của bạn. '
                          'Vui lòng đến đúng giờ để tránh bị ghi nhận vi phạm.',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.peakHour,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: AppColors.softShadow,
        ),
        child: SafeArea(
          top: false,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _handlePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isProcessing
                ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                ),
                SizedBox(width: 12),
                Text('Đang xử lý đơn đặt sân...',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.send_rounded, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Gửi yêu cầu đặt sân (${currencyFormat.format(finalPrice)} đ)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRadio(
      String value, String title, String subtitle, String icon) {
    final isSelected = _selectedPaymentMethod == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight.withValues(alpha: 0.4)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String title, String amount,
      {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          amount,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDiscount ? AppColors.primaryDark : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}