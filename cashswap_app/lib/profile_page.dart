import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../../../../shared/theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  bool _isMe = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final myId = await SecureStore.getUserId();
    final uid = widget.userId == 'me' ? myId! : widget.userId;
    _isMe = uid == myId;

    try {
      final profile = _isMe
          ? await ApiClient.instance.getMe()
          : await ApiClient.instance.getUserProfile(uid);
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: AppTheme.primary)));
    }

    final rating = (_profile?['rating'] as num?)?.toDouble() ?? 5.0;
    final totalRatings = _profile?['total_ratings'] as int? ?? 0;
    final completedSwaps = _profile?['completed_swaps'] as int? ?? 0;
    final isVerified = _profile?['is_verified'] as bool? ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isMe ? 'My Profile' : 'User Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 48,
              backgroundColor: AppTheme.primary.withOpacity(0.2),
              child: Text(
                (_profile?['display_name'] as String? ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 40, color: AppTheme.primary,
                  fontWeight: FontWeight.bold, fontFamily: 'Sora',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _profile?['display_name'] as String? ?? '',
                  style: AppTextStyles.heading2,
                ),
                if (isVerified) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.verified_rounded,
                      color: AppTheme.primary, size: 20),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _profile?['phone_number'] as String? ?? '',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 20),
            // Stats row
            Row(
              children: [
                Expanded(child: _StatCard(
                  value: rating.toStringAsFixed(1),
                  label: 'Rating',
                  icon: Icons.star_rounded,
                  color: AppTheme.warning,
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                  value: '$completedSwaps',
                  label: 'Swaps',
                  icon: Icons.swap_horiz_rounded,
                  color: AppTheme.primary,
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                  value: '$totalRatings',
                  label: 'Reviews',
                  icon: Icons.reviews_outlined,
                  color: AppTheme.secondary,
                )),
              ],
            ),
            const SizedBox(height: 20),
            // Star rating display
            RatingBar.builder(
              initialRating: rating,
              minRating: 1,
              allowHalfRating: true,
              itemCount: 5,
              ignoreGestures: true,
              itemBuilder: (_, __) =>
                  const Icon(Icons.star_rounded, color: AppTheme.warning),
              onRatingUpdate: (_) {},
            ),
            Text('$totalRatings ratings', style: AppTextStyles.caption),
            if (_isMe) ...[
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () {
                  // Logout
                },
                icon: const Icon(Icons.logout, color: AppTheme.error),
                label: const Text('Sign Out',
                    style: TextStyle(color: AppTheme.error, fontFamily: 'Sora')),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: AppTheme.error),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value, required this.label,
    required this.icon, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700,
                color: color, fontFamily: 'Sora',
              )),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
