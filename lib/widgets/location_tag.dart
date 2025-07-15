import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gps_camera/extensions/extention.dart';
import 'package:gps_camera/models/geotagging.dart';
import 'package:gps_camera/providers/geotagging_controller.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:latlong2/latlong.dart';

final GlobalKey locationTagKey = GlobalKey();

class LocationTag extends ConsumerWidget {
  const LocationTag({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final geoTagging = ref.watch(geoTaggingControllerProvider);
    return switch (geoTagging) {
      AsyncData(:final value) => _LocationTagData(data: value),
      AsyncError() => const SizedBox.shrink(),
      _ => const SizedBox.shrink(),
    };
  }
}

class GCMap extends StatelessWidget {
  const GCMap({super.key, this.position});

  final Position? position;

  @override
  Widget build(BuildContext context) {
    var loading = Center(child: CircularProgressIndicator());
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: AspectRatio(aspectRatio: 1, child: position == null ? loading : map(position!)),
    );
  }

  Widget map(Position position) {
    final latLong = LatLng(position.latitude, position.longitude);
    return FlutterMap(
      options: MapOptions(
        initialCenter: latLong,
        initialZoom: 15,
        minZoom: 2.0,
        maxZoom: 20,
        interactionOptions: InteractionOptions(flags: InteractiveFlag.none),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.gps_camera', // Ganti dengan package name Anda
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: latLong,
              width: 24, // Ukuran marker
              height: 24,
              child: Icon(IconsaxPlusBold.location, color: Colors.red),
            ),
          ],
        ),
      ],
    );
  }
}

class _LocationTagData extends StatelessWidget {
  const _LocationTagData({required this.data});

  final GeoTagging data;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return GestureDetector(
      onTap: () {
        if (kDebugMode) {
          debugPrint(data.address?.toString());
        }
      },
      child: Row(
        spacing: 8,
        children: [
          Expanded(flex: 1, child: GCMap(position: data.position)),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    showPlacemark().$1 ?? '',
                    style: TextStyle(
                      fontSize: 11.sp(context),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    showPlacemark().$2,
                    style: TextStyle(fontSize: 10.sp(context), color: Colors.white),
                  ),
                  Text(
                    'Lat ${data.position?.latitude ?? 0}° Long ${data.position?.longitude ?? 0}°',
                    style: TextStyle(fontSize: 10.sp(context), color: Colors.white),
                  ),
                  Text(
                    '${now.formatted} ${now.timeZoneName}',
                    style: TextStyle(fontSize: 10.sp(context), color: Colors.white),
                  ),
                  if (data.additionalInfo != null)
                    Text(
                      data.additionalInfo ?? '',
                      style: TextStyle(fontSize: 10.sp(context), color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  (String?, String) showPlacemark() {
    final p = data.address;
    if (p == null) {
      return (null, 'Lokasi Tidak Ditemukan');
    }
    return (
      '${p.locality!.replaceAll('Kecamatan ', '')}, ${p.administrativeArea}, ${p.country}',
      '${p.street!.replaceAll('Jalan', 'Jl.')}, ${p.subLocality}, ${p.locality!.replaceAll('Kecamatan', 'Kec.')}, ${p.subAdministrativeArea}, ${p.administrativeArea} (${p.postalCode}), ${p.country}',
    );
  }
}
