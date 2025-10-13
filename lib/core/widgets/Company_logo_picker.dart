import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../../config/app_spacing.dart';

class CompanyLogoPickerController extends GetxController {
  final void Function(File?) onImageSelected;
  final String? initialImage;
  CompanyLogoPickerController({required this.onImageSelected, this.initialImage});

  var selectedImage = Rxn<File>();
  static const int maxFileSizeKB = 200;
  static const int requiredWidth = 170;
  static const int requiredHeight = 170;

  Future<void> pickImage(ImageSource source, BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      await processAndCompressImage(bytes, context);
    }
  }

  Future<void> processAndCompressImage(Uint8List bytes, BuildContext context) async {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        showErrorDialog('Invalid Image', 'Unable to process the selected image.', context);
        return;
      }

      // Step 1: Resize proportionally (keep aspect ratio)
      final resized = img.copyResize(
        decoded,
        width: decoded.width > decoded.height ? null : requiredWidth,
        height: decoded.height >= decoded.width ? null : requiredHeight,
        interpolation: img.Interpolation.average,
      );

      // Step 2: Crop a centered square 170x170
      final cropped = img.copyCrop(
        resized,
        x: (resized.width - requiredWidth) ~/ 2,
        y: (resized.height - requiredHeight) ~/ 2,
        width: requiredWidth,
        height: requiredHeight,
      );

      // Step 3: Compress iteratively until under size limit
      int quality = 95;
      Uint8List compressedBytes;
      do {
        compressedBytes = Uint8List.fromList(img.encodeJpg(cropped, quality: quality));
        if (compressedBytes.length <= maxFileSizeKB * 1024) break;
        quality -= 10;
        if (quality < 30) {
          showErrorDialog('Compression Failed', 'Unable to compress image to required size. Please try a different image.', context);
          return;
        }
      } while (compressedBytes.length > maxFileSizeKB * 1024);

      // Save file
      final tempFile = await File(
        '${Directory.systemTemp.path}/logo_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ).writeAsBytes(compressedBytes);

      selectedImage.value = tempFile;
      onImageSelected(tempFile);

    } catch (e) {
      showErrorDialog('Processing Error', 'Failed to process image: $e', context);
    }
  }

  void showErrorDialog(String title, String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showSuccessDialog(String title, String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title, style: const TextStyle(color: Colors.green)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showImageSourceOptions(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) {
      await pickImage(source, context);
    }
  }

  void showPreview(BuildContext context) {
    if (selectedImage.value == null) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(selectedImage.value!),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Size: ${requiredWidth}x${requiredHeight}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompanyLogoPicker extends StatelessWidget {
  final void Function(File?) onImageSelected;
  final String? initialImage;
  final bool showAddIcon;

  const CompanyLogoPicker({
    Key? key,
    required this.onImageSelected,
    this.initialImage,
    required this.showAddIcon
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CompanyLogoPickerController controller = Get.put(
      CompanyLogoPickerController(
        onImageSelected: onImageSelected,
        initialImage: initialImage,
      ),
      tag: initialImage ?? UniqueKey().toString(),
    );
    ImageProvider? displayImage;
    if (controller.selectedImage.value != null) {
      displayImage = FileImage(controller.selectedImage.value!);
    } else if (initialImage != null && initialImage!.isNotEmpty) {
      displayImage = initialImage!.startsWith('http')
          ? NetworkImage(initialImage!)
          : FileImage(File(initialImage!));
    }
    return Obx(() => Column(
      children: [
        GestureDetector(
          onTap: controller.selectedImage.value != null ? () => controller.showPreview(context) : null,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: displayImage,
                child: displayImage == null
                    ? const Icon(Icons.camera_alt, color: Colors.grey, size: 40)
                    : null,
              ),
              if (showAddIcon)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => controller.showImageSourceOptions(context),
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.add, size: 16, color: Colors.deepOrange),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ));

  }
}