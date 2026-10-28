import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/booking.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookings = MockData.userBookings;
    final df = DateFormat('dd/MM/yyyy HH:mm', 'vi');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Lịch sử thanh toán')),
      body: bookings.isEmpty
          ? const Center(
        child: Text('Chưa có giao dịch nào',
            style: TextStyle(color: AppColors.textSecondary)),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, i) {
          final b = bookings[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _statusColor(b.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _statusIcon(b.status),
                    color: _statusColor(b.status),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.venue.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mã: ${b.id}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        df.format(b.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatVnd(b.finalAmount),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _statusLabel(b.status),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(b.status),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _statusColor(BookingStatus s) {
    switch (s) {
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.upcoming:
        return AppColors.primary;
      case BookingStatus.cancelled:
      case BookingStatus.rejected:
      case BookingStatus.noShow:
        return Colors.red;
    }
  }

  IconData _statusIcon(BookingStatus s) {
    switch (s) {
      case BookingStatus.completed:
        return Icons.check_circle;
      case BookingStatus.pending:
        return Icons.hourglass_top;
      case BookingStatus.upcoming:
        return Icons.event_available;
      case BookingStatus.cancelled:
      case BookingStatus.rejected:
      case BookingStatus.noShow:
        return Icons.cancel;
    }
  }

  String _statusLabel(BookingStatus s) {
    switch (s) {
      case BookingStatus.completed:
        return 'Hoàn thành';
      case BookingStatus.pending:
        return 'Chờ duyệt';
      case BookingStatus.upcoming:
        return 'Sắp tới';
      case BookingStatus.cancelled:
        return 'Đã hủy';
      case BookingStatus.rejected:
        return 'Bị từ chối';
      case BookingStatus.noShow:
        return 'Không đến';
    }
  }
}