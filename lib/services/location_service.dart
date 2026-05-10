import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    
    if (permission == LocationPermission.deniedForever) return null;
    
    return await Geolocator.getCurrentPosition();
  }
  
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // km
  }
  
  bool isWithinVotingRadius(double userLat, double userLon, 
      double checkpointLat, double checkpointLon) {
    final distance = calculateDistance(userLat, userLon, checkpointLat, checkpointLon);
    return distance <= 3.0; // 3km radius
  }
}