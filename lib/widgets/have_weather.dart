import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/get_weather_cubit/get_weather_cubit.dart';
import 'matrial_color_custom.dart';

class WeatherInfoBody extends StatelessWidget {
  const WeatherInfoBody({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    var weatherModel = BlocProvider.of<GetWeatherCubit>(context).weatherModel;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            getWeatherColor(weatherModel?.status),
            getWeatherColor(weatherModel?.status)[300]!,
            getWeatherColor(weatherModel?.status)[200]!,
            getWeatherColor(weatherModel?.status)[100]!,
          
          ])
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            weatherModel!.weatherLocation,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          Text(
            'Last Update ${weatherModel.date.hour} : ${weatherModel.date.minute}',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Image.network(weatherModel.imageSource??''),
              SizedBox(
                width: 100,
                height: 200,
                child: ImageIcon(
                  NetworkImage(weatherModel.imageSource),
                ),
              ),
              Text(
                weatherModel.degree.round().toString(),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Max Temp : ${weatherModel.maxTemp.round()}',
                  ),
                  Text('Min Temp  : ${weatherModel.mintemp.round()}'),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 50,
          ),
          Text(
            weatherModel.status,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
