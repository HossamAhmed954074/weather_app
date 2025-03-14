import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/cubits/get_weather_cubit/get_weather_cubit.dart';
import 'package:weather_app/cubits/get_weather_cubit/get_weather_states.dart';
import 'package:weather_app/screens/searching_screen.dart';
import 'package:weather_app/widgets/have_weather.dart';
import 'package:weather_app/widgets/no_weather_body_widget.dart';

import '../widgets/loading_indicator_custom.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchingScreen(),
                    ));
              },
              icon: Icon(Icons.search))
        ],
      ),
      body: BlocBuilder<GetWeatherCubit, WeatherStates>(
        builder: (context, state) {
          if (state is InitialState) {
            return NoWeatherBody();
          } else if (state is WeatherLoadingStates) {
            return LoadingIndicatorCustom();
          } else if (state is WeatherSuccessStates) {
            return WeatherInfoBody();
          } else {
            return Center(child: Text('Oops, Have a Error To get Data'));
          }
        },
      ),
    );
  }
}


