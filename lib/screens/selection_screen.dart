import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/driver_model.dart';
import '../models/vehicle_model.dart';
import '../providers/data_provider.dart';
import '../providers/selection_provider.dart';
import 'home_screen.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  Vehicle? _selectedVehicle;
  Driver? _selectedDriver;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DataProvider>(context, listen: false).fetchInitialData();
    });
  }

  void _continue() {
    if (_formKey.currentState!.validate()) {
      Provider.of<SelectionProvider>(
        context,
        listen: false,
      ).setSelection(_selectedVehicle!, _selectedDriver!);
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Consumer<DataProvider>(
              builder: (context, dataProvider, child) {
                if (dataProvider.isLoading && dataProvider.vehicles.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final uniqueVehicles = <String, Vehicle>{};
                for (var vehicle in dataProvider.vehicles) {
                  uniqueVehicles[vehicle.idKendaraan] = vehicle;
                }
                final uniqueVehicleList = uniqueVehicles.values.toList();

                final uniqueDrivers = <String, Driver>{};
                for (var driver in dataProvider.drivers) {
                  uniqueDrivers[driver.idSopir] = driver;
                }
                final uniqueDriverList = uniqueDrivers.values.toList();

                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                     Image.asset(
                        'assets/icon.png',
                        height: 250,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.route, size: 150);
                        },
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Selamat Datang',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pilih kendaraan dan sopir untuk memulai sesi.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 40),
                      DropdownButtonFormField<Vehicle>(
                        value: _selectedVehicle,
                        hint: const Text('Pilih Kendaraan'),
                        // Gunakan daftar yang sudah unik
                        items: uniqueVehicleList
                            .map(
                              (v) => DropdownMenuItem(
                                value: v,
                                child: Text(
                                  '${v.idKendaraan} (${v.tipeMobil})',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedVehicle = val),
                        validator: (v) =>
                            v == null ? 'Kendaraan wajib dipilih' : null,
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<Driver>(
                        value: _selectedDriver,
                        hint: const Text('Pilih Sopir'),
                        // Gunakan daftar yang sudah unik
                        items: uniqueDriverList
                            .map(
                              (d) => DropdownMenuItem(
                                value: d,
                                child: Text(d.namaSopir),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedDriver = val),
                        validator: (v) =>
                            v == null ? 'Sopir wajib dipilih' : null,
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: dataProvider.isLoading ? null : _continue,
                        child: dataProvider.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('LANJUTKAN'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

