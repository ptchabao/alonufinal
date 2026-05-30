import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// ============================================================================
// CUSTOM BUTTONS
// ============================================================================

/// Bouton Principal (Filled) - Utilisation standard des actions principales
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final bool isSmall;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
    this.padding,
    this.isSmall = false,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultPadding = isSmall 
        ? const EdgeInsets.symmetric(vertical: 8, horizontal: 12)
        : const EdgeInsets.symmetric(vertical: 14, horizontal: 16);

    return SizedBox(
      width: width ?? (isSmall ? null : double.infinity),
      child: ElevatedButton.icon(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        icon: isLoading ? SizedBox(
          height: isSmall ? 16 : 20,
          width: isSmall ? 16 : 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              foregroundColor ?? AppColors.onPrimary,
            ),
          ),
        ) : (icon != null ? Icon(icon, size: isSmall ? 16 : 20, color: foregroundColor ?? AppColors.onPrimary) : const SizedBox.shrink()),
        label: Text(
          label,
          style: isSmall 
              ? Theme.of(context).textTheme.labelMedium?.copyWith(color: foregroundColor ?? AppColors.onPrimary)
              : Theme.of(context).textTheme.titleMedium?.copyWith(color: foregroundColor ?? AppColors.onPrimary),
        ),
        style: ElevatedButton.styleFrom(
          padding: padding ?? defaultPadding,
          backgroundColor: isEnabled ? (backgroundColor ?? AppColors.primary) : AppColors.onSurfaceMuted,
          foregroundColor: foregroundColor ?? AppColors.onPrimary,
          disabledBackgroundColor: AppColors.onSurfaceMuted.withOpacity(0.5),
          disabledForegroundColor: (foregroundColor ?? AppColors.onPrimary).withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isSmall ? 8 : 12)),
          elevation: isEnabled ? 2 : 0,
        ),
      ),
    );
  }
}

/// Bouton Secondaire (Outlined) - Actions secondaires
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final double? width;
  final Color? borderColor;
  final Color? foregroundColor;

  const SecondaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
    this.borderColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: OutlinedButton.icon(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        icon: isLoading ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(foregroundColor ?? AppColors.primary),
          ),
        ) : (icon != null ? Icon(icon, color: foregroundColor ?? AppColors.primary) : const SizedBox.shrink()),
        label: Text(
          label,
          style: TextStyle(color: foregroundColor ?? AppColors.primary),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          foregroundColor: foregroundColor ?? AppColors.primary,
          side: BorderSide(
            color: isEnabled ? (borderColor ?? AppColors.primary) : AppColors.onSurfaceMuted,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

/// Bouton Tertiaire (Text) - Actions légères
class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? color;

  const AppTextButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: color ?? AppColors.primary),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color ?? AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// BADGES
// ============================================================================

/// Badge "MAÎTRE ARTISAN" avec gradient
class MasterArtisanBadge extends StatelessWidget {
  final double size;
  final Color? textColor;

  const MasterArtisanBadge({
    Key? key,
    this.size = 12,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.badgeGradient,
        borderRadius: BorderRadius.circular(8),
        boxShadow: AppColors.cardShadows,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            size: size,
            color: textColor ?? AppColors.onPrimary,
          ),
          const SizedBox(width: 4),
          Text(
            'MAÎTRE',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: textColor ?? AppColors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge de statut de commande
class StatusBadge extends StatelessWidget {
  final String status;
  final Color? backgroundColor;
  final Color? textColor;

  const StatusBadge({
    Key? key,
    required this.status,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
      case 'CONFIRMÉE':
        return AppColors.info;
      case 'IN_PROGRESS':
      case 'EN COURS':
        return AppColors.primary;
      case 'COMPLETED':
      case 'TERMINÉE':
        return AppColors.success;
      case 'CANCELLED':
      case 'ANNULÉE':
        return AppColors.error;
      case 'PENDING':
      case 'EN ATTENTE':
        return AppColors.warning;
      default:
        return AppColors.onSurfaceMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = backgroundColor ?? _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: textColor ?? color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Badge générique avec couleur personnalisée
class AppBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const AppBadge({
    Key? key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor ?? AppColors.primary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: textColor ?? AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CHIPS (FILTRES)
// ============================================================================

/// Chip filtrable
class AppFilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  const AppFilterChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.icon,
  }) : super(key: key);

  @override
  State<AppFilterChip> createState() => _AppFilterChipState();
}

class _AppFilterChipState extends State<AppFilterChip> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onSelected(!widget.isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: widget.isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 16,
                color: widget.isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              widget.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: widget.isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
