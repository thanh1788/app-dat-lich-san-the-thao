import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class UserLocationInfo {
  final double latitude;
  final double longitude;
  final String fullAddress;
  final String shortAddress;
  final String district;
  final bool isDefault;

  const UserLocationInfo({
    required this.latitude,
    required this.longitude,
    required this.fullAddress,
    required this.shortAddress,
    required this.district,
    this.isDefault = false,
  });

  // Vị trí mặc định chi tiết tại Bình Thạnh, TP.HCM
  static const defaultLocation = UserLocationInfo(
    latitude: 10.8015,
    longitude: 106.7118,
    fullAddress: 'Đường Điện Biên Phủ, Phường 25, Quận Bình Thạnh, TP. Hồ Chí Minh',
    shortAddress: 'Phường 25, Q. Bình Thạnh',
    district: 'Bình Thạnh',
    isDefault: true,
  );
}

class LocationService {
  static final LocationService instance = LocationService._internal();
  LocationService._internal();

  UserLocationInfo? _cachedLocation;
  UserLocationInfo get currentLocation => _cachedLocation ?? UserLocationInfo.defaultLocation;

  /// Danh sách các khu vực thực tế nổi bật tại TP. Hồ Chí Minh để người dùng chọn nhanh
  final List<UserLocationInfo> popularLocations = const [
    UserLocationInfo(
      latitude: 10.8015,
      longitude: 106.7118,
      fullAddress: 'Điện Biên Phủ, Phường 25, Quận Bình Thạnh, TP. Hồ Chí Minh',
      shortAddress: 'Phường 25, Q. Bình Thạnh',
      district: 'Bình Thạnh',
    ),
    UserLocationInfo(
      latitude: 10.8505,
      longitude: 106.7719,
      fullAddress: 'Võ Văn Ngân, Phường Linh Trung, TP. Thủ Đức, TP. Hồ Chí Minh',
      shortAddress: 'Linh Trung, TP. Thủ Đức',
      district: 'Thủ Đức',
    ),
    UserLocationInfo(
      latitude: 10.7769,
      longitude: 106.6653,
      fullAddress: 'Cách Mạng Tháng 8, Phường 12, Quận 10, TP. Hồ Chí Minh',
      shortAddress: 'Phường 12, Quận 10',
      district: 'Quận 10',
    ),
    UserLocationInfo(
      latitude: 10.7760,
      longitude: 106.7025,
      fullAddress: 'Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh',
      shortAddress: 'Bến Nghé, Quận 1',
      district: 'Quận 1',
    ),
    UserLocationInfo(
      latitude: 10.8388,
      longitude: 106.6657,
      fullAddress: 'Quang Trung, Phường 10, Quận Gò Vấp, TP. Hồ Chí Minh',
      shortAddress: 'Phường 10, Q. Gò Vấp',
      district: 'Gò Vấp',
    ),
    UserLocationInfo(
      latitude: 10.7327,
      longitude: 106.7196,
      fullAddress: 'Nguyễn Thị Thập, Phường Tân Phú, Quận 7, TP. Hồ Chí Minh',
      shortAddress: 'Tân Phú, Quận 7',
      district: 'Quận 7',
    ),
    UserLocationInfo(
      latitude: 10.8014,
      longitude: 106.6534,
      fullAddress: 'Cộng Hòa, Phường 13, Quận Tân Bình, TP. Hồ Chí Minh',
      shortAddress: 'Phường 13, Q. Tân Bình',
      district: 'Tân Bình',
    ),
  ];

  /// Cho phép thiết lập vị trí thủ công (khi chọn từ modal hoặc chọn quận)
  void setLocation(UserLocationInfo info) {
    _cachedLocation = info;
  }

  /// Yêu cầu quyền và lấy vị trí GPS thực tế kèm địa chỉ chữ chi tiết (Phường, Quận/Thủ Đức, TP.HCM)
  Future<UserLocationInfo> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Kiểm tra GPS có bật không
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('LocationService: Dịch vụ định vị GPS bị tắt');
        return currentLocation;
      }

      // Kiểm tra quyền
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('LocationService: Người dùng từ chối cấp quyền vị trí');
          return currentLocation;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('LocationService: Quyền vị trí bị từ chối vĩnh viễn');
        return currentLocation;
      }

      // Lấy tọa độ GPS thiết bị
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Giải mã tọa độ thành địa chỉ thực tế (miễn phí từ Android OS)
      String fullAddress = 'Tọa độ: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      String shortAddress = 'Quận Bình Thạnh, TP.HCM';
      String district = 'Bình Thạnh';

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 5));

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final street = place.street ?? place.name ?? '';
          final ward = place.subLocality ?? '';
          final dist = place.subAdministrativeArea ?? place.locality ?? '';
          final city = place.administrativeArea ?? 'TP. Hồ Chí Minh';

          if (dist.isNotEmpty) {
            district = dist;
          }

          // Tạo shortAddress rõ ràng (ưu tiên hiển thị Phường + Quận/Thủ Đức)
          if (ward.isNotEmpty && dist.isNotEmpty) {
            shortAddress = '$ward, $dist';
          } else if (dist.isNotEmpty && city.isNotEmpty) {
            shortAddress = '$dist, $city';
          } else if (dist.isNotEmpty) {
            shortAddress = dist;
          } else if (street.isNotEmpty) {
            shortAddress = street;
          }

          final List<String?> rawParts = [street, ward, dist, city];
          final parts = rawParts
              .whereType<String>()
              .map((p) => p.trim())
              .where((p) => p.isNotEmpty)
              .toSet()
              .toList();
          if (parts.isNotEmpty) {
            fullAddress = parts.join(', ');
          }
        }
      } catch (e) {
        debugPrint('LocationService: Không thể geocode địa chỉ chữ ($e). Giữ vị trí.');
      }

      _cachedLocation = UserLocationInfo(
        latitude: position.latitude,
        longitude: position.longitude,
        fullAddress: fullAddress,
        shortAddress: shortAddress,
        district: district,
        isDefault: false,
      );

      return _cachedLocation!;
    } catch (e) {
      debugPrint('LocationService: Lỗi xác định vị trí ($e)');
      return currentLocation;
    }
  }

  /// Tính khoảng cách km từ vị trí người dùng đến một tọa độ sân
  double calculateDistanceKm(double targetLat, double targetLng) {
    final current = currentLocation;
    final distanceMeters = Geolocator.distanceBetween(
      current.latitude,
      current.longitude,
      targetLat,
      targetLng,
    );
    return double.parse((distanceMeters / 1000).toStringAsFixed(1));
  }
}
