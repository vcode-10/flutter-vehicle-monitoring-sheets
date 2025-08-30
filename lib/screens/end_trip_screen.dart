import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';

class EndTripScreen extends StatefulWidget {
  const EndTripScreen({super.key});
  @override
  State<EndTripScreen> createState() => _EndTripScreenState();
}

class _EndTripScreenState extends State<EndTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kmAkhirController = TextEditingController();
  bool _isLoading = false;

  Future<void> _endTrip() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final tripId = Provider.of<TripProvider>(context, listen: false).currentTripStatus!.tripId;
      final tripData = {
        'id_perjalanan': tripId,
        'km_akhir': int.parse(_kmAkhirController.text),
      };
      await Provider.of<TripProvider>(context, listen: false).endTrip(tripData);
      if(mounted) Navigator.of(context).pop();
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selesaikan Perjalanan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _kmAkhirController,
                decoration: const InputDecoration(labelText: 'KM Akhir'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _endTrip,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, foregroundColor: Colors.white),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('SELESAIKAN PERJALANAN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}