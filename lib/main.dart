import 'package:flutter/material.dart';
import 'carbon_intensity_model.dart';
import 'carbon_intensity_controller.dart';
import 'carbon_intensity_view.dart';

void main() {
  final model = CarbonIntensityModel();
  final controller = CarbonIntensityController(model);

  controller.fetchData();
  controller.startDataFetchTimer();

  runApp(MyApp(controller: controller));
}

class MyApp extends StatelessWidget {
  final CarbonIntensityController controller;

  const MyApp({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carbon Intensity Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: Dashboard(controller: controller),
    );
  }
}