import 'dart:async';
import 'dart:math' show pi;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gps_camera/extensions/extention.dart';
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
              bottom: context.screenSize.height * .16,
              left: 8,
              right: 8,
              child: Transform.translate(
                offset: Offset(
                  isLandscape ? -context.screenSize.height * .16 : 0,
                  isLandscape ? -context.screenSize.width * .37 : 0,
                ),
                child: Transform.rotate(angle: isLandscape ? pi / 2 : 0, child: LocationTag()),
              ),
            ),
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: context.screenSize.height * .12,
                    color: Colors.black,
                    padding: EdgeInsets.only(top: MediaQuery.viewPaddingOf(context).top),
                    child: Center(child: Icon(IconsaxPlusBold.flash_slash, color: Colors.white)),
                  ),
                  Container(
                    height: context.screenSize.height * .15,
                    width: context.screenSize.width,
                    padding: EdgeInsets.fromLTRB(
                      24,
                      24,
                      24,
                      24 + MediaQuery.viewPaddingOf(context).bottom,
                    ),
                    color: Colors.black,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          height: 44,
                          width: 44,
                          child: Icon(IconsaxPlusLinear.refresh_2, size: 36, color: Colors.white),
                        ),
                        _ShutterButton(onPressed: () {}),
                        Container(height: 44, width: 44, color: Colors.white38),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onPressed,
      child: Container(
        height: 64,
        width: 64,
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.orange),
        child: Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
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
