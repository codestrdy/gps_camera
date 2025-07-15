import 'package:flutter/material.dart';
import 'package:gps_camera/widgets/camera.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GeoCamera();
  }
}