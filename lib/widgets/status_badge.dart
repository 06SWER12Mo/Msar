import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/localization.dart';

class StatusBadge extends StatelessWidget {
  final String status; // OPEN, CROWDED, CLOSED
  final bool showLabel;
  final double size;
  final bool compact;
  
  const StatusBadge({
    Key? key,
    required this.status,
    this.showLabel = true,
    this.size = 12,
    this.compact = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);
    
    if (compact) {
      // Compact version - just a colored dot
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: statusColor,
          shape: BoxShape.circle,
        ),
      );
    }
    
    // Full badge with label
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              _getLocalizedStatus(status),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'OPEN':
        return const Color(AppConstants.openColor);
      case 'CROWDED':
        return const Color(AppConstants.crowdedColor);
      case 'CLOSED':
        return const Color(AppConstants.closedColor);
      default:
        return const Color(AppConstants.openColor);
    }
  }
  
  String _getLocalizedStatus(String status) {
    switch (status) {
      case 'OPEN':
        return AppLocalizations.tr('open');
      case 'CROWDED':
        return AppLocalizations.tr('crowded');
      case 'CLOSED':
        return AppLocalizations.tr('closed');
      default:
        return status;
    }
  }
}

// Extension for easier usage
extension StatusBadgeExtension on String {
  Color get statusColor {
    switch (this) {
      case 'OPEN':
        return const Color(AppConstants.openColor);
      case 'CROWDED':
        return const Color(AppConstants.crowdedColor);
      case 'CLOSED':
        return const Color(AppConstants.closedColor);
      default:
        return const Color(AppConstants.openColor);
    }
  }
  
  String get localizedStatus {
    switch (this) {
      case 'OPEN':
        return AppLocalizations.tr('open');
      case 'CROWDED':
        return AppLocalizations.tr('crowded');
      case 'CLOSED':
        return AppLocalizations.tr('closed');
      default:
        return this;
    }
  }
}