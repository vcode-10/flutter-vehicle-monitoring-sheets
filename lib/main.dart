import 'package:flutter/material.dart';
import 'package:flutter_vehicle_monitoring_sheets/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'providers/report_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ReportProvider())],
      child: MaterialApp(
        title: 'Monitoring Kendaraan',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(), // Ganti dengan layar utama aplikasi Anda
      ),
    );
  }
}
