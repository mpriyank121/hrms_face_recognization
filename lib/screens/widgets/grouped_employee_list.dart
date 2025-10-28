import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_face_recognization/core/widgets/primary_button.dart';
import '../../../config/font_style.dart';
import '../controllers/employee_controller.dart';
import '../controllers/face_detection_controller.dart';
import '../models/employee_model.dart';

class GroupedEmployeeList extends StatelessWidget {
  final EmployeeController employeeController;
  final Function(EmployeeData)? onRegisterTap;

  GroupedEmployeeList({
    Key? key,
    required this.employeeController,
    this.onRegisterTap,
  }) : super(key: key);

  final faceDetectionController = Get.find<FaceDetectionController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Loading state
      if (employeeController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final departmentMap = employeeController.departmentWiseEmployees;

      // Empty state
      if (departmentMap.isEmpty) {
        return const Center(child: Text('No employee found'));
      }

      return ListView.builder(
        itemCount: departmentMap.length,
        itemBuilder: (context, sectionIndex) {
          final department = departmentMap.keys.elementAt(sectionIndex);
          final employees = departmentMap[department]!;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Department header
                Row(
                  children: [
                    Text(
                      department,
                      style: FontStyles.subTextStyle(fontSize: 22),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color(0xFFEEEEEE),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Employee list
                ...employees.map((employee) {
                  return _buildEmployeeCard(context, employee);
                }).toList(),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildEmployeeCard(BuildContext context, EmployeeData employee) {
    return Obx(() {
      final isDeletingThis = faceDetectionController.deletingEmployeeId.value == employee.empId;

      return Opacity(
        opacity: isDeletingThis ? 0.6 : 1.0,
        child: ListTile(
          enabled: !isDeletingThis,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            backgroundImage: (employee.empImage != null && employee.empImage!.isNotEmpty)
                ? NetworkImage(employee.empImage!)
                : null,
            child: (employee.empImage == null || employee.empImage!.isEmpty)
                ? Text(
              employee.empName.isNotEmpty ? employee.empName[0].toUpperCase() : '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            )
                : null,
          ),
          title: Text(
            employee.empName,
            style: FontStyles.subHeadingStyle(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            employee.position,
            style: FontStyles.subTextStyle(),
          ),
          trailing: _buildTrailingWidget(context, employee, isDeletingThis),
          onTap: null,
        ),
      );
    });
  }

  Widget _buildTrailingWidget(BuildContext context, EmployeeData employee, bool isDeletingThis) {
    if (employee.faceId.isEmpty) {
      // Show Register button if face_id is empty
      return PrimaryButton(
        textSize: 12,
        heightFactor: 0.2,
        widthFactor: 0.2,
        onPressed: () async {
          if (onRegisterTap != null) {
            await onRegisterTap!(employee);
            await employeeController.refreshEmployees();
          }
        },
        text: 'Register',
      );
    }

    // Show delete button or loading indicator
    if (isDeletingThis) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
        ),
      );
    }

    return IconButton(
      onPressed: () async {
        // Confirm deletion
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text('Are you sure you want to delete face data for ${employee.empName}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          // Set loading state immediately
          faceDetectionController.deletingEmployeeId.value = employee.empId;

          // Delete face
          await faceDetectionController.deleteFace(empId: employee.empId);

          // Refresh employees
          await employeeController.refreshEmployees();

          // Clear loading state
          faceDetectionController.deletingEmployeeId.value = null;
        }
      },
      icon: const Icon(
        Icons.delete,
        color: Colors.red,
      ),
    );
  }
}