class WeatherModel {
  final String weatherLocation;
  final DateTime date;
  final String imageSource;
  final double degree;
  final double maxTemp;
  final double mintemp;
  final String status;

  WeatherModel(
      {required this.weatherLocation,
      required this.date,
      required this.imageSource,
      required this.degree,
      required this.maxTemp,
      required this.mintemp,
      required this.status});

  factory WeatherModel.fromJson(jason) {
    return WeatherModel(
        weatherLocation: jason['location']['name'],
        date: DateTime.parse(jason['current']['last_updated']),
        imageSource:
            'https:${jason['forecast']['forecastday'][0]['day']['condition']['icon']}',
        degree: jason['forecast']['forecastday'][0]['day']['avgtemp_c'],
        maxTemp: jason['forecast']['forecastday'][0]['day']['maxtemp_c'],
        mintemp: jason['forecast']['forecastday'][0]['day']['mintemp_c'],
        status: jason['forecast']['forecastday'][0]['day']['condition']
            ['text']);
  }
}

class ErrorMasseage {
  final String masseageError;
  ErrorMasseage({required this.masseageError});
  factory ErrorMasseage.fromjson(json) {
    return ErrorMasseage(masseageError: json['error']['message']);
  }
}
