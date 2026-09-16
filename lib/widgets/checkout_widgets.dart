import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'network_image_with_fallback.dart';
import 'price_text.dart';
import 'quantity_stepper.dart';

/// A rounded dark panel used to group content on the checkout screens.
class RoundedPanel extends StatelessWidget {
  const RoundedPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color = AppColors.backgroundElevated,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: child,
    );
  }
}

/// A single line in an order summary: thumbnail, name + quantity, and price.
class OrderSummaryRow extends StatelessWidget {
  const OrderSummaryRow({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.quantity,
    required this.price,
    this.unitPrice,
    this.onIncrement,
    this.onDecrement,
  });

  final String imageUrl;
  final String name;
  final int quantity;
  final double price;
  final double? unitPrice;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 58,
            height: 58,
            child: NetworkImageWithFallback(url: imageUrl),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              if (onIncrement != null && onDecrement != null)
                QuantityStepper(
                  quantity: quantity,
                  size: 24,
                  onIncrement: onIncrement!,
                  onDecrement: onDecrement!,
                )
              else
                Text(
                  'Qty: $quantity',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Price: ${price.toInt()}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (unitPrice != null && quantity > 1) ...[
              const SizedBox(height: 2),
              Text(
                '${unitPrice!.toInt()} each',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// A label/value line ("Subtotal … ₹130"). Set [emphasized] for the grand total.
class PriceLine extends StatelessWidget {
  const PriceLine({
    super.key,
    required this.label,
    required this.value,
    this.emphasized = false,
    this.valueColor,
  });

  final String label;
  final double value;
  final bool emphasized;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      color: emphasized ? AppColors.textPrimary : AppColors.textSecondary,
      fontSize: emphasized ? 20 : 14,
      fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        PriceText(
          price: value,
          size: emphasized ? 20 : 15,
          color: valueColor ?? AppColors.textPrimary,
        ),
      ],
    );
  }
}

/// A thin horizontal divider tuned for the dark panels.
class PanelDivider extends StatelessWidget {
  const PanelDivider({super.key, this.height = 28});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: AppColors.border,
      thickness: 1,
      height: height,
    );
  }
}

/// A delivery-address line: pin, address text and an edit pencil.
class AddressRow extends StatelessWidget {
  const AddressRow({
    super.key,
    required this.address,
    this.onEdit,
  });

  final String address;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.location_on_outlined,
            color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            address,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.3,
            ),
          ),
        ),
        if (onEdit != null)
          _EditPencil(onTap: onEdit!),
      ],
    );
  }
}

class _EditPencil extends StatelessWidget {
  const _EditPencil({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: const SizedBox(
          width: 30,
          height: 30,
          child: Icon(Icons.edit_outlined, size: 15, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
