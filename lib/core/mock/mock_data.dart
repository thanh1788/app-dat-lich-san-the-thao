import 'package:flutter/foundation.dart';
import '../models/venue.dart';
import '../models/time_slot.dart';
import '../models/booking.dart';
import '../models/user.dart';
import '../services/booking_storage.dart';

class MockData {
  // ============================================================
  // USER & ROLE
  // ============================================================

  static final List<User> users = [
    const User(
      id: 'admin_1',
      fullName: 'Quản trị viên hệ thống',
      phone: '0900 000 001',
      email: 'admin@sport6h50.vn',
      role: UserRole.admin,
    ),
    const User(
      id: 'owner_1',
      fullName: 'Nguyễn Văn Chủ',
      phone: '0901 111 111',
      email: 'owner1@sport6h50.vn',
      role: UserRole.owner,
      venueIds: ['venue_1', 'venue_3'],
    ),
    const User(
      id: 'owner_2',
      fullName: 'Trần Thị Chủ',
      phone: '0902 222 222',
      email: 'owner2@sport6h50.vn',
      role: UserRole.owner,
      venueIds: ['venue_2', 'venue_4'],
    ),
    const User(
      id: 'user_1',
      fullName: 'Nguyễn Văn A',
      phone: '0909 123 456',
      email: 'khach1@gmail.com',
      role: UserRole.customer,
    ),
    const User(
      id: 'user_2',
      fullName: 'Lê Thị B',
      phone: '0909 654 321',
      email: 'khach2@gmail.com',
      role: UserRole.customer,
    ),
  ];

  static User? currentUser = users[3];

  static void setCurrentUser(String userId) {
    final user = users.firstWhere(
          (u) => u.id == userId,
      orElse: () => users[3],
    );
    currentUser = user;
  }

  static void loginAsCustomer() {
    currentUser = users.firstWhere((u) => u.role == UserRole.customer);
  }

  static void loginAsOwner() {
    currentUser = users.firstWhere((u) => u.role == UserRole.owner);
  }

  static void loginAsAdmin() {
    currentUser = users.firstWhere((u) => u.role == UserRole.admin);
  }

  static User? getUserById(String id) {
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  static String get currentCustomerId => 'user_1';
  static String get currentOwnerId => currentUser?.role == UserRole.owner
      ? currentUser!.id
      : 'owner_1';

  // ============================================================
  // VENUES
  // ============================================================

  static final List<Venue> venues = [
    Venue(
      id: 'venue_1',
      ownerId: 'owner_1',
      name: 'CLB Cầu Lông Kỳ Hòa Sport',
      sportType: SportType.badminton,
      address: '796 Sư Vạn Hạnh, Phường 12',
      district: 'Quận 10, TP.HCM',
      distanceKm: 1.2,
      rating: 4.8,
      reviewCount: 342,
      minPrice: 80000,
      maxPrice: 150000,
      imageUrl:
      'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&w=800&q=80',
      gallery: [
        'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1613918108466-292b78a8ef95?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=800&q=80',
      ],
      amenities: [
        'Thảm PVC chuẩn thi đấu',
        'Phòng tắm nóng lạnh',
        'Bãi giữ xe ô tô',
        'Căn tin & Nước uống',
        'Cho thuê vợt'
      ],
      openTime: '05:30 - 23:00',
      description:
      'Cụm 10 sân cầu lông chuẩn quốc tế, trần cao 11m không chói đèn, hệ thống quạt thông gió mát mẻ và đội ngũ phục vụ chuyên nghiệp.',
      subCourts: const [
        SubCourt(
            id: 'c1',
            name: 'Sân 01 (Thảm Yonex VIP)',
            type: 'Thảm tiêu chuẩn',
            basePrice: 110000),
        SubCourt(
            id: 'c2',
            name: 'Sân 02 (Thảm Yonex VIP)',
            type: 'Thảm tiêu chuẩn',
            basePrice: 110000),
        SubCourt(
            id: 'c3',
            name: 'Sân 03 (Thảm Victor)',
            type: 'Thảm tiêu chuẩn',
            basePrice: 90000),
        SubCourt(
            id: 'c4',
            name: 'Sân 04 (Thảm Victor)',
            type: 'Thảm tiêu chuẩn',
            basePrice: 90000),
      ],
    ),
    Venue(
      id: 'venue_2',
      ownerId: 'owner_2',
      name: 'Sân Bóng Đá Cỏ Nhân Tạo Chảo Lửa',
      sportType: SportType.football,
      address: '30 Phan Thúc Duyện, Phường 4',
      district: 'Quận Tân Bình, TP.HCM',
      distanceKm: 2.5,
      rating: 4.9,
      reviewCount: 520,
      minPrice: 200000,
      maxPrice: 450000,
      imageUrl:
      'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?auto=format&fit=crop&w=800&q=80',
      gallery: [
        'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=800&q=80',
      ],
      amenities: [
        'Cỏ nhập khẩu mềm mượt',
        'Đèn LED chống chói 1000W',
        'Trọng tài theo yêu cầu',
        'Quầy trang phục thi đấu',
        'Wifi Free'
      ],
      openTime: '06:00 - 24:00',
      description:
      'Tổ hợp 8 sân mini 5 người và có thể ghép thành 2 sân 7 người đạt chuẩn thi đấu giao hữu. Mặt cỏ cao cấp giảm chấn thương.',
      subCourts: const [
        SubCourt(
            id: 'c5',
            name: 'Sân 5A (Sân trong nhà)',
            type: 'Sân cỏ 5 người',
            basePrice: 250000),
        SubCourt(
            id: 'c6',
            name: 'Sân 5B (Sân ngoài trời)',
            type: 'Sân cỏ 5 người',
            basePrice: 220000),
        SubCourt(
            id: 'c7',
            name: 'Sân 7A (Sân lớn ghép)',
            type: 'Sân cỏ 7 người',
            basePrice: 420000),
      ],
    ),
    Venue(
      id: 'venue_3',
      ownerId: 'owner_1',
      name: 'D-Sports Pickleball Arena',
      sportType: SportType.pickleball,
      address: '12 Võ Văn Kiệt, Phường Cầu Ông Lãnh',
      district: 'Quận 1, TP.HCM',
      distanceKm: 0.8,
      rating: 4.95,
      reviewCount: 189,
      minPrice: 120000,
      maxPrice: 220000,
      imageUrl:
      'https://images.unsplash.com/photo-1599586120429-48281b6f0ece?auto=format&fit=crop&w=800&q=80',
      gallery: [
        'https://images.unsplash.com/photo-1599586120429-48281b6f0ece?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?auto=format&fit=crop&w=800&q=80',
      ],
      amenities: [
        'Sơn sân 5 lớp US Open',
        'Lưới thi đấu Selkirk',
        'Huấn luyện viên cơ bản',
        'Phòng thay đồ máy lạnh',
        'Quầy cà phê thể thao'
      ],
      openTime: '06:00 - 22:30',
      description:
      'Sân chơi Pickleball thời thượng ngay trung tâm Quận 1. Đầy đủ vợt thi đấu cao cấp cho thuê và cộng đồng giao lưu cởi mở.',
      subCourts: const [
        SubCourt(
            id: 'c8',
            name: 'Court 01 (Center Court)',
            type: 'Mặt sân Acrylic',
            basePrice: 160000),
        SubCourt(
            id: 'c9',
            name: 'Court 02 (Training Court)',
            type: 'Mặt sân Acrylic',
            basePrice: 140000),
        SubCourt(
            id: 'c10',
            name: 'Court 03 (Indoor Court)',
            type: 'Mặt sân Acrylic',
            basePrice: 150000),
      ],
    ),
    Venue(
      id: 'venue_4',
      ownerId: 'owner_2',
      name: 'CLB Quần Vợt Lan Anh Tennis Club',
      sportType: SportType.tennis,
      address: '291 Cách Mạng Tháng 8, Phường 12',
      district: 'Quận 10, TP.HCM',
      distanceKm: 1.7,
      rating: 4.7,
      reviewCount: 275,
      minPrice: 180000,
      maxPrice: 320000,
      imageUrl:
      'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?auto=format&fit=crop&w=800&q=80',
      gallery: [
        'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?auto=format&fit=crop&w=800&q=80',
      ],
      amenities: [
        'Sân cứng chuẩn ATP',
        'Nhặt bóng chuyên nghiệp',
        'Hồ bơi thư giãn',
        'Bãi đỗ xe rộng rãi',
        'Nhà hàng'
      ],
      openTime: '06:00 - 22:00',
      description:
      'Địa điểm tennis uy tín lâu năm tại Sài Gòn với mặt sân nảy chuẩn xác, dàn đèn đạt tiêu chuẩn tổ chức các giải đấu phong trào.',
      subCourts: const [
        SubCourt(
            id: 'c11',
            name: 'Sân Tennis Số 1',
            type: 'Sân Cứng Hard Court',
            basePrice: 220000),
        SubCourt(
            id: 'c12',
            name: 'Sân Tennis Số 2',
            type: 'Sân Cứng Hard Court',
            basePrice: 220000),
      ],
    ),
  ];

  static List<TimeSlot> generateSlotsForCourt(
      String subCourtId, double basePrice) {
    return [
      TimeSlot(
          id: '${subCourtId}_06',
          subCourtId: subCourtId,
          startTime: '06:00',
          endTime: '07:00',
          price: basePrice * 0.8,
          isBooked: true),
      TimeSlot(
          id: '${subCourtId}_07',
          subCourtId: subCourtId,
          startTime: '07:00',
          endTime: '08:00',
          price: basePrice * 0.8,
          isBooked: false),
      TimeSlot(
          id: '${subCourtId}_08',
          subCourtId: subCourtId,
          startTime: '08:00',
          endTime: '09:00',
          price: basePrice,
          isBooked: false),
      TimeSlot(
          id: '${subCourtId}_09',
          subCourtId: subCourtId,
          startTime: '09:00',
          endTime: '10:00',
          price: basePrice,
          isBooked: true),
      TimeSlot(
          id: '${subCourtId}_10',
          subCourtId: subCourtId,
          startTime: '10:00',
          endTime: '11:00',
          price: basePrice,
          isBooked: false),
      TimeSlot(
          id: '${subCourtId}_14',
          subCourtId: subCourtId,
          startTime: '14:00',
          endTime: '15:00',
          price: basePrice * 0.9,
          isBooked: false),
      TimeSlot(
          id: '${subCourtId}_15',
          subCourtId: subCourtId,
          startTime: '15:00',
          endTime: '16:00',
          price: basePrice,
          isBooked: false),
      TimeSlot(
          id: '${subCourtId}_16',
          subCourtId: subCourtId,
          startTime: '16:00',
          endTime: '17:00',
          price: basePrice,
          isBooked: false),
      TimeSlot(
          id: '${subCourtId}_17',
          subCourtId: subCourtId,
          startTime: '17:00',
          endTime: '18:00',
          price: basePrice * 1.3,
          isPeakHour: true,
          isBooked: true),
      TimeSlot(
          id: '${subCourtId}_18',
          subCourtId: subCourtId,
          startTime: '18:00',
          endTime: '19:00',
          price: basePrice * 1.4,
          isPeakHour: true,
          isBooked: false),
      TimeSlot(
          id: '${subCourtId}_19',
          subCourtId: subCourtId,
          startTime: '19:00',
          endTime: '20:00',
          price: basePrice * 1.4,
          isPeakHour: true,
          isBooked: false),
      TimeSlot(
          id: '${subCourtId}_20',
          subCourtId: subCourtId,
          startTime: '20:00',
          endTime: '21:00',
          price: basePrice * 1.2,
          isPeakHour: true,
          isBooked: false),
      TimeSlot(
          id: '${subCourtId}_21',
          subCourtId: subCourtId,
          startTime: '21:00',
          endTime: '22:00',
          price: basePrice,
          isBooked: false),
    ];
  }

  static const int cancelDeadlineHours = 3;

  // ============================================================
  // BOOKINGS
  // ============================================================
  static List<Booking> get defaultMockBookings {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return [
      // ===== ĐƠN CHỜ DUYỆT (Hiển thị ở Tab 2: Chờ duyệt) =====
      Booking(
        id: 'BK-90001',
        venue: venues[0],
        subCourt: venues[0].subCourts[1],
        bookingDate: tomorrow,
        selectedSlots: [
          const TimeSlot(
            id: 'slot_pending_1',
            subCourtId: 'c2',
            startTime: '19:00',
            endTime: '20:00',
            price: 154000,
            isPeakHour: true,
          ),
        ],
        totalPrice: 154000,
        discountAmount: 0,
        finalAmount: 154000,
        paymentMethod: 'Thanh toán tại sân',
        status: BookingStatus.pending,
        createdAt: now.subtract(const Duration(minutes: 25)),
        qrCodeData: 'SPORT6H50_PENDING_BK-90001_C2',
        customerId: 'user_1',
        customerName: 'Nguyễn Văn A',
        customerPhone: '0909 123 456',
        ownerId: 'owner_1',
      ),
      Booking(
        id: 'BK-90002',
        venue: venues[0],
        subCourt: venues[0].subCourts[2],
        bookingDate: tomorrow,
        selectedSlots: [
          const TimeSlot(
            id: 'slot_pending_2',
            subCourtId: 'c3',
            startTime: '20:00',
            endTime: '21:00',
            price: 140000,
            isPeakHour: true,
          ),
        ],
        totalPrice: 140000,
        discountAmount: 0,
        finalAmount: 140000,
        paymentMethod: 'Thanh toán tại sân',
        status: BookingStatus.pending,
        createdAt: now.subtract(const Duration(minutes: 10)),
        qrCodeData: 'SPORT6H50_PENDING_BK-90002_C3',
        customerId: 'user_2',
        customerName: 'Lê Thị B',
        customerPhone: '0909 654 321',
        ownerId: 'owner_1',
      ),
      Booking(
        id: 'BK-90003',
        venue: venues[0],
        subCourt: venues[0].subCourts[0],
        bookingDate: tomorrow,
        selectedSlots: [
          const TimeSlot(
            id: 'slot_pending_3',
            subCourtId: 'c1',
            startTime: '18:00',
            endTime: '19:00',
            price: 154000,
            isPeakHour: true,
          ),
        ],
        totalPrice: 154000,
        discountAmount: 0,
        finalAmount: 154000,
        paymentMethod: 'Thanh toán tại sân',
        status: BookingStatus.pending,
        createdAt: now.subtract(const Duration(minutes: 5)),
        qrCodeData: 'SPORT6H50_PENDING_BK-90003_C1',
        customerId: 'user_1',
        customerName: 'Trần Văn Cường',
        customerPhone: '0903 888 777',
        ownerId: 'owner_1',
      ),

      // ===== LỊCH HÔM NAY (CLB Cầu Lông Kỳ Hòa Sport - venue_1) =====
      // Sân 01
      Booking(
        id: 'BK-88101',
        venue: venues[0],
        subCourt: venues[0].subCourts[0],
        bookingDate: today,
        selectedSlots: [
          const TimeSlot(
            id: 'slot_today_c1_08',
            subCourtId: 'c1',
            startTime: '08:00',
            endTime: '09:00',
            price: 140000,
            isPeakHour: false,
          ),
        ],
        totalPrice: 140000,
        discountAmount: 0,
        finalAmount: 140000,
        paymentMethod: 'Thanh toán tại sân',
        status: BookingStatus.upcoming,
        createdAt: now.subtract(const Duration(hours: 4)),
        qrCodeData: 'SPORT6H50_CHECKIN_BK-88101_C1_0800',
        customerId: 'user_1',
        customerName: 'Nguyễn Văn A',
        customerPhone: '0909 123 456',
        ownerId: 'owner_1',
      ),
      Booking(
        id: 'BK-88102',
        venue: venues[0],
        subCourt: venues[0].subCourts[0],
        bookingDate: today,
        selectedSlots: [
          const TimeSlot(
            id: 'slot_today_c1_15',
            subCourtId: 'c1',
            startTime: '15:00',
            endTime: '16:00',
            price: 140000,
            isPeakHour: false,
          ),
        ],
        totalPrice: 140000,
        discountAmount: 0,
        finalAmount: 140000,
        paymentMethod: 'Thanh toán tại sân',
        status: BookingStatus.upcoming,
        createdAt: now.subtract(const Duration(hours: 3)),
        qrCodeData: 'SPORT6H50_CHECKIN_BK-88102_C1_1500',
        customerId: 'user_1',
        customerName: 'Nguyễn Văn A',
        customerPhone: '0909 123 456',
        ownerId: 'owner_1',
      ),
      Booking(
        id: 'BK-88103',
        venue: venues[0],
        subCourt: venues[0].subCourts[0],
        bookingDate: today,
        selectedSlots: [
          const TimeSlot(
            id: 'slot_today_c1_16',
            subCourtId: 'c1',
            startTime: '16:00',
            endTime: '17:00',
            price: 140000,
            isPeakHour: false,
          ),
        ],
        totalPrice: 140000,
        discountAmount: 0,
        finalAmount: 140000,
        paymentMethod: 'Thanh toán tại sân',
        status: BookingStatus.upcoming,
        createdAt: now.subtract(const Duration(hours: 3)),
        qrCodeData: 'SPORT6H50_CHECKIN_BK-88103_C1_1600',
        customerId: 'user_1',
        customerName: 'Nguyễn Văn A',
        customerPhone: '0909 123 456',
        ownerId: 'owner_1',
      ),
      Booking(
        id: 'BK-88201',
        venue: venues[0],
        subCourt: venues[0].subCourts[0],
        bookingDate: today,
        selectedSlots: [
          const TimeSlot(
            id: 'slot_today_c1_17',
            subCourtId: 'c1',
            startTime: '17:00',
            endTime: '18:00',
            price: 154000,
            isPeakHour: true,
          ),
        ],
        totalPrice: 154000,
        discountAmount: 0,
        finalAmount: 154000,
        paymentMethod: 'Đặt qua điện thoại',
        status: BookingStatus.upcoming,
        createdAt: now.subtract(const Duration(hours: 2)),
        qrCodeData: 'SPORT6H50_OFFLINE_BK-88201_C1',
        customerId: 'offline_c1_17',
        customerName: 'Anh Hoàng (Đặt Phone)',
        customerPhone: '0912 345 678',
        ownerId: 'owner_1',
      ),
      Booking(
        id: 'BK-89320',
        venue: venues[0],
        subCourt: venues[0].subCourts[0],
        bookingDate: today,
        selectedSlots: [
          const TimeSlot(
            id: 'slot_today_c1_19',
            subCourtId: 'c1',
            startTime: '19:00',
            endTime: '20:00',
            price: 154000,
            isPeakHour: true,
          ),
        ],
        totalPrice: 154000,
        discountAmount: 0,
        finalAmount: 154000,
        paymentMethod: 'Thanh toán tại sân',
        status: BookingStatus.upcoming,
        createdAt: now.subtract(const Duration(hours: 2)),
        qrCodeData: 'SPORT6H50_VERIFIED_CHECKIN_BK-89320_C1',
        customerId: 'user_1',
        customerName: 'Nguyễn Văn A',
        customerPhone: '0909 123 456',
        ownerId: 'owner_1',
      ),

      // Sân 02
      Booking(
        id: 'BK-88104',
        venue: venues[0],
        subCourt: venues[0].subCourts[1],
        bookingDate: today,
        selectedSlots: [
          const TimeSlot(
            id: 'slot_today_c2_08',
            subCourtId: 'c2',
            startTime: '08:00',
            endTime: '09:00',
            price: 140000,
            isPeakHour: false,
          ),
        ],
        totalPrice: 140000,
        discountAmount: 0,
        finalAmount: 140000,
        paymentMethod: 'Thanh toán tại sân',
        status: BookingStatus.upcoming,
        createdAt: now.subtract(const Duration(hours: 4)),
        qrCodeData: 'SPORT6H50_CHECKIN_BK-88104_C2',
        customerId: 'user_2',
        customerName: 'Lê Thị B',
        customerPhone: '0909 654 321',
        ownerId: 'owner_1',
      ),
      Booking(
        id: 'BK-88105',
        venue: venues[0],
        subCourt: venues[0].subCourts[1],
        bookingDate: today,
        selectedSlots: [
          const TimeSlot(
            id: 'slot_today_c2_15',
            subCourtId: 'c2',
            startTime: '15:00',
            endTime: '16:00',
            price: 140000,
            isPeakHour: false,
          ),
        ],
        totalPrice: 140000,
        discountAmount: 0,
        finalAmount: 140000,
        paymentMethod: 'Thanh toán tại sân',
        status: BookingStatus.upcoming,
        createdAt: now.subtract(const Duration(hours: 3)),
        qrCodeData: 'SPORT6H50_CHECKIN_BK-88105_C2',
        customerId: 'user_2',
        customerName: 'Lê Thị B',
        customerPhone: '0909 654 321',
        ownerId: 'owner_1',
      ),
      Booking(
        id: 'BK-88106',
        venue: venues[0],
        subCourt: venues[0].subCourts[1],
        bookingDate: today,
        selectedSlots: [
          const TimeSlot(
            id: 'slot_today_c2_16',
            subCourtId: 'c2',
            startTime: '16:00',
            endTime: '17:00',
            price: 140000,
            isPeakHour: false,
          ),
        ],
        totalPrice: 140000,
        discountAmount: 0,
        finalAmount: 140000,
        paymentMethod: 'Thanh toán tại sân',
        status: BookingStatus.upcoming,
        createdAt: now.subtract(const Duration(hours: 3)),
        qrCodeData: 'SPORT6H50_CHECKIN_BK-88106_C2',
        customerId: 'user_2',
        customerName: 'Lê Thị B',
        customerPhone: '0909 654 321',
        ownerId: 'owner_1',
      ),
      Booking(
        id: 'BK-88202',
        venue: venues[0],
        subCourt: venues[0].subCourts[1],
        bookingDate: today,
        selectedSlots: [
          const TimeSlot(
            id: 'slot_today_c2_17',
            subCourtId: 'c2',
            startTime: '17:00',
            endTime: '18:00',
            price: 154000,
            isPeakHour: true,
          ),
        ],
        totalPrice: 154000,
        discountAmount: 0,
        finalAmount: 154000,
        paymentMethod: 'Đặt qua điện thoại',
        status: BookingStatus.upcoming,
        createdAt: now.subtract(const Duration(hours: 2)),
        qrCodeData: 'SPORT6H50_OFFLINE_BK-88202_C2',
        customerId: 'offline_c2_17',
        customerName: 'Chị Mai (Đặt Phone)',
        customerPhone: '0988 765 432',
        ownerId: 'owner_1',
      ),

      // Sân 03
      Booking(
        id: 'BK-88301',
        venue: venues[0],
        subCourt: venues[0].subCourts[2],
        bookingDate: today,
        selectedSlots: [
          const TimeSlot(
            id: 'slot_today_c3_07',
            subCourtId: 'c3',
            startTime: '07:00',
            endTime: '08:00',
            price: 140000,
            isPeakHour: false,
          ),
        ],
        totalPrice: 140000,
        discountAmount: 0,
        finalAmount: 140000,
        paymentMethod: 'Thanh toán tại sân',
        status: BookingStatus.completed,
        createdAt: now.subtract(const Duration(hours: 6)),
        qrCodeData: 'SPORT6H50_CHECKIN_BK-88301_C3',
        customerId: 'user_1',
        customerName: 'Nguyễn Văn A',
        customerPhone: '0909 123 456',
        ownerId: 'owner_1',
      ),
      Booking(
        id: 'BK-88302',
        venue: venues[0],
        subCourt: venues[0].subCourts[2],
        bookingDate: today,
        selectedSlots: [
          const TimeSlot(
            id: 'slot_today_c3_09',
            subCourtId: 'c3',
            startTime: '09:00',
            endTime: '10:00',
            price: 140000,
            isPeakHour: false,
          ),
        ],
        totalPrice: 140000,
        discountAmount: 0,
        finalAmount: 140000,
        paymentMethod: 'Thanh toán tại sân',
        status: BookingStatus.completed,
        createdAt: now.subtract(const Duration(hours: 5)),
        qrCodeData: 'SPORT6H50_CHECKIN_BK-88302_C3',
        customerId: 'user_1',
        customerName: 'Nguyễn Văn A',
        customerPhone: '0909 123 456',
        ownerId: 'owner_1',
      ),
      Booking(
        id: 'BK-88107',
        venue: venues[0],
        subCourt: venues[0].subCourts[2],
        bookingDate: today,
        selectedSlots: [
          const TimeSlot(
            id: 'slot_today_c3_16',
            subCourtId: 'c3',
            startTime: '16:00',
            endTime: '17:00',
            price: 140000,
            isPeakHour: false,
          ),
        ],
        totalPrice: 140000,
        discountAmount: 0,
        finalAmount: 140000,
        paymentMethod: 'Thanh toán tại sân',
        status: BookingStatus.upcoming,
        createdAt: now.subtract(const Duration(hours: 2)),
        qrCodeData: 'SPORT6H50_CHECKIN_BK-88107_C3',
        customerId: 'user_1',
        customerName: 'Nguyễn Văn A',
        customerPhone: '0909 123 456',
        ownerId: 'owner_1',
      ),
      Booking(
        id: 'BK-88108',
        venue: venues[0],
        subCourt: venues[0].subCourts[2],
        bookingDate: today,
        selectedSlots: [
          const TimeSlot(
            id: 'slot_today_c3_18',
            subCourtId: 'c3',
            startTime: '18:00',
            endTime: '19:00',
            price: 154000,
            isPeakHour: true,
          ),
        ],
        totalPrice: 154000,
        discountAmount: 0,
        finalAmount: 154000,
        paymentMethod: 'Thanh toán tại sân',
        status: BookingStatus.upcoming,
        createdAt: now.subtract(const Duration(hours: 2)),
        qrCodeData: 'SPORT6H50_CHECKIN_BK-88108_C3',
        customerId: 'user_2',
        customerName: 'Lê Thị B',
        customerPhone: '0909 654 321',
        ownerId: 'owner_1',
      ),
      Booking(
        id: 'BK-88203',
        venue: venues[0],
        subCourt: venues[0].subCourts[2],
        bookingDate: today,
        selectedSlots: [
          const TimeSlot(
            id: 'slot_today_c3_20',
            subCourtId: 'c3',
            startTime: '20:00',
            endTime: '21:00',
            price: 154000,
            isPeakHour: true,
          ),
        ],
        totalPrice: 154000,
        discountAmount: 0,
        finalAmount: 154000,
        paymentMethod: 'Đặt qua điện thoại',
        status: BookingStatus.upcoming,
        createdAt: now.subtract(const Duration(hours: 1)),
        qrCodeData: 'SPORT6H50_OFFLINE_BK-88203_C3',
        customerId: 'offline_c3_20',
        customerName: 'Chú Dũng (Đặt Phone)',
        customerPhone: '0933 111 222',
        ownerId: 'owner_1',
      ),

      // Sân 04
      Booking(
        id: 'BK-88303',
        venue: venues[0],
        subCourt: venues[0].subCourts[3],
        bookingDate: today,
        selectedSlots: [
          const TimeSlot(
            id: 'slot_today_c4_08',
            subCourtId: 'c4',
            startTime: '08:00',
            endTime: '09:00',
            price: 120000,
            isPeakHour: false,
          ),
        ],
        totalPrice: 120000,
        discountAmount: 0,
        finalAmount: 120000,
        paymentMethod: 'Thanh toán tại sân',
        status: BookingStatus.completed,
        createdAt: now.subtract(const Duration(hours: 6)),
        qrCodeData: 'SPORT6H50_CHECKIN_BK-88303_C4',
        customerId: 'user_2',
        customerName: 'Lê Thị B',
        customerPhone: '0909 654 321',
        ownerId: 'owner_1',
      ),
      Booking(
        id: 'BK-88204',
        venue: venues[0],
        subCourt: venues[0].subCourts[3],
        bookingDate: today,
        selectedSlots: [
          const TimeSlot(
            id: 'slot_today_c4_14',
            subCourtId: 'c4',
            startTime: '14:00',
            endTime: '15:00',
            price: 120000,
            isPeakHour: false,
          ),
        ],
        totalPrice: 120000,
        discountAmount: 0,
        finalAmount: 120000,
        paymentMethod: 'Đặt qua điện thoại',
        status: BookingStatus.upcoming,
        createdAt: now.subtract(const Duration(hours: 3)),
        qrCodeData: 'SPORT6H50_OFFLINE_BK-88204_C4',
        customerId: 'offline_c4_14',
        customerName: 'Anh Phúc (Đặt Phone)',
        customerPhone: '0977 444 555',
        ownerId: 'owner_1',
      ),
      Booking(
        id: 'BK-88109',
        venue: venues[0],
        subCourt: venues[0].subCourts[3],
        bookingDate: today,
        selectedSlots: [
          const TimeSlot(
            id: 'slot_today_c4_18',
            subCourtId: 'c4',
            startTime: '18:00',
            endTime: '19:00',
            price: 140000,
            isPeakHour: true,
          ),
        ],
        totalPrice: 140000,
        discountAmount: 0,
        finalAmount: 140000,
        paymentMethod: 'Thanh toán tại sân',
        status: BookingStatus.upcoming,
        createdAt: now.subtract(const Duration(hours: 2)),
        qrCodeData: 'SPORT6H50_CHECKIN_BK-88109_C4',
        customerId: 'user_1',
        customerName: 'Nguyễn Văn A',
        customerPhone: '0909 123 456',
        ownerId: 'owner_1',
      ),
      Booking(
        id: 'BK-88110',
        venue: venues[0],
        subCourt: venues[0].subCourts[3],
        bookingDate: today,
        selectedSlots: [
          const TimeSlot(
            id: 'slot_today_c4_19',
            subCourtId: 'c4',
            startTime: '19:00',
            endTime: '20:00',
            price: 140000,
            isPeakHour: true,
          ),
        ],
        totalPrice: 140000,
        discountAmount: 0,
        finalAmount: 140000,
        paymentMethod: 'Thanh toán tại sân',
        status: BookingStatus.upcoming,
        createdAt: now.subtract(const Duration(hours: 2)),
        qrCodeData: 'SPORT6H50_CHECKIN_BK-88110_C4',
        customerId: 'user_1',
        customerName: 'Nguyễn Văn A',
        customerPhone: '0909 123 456',
        ownerId: 'owner_1',
      ),

      // ===== LỊCH SỬ BOOKING CÁC NGÀY KHÁC =====
      Booking(
        id: 'BK-78145',
        venue: venues[1],
        subCourt: venues[1].subCourts[0],
        bookingDate: now.subtract(const Duration(days: 5)),
        selectedSlots: [
          const TimeSlot(
              id: 'slot_hist_1',
              subCourtId: 'c5',
              startTime: '19:00',
              endTime: '20:00',
              price: 250000,
              isPeakHour: true),
        ],
        totalPrice: 250000,
        discountAmount: 0,
        finalAmount: 250000,
        paymentMethod: 'Thanh toán tại sân',
        status: BookingStatus.completed,
        createdAt: now.subtract(const Duration(days: 7)),
        qrCodeData: 'SPORT6H50_CHECKIN_BK-78145_C5_1900_2000',
        customerId: 'user_1',
        customerName: 'Nguyễn Văn A',
        customerPhone: '0909 123 456',
        ownerId: 'owner_2',
      ),
      Booking(
        id: 'BK-65432',
        venue: venues[2],
        subCourt: venues[2].subCourts[0],
        bookingDate: now.subtract(const Duration(days: 2)),
        selectedSlots: [
          const TimeSlot(
              id: 'slot_cancel_1',
              subCourtId: 'c8',
              startTime: '20:00',
              endTime: '21:00',
              price: 160000,
              isPeakHour: true),
        ],
        totalPrice: 160000,
        discountAmount: 0,
        finalAmount: 160000,
        paymentMethod: 'Thanh toán tại sân',
        status: BookingStatus.rejected,
        createdAt: now.subtract(const Duration(days: 4)),
        qrCodeData: 'SPORT6H50_REJECTED_BK-65432',
        customerId: 'user_1',
        customerName: 'Nguyễn Văn A',
        customerPhone: '0909 123 456',
        ownerId: 'owner_1',
        rejectReason: 'Đã có khách đặt',
      ),
      Booking(
        id: 'BK-54321',
        venue: venues[0],
        subCourt: venues[0].subCourts[2],
        bookingDate: now.subtract(const Duration(days: 3)),
        selectedSlots: [
          const TimeSlot(
              id: 'slot_cancel_2',
              subCourtId: 'c3',
              startTime: '20:00',
              endTime: '21:00',
              price: 126000,
              isPeakHour: true),
        ],
        totalPrice: 126000,
        discountAmount: 0,
        finalAmount: 126000,
        paymentMethod: 'Thanh toán tại sân',
        status: BookingStatus.cancelled,
        createdAt: now.subtract(const Duration(days: 5)),
        qrCodeData: 'SPORT6H50_CANCELLED_BK-54321',
        customerId: 'user_1',
        customerName: 'Nguyễn Văn A',
        customerPhone: '0909 123 456',
        ownerId: 'owner_1',
      ),
    ];
  }

  static List<Booking> userBookings = List.from(defaultMockBookings);

  // ============================================================
  // HELPER METHODS
  // ============================================================

  static List<Booking> getBookingsForCustomer(String customerId) {
    return userBookings.where((b) => b.customerId == customerId).toList();
  }

  static List<Booking> getBookingsForOwner(String ownerId) {
    return userBookings
        .where((b) => b.ownerId == ownerId || b.venue.ownerId == ownerId)
        .toList();
  }

  static List<Booking> getBookingsForVenue(String venueId) {
    return userBookings.where((b) => b.venue.id == venueId).toList();
  }

  static List<Booking> getPendingBookingsForOwner(String ownerId) {
    return userBookings
        .where((b) =>
            (b.ownerId == ownerId || b.venue.ownerId == ownerId) &&
            b.status == BookingStatus.pending)
        .toList();
  }

  static bool isSlotOccupied({
    required String subCourtId,
    required DateTime date,
    required String startTime,
  }) {
    return userBookings.any((b) {
      if (!b.isSlotOccupying) return false;
      final sameDate = b.bookingDate.year == date.year &&
          b.bookingDate.month == date.month &&
          b.bookingDate.day == date.day;
      if (!sameDate) return false;
      return b.subCourt.id == subCourtId &&
          b.selectedSlots.any((s) => s.startTime == startTime);
    });
  }

  static double hoursUntilBooking(Booking booking) {
    final diff = booking.startDateTime.difference(DateTime.now());
    return diff.inMinutes / 60.0;
  }

  static bool canCancelBooking(Booking booking) {
    if (booking.status == BookingStatus.pending) return true;
    if (booking.status == BookingStatus.upcoming) {
      return hoursUntilBooking(booking) >= cancelDeadlineHours;
    }
    return false;
  }

  static int cancelBooking(String bookingId) {
    final index = userBookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return 1;

    final old = userBookings[index];
    if (old.status != BookingStatus.pending &&
        old.status != BookingStatus.upcoming) {
      return 2;
    }
    if (!canCancelBooking(old)) return 3;

    userBookings[index] = old.copyWith(status: BookingStatus.cancelled);
    persistBookings();
    return 0;
  }

  static bool approveBooking(String bookingId) {
    final index = userBookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return false;

    final old = userBookings[index];
    if (old.status != BookingStatus.pending) return false;

    userBookings[index] = old.copyWith(status: BookingStatus.upcoming);
    persistBookings();
    return true;
  }

  static bool rejectBooking(String bookingId, String reason) {
    final index = userBookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return false;

    final old = userBookings[index];
    if (old.status != BookingStatus.pending) return false;

    userBookings[index] = old.copyWith(
      status: BookingStatus.rejected,
      rejectReason: reason,
    );
    persistBookings();
    return true;
  }

  static bool checkInBooking(String bookingId) {
    final index = userBookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return false;

    final old = userBookings[index];
    if (old.status != BookingStatus.upcoming) return false;

    userBookings[index] = old.copyWith(status: BookingStatus.completed);
    persistBookings();
    return true;
  }

  static bool reportNoShow(String bookingId) {
    final index = userBookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return false;

    final old = userBookings[index];
    if (old.status != BookingStatus.upcoming) return false;

    userBookings[index] = old.copyWith(status: BookingStatus.noShow);
    persistBookings();
    return true;
  }

  static void checkAndExpirePendingBookings() {
    bool hasChange = false;
    final now = DateTime.now();
    for (int i = 0; i < userBookings.length; i++) {
      final b = userBookings[i];
      if (b.status == BookingStatus.pending) {
        if (b.startDateTime.isBefore(now)) {
          userBookings[i] = b.copyWith(
            status: BookingStatus.rejected,
            rejectReason: 'Quá hạn duyệt từ chủ sân',
          );
          hasChange = true;
        }
      }
    }
    if (hasChange) {
      persistBookings();
    }
  }

  static Future<Booking?> createOfflineBooking({
    required Venue venue,
    required SubCourt subCourt,
    required DateTime bookingDate,
    required TimeSlot slot,
    required String customerName,
    required String customerPhone,
  }) async {
    if (isSlotOccupied(
      subCourtId: subCourt.id,
      date: bookingDate,
      startTime: slot.startTime,
    )) {
      return null;
    }

    final bookingId =
        'BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final booking = Booking(
      id: bookingId,
      venue: venue,
      subCourt: subCourt,
      bookingDate: bookingDate,
      selectedSlots: [slot],
      totalPrice: slot.price,
      discountAmount: 0,
      finalAmount: slot.price,
      paymentMethod: 'Đặt qua điện thoại',
      status: BookingStatus.upcoming,
      createdAt: DateTime.now(),
      qrCodeData: 'SPORT6H50_OFFLINE_${bookingId}_${subCourt.id}',
      customerId: 'offline_${DateTime.now().millisecondsSinceEpoch}',
      customerName: customerName,
      customerPhone: customerPhone,
      ownerId: venue.ownerId,
    );

    userBookings.insert(0, booking);
    await persistBookings();
    return booking;
  }

  // ============================================================
  // PERSISTENCE
  // ============================================================

  static Future<void> loadBookingsFromStorage() async {
    final raw = await BookingStorage.instance.load();

    debugPrint('=== LOAD STORAGE: ${raw.length} booking ===');

    final defaultList = defaultMockBookings;
    final defaultIds = defaultList.map((b) => b.id).toSet();

    if (raw.isEmpty) {
      debugPrint(
          'Storage trống, nạp danh sách mặc định (${defaultList.length})');
      userBookings = List.from(defaultList);
      await persistBookings();
      return;
    }

    final loaded = <Booking>[];
    for (final j in raw) {
      try {
        loaded.add(Booking.fromJson(j));
      } catch (e) {
        debugPrint('Lỗi parse booking: $e');
      }
    }

    debugPrint('Parse được ${loaded.length}/${raw.length} booking');

    final loadedMap = {for (final b in loaded) b.id: b};
    final result = <Booking>[];

    // 1. Thêm tất cả booking do người dùng tạo (đơn tại checkout, đặt offline)
    for (final b in loaded) {
      if (!defaultIds.contains(b.id)) {
        result.add(b);
      }
    }

    // 2. Thêm và hợp nhất các default booking để hôm nay và ngày mai luôn có dữ liệu sống động
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    for (final def in defaultList) {
      if (loadedMap.containsKey(def.id)) {
        final saved = loadedMap[def.id]!;
        final isTomorrow = def.id.startsWith('BK-900');
        final isHistory = def.id.startsWith('BK-7') ||
            def.id.startsWith('BK-6') ||
            def.id.startsWith('BK-5');

        DateTime newDate;
        if (isHistory) {
          newDate = saved.bookingDate;
        } else if (isTomorrow) {
          newDate = tomorrow;
        } else {
          newDate = today;
        }

        result.add(saved.copyWith(
          bookingDate: newDate,
        ));
      } else {
        result.add(def);
      }
    }

    userBookings = result;
    await persistBookings();
  }

  static Future<void> resetToDefault() async {
    userBookings = List.from(defaultMockBookings);
    await persistBookings();
  }

  static Future<void> persistBookings() async {
    try {
      await BookingStorage.instance.save(
        userBookings.map((b) => b.toJson()).toList(),
      );
      debugPrint('SAVE OK: ${userBookings.length} booking');
    } catch (e) {
      debugPrint('SAVE LỖI: $e');
    }
  }

  static Future<void> debugPrintStorage() async {
    final raw = await BookingStorage.instance.load();
    debugPrint('=== STORAGE có ${raw.length} booking ===');
    for (final j in raw) {
      debugPrint(
          '  id=${j['id']} customer=${j['customerName']} date=${j['bookingDate']}');
    }
  }
}