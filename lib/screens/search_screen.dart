import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/get_weather_cubit/get_weather_cubit.dart';
import '../cubits/get_weather_cubit/get_weather_states.dart';
import '../constants/app_constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<String> _searchHistory = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _loadSearchHistory();
  }

  void _initializeControllers() {
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  void _loadSearchHistory() async {
    final history = await context.read<WeatherCubit>().getSearchHistory();
    setState(() {
      _searchHistory = history;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty && query.length > 2) {
      if (!_isSearching) {
        setState(() {
          _isSearching = true;
        });
        context.read<WeatherCubit>().searchLocations(query);
      }
    } else {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryBlue.shade600,
              AppColors.primaryBlue.shade400,
              AppColors.primaryBlue.shade200,
            ],
          ),
        ),
        child: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: FadeTransition(
        opacity: _fadeAnimation,
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      title: FadeTransition(
        opacity: _fadeAnimation,
        child: Text(
          'Search Location',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              _buildSearchField(),
              const SizedBox(height: AppConstants.largePadding),
              Expanded(
                child: BlocBuilder<WeatherCubit, WeatherState>(
                  builder: (context, state) {
                    if (state is LocationSearchLoading) {
                      return _buildLoadingSection();
                    } else if (state is LocationSearchLoaded) {
                      return _buildSearchResults(state.locations);
                    } else if (state is LocationSearchErrorState) {
                      return _buildErrorSection(state.message);
                    } else {
                      return _buildDefaultSection();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: _onSearchSubmitted,
        decoration: InputDecoration(
          hintText: 'Enter city name or location...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.clear_rounded),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.defaultPadding,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSection() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: AppConstants.defaultPadding),
          Text(
            'Searching for locations...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<String> locations) {
    if (locations.isEmpty) {
      return _buildNoResultsSection();
    }

    return ListView.builder(
      itemCount: locations.length,
      itemBuilder: (context, index) {
        return _buildLocationItem(locations[index]);
      },
    );
  }

  Widget _buildLocationItem(String location) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.location_on_rounded,
          color: Colors.white,
        ),
        title: Text(
          location,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white,
          size: 16,
        ),
        onTap: () => _selectLocation(location),
      ),
    );
  }

  Widget _buildNoResultsSection() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 60,
            color: Colors.white,
          ),
          SizedBox(height: AppConstants.defaultPadding),
          Text(
            'No locations found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppConstants.smallPadding),
          Text(
            'Try searching with a different term',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSection(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 60,
            color: Colors.white,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'Search Error',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_searchHistory.isNotEmpty) ...[
          _buildSectionHeader('Recent Searches'),
          const SizedBox(height: AppConstants.defaultPadding),
          Expanded(
            child: ListView.builder(
              itemCount: _searchHistory.length,
              itemBuilder: (context, index) {
                return _buildHistoryItem(_searchHistory[index]);
              },
            ),
          ),
        ] else ...[
          _buildEmptyHistorySection(),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        if (_searchHistory.isNotEmpty)
          TextButton(
            onPressed: _clearHistory,
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.white70),
            ),
          ),
      ],
    );
  }

  Widget _buildHistoryItem(String location) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.history_rounded,
          color: Colors.white70,
        ),
        title: Text(
          location,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white,
          size: 16,
        ),
        onTap: () => _selectLocation(location),
      ),
    );
  }

  Widget _buildEmptyHistorySection() {
    return const Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_searching_rounded,
              size: 80,
              color: Colors.white54,
            ),
            SizedBox(height: AppConstants.largePadding),
            Text(
              'No Recent Searches',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppConstants.smallPadding),
            Text(
              'Start by searching for a city or location',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      _selectLocation(query.trim());
    }
  }

  void _selectLocation(String location) {
    context.read<WeatherCubit>().getCurrentWeather(location);
    Navigator.of(context).pop();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
  }

  void _clearHistory() async {
    await context.read<WeatherCubit>().clearSearchHistory();
    setState(() {
      _searchHistory.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Search history cleared'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
