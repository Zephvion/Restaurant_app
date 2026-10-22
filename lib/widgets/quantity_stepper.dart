import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A "−  n  +" stepper used to change a dish quantity (product screen and cart
/// rows). Two circular buttons flanking the current count.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.size = 34,
    this.minusEnabled = true,
    this.fontSize,
    this.minusIcon,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final double size;
  final bool minusEnabled;
  final double? fontSize;
  final IconData? minusIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E23),
        borderRadius: BorderRadius.circular(size),
        border: Border.all(color: const Color(0xFF303036)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundButton(
            icon: minusIcon ?? (quantity <= 1 ? Icons.delete_outline : Icons.remove),
            size: size,
            enabled: minusEnabled,
            onTap: onDecrement,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size <= 28 ? 8 : size * 0.32),
            child: Text(
              '$quantity',
              style: TextStyle(
                color: const Color(0xFFF5F5F5),
                fontSize: fontSize ?? (size <= 28 ? 13 : 16),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _RoundButton(
            icon: Icons.add,
            size: size,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.size,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final double size;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? const Color(0xFF10B981) : const Color(0xFF26262C),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: size * 0.55,
            color: enabled ? Colors.white : AppColors.hint,
          ),
        ),
      ),
    );
  }
}
