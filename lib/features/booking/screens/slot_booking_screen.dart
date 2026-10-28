import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/models/venue.dart';
import '../../../../core/models/time_slot.dart';
import '../../../../core/theme/app_colors.dart';
import '../../checkout/screens/checkout_screen.dart';

class SlotBookingScreen extends StatefulWidget {
  final Venue venue;

  const SlotBookingScreen({super.key, required this.venue});

  @override
  State<SlotBookingScreen> createState() => _SlotBookingScreenState();
}

class _SlotBookingScreenState extends State<SlotBookingScreen>
    with WidgetsBindingObserver {
  late DateTime _selectedDate;
  late SubCourt _selectedSubCourt;
  final Set<String> _selectedSlotIds = {};
  late List<TimeSlot> _currentCourtSlots;

  final List<DateTime> _upcomingDates = List.generate(
    14,
        (index) => DateTime.now().add(Duration(days: index)),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedDate = _upcomingDates.first;
    _selectedSubCourt = widget.venue.subCourts.first;
    _loadSlotsForCourt();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Khi app quay lại foreground → reload slot để cập nhật trạng thái
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() {
        _loadSlotsForCourt();
      });
    }
  }

  void _loadSlotsForCourt() {
    _selectedSlotIds.clear();
    _currentCourtSlots = MockData.generateSlotsForCourt(
      _selectedSubCourt.id,
      _selectedSubCourt.basePrice,
    );
  }

  bool _isSlotPast(TimeSlot slot) {
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
    if (!isToday) return false;

    final parts = slot.startTime.split(':');
    if (parts.length < 2) return false;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final slotTime = DateTime(now.year, now.month, now.day, hour, minute);
    return slotTime.isBefore(now);
  }

  /// Check slot này đã có booking nào trong MockData.userBookings chưa hoặc đã qua giờ
  bool _isSlotBooked(TimeSlot slot) {
    if (_isSlotPast(slot)) return true;
    return MockData.isSlotOccupied(
      subCourtId: slot.subCourtId,
      date: _selectedDate,
      startTime: slot.startTime,
    );
  }

  double get _totalPrice {
    double sum = 0;
    for (final slot in _currentCourtSlots) {
      if (_selectedSlotIds.contains(slot.id)) {
        sum += slot.price;
      }
    }
    return sum;
  }

  int get _totalMinutes => _selectedSlotIds.length * 60;

  List<TimeSlot> get _selectedSlotObjects {
    return _currentCourtSlots
        .where((s) => _selectedSlotIds.contains(s.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###', 'vi_VN');

    // Đếm slot trống thực tế (không tính slot đã đặt từ userBookings)
    final availableCount = _currentCourtSlots
        .where((s) => !s.isBooked && !_isSlotBooked(s))
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn khung giờ đặt sân',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              widget.venue.name,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, size: 22),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Quy định đặt sân',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  content: const Text(
                    '• Mỗi khung giờ tương ứng với 60 phút.\n'
                        '• Khung giờ vàng (17:00 - 21:00) có áp dụng phụ thu đèn chiếu sáng và nhu cầu cao.\n'
                        '• Có thể hủy lịch trước giờ chơi 3 tiếng và nhận hoàn tiền 100%.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Đã hiểu',
                          style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Calendar Date Strip
                  Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tháng ${DateFormat('MM / yyyy').format(_selectedDate)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('dd/MM/yyyy')
                                        .format(_selectedDate),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 84,
                          child: ListView.separated(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: _upcomingDates.length,
                            separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final date = _upcomingDates[index];
                              final isSelected =
                              DateUtils.isSameDay(date, _selectedDate);
                              final isToday =
                              DateUtils.isSameDay(date, DateTime.now());

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedDate = date;
                                    _loadSlotsForCourt();
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : (isToday
                                          ? AppColors.primary
                                          .withValues(alpha: 0.4)
                                          : AppColors.border),
                                      width:
                                      isSelected || isToday ? 1.5 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? AppColors.floatingShadow
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        isToday
                                            ? 'Hôm nay'
                                            : _getDayOfWeek(date),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              .withValues(alpha: 0.9)
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        date.day.toString().padLeft(2, '0'),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Sub-court Selector
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chọn sân con',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: widget.venue.subCourts.map((court) {
                              final isSelected =
                                  court.id == _selectedSubCourt.id;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedSubCourt = court;
                                        _loadSlotsForCourt();
                                      });
                                    }
                                  },
                                  avatar: isSelected
                                      ? const Icon(Icons.check,
                                      size: 16, color: Colors.white)
                                      : null,
                                  label: Text(
                                    court.name,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Legend
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceAround,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildLegendItem('Trống', AppColors.available,
                            AppColors.availableBorder),
                        _buildLegendItem('Đang chọn', AppColors.selected,
                            AppColors.selected),
                        _buildLegendItem('Đã đặt', AppColors.booked,
                            AppColors.bookedText),
                        _buildLegendItem('Giờ vàng ⚡',
                            AppColors.peakHourLight, AppColors.peakHour),
                      ],
                    ),
                  ),

                  // 4. Header đếm slot
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Lưới khung giờ thi đấu',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary),
                        ),
                        Text(
                          'Có $availableCount slot trống',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),

                  // 5. Grid slot
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _currentCourtSlots.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.5,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        final slot = _currentCourtSlots[index];
                        final isSelected =
                        _selectedSlotIds.contains(slot.id);
                        final isBooked =
                            slot.isBooked || _isSlotBooked(slot);

                        return _buildSlotCard(
                            slot, isSelected, isBooked, currencyFormat);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 6. Bottom bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: const Border(top: BorderSide(color: AppColors.border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedSlotIds.isEmpty
                              ? 'Chưa chọn khung giờ'
                              : 'Đã chọn ${_selectedSlotIds.length} slot ($_totalMinutes phút)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _selectedSlotIds.isEmpty
                                ? AppColors.textMuted
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${currencyFormat.format(_totalPrice)} đ',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _selectedSlotIds.isEmpty
                        ? null
                        : () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutScreen(
                            venue: widget.venue,
                            subCourt: _selectedSubCourt,
                            bookingDate: _selectedDate,
                            selectedSlots: _selectedSlotObjects,
                            totalPrice: _totalPrice,
                          ),
                        ),
                      );
                      // Sau khi back về → reload để cập nhật trạng thái
                      if (mounted) {
                        setState(() {
                          _loadSlotsForCourt();
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.border,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            'Tiếp tục đặt sân',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCard(TimeSlot slot, bool isSelected, bool isBooked,
      NumberFormat currencyFormat) {
    Color cardBg;
    Color borderColor;
    Color textColor;
    Color priceColor;

    if (isBooked) {
      cardBg = AppColors.booked;
      borderColor = Colors.transparent;
      textColor = AppColors.bookedText;
      priceColor = AppColors.bookedText;
    } else if (isSelected) {
      cardBg = AppColors.primary;
      borderColor = AppColors.primaryDark;
      textColor = Colors.white;
      priceColor = Colors.white.withValues(alpha: 0.9);
    } else if (slot.isPeakHour) {
      cardBg = AppColors.peakHourLight;
      borderColor = AppColors.peakHour;
      textColor = AppColors.textPrimary;
      priceColor = AppColors.peakHour;
    } else {
      cardBg = AppColors.surface;
      borderColor = AppColors.border;
      textColor = AppColors.textPrimary;
      priceColor = AppColors.primaryDark;
    }

    return GestureDetector(
      onTap: isBooked
          ? null
          : () {
        setState(() {
          if (isSelected) {
            _selectedSlotIds.remove(slot.id);
          } else {
            _selectedSlotIds.add(slot.id);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          boxShadow: isSelected ? AppColors.floatingShadow : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    slot.timeRange,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isBooked
                        ? 'Đã đặt'
                        : '${currencyFormat.format(slot.price)}đ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w700,
                      color: priceColor,
                    ),
                  ),
                ],
              ),
            ),
            if (slot.isPeakHour && !isBooked && !isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.peakHour,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '⚡',
                    style: TextStyle(fontSize: 8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, Color border) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: border),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _getDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'T.Hai';
      case DateTime.tuesday:
        return 'T.Ba';
      case DateTime.wednesday:
        return 'T.Tư';
      case DateTime.thursday:
        return 'T.Năm';
      case DateTime.friday:
        return 'T.Sáu';
      case DateTime.saturday:
        return 'T.Bảy';
      case DateTime.sunday:
        return 'C.Nhật';
      default:
        return '';
    }
  }
}