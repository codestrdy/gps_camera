import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  const LocationService._();

  static Future<bool> isLocationEnabled() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return true;
  }

  static Future<Position> getCurrentLocation() async {
    final isEnabled = await isLocationEnabled();
    if (!isEnabled) {
      throw Exception('Location services are disabled.');
    }

    return await Geolocator.getCurrentPosition();
  }

  static Future<Position?> getLastKnownLocation() async {
    final isEnabled = await isLocationEnabled();
    if (!isEnabled) {
      throw Exception('Location services are disabled.');
    }

    return await Geolocator.getLastKnownPosition();
  }

  static Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    );
  }

  static Future<List<Placemark>> getLocationDetails(Position position) async {
    return await placemarkFromCoordinates(position.latitude, position.longitude);
  }
}
