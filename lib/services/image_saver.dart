import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageSaver {
  static Future<String?> saveAsPng(GlobalKey repaintBoundaryKey) async {
    try {
      // Request storage permission
      if (Platform.isAndroid) {
        // Try photos permission first (Android 13+)
        PermissionStatus status = await Permission.photos.status;
        if (!status.isGranted) {
          status = await Permission.photos.request();
          if (!status.isGranted) {
            // Fallback to storage permission for older Android versions
            status = await Permission.storage.request();
            if (!status.isGranted) {
              return null;
            }
          }
        }
      }

      // Get the render object
      final RenderRepaintBoundary boundary =
          repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // Convert to image
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to gallery
      final result = await ImageGallerySaver.saveImage(
        pngBytes,
        quality: 100,
        name: 'uml_diagram_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result['isSuccess'] == true) {
        return result['filePath'] as String?;
      }
      return null;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  static Future<String?> saveToFile(GlobalKey repaintBoundaryKey) async {
    try {
      // Get the render object
      final RenderRepaintBoundary boundary =
          repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // Convert to image
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Get directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'uml_diagram_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      return file.path;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }
}

