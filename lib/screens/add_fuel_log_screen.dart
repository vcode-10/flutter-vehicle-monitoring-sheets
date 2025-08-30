import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';

class AddFuelLogScreen extends StatefulWidget {
  const AddFuelLogScreen({super.key});
  @override
  State<AddFuelLogScreen> createState() => _AddFuelLogScreenState();
}

class _AddFuelLogScreenState extends State<AddFuelLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kmController = TextEditingController();
  final _jenisBbmController = TextEditingController();
  final _literController = TextEditingController();
  final _biayaController = TextEditingController();
  File? _imageFile;
  final _picker = ImagePicker();
  bool _isSubmitting = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 50, maxWidth: 800);
    if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Kamera'),
            onTap: () {
              Navigator.of(context).pop();
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Galeri'),
            onTap: () {
              Navigator.of(context).pop();
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submitLog() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua field dan foto wajib diisi.')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final bytes = await _imageFile!.readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = _imageFile!.path.split('.').last;
      
      final tripId = Provider.of<TripProvider>(context, listen: false).currentTripStatus!.tripId;

      final logData = {
        'id_perjalanan': tripId,
        'km_isi_bbm': int.parse(_kmController.text),
        'jenis_bbm': _jenisBbmController.text,
        'jumlah_liter': double.parse(_literController.text),
        'biaya': int.parse(_biayaController.text),
        'foto_base64': base64Image,
        'foto_mime_type': 'image/$mimeType',
      };

      await Provider.of<TripProvider>(context, listen: false).addFuelLog(logData);
      if(mounted) Navigator.of(context).pop();
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if(mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input Log BBM')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _kmController, decoration: const InputDecoration(labelText: 'KM saat Isi BBM'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _jenisBbmController, decoration: const InputDecoration(labelText: 'Jenis BBM'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _literController, decoration: const InputDecoration(labelText: 'Jumlah Liter'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _biayaController, decoration: const InputDecoration(labelText: 'Total Biaya (Rp)'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 24),
              
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(12),
                    image: _imageFile != null ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover) : null,
                  ),
                  child: _imageFile == null 
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt_outlined, size: 40, color: Colors.grey.shade600), const SizedBox(height: 8), const Text('Ketuk untuk pilih foto')]))
                    : null,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitLog,
                child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('SIMPAN LOG'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
