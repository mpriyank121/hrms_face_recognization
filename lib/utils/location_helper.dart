import 'package:shared_preferences/shared_preferences.dart';

/// Helper class to easily access location data from SharedPreferences
class LocationHelper {
  // SharedPreferences keys
  static const String _keyLatitude = 'user_latitude';
  static const String _keyLongitude = 'user_longitude';
  static const String _keyCity = 'user_city';
  static const String _keyPincode = 'user_pincode';
  static const String _keyAddress = 'user_address';
  static const String _keyState = 'user_state';
  static const String _keyCountry = 'user_country';
  static const String _keyLastUpdated = 'location_last_updated';

  /// Get latitude
  static Future<double?> getLatitude() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyLatitude);
  }

  /// Get longitude
  static Future<double?> getLongitude() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyLongitude);
  }

  /// Get city
  static Future<String?> getCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCity);
  }

  /// Get pincode
  static Future<String?> getPincode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPincode);
  }

  /// Get full address
  static Future<String?> getAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAddress);
  }

  /// Get state
  static Future<String?> getState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyState);
  }

  /// Get country
  static Future<String?> getCountry() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCountry);
  }

  /// Get last updated timestamp
  static Future<DateTime?> getLastUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdatedStr = prefs.getString(_keyLastUpdated);

    if (lastUpdatedStr != null) {
      return DateTime.parse(lastUpdatedStr);
    }
    return null;
  }

  /// Get all location data as a map
  static Future<Map<String, dynamic>> getAllLocationData() async {
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

  /// Check if location data exists
  static Future<bool> hasLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyLatitude) && prefs.containsKey(_keyLongitude);
  }

  /// Get formatted location string
  static Future<String> getFormattedLocation() async {
    final city = await getCity();
    final state = await getState();
    final pincode = await getPincode();

    final parts = <String>[];
    if (city?.isNotEmpty ?? false) parts.add(city!);
    if (state?.isNotEmpty ?? false) parts.add(state!);
    if (pincode?.isNotEmpty ?? false) parts.add(pincode!);

    return parts.isNotEmpty ? parts.join(', ') : 'Location not available';
  }

  /// Get coordinates as string
  static Future<String> getCoordinatesString() async {
    final lat = await getLatitude();
    final lng = await getLongitude();

    if (lat != null && lng != null) {
      return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
    }

    return 'Coordinates not available';
  }
}