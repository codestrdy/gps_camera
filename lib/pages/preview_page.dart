import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:share_plus/share_plus.dart';

class PreviewPage extends ConsumerStatefulWidget {
  const PreviewPage({super.key, required this.image});

  final File image;

  @override
  ConsumerState<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends ConsumerState<PreviewPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              final params = ShareParams(files: [XFile(widget.image.path)]);
              await SharePlus.instance.share(params);
            },
            icon: Icon(IconsaxPlusLinear.share),
          ),
          SizedBox(width: 8),
          IconButton(
            onPressed: () async {
              await _saveToGallery(context);
            },
            icon: Icon(IconsaxPlusLinear.import_2),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Center(child: Image.file(widget.image)),
    );
  }

  Future<void> _saveToGallery(BuildContext context) async {
    final hasAccess = await Gal.hasAccess();
    log('hasAccess $hasAccess');
    if (!hasAccess) {
      await Gal.requestAccess();
    }
    log(widget.image.path);
    await Gal.putImage(widget.image.path);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Foto Tersimpan')));
    }
  }
}
