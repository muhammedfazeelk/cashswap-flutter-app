import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/theme/app_theme.dart';
import '../widgets/request_bottom_sheet.dart';
import '../widgets/nearby_marker_builder.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  List<dynamic> _nearbyRequests = [];
  bool _isLoadingLocation = true;
  Timer? _refreshTimer;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoadingLocation = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = position;
      _isLoadingLocation = false;
    });

    // Update location on backend
    await ApiClient.instance.updateLocation(position.latitude, position.longitude);

    // Load nearby requests and refresh every 30s
    await _loadNearbyRequests();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadNearbyRequests();
    });
  }

  Future<void> _loadNearbyRequests() async {
    if (_currentPosition == null) return;
    try {
      final requests = await ApiClient.instance.getNearbyRequests(
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
      );
      setState(() {
        _nearbyRequests = requests;
        _markers = NearbyMarkerBuilder.build(requests, _onMarkerTap);
      });
    } catch (e) {
      debugPrint('Failed to load nearby requests: $e');
    }
  }

  void _onMarkerTap(Map<String, dynamic> requestData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceAlt,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _RequestPreviewSheet(requestData: requestData),
    );
  }

  void _showCreateRequest() {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waiting for location...')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceAlt,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RequestBottomSheet(
        position: _currentPosition!,
        onCreated: _loadNearbyRequests,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          _isLoadingLocation
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentPosition?.latitude ?? 10.5276,
                      _currentPosition?.longitude ?? 76.2144,
                    ),
                    zoom: 14,
                  ),
                  onMapCreated: (ctrl) => _mapController = ctrl,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapType: MapType.normal,
                  style: _mapStyle,
                ),
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceAlt.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.swap_horiz_rounded,
                            color: AppTheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${_nearbyRequests.length} nearby',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontFamily: 'Sora',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Matches icon
                  GestureDetector(
                    onTap: () => context.push('/match/list'),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceAlt.withOpacity(0.95),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_outlined,
                          color: AppTheme.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Create request FAB
          Positioned(
            bottom: 100,
            right: 20,
            child: GestureDetector(
              onTap: _showCreateRequest,
              child: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 20, offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.add_rounded, color: Colors.black, size: 32),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) {
          setState(() => _selectedIndex = i);
          if (i == 1) context.push('/match/list');
          if (i == 2) context.push('/profile/me');
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined), label: 'Map'),
          BottomNavigationBarItem(
              icon: Icon(Icons.swap_calls_rounded), label: 'Swaps'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  static const String _mapStyle = '''
  [
    {"elementType":"geometry","stylers":[{"color":"#0f1923"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#8a9dc0"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#0f1923"}]},
    {"featureType":"road","elementType":"geometry","stylers":[{"color":"#1a2535"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0d1520"}]}
  ]
  ''';
}

class _RequestPreviewSheet extends StatelessWidget {
  final Map<String, dynamic> requestData;
  const _RequestPreviewSheet({required this.requestData});

  @override
  Widget build(BuildContext context) {
    final isCash = requestData['request_type'] == 'need_cash';
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isCash
                      ? AppTheme.cashColor.withOpacity(0.15)
                      : AppTheme.digitalColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isCash ? '💵 Needs Cash' : '📱 Needs Digital',
                  style: TextStyle(
                    color: isCash ? AppTheme.cashColor : AppTheme.digitalColor,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Sora',
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${requestData['distance_km']} km away',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '₹${requestData['amount']}',
                style: AppTextStyles.amount,
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppTheme.warning, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${requestData['user_rating']?.toStringAsFixed(1)}',
                    style: AppTextStyles.body,
                  ),
                  Text(
                    ' · ${requestData['user_completed_swaps']} swaps',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            requestData['user_display_name'] ?? '',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to match creation
            },
            child: const Text('Swap with this person'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
