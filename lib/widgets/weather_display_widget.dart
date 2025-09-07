import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../models/weather_model.dart';
import '../constants/app_constants.dart';

class WeatherDisplayWidget extends StatefulWidget {
  final WeatherModel weather;
  final bool isFromCache;

  const WeatherDisplayWidget({
    super.key,
    required this.weather,
    this.isFromCache = false,
  });

  @override
  State<WeatherDisplayWidget> createState() => _WeatherDisplayWidgetState();
}

class _WeatherDisplayWidgetState extends State<WeatherDisplayWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late List<Animation<Offset>> _slideAnimations;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: AppConstants.slowAnimation,
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: AppConstants.normalAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Create staggered slide animations for different sections
    _slideAnimations = List.generate(
      4,
      (index) => Tween<Offset>(
        begin: Offset(0, 0.5 + (index * 0.1)),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Interval(
          index * 0.2,
          1.0,
          curve: Curves.elasticOut,
        ),
      )),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          if (widget.isFromCache) _buildCacheIndicator(),
          if (widget.isFromCache)
            const SizedBox(height: AppConstants.defaultPadding),
          _buildMainWeatherCard(),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildWeatherDetailsGrid(),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildAdditionalInfo(),
          const SizedBox(
              height: AppConstants.defaultPadding), // Extra bottom padding
        ],
      ),
    );
  }

  Widget _buildCacheIndicator() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: Colors.orange.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cached_rounded,
              color: Colors.orange,
              size: 16,
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Text(
              'Showing cached data',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainWeatherCard() {
    return SlideTransition(
      position: _slideAnimations[0],
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 300,
          borderRadius: AppConstants.borderRadius,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.5),
              Colors.white.withOpacity(0.2),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLocationHeader(),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildTemperatureSection(),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildConditionSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Column(
      children: [
        Text(
          widget.weather.location,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        Text(
          widget.weather.country,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          'Updated ${widget.weather.formattedLastUpdated}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
        ),
      ],
    );
  }

  Widget _buildTemperatureSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildWeatherIcon(),
        Column(
          children: [
            Text(
              '${widget.weather.temperature.round()}°C',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Row(
              children: [
                Text(
                  'H: ${widget.weather.maxTemperature.round()}°',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  'L: ${widget.weather.minTemperature.round()}°',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: CachedNetworkImage(
        imageUrl: widget.weather.iconUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => const CircularProgressIndicator(
          color: Colors.white,
        ),
        errorWidget: (context, url, error) => const Icon(
          Icons.cloud_outlined,
          size: 50,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildConditionSection() {
    return Text(
      widget.weather.condition,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildWeatherDetailsGrid() {
    return SlideTransition(
      position: _slideAnimations[1],
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.3, // Increased from 1.5 to give more height
          mainAxisSpacing: AppConstants.defaultPadding,
          crossAxisSpacing: AppConstants.defaultPadding,
          children: [
            _buildDetailCard(
              'Humidity',
              '${widget.weather.humidity.round()}%',
              Icons.water_drop_outlined,
            ),
            _buildDetailCard(
              'Wind Speed',
              '${widget.weather.windSpeed.round()} ${widget.weather.windSpeedUnit}',
              Icons.air_rounded,
            ),
            _buildDetailCard(
              'Pressure',
              '${widget.weather.pressure.round()} ${widget.weather.pressureUnit}',
              Icons.compress_rounded,
            ),
            _buildDetailCard(
              'UV Index',
              widget.weather.uvIndex.round().toString(),
              Icons.wb_sunny_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: double.infinity,
      borderRadius: AppConstants.borderRadius,
      blur: 15,
      alignment: Alignment.bottomCenter,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 26, // Reduced from 30
            ),
            const SizedBox(
                height: AppConstants.smallPadding * 0.8), // Reduced spacing
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(
                height: AppConstants.smallPadding * 0.6), // Reduced spacing
            Flexible(
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14, // Slightly smaller font
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return SlideTransition(
      position: _slideAnimations[2],
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 110, // Increased height to prevent overflow
          borderRadius: AppConstants.borderRadius,
          blur: 15,
          alignment: Alignment.bottomCenter,
          border: 1,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.3),
              Colors.white.withOpacity(0.1),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _buildInfoColumn(
                    'Visibility',
                    '${widget.weather.visibility.round()} ${widget.weather.visibilityUnit}',
                    Icons.visibility_outlined,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: _buildInfoColumn(
                    'Wind Direction',
                    widget.weather.windDirection,
                    Icons.navigation_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 22, // Slightly smaller icon
        ),
        const SizedBox(
            height: AppConstants.smallPadding * 0.8), // Reduced spacing
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(
            height: AppConstants.smallPadding * 0.4), // Reduced spacing
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13, // Slightly smaller font
              ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
