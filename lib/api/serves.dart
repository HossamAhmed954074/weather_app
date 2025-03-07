import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:weather_app/models/weather_model.dart';

class WeatherServeces {
  Dio dio;
  final String _baseUrl = 'http://api.weatherapi.com/v1';
  final String _apiKey = 'key=83423fa8dd494234bb7214816251202';

  WeatherServeces({required this.dio});
  
  get apiKey => _apiKey;
  
  get baseUrl => _baseUrl;

  Future<WeatherModel> getCurrentWeather(String area) async {
    try {
      var response = await dio.get('$baseUrl/forecast.json?$apiKey&q=$area');

      return WeatherModel.fromJson(response.data);
    } on DioException catch (e) {
      final String errorMasseage =
          e.response?.data['error']['message'] ?? 'oops have error';
      throw Exception(errorMasseage);
    } catch (e) {
      log(e.toString());
      throw Exception('oops there was error');
    }
  }
}
