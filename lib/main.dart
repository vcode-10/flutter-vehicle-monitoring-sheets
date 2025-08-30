// di main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/report_provider.dart';
import 'providers/selection_provider.dart';
import 'providers/data_provider.dart';
import 'screens/selection_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SelectionProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: MaterialApp(
        title: 'Monitoring Kendaraan',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SelectionScreen(), // Ganti dengan layar utama aplikasi Anda
      ),
    );
  }
}