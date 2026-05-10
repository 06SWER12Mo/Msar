import 'package:cloud_firestore/cloud_firestore.dart';

class Vote {
  final String id;
  final String checkpointId;
  final String userId;
  final String direction; // ENTRANCE or EXIT
  final String status;    // OPEN, CROWDED, CLOSED
  final String? comment;
  final DateTime timestamp;
  final double? userLatitude;
  final double? userLongitude;
  
  Vote({
    required this.id,
    required this.checkpointId,
    required this.userId,
    required this.direction,
    required this.status,
    this.comment,
    required this.timestamp,
    this.userLatitude,
    this.userLongitude,
  });
  
  factory Vote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Vote(
      id: doc.id,
      checkpointId: data['checkpointId'] ?? '',
      userId: data['userId'] ?? '',
      direction: data['direction'] ?? '',
      status: data['status'] ?? '',
      comment: data['comment'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userLatitude: data['userLatitude']?.toDouble(),
      userLongitude: data['userLongitude']?.toDouble(),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'checkpointId': checkpointId,
      'userId': userId,
      'direction': direction,
      'status': status,
      'comment': comment,
      'timestamp': Timestamp.fromDate(timestamp),
      'userLatitude': userLatitude,
      'userLongitude': userLongitude,
    };
  }
}