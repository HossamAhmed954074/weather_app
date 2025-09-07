import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../constants/app_constants.dart';
import '../cubits/get_weather_cubit/get_weather_cubit.dart';

class NoWeatherDisplayWidget extends StatefulWidget {
  const NoWeatherDisplayWidget({super.key});

  @override
  State<NoWeatherDisplayWidget> createState() => _NoWeatherDisplayWidgetState();
}

class _NoWeatherDisplayWidgetState extends State<NoWeatherDisplayWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _fadeController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _bounceController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: AppConstants.slowAnimation,
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _bounceController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _bounceAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.cloud_outlined,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.largePadding),
          FadeTransition(
            opacity: _fadeAnimation,
            child: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'No Weather Data Available',
                  textStyle:
                      Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              isRepeatingAnimation: false,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'Search for a city to get started with weather information',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
            ),
          ),
          const SizedBox(height: AppConstants.largePadding * 2),
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildActionButtons(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => _navigateToSearch(context),
          icon: const Icon(Icons.search_rounded),
          label: const Text('Search Location'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.largePadding,
              vertical: AppConstants.defaultPadding,
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        TextButton.icon(
          onPressed: () => _requestLocationPermission(),
          icon: const Icon(Icons.my_location_rounded),
          label: const Text('Use Current Location'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.largePadding,
              vertical: AppConstants.defaultPadding,
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToSearch(BuildContext context) {
    Navigator.of(context).pushNamed('/search');
  }

  void _requestLocationPermission() {
    context.read<WeatherCubit>().getCurrentLocationWeather();
  }
}
