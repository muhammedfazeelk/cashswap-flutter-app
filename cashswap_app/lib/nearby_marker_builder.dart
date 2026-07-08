import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../shared/theme/app_theme.dart';

class NearbyMarkerBuilder {
  /// Build Google Maps markers from nearby requests list.
  static Set<Marker> build(
    List<dynamic> requests,
    Function(Map<String, dynamic>) onTap,
  ) {
    final markers = <Marker>{};
    for (final req in requests) {
      // Note: In production, add lat/lng to nearby request API response
      // For now using placeholder coords - real app would include them
      final isCash = req['request_type'] == 'need_cash';
      markers.add(
        Marker(
          markerId: MarkerId(req['id'] as String),
          // position: LatLng(req['latitude'], req['longitude']),
          // Using dummy position for schema - update API to return coords
          position: const LatLng(10.5276, 76.2144),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isCash
                ? BitmapDescriptor.hueOrange   // Cash = orange
                : BitmapDescriptor.hueGreen,    // Digital = green
          ),
          infoWindow: InfoWindow(
            title: isCash ? '💵 Needs Cash' : '📱 Needs Digital',
            snippet: '₹${req['amount']} · ${req['distance_km']} km',
          ),
          onTap: () => onTap(req as Map<String, dynamic>),
        ),
      );
    }
    return markers;
  }
}
