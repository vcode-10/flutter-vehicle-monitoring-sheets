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
    Provider.of<DataProvider>(context, listen: false).fetchInitialData();
  }

  void _continue() {
    if (_formKey.currentState!.validate()) {
      Provider.of<SelectionProvider>(context, listen: false)
          .setSelection(_selectedVehicle!, _selectedDriver!);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Kendaraan & Sopir')),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          if (dataProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dropdown Kendaraan
                  DropdownButtonFormField<Vehicle>(
                    value: _selectedVehicle,
                    hint: const Text('Pilih Kendaraan'),
                    items: dataProvider.vehicles.map((Vehicle vehicle) {
                      return DropdownMenuItem<Vehicle>(
                        value: vehicle,
                        child: Text('${vehicle.idKendaraan} (${vehicle.tipeMobil})'),
                      );
                    }).toList(),
                    onChanged: (Vehicle? newValue) {
                      setState(() {
                        _selectedVehicle = newValue;
                      });
                    },
                    validator: (value) => value == null ? 'Kendaraan harus dipilih' : null,
                  ),
                  const SizedBox(height: 20),

                  DropdownButtonFormField<Driver>(
                    value: _selectedDriver,
                    hint: const Text('Pilih Sopir'),
                    items: dataProvider.drivers.map((Driver driver) {
                      return DropdownMenuItem<Driver>(
                        value: driver,
                        child: Text('${driver.namaSopir} (${driver.idSopir})'),
                      );
                    }).toList(),
                    onChanged: (Driver? newValue) {
                      setState(() {
                        _selectedDriver = newValue;
                      });
                    },
                     validator: (value) => value == null ? 'Sopir harus dipilih' : null,
                  ),
                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: _continue,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('LANJUTKAN'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}