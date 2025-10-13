// import 'package:flutter/material.dart';
// import '../../config/font_style.dart';
// import 'package:get/get.dart';
//
// class DateRangeSelectorController extends GetxController {
//   final Rx<DateTimeRange?> selectedDateRange = Rx<DateTimeRange?>(null);
//   final RxString displayText = 'This Month'.obs;
//   final Color primaryColor;
//   late final Map<String, DateTimeRange Function()> dateOptions;
//   BuildContext? context;
//   void Function(DateTime, DateTime)? onDateRangeSelected;
//   bool _isInitialized = false; // Track if we've been initialized
//
//   DateRangeSelectorController({required this.primaryColor, this.onDateRangeSelected, this.context}) {
//     _initializeDateOptions();
//     _setThisMonth();
//   }
//
//   void _initializeDateOptions() {
//     final now = DateTime.now();
//     dateOptions = {
//       'Today': () => _dayRange(now),
//       'Yesterday': () => _dayRange(now.subtract(Duration(days: 1))),
//       'This Week': () => _weekRange(now),
//       'Last Week': () => _weekRange(now.subtract(Duration(days: 7))),
//       'This Month': () => _monthRange(now),
//       'Last Month': () => _monthRange(DateTime(now.year, now.month - 1)),
//     };
//   }
//
//   // void _setThisMonth() {
//   //   final range = dateOptions['This Month']!();
//   //   updateDateRange(range, 'This Month', skipCallback: true); // Skip callback on initialization
//   // }
//
//   void showDateRangeOptions() async {
//     if (context == null) return;
//     final result = await showDialog<DateTimeRange?>(
//       context: context!,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Container(
//           constraints: BoxConstraints(maxWidth: 400, maxHeight: 600),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildHeader(),
//               Flexible(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.all(8),
//                   child: Column(
//                     children: [
//                       ...dateOptions.entries.map((entry) =>
//                           _buildOption(entry.key, entry.value())),
//                       _buildCustomOption(),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//     if (result != null) updateDateRange(result);
//   }
//
//   Widget _buildHeader() {
//     return Container(
//       padding: EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: primaryColor.withOpacity(0.1),
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.date_range_rounded, color: primaryColor),
//           SizedBox(width: 12),
//           Text('Select Date Range', style: FontStyles.subHeadingStyle().copyWith(color: primaryColor)),
//           Spacer(),
//           IconButton(
//             onPressed: () => Navigator.pop(context!),
//             icon: Icon(Icons.close_rounded, size: 20),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOption(String title, DateTimeRange range) {
//     final isSelected = _isSelected(range);
//     final icon = _getIcon(title);
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 2),
//       child: InkWell(
//         onTap: () => Navigator.pop(context!, range),
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             color: isSelected ? primaryColor.withOpacity(0.1) : null,
//             border: isSelected ? Border.all(color: primaryColor.withOpacity(0.3)) : null,
//           ),
//           child: Row(
//             children: [
//               CircleAvatar(
//                 radius: 16,
//                 backgroundColor: isSelected ? primaryColor : Colors.grey.shade200,
//                 child: Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600, size: 16),
//               ),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(title, style: FontStyles.subTextStyle().copyWith(
//                       fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                       color: isSelected ? primaryColor : null,
//                     )),
//                     Text(_formatRange(range),
//                         style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
//                   ],
//                 ),
//               ),
//               if (isSelected)
//                 Icon(Icons.check_circle, color: primaryColor, size: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCustomOption() {
//     return InkWell(
//       onTap: () async {
//         Navigator.pop(context!);
//         final picked = await showDateRangePicker(
//           context: context!,
//           firstDate: DateTime(2020),
//           lastDate: DateTime(2030),
//           initialDateRange: selectedDateRange.value,
//         );
//         if (picked != null) updateDateRange(picked);
//       },
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey.shade300),
//         ),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 16,
//               backgroundColor: Colors.grey.shade200,
//               child: Icon(Icons.edit_calendar, color: Colors.grey.shade600, size: 16),
//             ),
//             SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Custom Range', style: FontStyles.subTextStyle()),
//                   Text('Select your own dates',
//                       style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
//                 ],
//               ),
//             ),
//             Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void updateDateRange(DateTimeRange range, [String? displayName, bool skipCallback = false]) {
//     selectedDateRange.value = range;
//     displayText.value = displayName ?? _getDisplayText(range);
//
//     // Only trigger callback if not skipping and callback exists
//     if (!skipCallback && onDateRangeSelected != null) {
//       onDateRangeSelected!(range.start, range.end);
//     }
//   }
//
//   String _getDisplayText(DateTimeRange range) {
//     for (final entry in dateOptions.entries) {
//       if (_isSameRange(range, entry.value())) return entry.key;
//     }
//     return _formatRange(range);
//   }
//
//   bool _isSelected(DateTimeRange range) {
//     return selectedDateRange.value != null && _isSameRange(selectedDateRange.value!, range);
//   }
//
//   bool _isSameRange(DateTimeRange r1, DateTimeRange r2) {
//     return _sameDay(r1.start, r2.start) && _sameDay(r1.end, r2.end);
//   }
//
//   bool _sameDay(DateTime d1, DateTime d2) {
//     return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
//   }
//
//   DateTimeRange _dayRange(DateTime date) {
//     return DateTimeRange(
//       start: DateTime(date.year, date.month, date.day),
//       end: DateTime(date.year, date.month, date.day, 23, 59, 59),
//     );
//   }
//
//   DateTimeRange _weekRange(DateTime date) {
//     final monday = date.subtract(Duration(days: date.weekday - 1));
//     final sunday = monday.add(Duration(days: 6));
//     return DateTimeRange(
//       start: DateTime(monday.year, monday.month, monday.day),
//       end: DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59),
//     );
//   }
//
//   DateTimeRange _monthRange(DateTime date) {
//     return DateTimeRange(
//       start: DateTime(date.year, date.month, 1),
//       end: DateTime(date.year, date.month + 1, 0, 23, 59, 59),
//     );
//   }
//
//   IconData _getIcon(String title) {
//     const icons = {
//       'Today': Icons.today,
//       'Yesterday': Icons.history,
//       'This Week': Icons.view_week,
//       'Last Week': Icons.view_week_outlined,
//       'This Month': Icons.calendar_view_month,
//       'Last Month': Icons.calendar_view_month_outlined,
//     };
//     return icons[title] ?? Icons.date_range;
//   }
//
//   String _formatRange(DateTimeRange range) {
//     return "${range.start.day}/${range.start.month}/${range.start.year} - "
//         "${range.end.day}/${range.end.month}/${range.end.year}";
//   }
// }
//
// class DateRangeSelectorWidget extends StatelessWidget {
//   final void Function(DateTime start, DateTime end)? onDateRangeSelected;
//   final Color? primaryColor;
//
//   const DateRangeSelectorWidget({
//     Key? key,
//     this.onDateRangeSelected,
//     this.primaryColor,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(DateRangeSelectorController(
//       primaryColor: primaryColor ?? Colors.deepOrange,
//       onDateRangeSelected: onDateRangeSelected,
//       context: context,
//     ));
//     return GestureDetector(
//       onTap: controller.showDateRangeOptions,
//       child: Obx(() => Container(
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade50,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey.shade300),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 4,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.calendar_today, color: controller.primaryColor, size: 18),
//             SizedBox(width: 8),
//             Text(controller.displayText.value, style: FontStyles.subTextStyle().copyWith(
//                 fontWeight: FontWeight.w500)),
//             SizedBox(width: 8),
//             Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600, size: 20),
//           ],
//         ),
//       )),
//     );
//   }
// }