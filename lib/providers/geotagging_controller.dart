import 'package:gps_camera/models/geotagging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/location_service.dart';

part 'geotagging_controller.g.dart';

@Riverpod(keepAlive: true)
class GeoTaggingController extends _$GeoTaggingController {
  @override
  FutureOr<GeoTagging> build() async {
    GeoTagging geoTagging = GeoTagging();
    final position = await LocationService.getCurrentLocation();
    final placemarks = await LocationService.getLocationDetails(position);
    return geoTagging.copyWith(position: position, address: placemarks.isNotEmpty ? placemarks[0] : null);
  }

  void addInfo(String info) {
    state = AsyncValue.data(state.value!.copyWith(additionalInfo: info));
  }
}
