// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'dart:math' show pi;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gps_camera/extensions/extention.dart';
import 'package:gps_camera/main.dart';
import 'package:gps_camera/routers/router.config.dart';
import 'package:gps_camera/utils/widget_to_image.dart';
import 'package:gps_camera/widgets/location_tag.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:image/image.dart' as img;
import 'package:native_storage/native_storage.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GeoCamera extends StatefulWidget {
  const GeoCamera({super.key});

  @override
  State<GeoCamera> createState() => _GeoCameraState();
}

class _GeoCameraState extends State<GeoCamera> with WidgetsBindingObserver {
  CameraController? controller;
  final storage = NativeStorage();

  final flashMode = ValueNotifier(FlashMode.off);
  final file = ValueNotifier<File?>(null);
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
    final latestImage = storage.read('geoImage');
    if (latestImage == null) return;
    file.value = File(latestImage);
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
                child: Transform.rotate(
                  angle: isLandscape ? pi / 2 : 0,
                  child: RepaintBoundary(key: locationTagKey, child: LocationTag()),
                ),
              ),
            ),
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ValueListenableBuilder(
                    valueListenable: flashMode,
                    builder: (context, value, child) {
                      return Container(
                        height: context.screenSize.height * .1,
                        color: Colors.black,
                        padding: EdgeInsets.only(top: MediaQuery.viewPaddingOf(context).top),
                        child: Center(
                          child: InkWell(
                            onTap: () async {
                              await _setFlashMode(controller!);
                              flashMode.value = controller!.value.flashMode;
                            },
                            child: Icon(
                              value == FlashMode.off
                                  ? IconsaxPlusLinear.flash_slash
                                  : IconsaxPlusBold.flash_1,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
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
                        GestureDetector(
                          onTap: _onCameraChanged,
                          child: SizedBox(
                            height: 44,
                            width: 44,
                            child: Icon(IconsaxPlusLinear.refresh_2, size: 36, color: Colors.white),
                          ),
                        ),
                        _ShutterButton(
                          onPressed: () async {
                            await _savePicture();
                          },
                        ),
                        ValueListenableBuilder(
                          valueListenable: file,
                          builder: (context, value, child) {
                            return GestureDetector(
                              onTap: () {
                                if (value == null) return;
                                PreviewRoute(value).push(context);
                              },
                              child: Container(
                                height: 44,
                                width: 44,
                                color: Colors.white24,
                                child: value != null ? Image.file(value, fit: BoxFit.cover) : null,
                              ),
                            );
                          },
                        ),
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

  Future<void> _onCameraChanged() async {
    if (cameras.isNotEmpty && controller != null) {
      if (controller!.description == cameras.first) {
        controller!.setDescription(cameras.last);
      } else {
        controller!.setDescription(cameras.first);
      }
    }
  }

  Future<void> _setFlashMode(CameraController controller) async {
    if (controller.value.flashMode == FlashMode.off) {
      await controller.setFlashMode(FlashMode.auto);
    } else if (controller.value.flashMode == FlashMode.auto) {
      await controller.setFlashMode(FlashMode.off);
    }
  }

  Future<void> _savePicture() async {
    XFile? pic = await controller?.takePicture();
    if (pic == null) return;
    final picData = await pic.readAsBytes();
    final geoTag = await WidgetToImage.captureWidgetAsImage(
      globalKey: locationTagKey,
      pixelRatio: 2,
    );
    if (geoTag == null) return;
    img.Image captured = img.decodeImage(picData)!;
    img.Image tag = img.decodeImage(geoTag)!;

    img.Image rotated = img.copyRotate(captured, angle: isLandscape ? -90 : 0);
    final int posX = (rotated.width - tag.width) ~/ 2;
    final int posY = rotated.height - tag.height - 20;
    img.Image result = img.compositeImage(rotated, tag, dstX: posX, dstY: posY);

    final newFile = await WidgetToImage.saveImageToFile(
      imageBytes: img.encodeJpg(result),
      fileName: 'geo_image_${DateTime.now().toIso8601String()}.jpg',
    );
    if (newFile == null) return;
    storage.write('geoImage', newFile.path);
    file.value = newFile;
  }
}

final _isLoading = ValueNotifier(false);

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({this.onPressed});

  final AsyncCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _isLoading,
      builder: (context, value, child) {
        return InkResponse(
          onTap: () async {
            _isLoading.value = true;
            await onPressed?.call();
            _isLoading.value = false;
          },
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.orange),
            child: Container(
              // padding: EdgeInsets.all(12),
              clipBehavior: Clip.antiAlias,
              height: 64,
              width: 64,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              child: value ? Center(child: CircularProgressIndicator(year2023: false)) : null,
            ),
          ),
        );
      },
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
