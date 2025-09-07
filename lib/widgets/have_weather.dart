import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/get_weather_cubit/get_weather_cubit.dart';
import '../cubits/get_weather_cubit/get_weather_states.dart';
import 'matrial_color_custom.dart';

class WeatherInfoBody extends StatelessWidget {
  const WeatherInfoBody({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        if (state is WeatherLoaded) {
          final weatherModel = state.weather;
          return Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  getWeatherColor(weatherModel.condition),
                  getWeatherColor(weatherModel.condition)[300]!,
                  getWeatherColor(weatherModel.condition)[200]!,
                  getWeatherColor(weatherModel.condition)[100]!,
                ])),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  weatherModel.location,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Last Update ${weatherModel.lastUpdated.hour} : ${weatherModel.lastUpdated.minute}',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Image.network(weatherModel.iconUrl??''),
                    SizedBox(
                      width: 100,
                      height: 200,
                      child: ImageIcon(
                        NetworkImage(weatherModel.iconUrl),
                      ),
                    ),
                    Text(
                      weatherModel.temperature.round().toString(),
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Max Temp : ${weatherModel.maxTemperature.round()}',
                        ),
                        Text(
                            'Min Temp  : ${weatherModel.minTemperature.round()}'),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                Text(
                  weatherModel.condition,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        } else {
          // Return a fallback widget for other states
          return Container(
            child: Center(
              child: Text('No weather data available'),
            ),
          );
        }
      },
    );
  }
}
