import 'package:hive/hive.dart';

part 'weather_model.g.dart';

@HiveType(typeId: 0)
class WeatherModel extends HiveObject {
  @HiveField(0)
  final String location;

  @HiveField(1)
  final String country;

  @HiveField(2)
  final DateTime lastUpdated;

  @HiveField(3)
  final String iconUrl;

  @HiveField(4)
  final double temperature;

  @HiveField(5)
  final double maxTemperature;

  @HiveField(6)
  final double minTemperature;

  @HiveField(7)
  final String condition;

  @HiveField(8)
  final double humidity;

  @HiveField(9)
  final double windSpeed;

  @HiveField(10)
  final double pressure;

  @HiveField(11)
  final double uvIndex;

  @HiveField(12)
  final double visibility;

  @HiveField(13)
  final String windDirection;

  @HiveField(14)
  final DateTime cacheTime;

  WeatherModel({
    required this.location,
    required this.country,
    required this.lastUpdated,
    required this.iconUrl,
    required this.temperature,
    required this.maxTemperature,
    required this.minTemperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.uvIndex,
    required this.visibility,
    required this.windDirection,
    required this.cacheTime,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    final current = json['current'];
    final forecast = json['forecast']['forecastday'][0];
    final day = forecast['day'];

    return WeatherModel(
      location: location['name'] ?? 'Unknown',
      country: location['country'] ?? 'Unknown',
      lastUpdated: DateTime.parse(current['last_updated']),
      iconUrl: 'https:${day['condition']['icon']}',
      temperature: (day['avgtemp_c'] ?? 0).toDouble(),
      maxTemperature: (day['maxtemp_c'] ?? 0).toDouble(),
      minTemperature: (day['mintemp_c'] ?? 0).toDouble(),
      condition: day['condition']['text'] ?? 'Unknown',
      humidity: (current['humidity'] ?? 0).toDouble(),
      windSpeed: (current['wind_kph'] ?? 0).toDouble(),
      pressure: (current['pressure_mb'] ?? 0).toDouble(),
      uvIndex: (current['uv'] ?? 0).toDouble(),
      visibility: (current['vis_km'] ?? 0).toDouble(),
      windDirection: current['wind_dir'] ?? 'N',
      cacheTime: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'country': country,
      'lastUpdated': lastUpdated.toIso8601String(),
      'iconUrl': iconUrl,
      'temperature': temperature,
      'maxTemperature': maxTemperature,
      'minTemperature': minTemperature,
      'condition': condition,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'pressure': pressure,
      'uvIndex': uvIndex,
      'visibility': visibility,
      'windDirection': windDirection,
      'cacheTime': cacheTime.toIso8601String(),
    };
  }

  bool get isCacheExpired {
    return DateTime.now().difference(cacheTime).inMinutes > 30;
  }

  String get formattedLastUpdated {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String get temperatureUnit => '°C';
  String get windSpeedUnit => 'km/h';
  String get pressureUnit => 'mb';
  String get visibilityUnit => 'km';
}

class WeatherError {
  final String message;
  final String? details;
  final int? statusCode;

  WeatherError({
    required this.message,
    this.details,
    this.statusCode,
  });

  factory WeatherError.fromJson(Map<String, dynamic> json) {
    return WeatherError(
      message: json['error']['message'] ?? 'Unknown error occurred',
      details: json['error']['details'],
      statusCode: json['error']['code'],
    );
  }

  @override
  String toString() => message;
}
