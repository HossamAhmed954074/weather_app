class WeatherStates {}

class InitialState extends WeatherStates {}

class WeatherLoadingStates extends WeatherStates {}
class WeatherSuccessStates extends WeatherStates {}
class WeatherFailureState extends WeatherStates {
  final String errorMessage;
  WeatherFailureState({required this.errorMessage});
}
