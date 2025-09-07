import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../cubits/get_weather_cubit/get_weather_cubit.dart';
import '../cubits/get_weather_cubit/get_weather_states.dart';
import '../widgets/weather_display_widget.dart';
import '../widgets/no_weather_display_widget.dart';
import '../widgets/enhanced_loading_widget.dart';
import '../widgets/error_display_widget.dart';
import '../widgets/weather_background_widget.dart';
import '../constants/app_constants.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _hasTriedToLoadLastWeather = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Try to load last weather after a short delay for better perceived performance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryLoadLastWeather();
    });
  }

  void _tryLoadLastWeather() async {
    if (_hasTriedToLoadLastWeather) return;
    _hasTriedToLoadLastWeather = true;

    // Small delay to allow UI to render first
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      context.read<WeatherCubit>().loadLastWeather();
    }
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: AppConstants.normalAnimation,
      vsync: this,
    );

    _slideController = AnimationController(
      duration: AppConstants.slowAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: BlocBuilder<WeatherCubit, WeatherState>(
        builder: (context, state) {
          return Stack(
            children: [
              WeatherBackgroundWidget(
                weatherCondition:
                    state is WeatherLoaded ? state.weather.condition : null,
              ),
              SafeArea(
                child: _buildBody(state),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedTextKit(
          animatedTexts: [
            TyperAnimatedText(
              'Professional Weather',
              textStyle: Theme.of(context).appBarTheme.titleTextStyle ??
                  const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
              speed: const Duration(milliseconds: 100),
            ),
          ],
          isRepeatingAnimation: false,
        ),
      ),
      actions: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: IconButton(
            onPressed: () =>
                context.read<WeatherCubit>().getCurrentLocationWeather(),
            icon: const Icon(Icons.my_location_rounded),
            tooltip: 'Use current location',
          ),
        ),
        FadeTransition(
          opacity: _fadeAnimation,
          child: IconButton(
            onPressed: () => _navigateToSearch(),
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search location',
          ),
        ),
        FadeTransition(
          opacity: _fadeAnimation,
          child: BlocBuilder<WeatherCubit, WeatherState>(
            builder: (context, state) {
              if (state is WeatherLoaded) {
                return IconButton(
                  onPressed: () => _refreshWeather(),
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh weather',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBody(WeatherState state) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: _getBodyWidget(state),
      ),
    );
  }

  Widget _getBodyWidget(WeatherState state) {
    if (state is WeatherInitial) {
      return const NoWeatherDisplayWidget();
    } else if (state is WeatherLoading || state is LocationLoading) {
      String message = state is WeatherLoading
          ? (state.message ?? 'Loading weather data...')
          : (state as LocationLoading).message;
      return EnhancedLoadingWidget(message: message);
    } else if (state is WeatherLoaded) {
      return WeatherDisplayWidget(
        weather: state.weather,
        isFromCache: state.isFromCache,
      );
    } else if (state is WeatherErrorState) {
      return ErrorDisplayWidget(
        message: state.message,
        details: state.details,
        canRetry: state.canRetry,
        cachedWeather: state.cachedWeather,
        onRetry: () => _retryRequest(),
      );
    } else if (state is LocationError) {
      return _buildLocationErrorWidget(state);
    } else {
      return const ErrorDisplayWidget(
        message: 'Unknown state occurred',
        canRetry: true,
      );
    }
  }

  void _navigateToSearch() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SearchScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: AppConstants.normalAnimation,
      ),
    );
  }

  void _refreshWeather() {
    context.read<WeatherCubit>().refreshCurrentWeather();
  }

  void _retryRequest() {
    context.read<WeatherCubit>().retryLastRequest();
  }

  Widget _buildLocationErrorWidget(LocationError state) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
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
                Icons.location_off_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.largePadding),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'Location Error',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              state.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
            ),
          ),
          const SizedBox(height: AppConstants.largePadding * 2),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                if (state.canOpenSettings)
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<WeatherCubit>().openLocationSettings(),
                    icon: const Icon(Icons.settings_rounded),
                    label: const Text('Open Location Settings'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.largePadding,
                        vertical: AppConstants.defaultPadding,
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade700,
                    ),
                  ),
                const SizedBox(height: AppConstants.defaultPadding),
                TextButton.icon(
                  onPressed: () =>
                      context.read<WeatherCubit>().getCurrentLocationWeather(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.largePadding,
                      vertical: AppConstants.defaultPadding,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                TextButton.icon(
                  onPressed: () => _navigateToSearch(),
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Search Manually'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.largePadding,
                      vertical: AppConstants.defaultPadding,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
