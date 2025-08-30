import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/selection_provider.dart';
import 'data_view_screen.dart';
import 'edit_fuel_screen.dart';
import 'form_input_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectionProvider = Provider.of<SelectionProvider>(context);
    final driverName = selectionProvider.selectedDriver?.namaSopir ?? 'Sopir';
    final vehicleId = selectionProvider.selectedVehicle?.idKendaraan ?? 'Kendaraan';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Utama'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kartu Sambutan
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Selamat Datang,',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      driverName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Menggunakan: $vehicleId',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Tombol Menu
            _MenuButton(
              icon: Icons.edit_document,
              label: 'Input Laporan BBM',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FormInputScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _MenuButton(
              icon: Icons.view_list,
              label: 'Lihat Laporan Hari Ini',
              onPressed: () {
                 Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DataViewScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _MenuButton(
              icon: Icons.local_gas_station,
              label: 'Edit Harga BBM',
              onPressed: () {
                 Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditFuelScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _MenuButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        textStyle: const TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}