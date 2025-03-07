import 'package:flutter/material.dart';

MaterialColor getWeatherColor(String? weatherCondition) {
  if (weatherCondition == null) {
    return Colors.blueGrey; // Default neutral color
  }

  switch (weatherCondition.toLowerCase()) {
    case 'sunny':
    case 'clear':
      return Colors.amber; // Bright yellow for sunny days
    case 'partly cloudy':
    case 'cloudy':
    case 'overcast':
      return Colors.grey; // Neutral grey for cloudy conditions
    case 'mist':
    case 'fog':
    case 'haze':
      return Colors.blueGrey; // Soft blue-grey for misty conditions
    case 'patchy rain possible':
    case 'light rain':
    case 'moderate rain':
    case 'heavy rain':
    case 'torrential rain':
      return Colors.blue; // Blue shades for rain
    case 'patchy snow possible':
    case 'light snow':
    case 'moderate snow':
    case 'heavy snow':
    case 'blizzard':
      return Colors.lightBlue; // Light blue for snowy conditions
    case 'thunderstorm':
    case 'patchy light rain with thunder':
    case 'moderate or heavy rain with thunder':
      return Colors.deepPurple; // Dark purple for storms
    case 'freezing drizzle':
    case 'ice pellets':
    case 'sleet':
      return Colors.cyan; // Cyan for icy conditions
    case 'dust':
    case 'sandstorm':
      return Colors.brown; // Brown for dusty conditions
    default:
      return Colors.blueGrey; // Default neutral color
  }
}
