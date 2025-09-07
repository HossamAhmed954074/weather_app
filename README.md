# 🌤️ Weather App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue.svg?style=for-the-badge)

A modern, feature-rich weather application built with Flutter and Cubit for state management. Get real-time weather information with beautiful animations and an intuitive user experience.

[Features](#-features) • [Installation](#-installation) • [Architecture](#-architecture) • [Contributing](#-contributing) • [License](#-license)

</div>

---

## 🚀 Features

### 🌍 Core Weather Features
- **Real-time Weather Data**: Get current weather conditions including temperature, humidity, wind speed, and atmospheric pressure
- **Location-based Weather**: Automatic location detection with GPS integration
- **City Search**: Search and get weather information for any city worldwide
- **Weather Forecasting**: Extended weather forecasts for better planning
- **Multiple Units**: Support for metric and imperial measurement systems

### 🎨 User Experience
- **Beautiful Animations**: Smooth Lottie animations and shimmer effects
- **Glassmorphism UI**: Modern glass-like interface elements
- **Animated Text**: Eye-catching text animations for better engagement
- **Responsive Design**: Optimized for various screen sizes and orientations
- **Dark/Light Theme**: Adaptive theming based on system preferences

### 🔧 Technical Features
- **Offline Support**: Local data caching with Hive database
- **Network Awareness**: Connectivity monitoring and offline mode
- **Permission Handling**: Smart location permission management
- **Environment Configuration**: Secure API key management with dotenv
- **Error Handling**: Comprehensive error states and user feedback

## 🛠️ Tech Stack

### Framework & Language
- **Flutter SDK** `^3.6.2` - Cross-platform mobile development
- **Dart** - Programming language

### State Management
- **Flutter BLoC/Cubit** `^9.0.0` - Predictable state management

### Networking & Data
- **Dio** `^5.8.0+1` - HTTP client for API requests
- **Hive** `^2.2.3` - Local database for caching
- **Shared Preferences** `^2.2.3` - Simple key-value storage

### Location & Permissions
- **Geolocator** `^12.0.0` - GPS location services
- **Geocoding** `^3.0.0` - Address to coordinates conversion
- **Permission Handler** `^11.3.1` - Runtime permission management
- **Connectivity Plus** `^6.0.3` - Network connectivity monitoring

### UI & Animations
- **Lottie** `^3.1.2` - Vector animations
- **Shimmer** `^3.0.0` - Loading skeleton animations
- **Animated Text Kit** `^4.2.2` - Text animations
- **Google Fonts** `^6.2.1` - Custom typography
- **Glassmorphism** `^3.0.0` - Modern glass effects
- **Cached Network Image** `^3.3.1` - Optimized image loading

### Development Tools
- **Flutter Lints** `^5.0.0` - Code quality and style
- **Build Runner** `^2.4.9` - Code generation
- **Hive Generator** `^2.0.1` - Hive model generation

## 📋 Prerequisites

Before getting started, ensure you have the following installed:

- **Flutter SDK** (>=3.6.2) - [Installation Guide](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (included with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **Git** for version control
- **Physical device** or **emulator** for testing

### Platform-specific Requirements

#### Android
- Android SDK (API level 21 or higher)
- Android device with USB debugging enabled

#### iOS (macOS only)
- Xcode (latest stable version)
- iOS Simulator or physical iOS device
- Apple Developer account (for device testing)

## 🔧 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/HossamAhmed954074/weather_app.git
cd weather_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Environment Setup
Create a `.env` file in the project root:
```env
# Weather API Configuration
WEATHER_API_KEY=your_api_key_here
WEATHER_BASE_URL=https://api.openweathermap.org/data/2.5

# App Configuration
APP_NAME=Weather App
DEBUG_MODE=true
```

### 4. API Key Configuration
1. Visit [OpenWeatherMap](https://openweathermap.org/api) and create a free account
2. Generate your API key
3. Add your API key to the `.env` file
4. Alternative APIs supported:
   - [WeatherAPI](https://www.weatherapi.com/)
   - [WeatherStack](https://weatherstack.com/)

### 5. Generate Required Files
```bash
flutter packages pub run build_runner build
```

### 6. Run the Application
```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Specific platform
flutter run -d android
flutter run -d ios
```

## 🏗️ Project Architecture

### 📁 Directory Structure
```
lib/
├── main.dart                 # Application entry point
├── api/                      # API service layer
│   └── serves.dart
├── constants/                # App-wide constants
│   └── app_constants.dart
├── cubits/                   # State management
│   └── get_weather_cubit/
│       ├── get_weather_cubit.dart
│       └── get_weather_states.dart
├── models/                   # Data models
│   ├── weather_model.dart
│   └── weather_model.g.dart
├── repositories/             # Data repositories
│   └── weather_repository.dart
├── screens/                  # UI screens
│   ├── home_screen.dart
│   ├── search_screen.dart
│   └── searching_screen.dart
├── services/                 # Business logic services
└── widgets/                  # Reusable UI components
```

### 🔄 State Management Pattern

This application follows the **BLoC (Cubit)** pattern for predictable state management:

```dart
// Weather States
abstract class GetWeatherState {}

class WeatherInitial extends GetWeatherState {}
class WeatherLoading extends GetWeatherState {}
class WeatherSuccess extends GetWeatherState {
  final WeatherModel weather;
  WeatherSuccess(this.weather);
}
class WeatherFailure extends GetWeatherState {
  final String errMessage;
  WeatherFailure(this.errMessage);
}

// Weather Cubit
class GetWeatherCubit extends Cubit<GetWeatherState> {
  GetWeatherCubit(this.weatherRepository) : super(WeatherInitial());
  
  final WeatherRepository weatherRepository;
  
  WeatherModel? weatherModel;
  
  Future<void> getWeather({required String cityName}) async {
    try {
      emit(WeatherLoading());
      weatherModel = await weatherRepository.getCurrentWeather(cityName: cityName);
      emit(WeatherSuccess(weatherModel!));
    } catch (e) {
      emit(WeatherFailure(e.toString()));
    }
  }
}
```

### 🗄️ Data Layer Architecture

- **Repository Pattern**: Abstracts data sources
- **Local Caching**: Hive database for offline support
- **Network Layer**: Dio for HTTP requests with interceptors
- **Error Handling**: Comprehensive error management

## 🚀 Getting Started

### First Launch
1. **Grant Permissions**: Allow location access for automatic weather detection
2. **Search Location**: Use the search feature to find weather for any city
3. **Explore Features**: Swipe through different weather metrics and forecasts

### Key User Flows
1. **Automatic Location Weather**:
   - App requests location permission
   - Fetches weather for current location
   - Displays comprehensive weather information

2. **Manual City Search**:
   - Tap search icon
   - Enter city name
   - View weather results
   - Save favorite locations

## 🧪 Testing

### Run Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter drive --target=test_driver/app.dart

# Coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Test Categories
- **Unit Tests**: Business logic and utilities
- **Widget Tests**: UI components and interactions
- **Integration Tests**: Complete user flows

## 🚀 Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (Recommended)
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🔧 Configuration

### API Endpoints
Configure different weather API providers in your `.env` file:

```env
# OpenWeatherMap
WEATHER_API_KEY=your_openweather_key
WEATHER_BASE_URL=https://api.openweathermap.org/data/2.5

# WeatherAPI (Alternative)
# WEATHER_API_KEY=your_weatherapi_key
# WEATHER_BASE_URL=https://api.weatherapi.com/v1
```

### App Constants
Modify `lib/constants/app_constants.dart` for:
- API endpoints
- Default locations
- UI configurations
- Cache durations

## 🐛 Troubleshooting

### Common Issues

#### Location Permission Denied
```dart
// Check permission status
LocationPermission permission = await Geolocator.checkPermission();
if (permission == LocationPermission.denied) {
  permission = await Geolocator.requestPermission();
}
```

#### Network Connectivity Issues
```dart
// Check internet connection
var connectivityResult = await Connectivity().checkConnectivity();
if (connectivityResult == ConnectivityResult.none) {
  // Show offline message
}
```

#### API Rate Limiting
- Implement proper caching strategies
- Use offline data when available
- Consider upgrading API plan

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the Repository**
```bash
git fork https://github.com/HossamAhmed954074/weather_app.git
```

2. **Create Feature Branch**
```bash
git checkout -b feature/amazing-feature
```

3. **Commit Changes**
```bash
git commit -m 'Add amazing feature'
```

4. **Push to Branch**
```bash
git push origin feature/amazing-feature
```

5. **Open Pull Request**

### Development Guidelines
- Follow [Flutter Style Guide](https://flutter.dev/docs/development/tools/formatting)
- Write tests for new features
- Update documentation
- Use conventional commit messages

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **OpenWeatherMap** for weather data API
- **Flutter Team** for the amazing framework
- **BLoC Library** for state management
- **Lottie** for beautiful animations
- **Community Contributors** for feedback and improvements

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/HossamAhmed954074/weather_app/issues)
- **Discussions**: [GitHub Discussions](https://github.com/HossamAhmed954074/weather_app/discussions)
- **Email**: [Contact Developer](mailto:hossamahmed954074@gmail.com)

---

<div align="center">
  <p>Made with ❤️ by <a href="https://github.com/HossamAhmed954074">Hossam Ahmed</a></p>
  <p>⭐ Star this repository if you found it helpful!</p>
</div>
