import 'dart:async';
import 'dart:math' show pi;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gps_camera/main.dart';
import 'package:gps_camera/widgets/location_tag.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GeoCamera extends StatefulWidget {
  const GeoCamera({super.key});

  @override
  State<GeoCamera> createState() => _GeoCameraState();
}

class _GeoCameraState extends State<GeoCamera> with WidgetsBindingObserver {
  CameraController? controller;

  final isLoading = ValueNotifier(false);
  final flashMode = ValueNotifier(FlashMode.off);
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  bool isLandscape = false;

  Future<void> _cameraSetup() async {
    if (cameras.isNotEmpty) {
      setState(() {
        controller = CameraController(
          cameras.first,
          ResolutionPreset.high,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );
      });
      controller
          ?.initialize()
          .then((value) async {
            if (mounted) {
              setState(() {});
            }
          })
          .catchError((e) {
            debugPrint(e.toString());
          });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameraSetup();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    _accelerometerSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      if (mounted) {
        setState(() {
          isLandscape = event.x.abs() > event.y.abs();
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    _accelerometerSubscription.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _cameraSetup();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || controller?.value.isInitialized == false) {
      return _CameraLoading();
    }
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            Align(alignment: Alignment.center, child: CameraPreview(controller!)),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Transform.translate(
                offset: Offset(0, isLandscape ? -200 : 0),
                child: Transform.rotate(angle: isLandscape ? pi / 2 : 0, child: LocationTag()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraLoading extends StatelessWidget {
  const _CameraLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              Icon(IconsaxPlusBold.camera, size: 36),
              SizedBox(width: 28, height: 28, child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
