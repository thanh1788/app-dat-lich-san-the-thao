import 'time_slot.dart';
import 'venue.dart';

enum BookingStatus {
  pending,
  upcoming,
  completed,
  cancelled,
  rejected,
  noShow;

  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Chờ duyệt';
      case BookingStatus.upcoming:
        return 'Sắp diễn ra';
      case BookingStatus.completed:
        return 'Hoàn thành';
      case BookingStatus.cancelled:
        return 'Đã hủy';
      case BookingStatus.rejected:
        return 'Bị từ chối';
      case BookingStatus.noShow:
        return 'Không đến';
    }
  }
}

class Booking {
  final String id;
  final Venue venue;
  final SubCourt subCourt;
  final DateTime bookingDate;
  final List<TimeSlot> selectedSlots;
  final double totalPrice;
  final double discountAmount;
  final double finalAmount;
  final String paymentMethod;
  final BookingStatus status;
  final DateTime createdAt;
  final String qrCodeData;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String ownerId;
  final String? rejectReason;

  const Booking({
    required this.id,
    required this.venue,
    required this.subCourt,
    required this.bookingDate,
    required this.selectedSlots,
    required this.totalPrice,
    required this.discountAmount,
    required this.finalAmount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.qrCodeData,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.ownerId,
    this.rejectReason,
  });

  Booking copyWith({
    String? id,
    Venue? venue,
    SubCourt? subCourt,
    DateTime? bookingDate,
    List<TimeSlot>? selectedSlots,
    double? totalPrice,
    double? discountAmount,
    double? finalAmount,
    String? paymentMethod,
    BookingStatus? status,
    DateTime? createdAt,
    String? qrCodeData,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? ownerId,
    String? rejectReason,
  }) {
    return Booking(
      id: id ?? this.id,
      venue: venue ?? this.venue,
      subCourt: subCourt ?? this.subCourt,
      bookingDate: bookingDate ?? this.bookingDate,
      selectedSlots: selectedSlots ?? this.selectedSlots,
      totalPrice: totalPrice ?? this.totalPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      ownerId: ownerId ?? this.ownerId,
      rejectReason: rejectReason ?? this.rejectReason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venue': venue.toJson(),
      'subCourt': subCourt.toJson(),
      'bookingDate': bookingDate.toIso8601String(),
      'selectedSlots': selectedSlots.map((s) => s.toJson()).toList(),
      'totalPrice': totalPrice,
      'discountAmount': discountAmount,
      'finalAmount': finalAmount,
      'paymentMethod': paymentMethod,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'qrCodeData': qrCodeData,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'ownerId': ownerId,
      'rejectReason': rejectReason,
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString() ?? '',
      venue: Venue.fromJson(
        Map<String, dynamic>.from(json['venue'] as Map? ?? {}),
      ),
      subCourt: SubCourt.fromJson(
        Map<String, dynamic>.from(json['subCourt'] as Map? ?? {}),
      ),
      bookingDate: DateTime.parse(json['bookingDate']),
      selectedSlots: (json['selectedSlots'] as List<dynamic>? ?? [])
          .map((s) => TimeSlot.fromJson(Map<String, dynamic>.from(s as Map)))
          .toList(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
      finalAmount: (json['finalAmount'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      status: BookingStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      qrCodeData: json['qrCodeData']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      customerPhone: json['customerPhone']?.toString() ?? '',
      ownerId: json['ownerId']?.toString() ?? '',
      rejectReason: json['rejectReason']?.toString(),
    );
  }

  DateTime get startDateTime {
    if (selectedSlots.isEmpty) return bookingDate;
    final firstSlot = selectedSlots.first;
    final parts = firstSlot.startTime.split(':');
    if (parts.length < 2) return bookingDate;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return DateTime(
      bookingDate.year,
      bookingDate.month,
      bookingDate.day,
      hour,
      minute,
    );
  }

  bool get isSlotOccupying =>
      status == BookingStatus.pending || status == BookingStatus.upcoming;

  bool get isOffline =>
      customerId.startsWith('offline_') ||
      paymentMethod.toLowerCase().contains('điện thoại') ||
      paymentMethod.toLowerCase().contains('offline');
}