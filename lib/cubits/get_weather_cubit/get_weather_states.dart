class WeatherStates {}

class InitialState extends WeatherStates {}

class WeatherLoadedStates extends WeatherStates {}

class WeatherFailureState extends WeatherStates {
  final String errorMessage;
  WeatherFailureState({required this.errorMessage});
}
