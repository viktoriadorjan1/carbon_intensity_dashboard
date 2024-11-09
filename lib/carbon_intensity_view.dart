import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'carbon_intensity_controller.dart';

class CarbonIntensityGraph extends StatelessWidget {
  final List<FlSpot> actualSpots;
  final List<FlSpot> forecastSpots;
  final List<String> timeLabels;

  const CarbonIntensityGraph({
    required this.actualSpots, required this.forecastSpots,
    required this.timeLabels, super.key
  });

  @override
  Widget build(BuildContext context) {
    // To avoid drawing outside of the graph, set maxY based on values.
    double maxY = 100;
    if (actualSpots.isNotEmpty || forecastSpots.isNotEmpty) {
      maxY = (actualSpots + forecastSpots)
          .map((e) => e.y)
          .reduce((a, b) => a > b ? a : b);
      // To avoid drawing on the grids, add 10% on the top of the graph.
      maxY += maxY * 0.1;
    }

    return Column(
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: forecastSpots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: actualSpots,
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                ),
              ],
              titlesData: FlTitlesData(
                // Hide top titles.
                topTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: maxY / 10,
                    getTitlesWidget: (value, _) {
                      return Text(
                        '${value.toInt()} gCO₂/kWh',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: maxY / 10,
                    getTitlesWidget: (value, _) {
                      return Text(
                        '${value.toInt()} gCO₂/kWh',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < timeLabels.length) {
                        return Text(timeLabels[index], style: const TextStyle(fontSize: 10));
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: true),
            ),
          ),
        ),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 16,
              height: 16,
              color: Colors.green,
            ),
            const SizedBox(width: 4),
            const Text(
              'Actual',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 16),
            Container(
              width: 16,
              height: 16,
              color: Colors.blue,
            ),
            const SizedBox(width: 4),
            const Text(
              'Predicted',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 16)
      ],
    );
  }
}

class Dashboard extends StatelessWidget {
  final CarbonIntensityController controller;

  const Dashboard({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carbon Intensity Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CurrentCarbonIntensity(controller: controller),
            const Text(
              'Today\'s Carbon Intensity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ValueListenableBuilder<List<FlSpot>>(
                valueListenable: controller.actualSpots,
                builder: (context, actual, child) {
                  return ValueListenableBuilder<List<FlSpot>>(
                    valueListenable: controller.forecastSpots,
                    builder: (context, forecast, child) {
                      return ValueListenableBuilder<List<String>>(
                        valueListenable: controller.timeLabels,
                        builder: (context, labels, child) {
                          return CarbonIntensityGraph(
                            actualSpots: actual,
                            forecastSpots: forecast,
                            timeLabels: labels,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurrentCarbonIntensity extends StatelessWidget{
  final CarbonIntensityController controller;

  const CurrentCarbonIntensity({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Carbon Intensity:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<int?>(
          valueListenable: controller.currentIntensity,
          builder: (context, intensity, child) {
            return Text(
              intensity != null ? '$intensity gCO₂/kWh' : 'Loading...',
              style: const TextStyle(fontSize: 24, color: Colors.green),
            );
          },
        )
      ],
    );
  }

}