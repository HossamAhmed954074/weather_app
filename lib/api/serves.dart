import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather_model.dart';
import '../constants/app_constants.dart';

class WeatherService {
  late final Dio _dio;
  late final String _baseUrl;
  late final String _apiKey;

  WeatherService() {
    _baseUrl =
        dotenv.env['WEATHER_API_BASE_URL'] ?? 'http://api.weatherapi.com/v1';
    _apiKey = dotenv.env['WEATHER_API_KEY'] ?? '';

    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: Duration(seconds: AppConstants.apiTimeout),
      receiveTimeout: Duration(seconds: AppConstants.apiTimeout),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => log(obj.toString()),
    ));
  }

  Future<bool> _hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<WeatherModel> getCurrentWeather(String location) async {
    if (!await _hasInternetConnection()) {
      throw WeatherException(
        'No internet connection. Please check your network settings.',
        type: WeatherExceptionType.network,
      );
    }

    try {
      final response = await _dio.get(
        '/forecast.json',
        queryParameters: {
          'key': _apiKey,
          'q': location,
          'days': 1,
          'aqi': 'yes',
          'alerts': 'yes',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return WeatherModel.fromJson(response.data);
      } else {
        throw WeatherException(
          'Failed to fetch weather data. Please try again.',
          type: WeatherExceptionType.api,
        );
      }
    } on DioException catch (e) {
      log('DioException: ${e.message}');

      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data?['error']?['message'] ??
            'Invalid location. Please check the city name.';
        throw WeatherException(
          errorMessage,
          type: WeatherExceptionType.invalidLocation,
        );
      } else if (e.response?.statusCode == 401) {
        throw WeatherException(
          'API authentication failed. Please check your API key.',
          type: WeatherExceptionType.authentication,
        );
      } else if (e.response?.statusCode == 403) {
        throw WeatherException(
          'API quota exceeded. Please try again later.',
          type: WeatherExceptionType.quotaExceeded,
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw WeatherException(
          'Connection timeout. Please check your internet connection.',
          type: WeatherExceptionType.timeout,
        );
      } else {
        throw WeatherException(
          'Network error occurred. Please try again.',
          type: WeatherExceptionType.network,
        );
      }
    } catch (e) {
      log('Unexpected error: ${e.toString()}');
      throw WeatherException(
        'An unexpected error occurred. Please try again.',
        type: WeatherExceptionType.unknown,
      );
    }
  }

  Future<List<WeatherModel>> getWeatherForecast(String location,
      {int days = 7}) async {
    if (!await _hasInternetConnection()) {
      throw WeatherException(
        'No internet connection. Please check your network settings.',
        type: WeatherExceptionType.network,
      );
    }

    try {
      final response = await _dio.get(
        '/forecast.json',
        queryParameters: {
          'key': _apiKey,
          'q': location,
          'days': days,
          'aqi': 'no',
          'alerts': 'no',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> forecastDays =
            response.data['forecast']['forecastday'];
        return forecastDays
            .map((day) => WeatherModel.fromJson({
                  'location': response.data['location'],
                  'current': response.data['current'],
                  'forecast': {
                    'forecastday': [day]
                  },
                }))
            .toList();
      } else {
        throw WeatherException(
          'Failed to fetch forecast data. Please try again.',
          type: WeatherExceptionType.api,
        );
      }
    } catch (e) {
      if (e is WeatherException) rethrow;
      log('Unexpected error in forecast: ${e.toString()}');
      throw WeatherException(
        'An unexpected error occurred while fetching forecast.',
        type: WeatherExceptionType.unknown,
      );
    }
  }

  Future<List<String>> searchLocations(String query) async {
    if (!await _hasInternetConnection()) {
      throw WeatherException(
        'No internet connection. Please check your network settings.',
        type: WeatherExceptionType.network,
      );
    }

    try {
      final response = await _dio.get(
        '/search.json',
        queryParameters: {
          'key': _apiKey,
          'q': query,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> locations = response.data;
        return locations
            .map((location) => '${location['name']}, ${location['country']}')
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      log('Search error: ${e.toString()}');
      return [];
    }
  }
}

enum WeatherExceptionType {
  network,
  api,
  invalidLocation,
  authentication,
  quotaExceeded,
  timeout,
  unknown,
}

class WeatherException implements Exception {
  final String message;
  final WeatherExceptionType type;

  WeatherException(this.message, {required this.type});

  @override
  String toString() => message;
}
