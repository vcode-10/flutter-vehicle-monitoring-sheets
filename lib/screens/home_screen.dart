import 'package:flutter/material.dart';
import 'form_input_screen.dart';
import 'data_view_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Kendaraan & BBM'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FormInputScreen()),
                );
              },
              child: const Text('Input Laporan'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DataViewScreen()),
                );
              },
              child: const Text('Lihat Laporan'),
            ),
          ],
        ),
      ),
    );
  }
}