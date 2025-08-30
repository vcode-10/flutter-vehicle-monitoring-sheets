import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/data_provider.dart';
import 'providers/selection_provider.dart';
import 'providers/trip_provider.dart';
import 'providers/theme_provider.dart'; 
import 'screens/selection_screen.dart';
import 'theme/app_theme.dart';

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
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), 
      ],
      child: Consumer<ThemeProvider>( 
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Manajemen Perjalanan',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode, 
            debugShowCheckedModeBanner: false,
            home: const SelectionScreen(),
          );
        },
      ),
    );
  }
}