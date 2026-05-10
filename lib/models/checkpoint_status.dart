import '../utils/localization.dart';
import '../utils/constants.dart';

class DirectionStatus {
  final String status; // OPEN, CROWDED, CLOSED
  final double percentage;
  final DateTime lastUpdated;
  final int totalVotes;
  
  DirectionStatus({
    required this.status,
    required this.percentage,
    required this.lastUpdated,
    required this.totalVotes,
  });
  
  String get localizedStatus => AppLocalizations.tr(status.toLowerCase());
  
  int get color {
    switch (status) {
      case 'OPEN': return AppConstants.openColor;
      case 'CROWDED': return AppConstants.crowdedColor;
      case 'CLOSED': return AppConstants.closedColor;
      default: return AppConstants.openColor;
    }
  }
}

class CheckpointStatus {
  final String checkpointId;
  final DirectionStatus entrance;
  final DirectionStatus exit;
  
  CheckpointStatus({
    required this.checkpointId,
    required this.entrance,
    required this.exit,
  });
}