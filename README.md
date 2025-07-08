# Weather App

A simple **Weather App** built with **Flutter**, **Cubit** for state management, and a **RESTful API** to fetch weather data. This app provides users with current weather information, including temperature, humidity, wind speed, and forecasts for their location or any city.

## Features

- **Current Weather**: Displays real-time weather information such as temperature, humidity, wind speed, and weather conditions.
- **Search Cities**: Users can search for weather data by city name.
- **Forecast**: View a simple weather forecast for the next few days.
- **Cubit for State Management**: Manages the app's state using the **Cubit** pattern for better scalability and maintainability.
- **RESTful API**: Fetches weather data from a public weather API (e.g., OpenWeatherMap, WeatherStack).

## Technologies Used

- **Flutter**: The mobile framework used to build the app.
- **Dart**: Programming language used for development.
- **Cubit**: A simple state management solution for managing app states.
- **RESTful API**: The app communicates with a weather API to fetch weather data.
- **HTTP Package**: For making API requests to fetch weather data.
- **JSON**: To parse the data from the API.

## Installation

### Prerequisites

Before running the project, make sure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- An IDE like **Android Studio** or **VSCode** for Flutter development.

### API Key

To fetch weather data, you will need an API key. For example, you can use **OpenWeatherMap** or **WeatherStack**. Follow the instructions below:

1. **OpenWeatherMap**:
   - Go to [OpenWeatherMap](https://openweathermap.org/api).
   - Sign up and get your API key.
   
2. **WeatherStack**:
   - Go to [WeatherStack](https://weatherstack.com/).
   - Sign up and get your API key.

Once you have your API key, replace it in the code where the API URL is defined.

### Steps to Run the Project Locally

1. **Clone the repository**:
    ```bash
    git clone https://github.com/HossamAhmed954074/weather_app.git
    ```

2. **Navigate to the project directory**:
    ```bash
    cd weather_app
    ```

3. **Install dependencies**:
    ```bash
    flutter pub get
    ```

4. **Set up API Key**:
   - Replace the placeholder in the API URL with your actual API key in the code.

5. **Run the app**:
    - For **Android**:
      ```bash
      flutter run
      ```
    - For **iOS** (on macOS):
      ```bash
      flutter run
      ```

## Usage

Once the app is running:

- **View Current Weather**: The app will show the current weather information like temperature, humidity, wind speed, and weather condition.
- **Search for Cities**: Users can search for the weather of any city by entering the city name in the search bar.
- **View Forecast**: Get a simple weather forecast for the upcoming days.
  
The app will fetch data from the RESTful API and update the UI with the weather information.

## Cubit Architecture

This app uses **Cubit** for state management. Cubit provides a simpler way to manage app state compared to more complex state management solutions, like **BLoC**. 

### Key Cubit Components:

- **WeatherCubit**: Manages the state related to weather data (current weather, forecast).
- **WeatherState**: Holds the state of the weather data (loading, loaded, error).
  
The app updates the UI based on different states like loading, success, or failure using the Cubit pattern.

### WeatherCubit Example:

```dart
class WeatherCubit extends Cubit<WeatherState> {
  final WeatherRepository weatherRepository;

  WeatherCubit(this.weatherRepository) : super(WeatherInitial());

  Future<void> fetchWeather(String city) async {
    try {
      emit(WeatherLoading());
      final weatherData = await weatherRepository.getWeather(city);
      emit(WeatherLoaded(weatherData));
    } catch (e) {
      emit(WeatherError("Failed to fetch weather data"));
    }
  }
}

