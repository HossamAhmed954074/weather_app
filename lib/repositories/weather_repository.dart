import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../api/serves.dart';
import '../constants/app_constants.dart';

class WeatherRepository {
  late final WeatherService _weatherService;
  // late final Box<WeatherModel> _weatherCache;
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  WeatherRepository._();

  static WeatherRepository? _instance;
  static WeatherRepository get instance {
    _instance ??= WeatherRepository._();
    return _instance!;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _weatherService = WeatherService();
      await Hive.initFlutter();

      // if (!Hive.isAdapterRegistered(0)) {
      //   Hive.registerAdapter(WeatherModelAdapter());
      // }

      // _weatherCache = await Hive.openBox<WeatherModel>('weather_cache');
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    } catch (e) {
      // If initialization fails, create a fallback instance
      _weatherService = WeatherService();
      _isInitialized = true;
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  Future<WeatherModel> getCurrentWeather(String location,
      {bool forceRefresh = false}) async {
    await _ensureInitialized();

    // Try to get cached data first
    // if (!forceRefresh) {
    //   final cachedWeather = _weatherCache.get(cacheKey);
    //   if (cachedWeather != null && !cachedWeather.isCacheExpired) {
    //     return cachedWeather;
    //   }
    // }

    try {
      // Fetch fresh data from API
      final weather = await _weatherService.getCurrentWeather(location);

      // Cache the new data
      // await _weatherCache.put(cacheKey, weather);
      await _saveLastSearchedLocation(location);

      return weather;
    } catch (e) {
      // If API fails and we have cached data, return it
      // final cachedWeather = _weatherCache.get(cacheKey);
      // if (cachedWeather != null) {
      //   return cachedWeather;
      // }
      rethrow;
    }
  }

  Future<List<WeatherModel>> getWeatherForecast(String location,
      {int days = 7}) async {
    await _ensureInitialized();
    return await _weatherService.getWeatherForecast(location, days: days);
  }

  Future<List<String>> searchLocations(String query) async {
    await _ensureInitialized();
    if (query.trim().isEmpty) return [];
    return await _weatherService.searchLocations(query);
  }

  Future<void> _saveLastSearchedLocation(String location) async {
    await _ensureInitialized();
    await _prefs?.setString(AppConstants.lastLocationCacheKey, location);
  }

  String? getLastSearchedLocation() {
    return _prefs?.getString(AppConstants.lastLocationCacheKey);
  }

  Future<List<String>> getSearchHistory() async {
    await _ensureInitialized();
    return _prefs?.getStringList('search_history') ?? [];
  }

  Future<void> addToSearchHistory(String location) async {
    await _ensureInitialized();
    final history = await getSearchHistory();

    // Remove if already exists to avoid duplicates
    history.remove(location);

    // Add to beginning
    history.insert(0, location);

    // Keep only last 10 searches
    if (history.length > 10) {
      history.removeRange(10, history.length);
    }

    await _prefs?.setStringList('search_history', history);
  }

  Future<void> clearCache() async {
    // await _weatherCache.clear();
  }

  Future<void> clearSearchHistory() async {
    await _ensureInitialized();
    await _prefs?.remove('search_history');
  }

  Future<bool> hasPermissionForLocation() async {
    // This will be implemented when we add location features
    return false;
  }

  List<WeatherModel> getCachedWeatherList() {
    // return _weatherCache.values.toList();
    return [];
  }

  Future<void> dispose() async {
    // await _weatherCache.close();
  }
}
