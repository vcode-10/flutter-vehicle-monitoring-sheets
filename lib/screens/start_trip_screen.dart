import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/route_model.dart';
import '../providers/data_provider.dart';
import '../providers/selection_provider.dart';
import '../providers/trip_provider.dart';

class StartTripScreen extends StatefulWidget {
  const StartTripScreen({super.key});

  @override
  State<StartTripScreen> createState() => _StartTripScreenState();
}

class _StartTripScreenState extends State<StartTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kmAwalController = TextEditingController();
  RouteModel? _selectedRoute;
  bool _isLoading = false;
  bool _isOdoLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLastOdometer();
  }

  Future<void> _loadLastOdometer() async {
    setState(() => _isOdoLoading = true);
    final vehicleId = Provider.of<SelectionProvider>(context, listen: false).selectedVehicle!.idKendaraan;
    final lastOdo = await Provider.of<TripProvider>(context, listen: false).getLastOdometer(vehicleId);
    if (mounted) {
      _kmAwalController.text = lastOdo.toString();
      setState(() => _isOdoLoading = false);
    }
  }

  Future<void> _startTrip() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final selection = Provider.of<SelectionProvider>(context, listen: false);
      final tripData = {
        'id_sopir': selection.selectedDriver!.idSopir,
        'id_kendaraan': selection.selectedVehicle!.idKendaraan,
        'km_awal': int.parse(_kmAwalController.text),
        'id_rute': _selectedRoute!.idRute,
      };
      await Provider.of<TripProvider>(context, listen: false).startTrip(tripData);
      if(mounted) Navigator.of(context).pop();
    } catch(e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memulai perjalanan: $e')));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final routes = Provider.of<DataProvider>(context).routes;
    return Scaffold(
      appBar: AppBar(title: const Text('Mulai Perjalanan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _kmAwalController,
                decoration: InputDecoration(
                  labelText: 'KM Awal',
                  suffixIcon: _isOdoLoading ? const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2)) : null,
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                readOnly: _isOdoLoading,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RouteModel>(
                value: _selectedRoute,
                hint: const Text('Pilih Rute Perjalanan'),
                items: routes.map((r) => DropdownMenuItem(value: r, child: Text(r.namaRute))).toList(),
                onChanged: (val) => setState(() => _selectedRoute = val),
                validator: (v) => v == null ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _startTrip,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('MULAI'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}