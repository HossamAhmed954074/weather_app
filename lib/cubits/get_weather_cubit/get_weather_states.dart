import '../../models/weather_model.dart';

abstract class WeatherState {
  const WeatherState();
}

class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

class WeatherLoading extends WeatherState {
  final String? message;
  const WeatherLoading({this.message});
}

class WeatherLoaded extends WeatherState {
  final WeatherModel weather;
  final bool isFromCache;

  const WeatherLoaded({
    required this.weather,
    this.isFromCache = false,
  });
}

class WeatherErrorState extends WeatherState {
  final String message;
  final String? details;
  final bool canRetry;
  final WeatherModel? cachedWeather;

  const WeatherErrorState({
    required this.message,
    this.details,
    this.canRetry = true,
    this.cachedWeather,
  });
}

class WeatherForecastLoading extends WeatherState {
  const WeatherForecastLoading();
}

class WeatherForecastLoaded extends WeatherState {
  final List<WeatherModel> forecast;

  const WeatherForecastLoaded(this.forecast);
}

class WeatherForecastErrorState extends WeatherState {
  final String message;

  const WeatherForecastErrorState(this.message);
}

class LocationSearchLoading extends WeatherState {
  const LocationSearchLoading();
}

class LocationSearchLoaded extends WeatherState {
  final List<String> locations;
  final String query;

  const LocationSearchLoaded({
    required this.locations,
    required this.query,
  });
}

class LocationSearchErrorState extends WeatherState {
  final String message;

  const LocationSearchErrorState(this.message);
}

class LocationLoading extends WeatherState {
  final String message;

  const LocationLoading({this.message = 'Getting your location...'});
}

class LocationError extends WeatherState {
  final String message;
  final bool canOpenSettings;

  const LocationError({
    required this.message,
    this.canOpenSettings = false,
  });
}
