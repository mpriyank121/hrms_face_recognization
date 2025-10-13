import 'package:get/get.dart';
import '../face_detection/service/face_detection_service.dart';
import '../models/employee_model.dart';

class EmployeeController extends GetxController {
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxMap<String, List<EmployeeData>> departmentWiseEmployees = <String, List<EmployeeData>>{}.obs;
  final RxList<EmployeeData> employeeList = <EmployeeData>[].obs;
  final RxString errorMessage = ''.obs;

  // Filter variables

  @override
  void onInit() {
    super.onInit();
    fetchEmployees();
  }

  /// Fetch employees and group by department
  Future<void> fetchEmployees() async {
    try {
      isLoading.value = true;
      final Map<String, dynamic> response = await FaceRecognitionService.fetchEmployees();

      if (response['status'] == true && response['data'] != null) {
        final List<EmployeeData> employees = (response['data'] as List)
            .map((e) => EmployeeData.fromJson(e))
            .toList();

        _processEmployees(employees);
      } else {
        errorMessage.value = response['message'] ?? 'No data found';
      }
    } catch (e) {
      errorMessage.value = 'Error fetching employees: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Process employee list: flatten and group by department
  void _processEmployees(List<EmployeeData> employees) {
    employeeList.assignAll(employees);

    final Map<String, List<EmployeeData>> grouped = {};
    for (var emp in employees) {
      if (!grouped.containsKey(emp.department)) {
        grouped[emp.department] = [];
      }
      grouped[emp.department]!.add(emp);
    }

    departmentWiseEmployees.assignAll(grouped);
  }

  /// Refresh employee list
  Future<void> refreshEmployees() async {
    await fetchEmployees();
  }

  /// Get all employees (flattened list)
  List<EmployeeData> getAllEmployees() {
    return employeeList.toList();
  }

  /// Get employee by ID
  EmployeeData? getEmployeeById(String id) {
    try {
      return employeeList.firstWhere((emp) => emp.empId == id);
    } catch (e) {
      return null;
    }
  }

  /// Get employees by department
  List<EmployeeData> getEmployeesByDepartment(String departmentName) {
    return departmentWiseEmployees[departmentName] ?? [];
  }

  /// Search employees by name/code/department/position
  List<EmployeeData> searchEmployees(String query) {
    if (query.isEmpty) return employeeList.toList();

    final lowerQuery = query.toLowerCase();
    return employeeList.where((emp) {
      return emp.empName.toLowerCase().contains(lowerQuery) ||
          emp.empCode.toLowerCase().contains(lowerQuery) ||
          emp.department.toLowerCase().contains(lowerQuery) ||
          emp.position.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get total employee count
  int getTotalEmployeeCount() {
    return employeeList.length;
  }

  /// Sort employees within departments
  void sortEmployeesByName({bool ascending = true}) {
    final sortedMap = <String, List<EmployeeData>>{};

    departmentWiseEmployees.forEach((dept, employees) {
      final sortedEmployees = List<EmployeeData>.from(employees)
        ..sort((a, b) => ascending
            ? a.empName.compareTo(b.empName)
            : b.empName.compareTo(a.empName));
      sortedMap[dept] = sortedEmployees;
    });

    departmentWiseEmployees.value = sortedMap;
  }

  /// Clear all data
  void clearData() {
    departmentWiseEmployees.clear();
    employeeList.clear();
    errorMessage.value = '';

  }
}
