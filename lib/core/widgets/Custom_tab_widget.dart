import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabControllerX extends GetxController {
  var selectedIndex = 0.obs;

  void selectTab(int index) {
    selectedIndex.value = index;
  }

  @override
  void onClose() {
    // Clean up when controller is disposed
    super.onClose();
  }
}

class CustomTabWidget extends StatelessWidget {
  final List<String> tabTitles;
  final TabControllerX controller;
  final Function(int)? onTabChanged; // Add callback parameter

  const CustomTabWidget({
    Key? key,
    required this.tabTitles,
    required this.controller,
    this.onTabChanged, // Make it optional
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: List.generate(tabTitles.length, (index) {
            bool isSelected = controller.selectedIndex.value == index;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  controller.selectTab(index);
                  onTabChanged?.call(index); // Call the callback if provided
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.deepOrange : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tabTitles[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.deepOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      );
    });
  }
}