import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class WeatherBackgroundWidget extends StatefulWidget {
  final String? weatherCondition;

  const WeatherBackgroundWidget({
    super.key,
    this.weatherCondition,
  });

  @override
  State<WeatherBackgroundWidget> createState() =>
      _WeatherBackgroundWidgetState();
}

class _WeatherBackgroundWidgetState extends State<WeatherBackgroundWidget>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _gradientController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.linear,
    ));

    _gradientController.repeat();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gradientAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: _getWeatherGradient(),
          ),
          child: _buildWeatherEffects(),
        );
      },
    );
  }

  LinearGradient _getWeatherGradient() {
    final condition = widget.weatherCondition?.toLowerCase() ?? '';

    if (condition.contains('sunny') || condition.contains('clear')) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(AppColors.sunnyYellow.shade600,
              AppColors.sunnyYellow.shade400, _gradientAnimation.value)!,
          Color.lerp(AppColors.sunnyYellow.shade400,
              AppColors.sunnyYellow.shade200, _gradientAnimation.value)!,
          Color.lerp(AppColors.sunnyYellow.shade200,
              AppColors.sunnyYellow.shade100, _gradientAnimation.value)!,
        ],
      );
    } else if (condition.contains('rain') || condition.contains('drizzle')) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(AppColors.rainyBlue.shade800, AppColors.rainyBlue.shade600,
              _gradientAnimation.value)!,
          Color.lerp(AppColors.rainyBlue.shade600, AppColors.rainyBlue.shade400,
              _gradientAnimation.value)!,
          Color.lerp(AppColors.rainyBlue.shade400, AppColors.rainyBlue.shade200,
              _gradientAnimation.value)!,
        ],
      );
    } else if (condition.contains('cloud')) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(AppColors.cloudyGrey.shade600,
              AppColors.cloudyGrey.shade400, _gradientAnimation.value)!,
          Color.lerp(AppColors.cloudyGrey.shade400,
              AppColors.cloudyGrey.shade300, _gradientAnimation.value)!,
          Color.lerp(AppColors.cloudyGrey.shade300,
              AppColors.cloudyGrey.shade100, _gradientAnimation.value)!,
        ],
      );
    } else if (condition.contains('snow')) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(AppColors.snowyLightBlue.shade400,
              AppColors.snowyLightBlue.shade200, _gradientAnimation.value)!,
          Color.lerp(AppColors.snowyLightBlue.shade200,
              AppColors.snowyLightBlue.shade100, _gradientAnimation.value)!,
          Color.lerp(AppColors.snowyLightBlue.shade100,
              AppColors.snowyLightBlue.shade50, _gradientAnimation.value)!,
        ],
      );
    } else if (condition.contains('storm') || condition.contains('thunder')) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(AppColors.stormyPurple.shade800,
              AppColors.stormyPurple.shade600, _gradientAnimation.value)!,
          Color.lerp(AppColors.stormyPurple.shade600,
              AppColors.stormyPurple.shade400, _gradientAnimation.value)!,
          Color.lerp(AppColors.stormyPurple.shade400,
              AppColors.stormyPurple.shade200, _gradientAnimation.value)!,
        ],
      );
    } else {
      // Default gradient
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(AppColors.primaryBlue.shade600,
              AppColors.primaryBlue.shade400, _gradientAnimation.value)!,
          Color.lerp(AppColors.primaryBlue.shade400,
              AppColors.primaryBlue.shade200, _gradientAnimation.value)!,
          Color.lerp(AppColors.primaryBlue.shade200,
              AppColors.primaryBlue.shade100, _gradientAnimation.value)!,
        ],
      );
    }
  }

  Widget _buildWeatherEffects() {
    final condition = widget.weatherCondition?.toLowerCase() ?? '';

    if (condition.contains('rain')) {
      return _buildRainEffect();
    } else if (condition.contains('snow')) {
      return _buildSnowEffect();
    } else if (condition.contains('cloud')) {
      return _buildCloudEffect();
    }

    return const SizedBox.shrink();
  }

  Widget _buildRainEffect() {
    return Stack(
      children: List.generate(50, (index) {
        return Positioned(
          left: (index * 20.0) % MediaQuery.of(context).size.width,
          top: -20,
          child: AnimatedBuilder(
            animation: _gradientAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                    0,
                    (_gradientAnimation.value *
                            MediaQuery.of(context).size.height *
                            2) %
                        (MediaQuery.of(context).size.height + 40)),
                child: Container(
                  width: 2,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildSnowEffect() {
    return Stack(
      children: List.generate(30, (index) {
        return Positioned(
          left: (index * 30.0) % MediaQuery.of(context).size.width,
          top: -10,
          child: AnimatedBuilder(
            animation: _gradientAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                    0,
                    (_gradientAnimation.value *
                            MediaQuery.of(context).size.height *
                            1.5) %
                        (MediaQuery.of(context).size.height + 20)),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildCloudEffect() {
    return Positioned(
      top: 50,
      left: -50,
      child: AnimatedBuilder(
        animation: _gradientAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
                (_gradientAnimation.value *
                            (MediaQuery.of(context).size.width + 100)) %
                        (MediaQuery.of(context).size.width + 100) -
                    50,
                0),
            child: Opacity(
              opacity: 0.3,
              child: Icon(
                Icons.cloud,
                size: 100,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          );
        },
      ),
    );
  }
}
