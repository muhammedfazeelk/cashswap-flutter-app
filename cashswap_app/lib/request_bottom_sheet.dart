import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/theme/app_theme.dart';

class RequestBottomSheet extends StatefulWidget {
  final Position position;
  final VoidCallback onCreated;

  const RequestBottomSheet({
    super.key,
    required this.position,
    required this.onCreated,
  });

  @override
  State<RequestBottomSheet> createState() => _RequestBottomSheetState();
}

class _RequestBottomSheetState extends State<RequestBottomSheet> {
  String _requestType = 'need_cash';
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Create Swap Request', style: AppTextStyles.heading2),
          const SizedBox(height: 20),
          // Type selector
          Row(
            children: [
              Expanded(child: _TypeButton(
                label: '💵 I need Cash',
                subtitle: 'Have digital money',
                value: 'need_cash',
                selectedValue: _requestType,
                color: AppTheme.cashColor,
                onTap: () => setState(() => _requestType = 'need_cash'),
              )),
              const SizedBox(width: 12),
              Expanded(child: _TypeButton(
                label: '📱 I need Digital',
                subtitle: 'Have physical cash',
                value: 'need_digital',
                selectedValue: _requestType,
                color: AppTheme.digitalColor,
                onTap: () => setState(() => _requestType = 'need_digital'),
              )),
            ],
          ),
          const SizedBox(height: 16),
          // Amount
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              color: AppTheme.textPrimary, fontFamily: 'Sora', fontSize: 18,
            ),
            decoration: const InputDecoration(
              labelText: 'Amount (₹)',
              prefixText: '₹ ',
              prefixStyle: TextStyle(color: AppTheme.primary, fontSize: 18),
            ),
          ),
          const SizedBox(height: 12),
          // Description
          TextField(
            controller: _descriptionController,
            maxLength: 200,
            style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'Sora'),
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              hintText: 'E.g. Near Thrissur bus stand',
              counterStyle: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
          // Submit
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _requestType == 'need_cash'
                  ? AppTheme.cashColor
                  : AppTheme.digitalColor,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                  )
                : const Text('Post Request & Find Match'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiClient.instance.createRequest(
        requestType: _requestType,
        amount: amount,
        latitude: widget.position.latitude,
        longitude: widget.position.longitude,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request posted! Looking for matches nearby...'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _TypeButton extends StatelessWidget {
  final String label, subtitle, value, selectedValue;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label, required this.subtitle, required this.value,
    required this.selectedValue, required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == selectedValue;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                  color: selected ? color : AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Sora',
                  fontSize: 13,
                )),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontFamily: 'Sora',
                )),
          ],
        ),
      ),
    );
  }
}
