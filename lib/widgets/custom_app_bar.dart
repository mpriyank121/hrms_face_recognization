import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_borders.dart';
import '../config/font_style.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final String? title;
  final Widget? trailing;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showTrailing;
  final bool showOrgLogo;
  final bool showOrgName;
  final bool showAddLogoWhenMissing;

  const CustomAppBar({
    Key? key,
    this.leading,
    this.title,
    this.actions,
    this.showBackButton = true,
    this.showTrailing = false,
    this.showOrgLogo = false,
    this.showOrgName = false,
    this.showAddLogoWhenMissing = true,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use Get.find() instead of Get.put() to retrieve existing controller
    // Only wrap in Obx if we need reactive logo/name
    if (showOrgLogo || showOrgName) {
      return Container(
        decoration: AppBorders.bottomBorder,
        child: Obx(() {

          return AppBar(
            automaticallyImplyLeading: false,
            leading: leading,
            title: Text(title ?? "", style: FontStyles.headingStyle()),

          );
        }),
      );
    }

    // If not using logo/name, don't use Obx or controller at all
    return Container(
      decoration: AppBorders.bottomBorder,
      child: AppBar(
        automaticallyImplyLeading: false,
        leading: showBackButton
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        )
            : null,
        title: Text(title ?? "", style: FontStyles.headingStyle()),
        centerTitle: true,
        actions: [
          if (actions != null) ...actions!,
          if (showTrailing && trailing != null) trailing!,
        ],
      ),
    );
  }





  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}