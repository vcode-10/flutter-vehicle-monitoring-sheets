import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/fuel_type_model.dart';
import '../providers/data_provider.dart';
import '../providers/report_provider.dart';
import '../providers/selection_provider.dart';

class FormInputScreen extends StatefulWidget {
  const FormInputScreen({super.key});

  @override
  State<FormInputScreen> createState() => _FormInputScreenState();
}

class _FormInputScreenState extends State<FormInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _odometerController = TextEditingController();
  final _literController = TextEditingController();

  FuelType? _selectedFuelType;
  int _calculatedCost = 0;
  
  File? _imageFile;
  final _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _literController.addListener(_calculateCost);
  }

  void _calculateCost() {
    if (_selectedFuelType != null && _literController.text.isNotEmpty) {
      final liters = double.tryParse(_literController.text) ?? 0.0;
      setState(() {
        _calculatedCost = (liters * _selectedFuelType!.hargaPerLiter).round();
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(ctx).pop();
                }),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Ambil dengan Kamera'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field dan foto wajib diisi.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() { _isSubmitting = true; });

    try {
      // Konversi gambar ke base64
      final bytes = await _imageFile!.readAsBytes();
      String base64Image = base64Encode(bytes);
      String mimeType = _imageFile!.path.split('.').last;

      final selection = Provider.of<SelectionProvider>(context, listen: false);
      final reportData = {
        'id_kendaraan': selection.selectedVehicle!.idKendaraan,
        'nama_driver': selection.selectedDriver!.namaSopir,
        'odometer': int.parse(_odometerController.text),
        'jenis_bbm': _selectedFuelType!.jenisBbm,
        'jumlah_liter': double.parse(_literController.text),
        'biaya': _calculatedCost,
        // Kirim data gambar
        'foto_base64': base64Image,
        'foto_mime_type': 'image/$mimeType',
      };

      await Provider.of<ReportProvider>(context, listen: false).submitReport(reportData);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan berhasil dikirim!'), backgroundColor: Colors.green,));
      Navigator.of(context).pop();

    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $error'), backgroundColor: Colors.red,));
    } finally {
       if (mounted) {
         setState(() { _isSubmitting = false; });
       }
    }
  }
  
  @override
  void dispose() {
    _odometerController.dispose();
    _literController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selection = Provider.of<SelectionProvider>(context);
    final fuelTypes = Provider.of<DataProvider>(context).fuelTypes;

    return Scaffold(
      appBar: AppBar(title: const Text('Input Laporan BBM')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Sopir: ${selection.selectedDriver?.namaSopir ?? ''}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Kendaraan: ${selection.selectedVehicle?.idKendaraan ?? ''}', style: const TextStyle(fontSize: 16)),
              const Divider(height: 30),

              TextFormField(
                controller: _odometerController,
                decoration: const InputDecoration(labelText: 'Odometer (KM)'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

             DropdownButtonFormField<FuelType>(
                value: _selectedFuelType,
                hint: const Text('Pilih Jenis BBM'),
                items: fuelTypes.map((FuelType fuel) {
                  return DropdownMenuItem<FuelType>(
                    value: fuel,
                    child: Text('${fuel.jenisBbm} (Rp ${fuel.hargaPerLiter}/L)'),
                  );
                }).toList(),
                onChanged: (FuelType? newValue) {
                  setState(() {
                    _selectedFuelType = newValue;
                  });
                  _calculateCost();
                },
                validator: (v) => v == null ? 'BBM harus dipilih' : null,
              ),
              const SizedBox(height: 16),
               TextFormField(
                controller: _literController,
                decoration: const InputDecoration(labelText: 'Jumlah Liter'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              
              Text('Total Biaya: Rp $_calculatedCost', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                ),
                child: _imageFile != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(_imageFile!, fit: BoxFit.cover))
                    : const Center(child: Text('Foto Bukti Belum Dipilih', style: TextStyle(color: Colors.grey))),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _showImagePickerOptions,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Ambil/Pilih Foto Bukti'),
              ),
              
              const SizedBox(height: 30),
              
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('SUBMIT'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}