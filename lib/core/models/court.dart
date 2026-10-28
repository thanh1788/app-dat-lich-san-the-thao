import '../services/location_service.dart';
import 'time_slot.dart';
import 'venue.dart';

class Court {
  final int id;
  final int venueId;
  final String name;
  final String sportType;
  final double pricePerHour;
  final String address;
  final bool isActive;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  const Court({
    required this.id,
    this.venueId = 1,
    required this.name,
    required this.sportType,
    required this.pricePerHour,
    required this.address,
    this.isActive = true,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    // Determine default image based on sportType if not provided
    final sport = (json['sportType'] ?? '').toString().toLowerCase();
    String defaultImage = 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800&auto=format&fit=crop&q=80'; // Badminton default
    if (sport.contains('foot') || sport.contains('bóng đá')) {
      defaultImage = 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800&auto=format&fit=crop&q=80';
    } else if (sport.contains('tennis')) {
      defaultImage = 'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?w=800&auto=format&fit=crop&q=80';
    } else if (sport.contains('pickle')) {
      defaultImage = 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&auto=format&fit=crop&q=80';
    } else if (sport.contains('basket') || sport.contains('rổ')) {
      defaultImage = 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800&auto=format&fit=crop&q=80';
    }

    return Court(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      venueId: json['venueId'] is int ? json['venueId'] : int.tryParse(json['venueId']?.toString() ?? '1') ?? 1,
      name: json['name']?.toString() ?? 'Sân Thể Thao',
      sportType: json['sportType']?.toString() ?? 'Badminton',
      pricePerHour: json['pricePerHour'] is num
          ? (json['pricePerHour'] as num).toDouble()
          : double.tryParse(json['pricePerHour']?.toString() ?? '100000') ?? 100000.0,
      address: json['address']?.toString() ?? 'Việt Nam',
      isActive: json['isActive'] == null ? true : (json['isActive'] == true || json['isActive'] == 1),
      imageUrl: json['imageUrl']?.toString() ?? defaultImage,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venueId': venueId,
      'name': name,
      'sportType': sportType,
      'pricePerHour': pricePerHour,
      'address': address,
      'isActive': isActive,
    };
  }

  Court copyWith({
    int? id,
    int? venueId,
    String? name,
    String? sportType,
    double? pricePerHour,
    String? address,
    bool? isActive,
    String? imageUrl,
    double? latitude,
    double? longitude,
  }) {
    return Court(
      id: id ?? this.id,
      venueId: venueId ?? this.venueId,
      name: name ?? this.name,
      sportType: sportType ?? this.sportType,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Venue toVenue([UserLocationInfo? userLocation]) {
    SportType st = SportType.badminton;
    final lower = sportType.toLowerCase();
    if (lower.contains('foot') || lower.contains('bóng đá')) {
      st = SportType.football;
    } else if (lower.contains('tennis')) {
      st = SportType.tennis;
    } else if (lower.contains('pickle')) {
      st = SportType.pickleball;
    } else if (lower.contains('basket') || lower.contains('rổ')) {
      st = SportType.basketball;
    }

    double dist = 1.8;
    if (userLocation != null && latitude != null && longitude != null) {
      dist = LocationService.instance.calculateDistanceKm(latitude!, longitude!);
    }

    final parts = address.split(',');
    final districtStr = parts.length > 1 ? parts[1].trim() : 'Quận 10';

    return Venue(
      id: 'court_$id',
      ownerId: 'owner_1',
      name: name,
      sportType: st,
      address: address,
      district: districtStr,
      distanceKm: dist,
      rating: 4.8,
      reviewCount: 38,
      minPrice: pricePerHour,
      maxPrice: pricePerHour * 1.5,
      imageUrl: imageUrl ?? 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800&auto=format&fit=crop&q=80',
      gallery: [
        imageUrl ?? 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800&auto=format&fit=crop&q=80',
      ],
      amenities: ['Wifi miễn phí', 'Chỗ đậu xe', 'Căn tin & Nước uống', 'Đèn chiếu sáng tiêu chuẩn'],
      openTime: '06:00 - 22:00',
      description: 'Sân thể thao chuyên nghiệp đạt chuẩn thi đấu từ hệ thống Sport6h50. Đồng bộ trực tiếp từ REST API server.',
      subCourts: [
        SubCourt(id: 'c_${id}_1', name: '$name - Sân 1', type: 'Sân tiêu chuẩn', basePrice: pricePerHour),
        SubCourt(id: 'c_${id}_2', name: '$name - Sân 2', type: 'Sân VIP', basePrice: pricePerHour),
      ],
    );
  }
}

