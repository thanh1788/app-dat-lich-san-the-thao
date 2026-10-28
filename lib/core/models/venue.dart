import 'time_slot.dart';

enum SportType {
  all('Tất cả', '🏆'),
  football('Bóng đá', '⚽'),
  badminton('Cầu lông', '🏸'),
  pickleball('Pickleball', '🏓'),
  tennis('Tennis', '🎾'),
  basketball('Bóng rổ', '🏀');

  final String title;
  final String icon;
  const SportType(this.title, this.icon);

  static SportType fromName(String? name) {
    return SportType.values.firstWhere(
          (e) => e.name == name,
      orElse: () => SportType.badminton,
    );
  }
}

class Venue {
  final String id;
  final String ownerId;
  final String name;
  final SportType sportType;
  final String address;
  final String district;
  final double distanceKm;
  final double rating;
  final int reviewCount;
  final double minPrice;
  final double maxPrice;
  final String imageUrl;
  final List<String> gallery;
  final List<String> amenities;
  final String openTime;
  final List<SubCourt> subCourts;
  final String description;

  const Venue({
    required this.id,
    this.ownerId = 'owner_1',
    required this.name,
    required this.sportType,
    required this.address,
    required this.district,
    required this.distanceKm,
    required this.rating,
    required this.reviewCount,
    required this.minPrice,
    required this.maxPrice,
    required this.imageUrl,
    required this.gallery,
    required this.amenities,
    required this.openTime,
    required this.subCourts,
    required this.description,
  });

  Venue copyWith({
    String? id,
    String? ownerId,
    String? name,
    SportType? sportType,
    String? address,
    String? district,
    double? distanceKm,
    double? rating,
    int? reviewCount,
    double? minPrice,
    double? maxPrice,
    String? imageUrl,
    List<String>? gallery,
    List<String>? amenities,
    String? openTime,
    List<SubCourt>? subCourts,
    String? description,
  }) {
    return Venue(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      sportType: sportType ?? this.sportType,
      address: address ?? this.address,
      district: district ?? this.district,
      distanceKm: distanceKm ?? this.distanceKm,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      gallery: gallery ?? this.gallery,
      amenities: amenities ?? this.amenities,
      openTime: openTime ?? this.openTime,
      subCourts: subCourts ?? this.subCourts,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'sportType': sportType.name,
      'address': address,
      'district': district,
      'distanceKm': distanceKm,
      'rating': rating,
      'reviewCount': reviewCount,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'imageUrl': imageUrl,
      'gallery': gallery,
      'amenities': amenities,
      'openTime': openTime,
      'subCourts': subCourts.map((s) => s.toJson()).toList(),
      'description': description,
    };
  }

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id']?.toString() ?? '',
      ownerId: json['ownerId']?.toString() ?? 'owner_1',
      name: json['name']?.toString() ?? '',
      sportType: SportType.fromName(json['sportType']?.toString()),
      address: json['address']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      minPrice: (json['minPrice'] as num?)?.toDouble() ?? 0,
      maxPrice: (json['maxPrice'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imageUrl']?.toString() ?? '',
      gallery: (json['gallery'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      amenities: (json['amenities'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      openTime: json['openTime']?.toString() ?? '',
      subCourts: (json['subCourts'] as List<dynamic>? ?? [])
          .map((s) => SubCourt.fromJson(Map<String, dynamic>.from(s as Map)))
          .toList(),
      description: json['description']?.toString() ?? '',
    );
  }
}