import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  static LocationService get instance => _instance;

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get current location permission status
  Future<LocationPermission> getLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestLocationPermission() async {
    log('LocationService: Checking current permission');
    LocationPermission permission = await Geolocator.checkPermission();
    log('LocationService: Current permission: $permission');

    if (permission == LocationPermission.denied) {
      log('LocationService: Permission denied, requesting permission');
      permission = await Geolocator.requestPermission();
      log('LocationService: Permission after request: $permission');

      if (permission == LocationPermission.denied) {
        throw LocationServiceException(
            'Location permission denied. Please allow location access to get weather for your current location.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
        'Location permissions are permanently denied. Please enable location access in app settings.',
      );
    }

    if (permission == LocationPermission.unableToDetermine) {
      throw LocationServiceException(
        'Unable to determine location permission status. Please check your device settings.',
      );
    }

    log('LocationService: Permission granted: $permission');
    return permission;
  }

  /// Get current position
  Future<Position> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
  }) async {
    log('LocationService: Starting getCurrentPosition');

    // Check if location service is enabled
    bool serviceEnabled = await isLocationServiceEnabled();
    log('LocationService: Service enabled: $serviceEnabled');
    if (!serviceEnabled) {
      throw LocationServiceException(
          'Location services are disabled. Please enable location services in your device settings.');
    }

    // Check and request permission
    log('LocationService: Requesting permission');
    LocationPermission permission = await requestLocationPermission();
    log('LocationService: Permission result: $permission');

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw LocationServiceException('Location permissions denied');
    }

    try {
      log('LocationService: Getting position with accuracy: $accuracy');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: timeLimit ?? const Duration(seconds: 30),
      );
      log('LocationService: Position obtained: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      log('Error getting current position: $e');
      if (e.toString().contains('timeout')) {
        throw LocationServiceException(
            'Location request timed out. Please try again or check if you are indoors.');
      } else if (e.toString().contains('disabled')) {
        throw LocationServiceException(
            'Location services are disabled. Please enable them in device settings.');
      } else {
        throw LocationServiceException(
            'Failed to get current location. Please ensure location services are enabled and try again.');
      }
    }
  }

  /// Get location from coordinates as a readable string
  Future<String> getLocationFromCoordinates(
      double latitude, double longitude) async {
    try {
      log('LocationService: Getting address for coordinates: $latitude, $longitude');

      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      log('LocationService: Got ${placemarks.length} placemarks');

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        log('LocationService: First placemark: ${place.toString()}');

        // Build location string
        List<String> locationParts = [];

        if (place.locality != null && place.locality!.isNotEmpty) {
          locationParts.add(place.locality!);
        }

        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          locationParts.add(place.administrativeArea!);
        }

        if (place.country != null && place.country!.isNotEmpty) {
          locationParts.add(place.country!);
        }

        if (locationParts.isEmpty) {
          log('LocationService: No location parts found, using coordinates');
          return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
        }

        String result = locationParts.join(', ');
        log('LocationService: Built location string: $result');
        return result;
      }

      log('LocationService: No placemarks found, using coordinates');
      return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
    } catch (e) {
      log('Error getting location from coordinates: $e');
      // If geocoding fails, return coordinates as fallback
      String fallback =
          '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
      log('LocationService: Geocoding failed, using fallback: $fallback');
      return fallback;
    }
  }

  /// Get current location as a readable string
  Future<String> getCurrentLocation() async {
    try {
      log('LocationService: Starting getCurrentLocation');
      Position position = await getCurrentPosition(
        accuracy: LocationAccuracy.medium, // Try with medium accuracy first
        timeLimit: const Duration(seconds: 15), // Shorter timeout
      );
      log('LocationService: Got position, now getting address');
      String address = await getLocationFromCoordinates(
          position.latitude, position.longitude);
      log('LocationService: Final address: $address');
      return address;
    } catch (e) {
      log('LocationService: Error in getCurrentLocation: $e');
      rethrow;
    }
  }

  /// Get current coordinates
  Future<Map<String, double>> getCurrentCoordinates() async {
    try {
      Position position = await getCurrentPosition();
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      log('Error opening location settings: $e');
      return false;
    }
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      log('Error opening app settings: $e');
      return false;
    }
  }

  /// Test location service status and permissions
  Future<Map<String, dynamic>> getLocationStatus() async {
    try {
      bool serviceEnabled = await isLocationServiceEnabled();
      LocationPermission permission = await getLocationPermission();

      return {
        'serviceEnabled': serviceEnabled,
        'permission': permission.toString(),
        'permissionGranted': permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse,
      };
    } catch (e) {
      log('Error getting location status: $e');
      return {
        'serviceEnabled': false,
        'permission': 'unknown',
        'permissionGranted': false,
        'error': e.toString(),
      };
    }
  }

  /// Debug method to test the complete location flow
  Future<String> debugLocationFlow() async {
    try {
      log('=== DEBUG LOCATION FLOW START ===');

      // Step 1: Check service enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      log('Step 1 - Service enabled: $serviceEnabled');
      if (!serviceEnabled) {
        return 'Location services are disabled';
      }

      // Step 2: Check permission
      LocationPermission permission = await getLocationPermission();
      log('Step 2 - Current permission: $permission');

      // Step 3: Request permission if needed
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        log('Step 3 - Permission after request: $permission');
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return 'Location permission denied: $permission';
      }

      // Step 4: Get position
      log('Step 4 - Getting position...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      log('Step 4 - Position: ${position.latitude}, ${position.longitude}');

      // Step 5: Get address
      log('Step 5 - Getting address...');
      String address = await getLocationFromCoordinates(
          position.latitude, position.longitude);
      log('Step 5 - Address: $address');

      log('=== DEBUG LOCATION FLOW SUCCESS ===');
      return address;
    } catch (e) {
      log('=== DEBUG LOCATION FLOW ERROR: $e ===');
      return 'Error: $e';
    }
  }
}

class LocationServiceException implements Exception {
  final String message;

  const LocationServiceException(this.message);

  @override
  String toString() => 'LocationServiceException: $message';
}
