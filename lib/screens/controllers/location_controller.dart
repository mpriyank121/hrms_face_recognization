import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/location_model.dart';

class LocationController extends GetxController {
  // Observable states
  final isLoading = false.obs;
  final isLocationLoading = false.obs;
  final lastPunchResponse = Rx<Map<String, dynamic>?>(null);
  final errorMessage = ''.obs;
  final serverTime = ''.obs;
  final currentLocation = Rx<LocationModel?>(null);
  final currentAddress = ''.obs;

  // SharedPreferences keys
  static const String _keyLatitude = 'user_latitude';
  static const String _keyLongitude = 'user_longitude';
  static const String _keyCity = 'user_city';
  static const String _keyPincode = 'user_pincode';
  static const String _keyAddress = 'user_address';
  static const String _keyState = 'user_state';
  static const String _keyCountry = 'user_country';
  static const String _keyLastUpdated = 'location_last_updated';

  @override
  void onInit() {
    super.onInit();
    // Fetch location when controller is initialized
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    // Try to load saved location first
    await loadSavedLocation();

    // Then fetch fresh location
    await fetchCurrentLocationWithDetails();
  }

  /// Load saved location from SharedPreferences
  Future<void> loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final latitude = prefs.getDouble(_keyLatitude);
      final longitude = prefs.getDouble(_keyLongitude);
      final city = prefs.getString(_keyCity);
      final pincode = prefs.getString(_keyPincode);
      final address = prefs.getString(_keyAddress);
      final lastUpdated = prefs.getString(_keyLastUpdated);

      if (latitude != null && longitude != null) {
        currentLocation.value = LocationModel(
          latitude: latitude,
          longitude: longitude,
          city: city,
          pincode: pincode,
          address: address,
        );

        currentAddress.value = address ?? '$latitude, $longitude';

        debugPrint('📍 Loaded saved location from: $lastUpdated');
        debugPrint('   Lat: $latitude, Lng: $longitude');
        debugPrint('   City: $city, Pincode: $pincode');
      }
    } catch (e) {
      debugPrint('❌ Error loading saved location: $e');
    }
  }

  /// Save location data to SharedPreferences
  Future<void> _saveLocationToPrefs(LocationModel location, Map<String, String?> addressDetails) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setDouble(_keyLatitude, location.latitude);
      await prefs.setDouble(_keyLongitude, location.longitude);
      await prefs.setString(_keyCity, location.city ?? '');
      await prefs.setString(_keyPincode, location.pincode ?? '');
      await prefs.setString(_keyAddress, location.address ?? '');
      await prefs.setString(_keyState, addressDetails['state'] ?? '');
      await prefs.setString(_keyCountry, addressDetails['country'] ?? '');
      await prefs.setString(_keyLastUpdated, DateTime.now().toIso8601String());

      debugPrint('✅ Location saved to SharedPreferences');
    } catch (e) {
      debugPrint('❌ Error saving location: $e');
    }
  }

  /// Get saved location data as a map
  Future<Map<String, dynamic>> getSavedLocationData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'latitude': prefs.getDouble(_keyLatitude),
      'longitude': prefs.getDouble(_keyLongitude),
      'city': prefs.getString(_keyCity),
      'pincode': prefs.getString(_keyPincode),
      'address': prefs.getString(_keyAddress),
      'state': prefs.getString(_keyState),
      'country': prefs.getString(_keyCountry),
      'lastUpdated': prefs.getString(_keyLastUpdated),
    };
  }

  /// Fetch current location with full details
  Future<void> fetchCurrentLocationWithDetails() async {
    try {
      isLocationLoading.value = true;
      errorMessage.value = '';

      // Check if location service is enabled
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showCupertinoDialog(
          'Location Disabled',
          'Please enable location services to continue.',
          onConfirm: () => Geolocator.openLocationSettings(),
        );
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showCupertinoDialog(
            'Permission Required',
            'Location permission is required for punch in/out.',
            onConfirm: () => Geolocator.openAppSettings(),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showCupertinoDialog(
          'Permission Permanently Denied',
          'Please enable location permission from app settings.',
          onConfirm: () => Geolocator.openAppSettings(),
        );
        return;
      }

      // Fetch position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Get address details
      final addressDetails = await _getAddressFromCoordinates(
        LatLng(position.latitude, position.longitude),
      );

      currentLocation.value = LocationModel.fromPosition(
        position,
        city: addressDetails['city'],
        pincode: addressDetails['pincode'],
        address: addressDetails['address'],
      );

      currentAddress.value = addressDetails['address'] ??
          '${position.latitude}, ${position.longitude}';

      // Save to SharedPreferences
      await _saveLocationToPrefs(currentLocation.value!, addressDetails);

      debugPrint('📍 Location fetched successfully:');
      debugPrint('   Latitude: ${position.latitude}');
      debugPrint('   Longitude: ${position.longitude}');
      debugPrint('   City: ${addressDetails['city']}');
      debugPrint('   Pincode: ${addressDetails['pincode']}');
      debugPrint('   Address: ${addressDetails['address']}');

    } catch (e) {
      errorMessage.value = 'Failed to get location: $e';
      debugPrint('❌ Location fetch error: $e');

      _showCupertinoDialog(
        'Location Error',
        'Failed to get your current location. Please try again.',
      );
    } finally {
      isLocationLoading.value = false;
    }
  }

  /// Get address from coordinates using geocoding
  Future<Map<String, String?>> _getAddressFromCoordinates(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        final addressParts = [
          if (place.street?.isNotEmpty ?? false) place.street,
          if (place.subLocality?.isNotEmpty ?? false) place.subLocality,
          if (place.locality?.isNotEmpty ?? false) place.locality,
          if (place.postalCode?.isNotEmpty ?? false) place.postalCode,
        ];

        return {
          'address': addressParts.join(', '),
          'city': place.locality,
          'pincode': place.postalCode,
          'state': place.administrativeArea,
          'country': place.country,
        };
      }
    } catch (e) {
      debugPrint('❌ Error getting address from coordinates: $e');
    }

    return {
      'address': '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
      'city': null,
      'pincode': null,
      'state': null,
      'country': null,
    };
  }

  /// Show Cupertino style dialog
  void _showCupertinoDialog(
      String title,
      String message,
      {VoidCallback? onConfirm}
      ) {
    Get.dialog(
      CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(message),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Get.back(),
          ),
          if (onConfirm != null)
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text("Open Settings"),
              onPressed: () {
                Get.back();
                onConfirm();
              },
            ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Clear saved location data
  Future<void> clearSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_keyLatitude);
      await prefs.remove(_keyLongitude);
      await prefs.remove(_keyCity);
      await prefs.remove(_keyPincode);
      await prefs.remove(_keyAddress);
      await prefs.remove(_keyState);
      await prefs.remove(_keyCountry);
      await prefs.remove(_keyLastUpdated);

      currentLocation.value = null;
      currentAddress.value = '';

      debugPrint('🗑️ Location data cleared');
    } catch (e) {
      debugPrint('❌ Error clearing location: $e');
    }
  }

  /// Check if location is saved
  Future<bool> hasLocationSaved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyLatitude) && prefs.containsKey(_keyLongitude);
  }

  /// Get location age in minutes
  Future<int?> getLocationAgeInMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdated = prefs.getString(_keyLastUpdated);

    if (lastUpdated != null) {
      final lastUpdateTime = DateTime.parse(lastUpdated);
      final now = DateTime.now();
      return now.difference(lastUpdateTime).inMinutes;
    }

    return null;
  }

  /// Refresh location if older than specified minutes
  Future<void> refreshLocationIfOld({int maxAgeMinutes = 30}) async {
    final age = await getLocationAgeInMinutes();

    if (age == null || age > maxAgeMinutes) {
      debugPrint('🔄 Location is ${age ?? "unknown"} minutes old. Refreshing...');
      await fetchCurrentLocationWithDetails();
    } else {
      debugPrint('✅ Location is fresh (${age} minutes old)');
    }
  }
}