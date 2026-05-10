import 'package:cloud_firestore/cloud_firestore.dart';

class Checkpoint {
  final String id;
  final String name;
  final String region;
  final double latitude;
  final double longitude;
  final String? createdBy;
  final DateTime createdAt;
  
  Checkpoint({
    required this.id,
    required this.name,
    required this.region,
    required this.latitude,
    required this.longitude,
    this.createdBy,
    required this.createdAt,
  });
  
  factory Checkpoint.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Safe conversion from any type to double
    double _toDouble(dynamic value) {
      if (value == null)
       return 0.0;

      if (value is double)
       return value;

      if (value is int)
       return value.toDouble();
       
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed ?? 0.0;
      }
      return 0.0;
    }
    
    return Checkpoint(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      region: data['region']?.toString() ?? '',
      latitude: _toDouble(data['latitude']),
      longitude: _toDouble(data['longitude']),
      createdBy: data['createdBy']?.toString(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'region': region,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}