// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../Employee/Widgets/Employee_Navigation.dart';
// import '../../config/app_colors.dart';
// import '../../features/Employees/employees_screen.dart';
// import '../../features/Management/management_screen.dart';
// import '../../features/Salary/salary_screen.dart';
// import '../../features/Settings/setting_page.dart';
//
// class MainScreenController extends GetxController {
//   final RxInt selectedIndex = 0.obs;
//   final List<Widget> screens = [
//     ManagementScreen(),
//     SalaryScreen(),
//     EmployeesScreen(),
//     SettingPage(title: '',)
//   ];
//
//   void onItemTapped(int index) {
//     selectedIndex.value = index;
//   }
//
//   Future<bool> onWillPop() async {
//     if (selectedIndex.value != 2) {
//       selectedIndex.value = 2;
//       return false;
//     }
//     return true;
//   }
// }
//
// class MainScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(MainScreenController());
//     final List<NavTab> tabs = [
//       NavTab(label: 'Attendance', assetPath: 'assets/images/clock.png', iconType: IconType.png),
//       NavTab(label: 'Salary', assetPath: 'assets/images/currency-rupee-circle.png', iconType: IconType.png),
//       NavTab(label: 'Employees', assetPath: 'assets/images/users-03.png', iconType: IconType.png),
//       NavTab(label: 'Profile', assetPath: 'assets/images/settings-02.png', iconType: IconType.png),
//     ];
//     return CustomBottomNavigationBar(
//       screens: controller.screens,
//       tabs: tabs,
//       selectedIndex: controller.selectedIndex,
//       onTabChanged: controller.onItemTapped,
//       onWillPop: controller.onWillPop,
//       selectedItemColor: AppColors.secondary,
//       unselectedItemColor: Colors.grey,
//       iconSize: 24,
//       fontSize: 12,
//     );
//   }
// }
