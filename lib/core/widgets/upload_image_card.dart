import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

class UploadImageCardController extends GetxController {
  final Rx<File?> selectedImage = Rx<File?>(null);
  final void Function(File?) onImageSelected;
  final BuildContext context;
  UploadImageCardController({required this.onImageSelected, required this.context});

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
      onImageSelected(selectedImage.value);
    }
  }
}

class UploadImageCard extends StatelessWidget {
  final String title;
  final void Function(File?) onImageSelected;

  const UploadImageCard({
    Key? key,
    required this.title,
    required this.onImageSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UploadImageCardController(onImageSelected: onImageSelected, context: context));
    return GestureDetector(
      onTap: controller.pickImage,
      child: Obx(() => Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: controller.selectedImage.value != null
            ? Image.file(controller.selectedImage.value!, fit: BoxFit.cover)
            : Center(child: Text("Tap to upload $title")),
      )),
    );
  }
}
