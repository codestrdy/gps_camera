import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

/// A utility class for converting widgets to images using RepaintBoundary
class WidgetToImage {
  /// Captures a widget as an image using RepaintBoundary
  /// 
  /// [globalKey] - The GlobalKey associated with the RepaintBoundary widget
  /// [pixelRatio] - The pixel ratio to use when capturing the image (default: 3.0)
  static Future<Uint8List?> captureWidgetAsImage({
    required GlobalKey globalKey,
    double pixelRatio = 3.0,
  }) async {
    try {
      // Find the RenderRepaintBoundary using the provided key
      final RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      // Capture the image from the boundary
      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      
      // Convert the image to bytes
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        return byteData.buffer.asUint8List();
      }
      return null;
    } catch (e) {
      debugPrint('Error capturing widget as image: $e');
      return null;
    }
  }

  /// Saves the captured widget image to a file
  /// 
  /// [imageBytes] - The bytes of the captured image
  /// [fileName] - The name to use for the saved file (default: 'widget_image.png')
  static Future<File?> saveImageToFile({
    required Uint8List imageBytes,
    String fileName = 'widget_image.png',
  }) async {
    try {
      // Get the temporary directory path
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';
      
      // Write the image bytes to a file
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);
      
      return file;
    } catch (e) {
      debugPrint('Error saving image to file: $e');
      return null;
    }
  }

  /// Captures a widget and saves it as an image file in one step
  /// 
  /// [globalKey] - The GlobalKey associated with the RepaintBoundary widget
  /// [fileName] - The name to use for the saved file (default: 'widget_image.png')
  /// [pixelRatio] - The pixel ratio to use when capturing the image (default: 3.0)
  static Future<File?> captureAndSaveWidgetAsImage({
    required GlobalKey globalKey,
    String fileName = 'widget_image.png',
    double pixelRatio = 3.0,
  }) async {
    final imageBytes = await captureWidgetAsImage(
      globalKey: globalKey,
      pixelRatio: pixelRatio,
    );
    
    if (imageBytes != null) {
      return await saveImageToFile(
        imageBytes: imageBytes,
        fileName: fileName,
      );
    }
    
    return null;
  }
}