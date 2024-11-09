import 'dart:convert';
import 'package:http/http.dart' as http;

class CarbonIntensityModel {
  Future<int> fetchCurrentIntensity() async {
    final response = await http.get(
        Uri.parse('https://api.carbonintensity.org.uk/intensity')
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'][0]['intensity']['actual'] ?? 0;
    } else {
      throw Exception('Failed to fetch current intensity');
    }
  }

  Future<Map<String, dynamic>> fetchDailyIntensityData() async {
    final response = await http.get(
        Uri.parse('https://api.carbonintensity.org.uk/intensity/date')
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to fetch daily intensity data');
    }
  }
}