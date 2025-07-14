import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_camera/utils/widget_to_image.dart';
import 'package:gps_camera/widgets/location_tag.dart';

class CaptureWidgetExample extends ConsumerStatefulWidget {
  const CaptureWidgetExample({super.key});

  @override
  ConsumerState<CaptureWidgetExample> createState() => _CaptureWidgetExampleState();
}

class _CaptureWidgetExampleState extends ConsumerState<CaptureWidgetExample> {
  // Create a GlobalKey to identify the RepaintBoundary
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  
  // Store the captured image file
  File? _capturedImageFile;
  
  // Loading state
  bool _isCapturing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Widget Example'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Original Widget:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            // Wrap the widget with RepaintBoundary and assign the GlobalKey
            RepaintBoundary(
              key: _repaintBoundaryKey,
              child: const LocationTag(),
            ),
            
            const SizedBox(height: 24),
            
            // Button to capture the widget as an image
            ElevatedButton.icon(
              onPressed: _isCapturing ? null : _captureWidget,
              icon: _isCapturing 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Icon(Icons.camera_alt),
              label: Text(_isCapturing ? 'Capturing...' : 'Capture Widget as Image'),
            ),
            
            const SizedBox(height: 24),
            
            // Display the captured image if available
            if (_capturedImageFile != null) ...[  
              const Text(
                'Captured Image:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Image.file(_capturedImageFile!),
              const SizedBox(height: 8),
              Text('Image saved at: ${_capturedImageFile!.path}'),
            ],
          ],
        ),
      ),
    );
  }

  // Method to capture the widget as an image
  Future<void> _captureWidget() async {
    setState(() {
      _isCapturing = true;
    });
    
    try {
      // Use the utility class to capture and save the widget as an image
      final file = await WidgetToImage.captureAndSaveWidgetAsImage(
        globalKey: _repaintBoundaryKey,
        fileName: 'location_tag_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      
      if (file != null) {
        setState(() {
          _capturedImageFile = file;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Widget captured and saved to: ${file.path}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture widget')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }
}