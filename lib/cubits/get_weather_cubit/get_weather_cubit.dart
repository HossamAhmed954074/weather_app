import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/weather_repository.dart';
import '../../services/location_service.dart';
import '../../api/serves.dart';
import 'get_weather_states.dart';
import '../../models/weather_model.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final WeatherRepository _repository;
  final LocationService _locationService;
  WeatherModel? _currentWeather;
  Timer? _refreshTimer;
  bool _isInitialized = false;

  WeatherCubit({
    WeatherRepository? repository,
    LocationService? locationService,
  })  : _repository = repository ?? WeatherRepository.instance,
        _locationService = locationService ?? LocationService.instance,
        super(const WeatherInitial());

  WeatherModel? get currentWeather => _currentWeather;

  /// Initialize lazily - only when needed
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    try {
      await _repository.initialize();
      _isInitialized = true;

      // Try to load last weather only after manual request
      // Don't do it automatically to speed up startup
    } catch (e) {
      log('Failed to initialize WeatherCubit: $e');
      _isInitialized = true; // Mark as initialized even if failed
    }
  }

  /// Load last weather data - called manually when needed
  Future<void> loadLastWeather() async {
    await _ensureInitialized();
    final lastLocation = _repository.getLastSearchedLocation();
    if (lastLocation != null) {
      await getCurrentWeather(lastLocation);
    }
  }

  Future<void> getCurrentWeather(String location,
      {bool forceRefresh = false}) async {
    await _ensureInitialized();

    if (location.trim().isEmpty) {
      emit(const WeatherErrorState(
        message: 'Please enter a valid location',
        canRetry: false,
      ));
      return;
    }

    emit(WeatherLoading(
      message: forceRefresh
          ? 'Refreshing weather data...'
          : 'Loading weather data...',
    ));

    try {
      final weather = await _repository.getCurrentWeather(
        location,
        forceRefresh: forceRefresh,
      );

      _currentWeather = weather;
      await _repository.addToSearchHistory(location);

      emit(WeatherLoaded(
        weather: weather,
        isFromCache: !forceRefresh && weather.isCacheExpired,
      ));

      _startAutoRefresh();
    } on WeatherException catch (e) {
      log('WeatherException: ${e.message}');

      // Try to get cached data if available
      final cachedWeather = _repository
              .getCachedWeatherList()
              .where((w) =>
                  w.location.toLowerCase().contains(location.toLowerCase()))
              .isNotEmpty
          ? _repository.getCachedWeatherList().firstWhere(
              (w) => w.location.toLowerCase().contains(location.toLowerCase()))
          : null;

      emit(WeatherErrorState(
        message: e.message,
        details: e.type.toString(),
        canRetry: e.type != WeatherExceptionType.invalidLocation,
        cachedWeather: cachedWeather,
      ));
    } catch (e) {
      log('Unexpected error: $e');
      emit(WeatherErrorState(
        message: 'An unexpected error occurred. Please try again.',
        details: e.toString(),
      ));
    }
  }

  Future<void> refreshCurrentWeather() async {
    if (_currentWeather != null) {
      await getCurrentWeather(_currentWeather!.location, forceRefresh: true);
    }
  }

  Future<void> getWeatherForecast(String location, {int days = 7}) async {
    await _ensureInitialized();
    emit(const WeatherForecastLoading());

    try {
      final forecast =
          await _repository.getWeatherForecast(location, days: days);
      emit(WeatherForecastLoaded(forecast));
    } on WeatherException catch (e) {
      emit(WeatherForecastErrorState(e.message));
    } catch (e) {
      log('Forecast error: $e');
      emit(WeatherForecastErrorState('Failed to load forecast data'));
    }
  }

  Future<void> searchLocations(String query) async {
    await _ensureInitialized();
    if (query.trim().isEmpty) {
      emit(const LocationSearchLoaded(locations: [], query: ''));
      return;
    }

    emit(const LocationSearchLoading());

    try {
      final locations = await _repository.searchLocations(query);
      emit(LocationSearchLoaded(locations: locations, query: query));
    } catch (e) {
      log('Search error: $e');
      emit(LocationSearchErrorState('Failed to search locations'));
    }
  }

  Future<List<String>> getSearchHistory() async {
    await _ensureInitialized();
    return await _repository.getSearchHistory();
  }

  Future<void> clearSearchHistory() async {
    await _ensureInitialized();
    await _repository.clearSearchHistory();
  }

  Future<void> clearCache() async {
    await _ensureInitialized();
    await _repository.clearCache();
    _currentWeather = null;
    emit(const WeatherInitial());
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      if (_currentWeather != null) {
        refreshCurrentWeather();
      }
    });
  }

  void retryLastRequest() {
    if (_currentWeather != null) {
      getCurrentWeather(_currentWeather!.location);
    }
  }

  /// Get weather for current location using GPS
  Future<void> getCurrentLocationWeather() async {
    emit(const LocationLoading(message: 'Getting your location...'));

    try {
      log('WeatherCubit: Starting location weather request');

      // Check if location service is enabled first
      bool serviceEnabled = await _locationService.isLocationServiceEnabled();
      log('WeatherCubit: Location service enabled: $serviceEnabled');

      if (!serviceEnabled) {
        emit(const LocationError(
          message:
              'Location services are disabled. Please enable them in device settings.',
          canOpenSettings: true,
        ));
        return;
      }

      emit(const LocationLoading(message: 'Requesting location permission...'));

      // Directly try to get the current location - this will request permission if needed
      String location = await _locationService.getCurrentLocation();
      log('WeatherCubit: Got location: $location');

      emit(const LocationLoading(message: 'Loading weather data...'));

      // Get weather for the current location
      await getCurrentWeather(location);
    } on LocationServiceException catch (e) {
      log('LocationServiceException: ${e.message}');

      bool canOpenSettings = e.message.contains('permanently denied') ||
          e.message.contains('denied') ||
          e.message.contains('disabled') ||
          e.message.contains('settings');

      emit(LocationError(
        message: e.message,
        canOpenSettings: canOpenSettings,
      ));
    } catch (e) {
      log('Location error: $e');
      emit(LocationError(
        message:
            'Failed to get your location: ${e.toString()}. Please try again or search manually.',
        canOpenSettings: true,
      ));
    }
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    try {
      await _locationService.openLocationSettings();
    } catch (e) {
      log('Failed to open location settings: $e');
    }
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    try {
      await _locationService.openAppSettings();
    } catch (e) {
      log('Failed to open app settings: $e');
    }
  }

  /// Debug location functionality
  Future<void> debugLocation() async {
    emit(const LocationLoading(message: 'Testing location service...'));

    try {
      String result = await _locationService.debugLocationFlow();

      if (result.startsWith('Error:') ||
          result.contains('denied') ||
          result.contains('disabled')) {
        emit(LocationError(
          message: result,
          canOpenSettings: true,
        ));
      } else {
        // If we get a valid location, try to get weather for it
        await getCurrentWeather(result);
      }
    } catch (e) {
      log('Debug location error: $e');
      emit(LocationError(
        message: 'Debug failed: ${e.toString()}',
        canOpenSettings: true,
      ));
    }
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
