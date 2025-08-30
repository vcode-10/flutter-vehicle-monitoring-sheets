// lib/screens/edit_fuel_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class EditFuelScreen extends StatefulWidget {
  const EditFuelScreen({super.key});

  @override
  State<EditFuelScreen> createState() => _EditFuelScreenState();
}

class _EditFuelScreenState extends State<EditFuelScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final fuelTypes = Provider.of<DataProvider>(context, listen: false).fuelTypes;
    for (var fuel in fuelTypes) {
      _controllers[fuel.jenisBbm] = TextEditingController(text: fuel.hargaPerLiter.toString());
    }
  }
  
  void _saveChanges() {
    setState(() { _isLoading = true; });
    
    final List<Map<String, dynamic>> updatedPrices = [];
    _controllers.forEach((fuelName, controller) {
      updatedPrices.add({
        'jenis_bbm': fuelName,
        'harga_per_liter': int.parse(controller.text),
      });
    });

    Provider.of<DataProvider>(context, listen: false)
      .updateFuelPrices(updatedPrices)
      .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harga berhasil diperbarui!')));
          Navigator.of(context).pop();
      }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $error')));
      }).whenComplete(() {
          setState(() { _isLoading = false; });
      });
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Harga BBM')),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          if (dataProvider.fuelTypes.isEmpty) {
            return const Center(child: Text('Tidak ada data BBM.'));
          }
          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: dataProvider.fuelTypes.length,
                itemBuilder: (context, index) {
                  final fuel = dataProvider.fuelTypes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(fuel.jenisBbm, style: const TextStyle(fontSize: 16)),
                          ),
                          const Text('Rp '),
                          SizedBox(
                            width: 120,
                            child: TextFormField(
                              controller: _controllers[fuel.jenisBbm],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveChanges,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          child: const Text('SIMPAN PERUBAHAN'),
        ),
      ),
    );
  }
}