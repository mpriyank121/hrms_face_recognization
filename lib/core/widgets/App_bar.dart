// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../config/app_borders.dart';
//
// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final Widget? leading;
//   final String? title;
//   final Widget? trailing;
//   final List<Widget>? actions;
//   final bool showBackButton;
//   final bool showTrailing;
//   final bool showOrgLogo;
//   final bool showOrgName;
//   final bool showAddLogoWhenMissing;
//
//   const CustomAppBar({
//     Key? key,
//     this.leading,
//     this.title,
//     this.actions,
//     this.showBackButton = true,
//     this.showTrailing = false,
//     this.showOrgLogo = false,
//     this.showOrgName = false,
//     this.showAddLogoWhenMissing = true,
//     this.trailing,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // Use Get.find() instead of Get.put() to retrieve existing controller
//     // Only wrap in Obx if we need reactive logo/name
//     if (showOrgLogo || showOrgName) {
//       return Container(
//         decoration: AppBorders.bottomBorder,
//         child: Obx(() {
//           final settingsController = Get.find<SettingsController>();
//
//           // Determine if leading exists
//           final bool hasLeading = showBackButton ||
//               (showOrgLogo &&
//                   (settingsController.orgLogoUrl.value.isNotEmpty ||
//                       showAddLogoWhenMissing));
//
//           return AppBar(
//             automaticallyImplyLeading: false,
//             leading: _buildLeadingWidget(context, settingsController),
//             title: Text(title ?? "", style: FontStyles.headingStyle()),
//             centerTitle: hasLeading,
//             actions: [
//               if (actions != null) ...actions!,
//               if (showTrailing && trailing != null) trailing!,
//             ],
//           );
//         }),
//       );
//     }
//
//     // If not using logo/name, don't use Obx or controller at all
//     return Container(
//       decoration: AppBorders.bottomBorder,
//       child: AppBar(
//         automaticallyImplyLeading: false,
//         leading: showBackButton
//             ? IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Get.back(),
//         )
//             : null,
//         title: Text(title ?? "", style: FontStyles.headingStyle()),
//         centerTitle: showBackButton,
//         actions: [
//           if (actions != null) ...actions!,
//           if (showTrailing && trailing != null) trailing!,
//         ],
//       ),
//     );
//   }
//
//   Widget? _buildLeadingWidget(
//       BuildContext context, SettingsController settingsController) {
//     if (showBackButton) {
//       return IconButton(
//         icon: const Icon(Icons.arrow_back),
//         onPressed: () => Get.back(),
//       );
//     }
//
//     if (showOrgLogo) {
//       final logoUrl = settingsController.orgLogoUrl.value;
//
//       if (logoUrl.isNotEmpty) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//           child: CircleAvatar(
//             backgroundImage: NetworkImage(logoUrl),
//             backgroundColor: Colors.grey.shade200,
//           ),
//         );
//       } else if (showAddLogoWhenMissing) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//           child: _buildAddLogoWidget(settingsController),
//         );
//       }
//     }
//
//     return null;
//   }
//
//   Widget _buildAddLogoWidget(SettingsController settingsController) {
//     return InkWell(
//       onTap: () => Get.to(() => CompanyDetailsScreen(
//         phone: settingsController.userPhone.value,
//         isEditMode: true,
//       )),
//       child: Stack(
//         alignment: Alignment.center,
//         clipBehavior: Clip.none,
//         children: [
//           Container(
//             width: double.infinity,
//             height: double.infinity,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: [Colors.grey.shade200, Colors.grey.shade100],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               border: Border.all(
//                 color: Colors.grey.shade400,
//                 width: 1,
//               ),
//             ),
//             child: Icon(
//               Icons.camera_alt_outlined,
//               color: Colors.grey.shade600,
//               size: 18,
//             ),
//           ),
//           Positioned(
//             bottom: 1,
//             right: -4,
//             child: Container(
//               padding: const EdgeInsets.all(3),
//               decoration: BoxDecoration(
//                 color: Colors.deepOrange,
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.15),
//                     blurRadius: 3,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.add,
//                 size: 12,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }