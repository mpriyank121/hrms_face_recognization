import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'Leave_Container.dart';

class MultiImagePickerController extends GetxController {
  final RxList<File> selectedImages = <File>[].obs;
  final int maxImages;
  BuildContext? context;
  void Function(List<File>)? onImagesSelected;

  MultiImagePickerController({required this.maxImages, this.context, this.onImagesSelected, List<String>? initialImages}) {
    if (initialImages != null) {
      for (String imagePath in initialImages) {
        if (imagePath.isNotEmpty && !imagePath.startsWith('http')) {
          final file = File(imagePath);
          if (file.existsSync()) {
            selectedImages.add(file);
          }
        }
      }
    }
  }

  Future<void> pickImages() async {
    if (selectedImages.length >= maxImages) {
      _showErrorDialog(
        'Maximum images reached',
        'You can only select up to $maxImages images.',
      );
      return;
    }
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null) {
      final newImages = images.map((xFile) => File(xFile.path)).toList();
      if (selectedImages.length + newImages.length > maxImages) {
        _showErrorDialog(
          'Too many images',
          'You can only select up to $maxImages images in total.',
        );
        return;
      }
      selectedImages.addAll(newImages);
      if (onImagesSelected != null) onImagesSelected!(selectedImages);
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
    if (onImagesSelected != null) onImagesSelected!(selectedImages);
  }

  void _showErrorDialog(String title, String message) {
    if (context == null) return;
    showDialog(
      context: context!,
      builder: (BuildContext context) {
        return AlertDialog(
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
}

class MultiImagePicker extends StatelessWidget {
  final void Function(List<File>) onImagesSelected;
  final List<String>? initialImages;
  final int maxImages;

  const MultiImagePicker({
    Key? key,
    required this.onImagesSelected,
    this.initialImages,
    this.maxImages = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MultiImagePickerController(
      maxImages: maxImages,
      context: context,
      onImagesSelected: onImagesSelected,
      initialImages: initialImages,
    ));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LeaveContainer(
          child: InkWell(
            onTap: controller.pickImages,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload,
                    size: 40,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                    'Tap to select images ( ${controller.selectedImages.length}/$maxImages)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  )),
                  Obx(() => controller.selectedImages.isNotEmpty ? Column(
                    children: [
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: controller.selectedImages.asMap().entries.map((entry) {
                          final index = entry.key;
                          final image = entry.value;
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  image,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => controller.removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ) : SizedBox.shrink()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
} 