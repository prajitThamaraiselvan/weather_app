import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(
    MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather Forecast',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'assets/background.gif',
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 40.0,
            left: 0.0,
            right: 0.0,
            child: Column(
              children: [
                Text(
                  'Weather Forecast',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10), // Add spacing between text and icon
                Image.asset(
                  'assets/your_icon.png', // Replace 'your_icon.png' with your icon asset path
                  width: 50, // Adjust the width as needed
                  height: 50, // Adjust the height as needed
                ),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Enter a City',
                        prefixIcon: GestureDetector(
                          onTap: () {
                            _searchWeather(context, _searchController.text);
                          },
                          child: Icon(Icons.search),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0),
                          borderSide: BorderSide(
                            width: 1,
                            color: Colors.transparent,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0),
                          borderSide: BorderSide(
                            width: 1,
                            color: Colors.transparent,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.3),
                      ),
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      onSubmitted: (value) {
                        _searchWeather(context, value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _searchWeather(BuildContext context, String cityName) async {
    final apiKey = '9bd5195f3eb3bd08347ba11661bdc5ba';
    final apiUrl =
        'http://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final weather = data['weather'][0]['main'];
      final temp = data['main']['temp'];
      final windSpeed = data['wind']['speed'];
      final humidity = data['main']['humidity'];
      final timestamp = data['dt'];
      final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WeatherScreen(
            cityName: cityName,
            weather: weather,
            temperature: temp,
            windSpeed: windSpeed,
            humidity: humidity,
            dateTime: dateTime,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch weather data. Please try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}


// WeatherScreen Widget
class WeatherScreen extends StatelessWidget {
  final String cityName;
  final String weather;
  final double temperature;
  final double windSpeed;
  final int humidity;
  final DateTime dateTime;

  WeatherScreen({
    required this.cityName,
    required this.weather,
    required this.temperature,
    required this.windSpeed,
    required this.humidity,
    required this.dateTime,
  });

  String _getWeatherIconPath(String weatherCondition) {
    switch (weatherCondition) {
      case 'Clear':
        return 'assets/sunny.png';
      case 'Clouds':
        return 'assets/cloudy.png';
      case 'Rain':
        return 'assets/rainy.png';
      case 'Snow':
        return 'assets/snowy.png';
      case 'Haze':
        return 'assets/haze.png';
      case 'Thunderstorm':
        return 'assets/thunderstorm.png';
      default:
        return 'assets/error.png'; // Default icon for unknown weather
    }
  }

  String _getTemperatureIconPath() {
    if (temperature < 20) {
      return 'assets/low_temperature_icon.png';
    } else if (temperature >= 20 && temperature <= 30) {
      return 'assets/normal_temperature_icon.png';
    } else {
      return 'assets/high_temperature_icon.png';
    }
  }

  String _getWindSpeedIconPath(double windSpeed) {
    if (windSpeed < 5) {
      return 'assets/low_wind_speed_icon.png';
    } else if (windSpeed >= 5 && windSpeed <= 10) {
      return 'assets/medium_wind_speed_icon.png';
    } else {
      return 'assets/high_wind_speed_icon.png';
    }
  }

  String _getHumidityIconPath(int humidity) {
    if (humidity < 30) {
      return 'assets/low_humidity_icon.png';
    } else if (humidity >= 30 && humidity <= 60) {
      return 'assets/medium_humidity_icon.png';
    } else {
      return 'assets/high_humidity_icon.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final formattedDate = dateFormat.format(dateTime);

    return Scaffold(
      
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'assets/background.gif',
              fit: BoxFit.cover,
            ),
          ),
          ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              // Calculate the date for the forecast
              final forecastDay = dateTime.add(Duration(days: index));
              final formattedForecastDate = dateFormat.format(forecastDay);

              return Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date:$formattedForecastDate',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Image.asset(
                          _getWeatherIconPath(weather),
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Weather: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          weather,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Image.asset(
                          _getTemperatureIconPath(),
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Temperature: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${(temperature - 273.15).toStringAsFixed(2)}°C',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Image.asset(
                          _getWindSpeedIconPath(windSpeed),
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Wind Speed: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${windSpeed.toStringAsFixed(2)} m/s',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Image.asset(
                          _getHumidityIconPath(humidity),
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Humidity: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '$humidity%',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

