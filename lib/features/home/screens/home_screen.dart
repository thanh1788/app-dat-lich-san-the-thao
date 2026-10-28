import 'package:flutter/material.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/models/court.dart';
import '../../../../core/models/venue.dart';
import '../../../../core/services/court_api_service.dart';
import '../../../../core/services/favorite_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import 'widgets/category_filter_bar.dart';
import 'widgets/venue_card.dart';
import '../../venue_detail/screens/venue_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onSwitchToOwnerMode;

  const HomeScreen({
    super.key,
    required this.onSwitchToOwnerMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SportType _selectedCategory = SportType.all;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  UserLocationInfo? _userLocation;
  bool _isLoadingLocation = false;
  List<Court> _apiCourts = [];
  bool _isLoadingCourts = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
    _loadCourts();
    FavoriteService.instance.addListener(_onFavChanged);
  }

  void _onFavChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    FavoriteService.instance.removeListener(_onFavChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation({bool manual = false}) async {
    setState(() => _isLoadingLocation = true);
    try {
      final loc = await LocationService.instance.determinePosition();
      if (mounted) {
        setState(() {
          _userLocation = loc;
          _isLoadingLocation = false;
        });
        if (manual) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã cập nhật vị trí: ${loc.shortAddress}'),
              backgroundColor: AppColors.primaryDark,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _loadCourts() async {
    setState(() => _isLoadingCourts = true);
    try {
      final courts = await CourtApiService.instance.fetchCourts();
      if (mounted) {
        setState(() {
          _apiCourts = courts;
          _isLoadingCourts = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCourts = false);
    }
  }

  List<Venue> get _filteredVenues {
    final favService = FavoriteService.instance;

    final convertedApiVenues =
    _apiCourts.map((c) => c.toVenue(_userLocation)).toList();

    final allVenues = [...convertedApiVenues, ...MockData.venues];

    final filtered = allVenues.where((venue) {
      final isFav = favService.isFavorite(venue.id);

      final matchesCategory = _selectedCategory == SportType.all ||
          venue.sportType == _selectedCategory ||
          isFav;

      final matchesSearch = _searchQuery.isEmpty ||
          venue.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          venue.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          venue.district.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();

    filtered.sort((a, b) {
      final aFav = favService.isFavorite(a.id);
      final bFav = favService.isFavorite(b.id);
      if (aFav == bFav) return 0;
      return aFav ? -1 : 1;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future.wait([
              _fetchLocation(manual: false),
              _loadCourts(),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ==================== TOP APP BAR ====================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      // Cột địa chỉ — chạm để tự quét lại GPS
                      Expanded(
                        child: InkWell(
                          onTap: () => _fetchLocation(manual: true),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _userLocation != null &&
                                          !_userLocation!.isDefault
                                          ? Icons.my_location
                                          : Icons.location_on,
                                      size: 15,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        _isLoadingLocation
                                            ? 'Đang định vị GPS...'
                                            : 'Vị trí của bạn (Chạm để cập nhật)',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    if (_isLoadingLocation)
                                      const SizedBox(
                                        width: 10,
                                        height: 10,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                            color: AppColors.primary),
                                      )
                                    else
                                      const Icon(Icons.refresh,
                                          size: 14,
                                          color: AppColors.primary),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _userLocation?.shortAddress ??
                                            'Đang xác định vị trí...',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Chuông thông báo
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                  Icons.notifications_none_rounded),
                              color: AppColors.textPrimary,
                              iconSize: 20,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Không có thông báo mới nào')),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText:
                        'Tìm kiếm sân bóng, cầu lông, pickleball...',
                        hintStyle: const TextStyle(
                            fontSize: 13, color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.textSecondary, size: 22),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                            : Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.tune_rounded,
                              color: AppColors.primaryDark, size: 18),
                        ),
                        border: InputBorder.none,
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
              ),

              // Promotional Banner
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C853), Color(0xFF00B4D8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: AppColors.floatingShadow,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '🎉 KHUYẾN MÃI GIỜ VÀNG',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Giảm 10% khi đặt trước\nsân khung giờ 14h - 17h',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Nhập mã: SPORT6H50',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text('🏸⚽', style: TextStyle(fontSize: 40)),
                    ],
                  ),
                ),
              ),

              // Sports Category Selector Bar
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Text(
                        'Môn thể thao',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    CategoryFilterBar(
                      selectedCategory: _selectedCategory,
                      onCategoryChanged: (category) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),

              // Venue List Header
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Sân gần bạn (${_filteredVenues.length})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (_isLoadingCourts) ...[
                              const SizedBox(width: 8),
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.primary),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Xem tất cả',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Venue Cards List
              _filteredVenues.isEmpty
                  ? const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'Không tìm thấy sân phù hợp',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              )
                  : SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final venue = _filteredVenues[index];
                      return VenueCard(
                        venue: venue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VenueDetailScreen(venue: venue),
                            ),
                          );
                        },
                      );
                    },
                    childCount: _filteredVenues.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}