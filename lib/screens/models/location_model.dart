import 'package:geolocator/geolocator.dart';

class LocationModel {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final String? city;
  final String? pincode;
  final String? address;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.city,
    this.pincode,
    this.address,
  });

  factory LocationModel.fromPosition(Position position, {String? city, String? pincode, String? address}) {
    return LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      city: city,
      pincode: pincode,
      address: address,
    );
  }

  @override
  String toString() => 'LocationModel(lat: $latitude, lng: $longitude, city: $city, pincode: $pincode)';
}