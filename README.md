# GPS Camera App

## Widget to Image Capture Feature

This project demonstrates how to capture Flutter widgets as images using RepaintBoundary.

### How to Capture a Widget as an Image

The app includes a utility class `WidgetToImage` that provides methods for capturing widgets as images using RepaintBoundary.

#### Basic Steps:

1. Wrap the widget you want to capture with a `RepaintBoundary` and assign it a `GlobalKey`:

```dart
final GlobalKey _repaintBoundaryKey = GlobalKey();

// In your build method:
RepaintBoundary(
  key: _repaintBoundaryKey,
  child: YourWidget(),
)
```

2. Use the `WidgetToImage` utility to capture and save the widget as an image:

```dart
Future<void> captureWidget() async {
  final file = await WidgetToImage.captureAndSaveWidgetAsImage(
    globalKey: _repaintBoundaryKey,
    fileName: 'widget_image.png',
  );
  
  if (file != null) {
    // Image captured successfully
    print('Image saved at: ${file.path}');
  }
}
```

### Example

The app includes a complete example in `lib/examples/capture_widget_example.dart` that demonstrates how to:

1. Wrap a widget with RepaintBoundary
2. Capture it as an image
3. Display the captured image
4. Show the file path where the image is saved

### Available Methods

The `WidgetToImage` utility provides three main methods:

1. `captureWidgetAsImage` - Captures a widget as a Uint8List of image bytes
2. `saveImageToFile` - Saves image bytes to a file
3. `captureAndSaveWidgetAsImage` - Combines the above two operations in one step

### Tips for Best Results

- Use a higher `pixelRatio` for better quality images (default is 3.0)
- Ensure the widget is fully rendered before capturing
- For widgets that depend on network resources, consider adding a delay before capture
- The captured image will match exactly what is displayed on screen, including any transparency

### Dependencies

This feature uses the following packages:
- `path_provider` - For accessing the file system to save images
