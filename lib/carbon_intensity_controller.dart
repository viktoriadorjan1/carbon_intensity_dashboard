import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'carbon_intensity_model.dart';
import 'package:fl_chart/fl_chart.dart';

class CarbonIntensityController {

  ValueNotifier<int?> currentIntensity = ValueNotifier<int?>(null);
  ValueNotifier<List<FlSpot>> actualSpots = ValueNotifier<List<FlSpot>>([]);
  ValueNotifier<List<FlSpot>> forecastSpots = ValueNotifier<List<FlSpot>>([]);
  ValueNotifier<List<String>> timeLabels = ValueNotifier<List<String>>([]);

  Timer? updateTimer;

  final CarbonIntensityModel model;
  CarbonIntensityController(this.model);

  void startDataFetchTimer() {
    // A periodic timer updates data every 5 minutes
    updateTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    try {
      // Fetch current intensity value
      final currentIntensityValue = await model.fetchCurrentIntensity();
      currentIntensity.value = currentIntensityValue;

      // Fetch intensity data for the day to display on the graph
      final todayData = await model.fetchDailyIntensityData();
      List<dynamic> dataPoints = todayData['data'];

      // Lists for the new data points and time labels.
      List<FlSpot> newActualSpots = [];
      List<FlSpot> newForecastSpots = [];
      List<String> newTimeLabels = [];

      // Convert data points to FlSpot objects.
      for (var i = 0; i < dataPoints.length; i++) {
        final point = dataPoints[i];
        final timeString = point['from'];
        final actualIntensity = point['intensity']['actual']?.toDouble() ?? 0.0;
        final forecastIntensity = point['intensity']['forecast'].toDouble();

        // Convert timestamp from String to DateTime and format as HH:MM.
        final timestamp = DateTime.parse(timeString);
        final formattedTime = DateFormat.Hm().format(timestamp);

        // Only add and display data points up to the current time.
        if (timestamp.isAfter(DateTime.now())) {
          break;
        } else {
          if (actualIntensity > 0.0) {
            newActualSpots.add(FlSpot(i.toDouble(), actualIntensity));
            newForecastSpots.add(FlSpot(i.toDouble(), forecastIntensity));
          } else {
            newForecastSpots.add(FlSpot(i.toDouble(), forecastIntensity));
          }
        }

        newTimeLabels.add(formattedTime);
      }

      // Update ValueNotifiers.
      actualSpots.value = newActualSpots;
      forecastSpots.value = newForecastSpots;
      timeLabels.value = newTimeLabels;
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void dispose() {
    // cancel timer upon disposal.
    updateTimer?.cancel();
    currentIntensity.dispose();
    actualSpots.dispose();
    forecastSpots.dispose();
    timeLabels.dispose();
  }
}