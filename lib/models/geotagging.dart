import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class GeoTagging {
  final Position? position;
  final Placemark? address;
  final String? additionalInfo;

  const GeoTagging({
    this.position,
    this.address,
    this.additionalInfo,
  });

  GeoTagging copyWith({
    Position? position,
    Placemark? address,
    String? additionalInfo,
  }) {
    return GeoTagging(
      position: position ?? this.position,
      address: address ?? this.address,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}
