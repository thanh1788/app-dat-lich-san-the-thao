class TimeSlot {
  final String id;
  final String subCourtId;
  final String startTime;
  final String endTime;
  final double price;
  final bool isBooked;
  final bool isPeakHour;

  const TimeSlot({
    required this.id,
    required this.subCourtId,
    required this.startTime,
    required this.endTime,
    required this.price,
    this.isBooked = false,
    this.isPeakHour = false,
  });

  String get timeRange => '$startTime - $endTime';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subCourtId': subCourtId,
      'startTime': startTime,
      'endTime': endTime,
      'price': price,
      'isBooked': isBooked,
      'isPeakHour': isPeakHour,
    };
  }

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id']?.toString() ?? '',
      subCourtId: json['subCourtId']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      isBooked: json['isBooked'] == true,
      isPeakHour: json['isPeakHour'] == true,
    );
  }
}

class SubCourt {
  final String id;
  final String name;
  final String type;
  final double basePrice;

  const SubCourt({
    required this.id,
    required this.name,
    required this.type,
    required this.basePrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'basePrice': basePrice,
    };
  }

  factory SubCourt.fromJson(Map<String, dynamic> json) {
    return SubCourt(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0,
    );
  }
}