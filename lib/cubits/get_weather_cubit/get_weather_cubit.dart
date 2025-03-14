import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/api/serves.dart';
import 'package:weather_app/cubits/get_weather_cubit/get_weather_states.dart';
import 'package:weather_app/models/weather_model.dart';

class GetWeatherCubit extends Cubit<WeatherStates> {
  GetWeatherCubit() : super(InitialState());
  WeatherModel? weatherModel;

  getCurrentWeather({required String nameCity}) async {
    emit(WeatherLoadingStates());
    try {
      // ignore: unused_local_variable
      weatherModel =
          await WeatherServeces(dio: Dio()).getCurrentWeather(nameCity);

      emit(WeatherSuccessStates());
    } catch (e) {
      emit(WeatherFailureState(errorMessage: e.toString()));
    }
  }
}
