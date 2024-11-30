import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiKey = '0741bbbfaa5554c40964fc241198e0e7';

class WeatherService {
  final String apiKey = '0741bbbfaa5554c40964fc241198e0e7'; // Your API key
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> getWeather(String city) async {
    final response = await http.get(Uri.parse(
      '$baseUrl?q=$city&appid=$apiKey&units=metric',
    ));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
