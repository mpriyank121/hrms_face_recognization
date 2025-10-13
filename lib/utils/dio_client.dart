import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:hrms_face_recognization/utils/platform_Service.dart';
import 'package:hrms_face_recognization/utils/shared_pref_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../constants/api_constants.dart';
import 'encryption_helper.dart';
import 'get_device_id.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio dio;
  final platform = getPlatform();

  // Store headers internally to ensure they persist
  final Map<String, dynamic> _persistentHeaders = <String, dynamic>{};

  // Track FCM token state
  String? _cachedFcmToken;
  bool _isInitialized = false;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        baseUrl: ApiConstants.baseUrl,
      ),
    );

    // Add interceptors
    dio.interceptors.add(HeaderEnsuranceInterceptor(_persistentHeaders));
    dio.interceptors.add(HeaderLoggingInterceptor());
    dio.interceptors.add(JsonDecodeInterceptor());
    dio.interceptors.add(ErrorHandlerInterceptor());
  }

  /// Initialize the client - call this once at app startup
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _initializeBasicHeaders();
      _isInitialized = true;
      debugPrint('✅ DioClient initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing DioClient: $e');
      rethrow;
    }
  }

  /// Initialize basic headers that should always be present
  Future<void> _initializeBasicHeaders() async {
    try {
      final deviceId = await getDeviceId();
      final appVersion = await getAppVersion();

      final basicHeaders = {
        'Device-Id': deviceId,
        'X-Platform': platform,
        'X-App-Version': appVersion,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      _updateHeaders(basicHeaders);

      // Try to get FCM token with retry logic
      await _initializeFcmToken();

    } catch (e) {
      debugPrint('Error initializing basic headers: $e');
      rethrow;
    }
  }

  /// Initialize FCM token with retry logic
  Future<void> _initializeFcmToken() async {
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    for (int i = 0; i < maxRetries; i++) {
      try {
        final fcmToken = await _getFcmTokenWithTimeout();
        if (fcmToken != null && fcmToken.isNotEmpty) {
          _cachedFcmToken = fcmToken;
          _updateHeaders({'X-FCM-Token': fcmToken});
          debugPrint('✅ FCM Token initialized: ${fcmToken.substring(0, 20)}...');
          return;
        }
      } catch (e) {
        debugPrint('⚠️ FCM Token attempt ${i + 1} failed: $e');
      }

      if (i < maxRetries - 1) {
        await Future.delayed(retryDelay);
      }
    }

    debugPrint('⚠️ FCM Token initialization failed after $maxRetries attempts');
  }

  /// Get FCM token with timeout
  Future<String?> _getFcmTokenWithTimeout() async {
    try {
      return await FirebaseMessaging.instance.getToken()
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Force refresh FCM token
  Future<bool> refreshFcmToken() async {
    try {
      final fcmToken = await _getFcmTokenWithTimeout();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        _cachedFcmToken = fcmToken;
        _updateHeaders({'X-FCM-Token': fcmToken});
        debugPrint('✅ FCM Token refreshed: ${fcmToken.substring(0, 20)}...');
        return true;
      } else {
        debugPrint('⚠️ FCM Token not available during refresh');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error refreshing FCM token: $e');
      return false;
    }
  }

  /// Set authentication headers (call after login)
  Future<void> setHeaders({
    String? employeeId,
    String? organizationId,
    bool forceRefreshFcm = false,
  }) async {
    try {
      final headers = <String, dynamic>{};

      // Refresh FCM token if requested or if we don't have one
      if (forceRefreshFcm || _cachedFcmToken == null) {
        await refreshFcmToken();
      }

      // Add FCM token if available
      if (_cachedFcmToken != null) {
        headers['X-FCM-Token'] = _cachedFcmToken!;
      }

      // Add employee ID if provided
      if (employeeId != null && employeeId.isNotEmpty) {
        headers['X-Emp-Id'] = EncryptionHelper.encryptString(employeeId);
      }

      // Add organization ID (prefer parameter over shared pref)
      final orgId = organizationId ?? SharedPrefHelper.getCompanyId();
      if (orgId != null ) {
        headers['X-Organization-Id'] = orgId;
      }

      _updateHeaders(headers);

    } catch (e) {
      debugPrint('Error setting auth headers: $e');
    }
  }

  /// Update multiple headers at once (thread-safe)
  void _updateHeaders(Map<String, dynamic> headers) {
    _persistentHeaders.addAll(headers);
    dio.options.headers.addAll(headers);
  }

  /// Update a specific header
  void updateHeader(String key, String value) {
    _persistentHeaders[key] = value;
    dio.options.headers[key] = value;
  }

  /// Remove a specific header
  void removeHeader(String key) {
    _persistentHeaders.remove(key);
    dio.options.headers.remove(key);
  }

  /// Get app version from package info
  Future<String> getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      debugPrint('Error getting app version: $e');
      return '1.0.0';
    }
  }

  /// Get current FCM token (cached version)
  String? get currentFcmToken => _cachedFcmToken;

  /// Get all current persistent headers
  Map<String, dynamic> getAllHeaders() {
    return Map<String, dynamic>.from(_persistentHeaders);
  }

  /// Clear authentication headers but keep basic ones
  void clearAuthHeaders() {
    final authHeaders = [
      'X-FCM-Token',
      'X-Emp-Id',
      'X-Organization-Id'
    ];

    for (final header in authHeaders) {
      _persistentHeaders.remove(header);
      dio.options.headers.remove(header);
    }

    _cachedFcmToken = null;
  }

  /// Clear all headers and reinitialize
  Future<void> resetHeaders() async {
    _persistentHeaders.clear();
    dio.options.headers.clear();
    _cachedFcmToken = null;
    _isInitialized = false;

    await initialize();
  }

  /// Check if client is properly initialized
  bool get isInitialized => _isInitialized;

  /// Get the Dio instance
  Dio get client => dio;
}

// Rest of the interceptors remain the same...
class HeaderEnsuranceInterceptor extends Interceptor {
  final Map<String, dynamic> persistentHeaders;

  HeaderEnsuranceInterceptor(this.persistentHeaders);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // ✅ Always override with persistent headers
    options.headers.addAll(persistentHeaders);

    // Add request time
    options.headers['X-Request-Time'] = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      // 🔹 Fetch orgId and empId dynamically if available
      final orgId = await SharedPrefHelper.getCompanyId();
      final empId = await SharedPrefHelper.getEmpId();

      if (orgId != null ) {
        options.headers['X-Organization-Id'] = (orgId) ;
      }

      if (empId != null) {
        options.headers['X-Emp-Id'] =EncryptionHelper.encryptString(empId);
      }
    } catch (e) {
      debugPrint('⚠️ Failed to attach empId/orgId headers: $e');
    }

    handler.next(options);
  }
}


class JsonDecodeInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is String) {
      try {
        response.data = jsonDecode(response.data);
      } catch (_) {
        // If not JSON, leave as is
      }
    }
    handler.next(response);
  }
}

class HeaderLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('\n🚀 Request to: ${options.uri}');
    debugPrint('🔗 Method: ${options.method}');
    debugPrint('📦 Final Headers Sent (${options.headers.length}):');
    options.headers.forEach((key, value) {
      debugPrint('🔐 $key: $value');
    });



    if (options.data != null) {
      debugPrint('📄 Request Data: ${options.data.toString().length > 200 ? '${options.data.toString().substring(0, 200)}...' : options.data}');
    }

    debugPrint('─' * 50);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('\n📥 Response from: ${response.requestOptions.uri}');
    debugPrint('✅ Status Code: ${response.statusCode}');
    debugPrint('📦 Response Headers (${response.headers.map.length}):');
    response.headers.forEach((key, values) {
      debugPrint('🔐 $key: ${values.join(", ")}');
    });
    debugPrint('─' * 50);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('\n❌ Error for: ${err.requestOptions.uri}');
    debugPrint('💥 Error Type: ${err.type}');
    debugPrint('📝 Error Message: ${err.message}');
    if (err.response != null) {
      debugPrint('📊 Response Status: ${err.response?.statusCode}');
    }
    debugPrint('─' * 50);
    handler.next(err);
  }
}
class ErrorHandlerInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String userMessage = "Something went wrong. Please try again later.";

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        userMessage = "Unable to connect. Please check your internet connection.";
        break;

      case DioExceptionType.badResponse:
        if (err.response?.statusCode == 401) {
          userMessage = "Unauthorized access. Please login again.";
        } else if (err.response?.statusCode == 403) {
          userMessage = "Access denied. You don’t have permission.";
        } else if (err.response?.statusCode == 500) {
          userMessage = "Server error. Please try again later.";
        }
        break;

      default:
        userMessage = "Something went wrong. Please try again later.";
        break;
    }

    // Replace the error with a clean one
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        message: userMessage,
        type: err.type,
        response: err.response,
      ),
    );
  }
}



/// Extension methods remain the same
extension DioClientExtension on DioClient {
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return client.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return client.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return client.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return client.delete(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return client.patch(path, data: data, queryParameters: queryParameters);
  }
}