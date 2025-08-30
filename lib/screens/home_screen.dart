import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/selection_provider.dart';
import '../providers/theme_provider.dart'; 
import '../providers/trip_provider.dart';
import 'start_trip_screen.dart';
import 'add_fuel_log_screen.dart';
import 'end_trip_screen.dart';
import 'selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkStatus());
  }

  Future<void> _checkStatus() async {
    final selection = Provider.of<SelectionProvider>(context, listen: false);
    await Provider.of<TripProvider>(context, listen: false).checkTripStatus(
      selection.selectedVehicle!.idKendaraan,
      selection.selectedDriver!.idSopir,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selection = Provider.of<SelectionProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context); 
    final driverName = selection.selectedDriver?.namaSopir ?? 'Sopir';
    final vehicleId = selection.selectedVehicle?.idKendaraan ?? 'Kendaraan';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Ganti Pengguna',
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const SelectionScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            tooltip: 'Ganti Tema',
            onPressed: () {
              final provider = Provider.of<ThemeProvider>(context, listen: false);
              provider.toggleTheme(!themeProvider.isDarkMode);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Status',
            onPressed: _checkStatus,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Sesi Aktif',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        driverName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Menggunakan: $vehicleId',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Consumer<TripProvider>(
                builder: (context, trip, child) {
                  if (trip.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (trip.currentTripStatus == null) {
                    return const Center(child: Text('Gagal memeriksa status perjalanan.'));
                  }
                  
                  if (!trip.currentTripStatus!.tripExists || trip.currentTripStatus!.isFinished) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _ActionButton(
                          icon: Icons.play_arrow_rounded,
                          label: 'Mulai Perjalanan',
                          onPressed: () async {
                            await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StartTripScreen()));
                            _checkStatus(); // Refresh setelah kembali
                          },
                        ),
                      ],
                    );
                  } 
                  else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ActionButton(
                          icon: Icons.local_gas_station_rounded,
                          label: 'Input Isi BBM',
                          onPressed: () async {
                            await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddFuelLogScreen()));
                             _checkStatus();
                          },
                        ),
                        const SizedBox(height: 16),
                        _ActionButton(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'Selesaikan Perjalanan',
                          onPressed: () async {
                            await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EndTripScreen()));
                             _checkStatus();
                          },
                          color: Colors.red.shade400,
                          foregroundColor: Colors.white,
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final Color? foregroundColor;

  const _ActionButton({required this.icon, required this.label, required this.onPressed, this.color, this.foregroundColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(vertical: 24),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        alignment: Alignment.center,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}
