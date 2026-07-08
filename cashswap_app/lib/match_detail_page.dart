import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/theme/app_theme.dart';

class MatchDetailPage extends StatefulWidget {
  final String matchId;
  final Map<String, dynamic> matchData;

  const MatchDetailPage({super.key, required this.matchId, required this.matchData});

  @override
  State<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends State<MatchDetailPage> {
  Map<String, dynamic>? _match;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.matchData.isNotEmpty) {
      _match = widget.matchData;
      _isLoading = false;
    } else {
      _loadMatch();
    }
  }

  Future<void> _loadMatch() async {
    try {
      final matches = await ApiClient.instance.getMyMatches();
      final match = matches.firstWhere(
        (m) => (m as Map<String, dynamic>)['id'] == widget.matchId,
        orElse: () => <String, dynamic>{},
      );
      setState(() {
        _match = match as Map<String, dynamic>;
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
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    final status = _match?['status'] as String? ?? '';
    final distance = _match?['distance_km'] as double? ?? 0;
    final roomId = _match?['chat_room_id'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Swap Match')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            _StatusBadge(status: status),
            const SizedBox(height: 24),
            // Distance card
            _InfoCard(
              icon: Icons.place_outlined,
              label: 'Distance',
              value: '${distance.toStringAsFixed(1)} km apart',
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.access_time_rounded,
              label: 'Matched',
              value: _match?['created_at'] != null
                  ? _match!['created_at'].toString().substring(0, 16)
                  : '—',
            ),
            const SizedBox(height: 32),
            // Actions
            if (status == 'pending') ...[
              ElevatedButton(
                onPressed: () => _doAction('accept'),
                child: const Text('Accept Match'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _doAction('reject'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  side: const BorderSide(color: AppTheme.error),
                  foregroundColor: AppTheme.error,
                ),
                child: const Text('Decline'),
              ),
            ],
            if (status == 'accepted') ...[
              ElevatedButton.icon(
                onPressed: () => context.push('/chat/$roomId', extra: _match),
                icon: const Icon(Icons.chat_rounded),
                label: const Text('Open Chat'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _doAction('complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success,
                ),
                child: const Text('Mark as Completed'),
              ),
            ],
            if (status == 'completed')
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppTheme.success, size: 64),
                    const SizedBox(height: 12),
                    const Text('Swap Completed!', style: AppTextStyles.heading2),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to rating page
                      },
                      child: const Text('Rate your partner'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _doAction(String action) async {
    try {
      final updated = await ApiClient.instance.matchAction(widget.matchId, action);
      setState(() => _match = updated);
      if (action == 'accept' && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Match accepted! Start chatting.'),
              backgroundColor: AppTheme.success),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
      );
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'pending': color = AppTheme.warning; label = '⏳ Pending Acceptance'; break;
      case 'accepted': color = AppTheme.primary; label = '✅ Accepted'; break;
      case 'completed': color = AppTheme.success; label = '🎉 Completed'; break;
      case 'rejected': color = AppTheme.error; label = '❌ Rejected'; break;
      default: color = AppTheme.textSecondary; label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600, fontFamily: 'Sora')),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              Text(value, style: AppTextStyles.body),
            ],
          ),
        ],
      ),
    );
  }
}
