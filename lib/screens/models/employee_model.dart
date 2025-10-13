// employee_response.dart

class EmployeeResponse {
  final bool status;
  final String message;
  final List<EmployeeData> data;

  EmployeeResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory EmployeeResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<EmployeeData>.from(
          (json['data'] as List).map((x) => EmployeeData.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((x) => x.toJson()).toList(),
    };
  }
}

class EmployeeData {
  final String empId;
  final String department;
  final String empName;
  final String? empImage; // nullable
  final String position;
  final String empCode;
  final String faceId;

  EmployeeData({
    required this.empId,
    required this.department,
    required this.empName,
    this.empImage,
    required this.position,
    required this.empCode,
    required this.faceId,
  });

  factory EmployeeData.fromJson(Map<String, dynamic> json) {
    return EmployeeData(
      empId: json['emp_id'] ?? '',
      department: json['department'] ?? '',
      empName: json['emp_name'] ?? '',
      empImage: json['emp_image'], // can be null
      position: json['emp_pos'] ?? '',
      empCode: json['emp_code'] ?? '',
      faceId: json['face_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emp_id': empId,
      'department': department,
      'emp_name': empName,
      'emp_image': empImage,
      'position': position,
      'emp_code': empCode,
      'face_id': faceId,
    };
  }
}
