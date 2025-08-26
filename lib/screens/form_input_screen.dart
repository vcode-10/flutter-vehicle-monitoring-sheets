import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';

class FormInputScreen extends StatefulWidget {
  const FormInputScreen({super.key});

  @override
  State<FormInputScreen> createState() => _FormInputScreenState();
}

class _FormInputScreenState extends State<FormInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _idKendaraanController = TextEditingController();
  final _namaDriverController = TextEditingController();
  final _odometerController = TextEditingController();
  final _jenisBBMController = TextEditingController();
  final _jumlahLiterController = TextEditingController();
  final _biayaController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _idKendaraanController.dispose();
    _namaDriverController.dispose();
    _odometerController.dispose();
    _jenisBBMController.dispose();
    _jumlahLiterController.dispose();
    _biayaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
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
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take with Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and provide a photo.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bytes = await _imageFile!.readAsBytes();
      String base64Image = base64Encode(bytes);
      String mimeType = _imageFile!.path.split('.').last;

      Map<String, dynamic> data = {
        'id_kendaraan': _idKendaraanController.text,
        'nama_driver': _namaDriverController.text,
        'odometer': int.parse(_odometerController.text),
        'jenis_bbm': _jenisBBMController.text,
        'jumlah_liter': double.parse(_jumlahLiterController.text),
        'biaya': int.parse(_biayaController.text),
        'foto_base64': base64Image,
        'foto_mime_type': 'image/$mimeType',
      };

      if (!mounted) return;
      await Provider.of<ReportProvider>(
        context,
        listen: false,
      ).submitReport(data);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // 4. Reset form
     Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mempersiapkan data: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input Report Form'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _idKendaraanController,
                decoration: const InputDecoration(labelText: 'Vehicle ID'),
                validator: (v) => v!.isEmpty ? 'This field is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _namaDriverController,
                decoration: const InputDecoration(labelText: 'Driver Name'),
                validator: (v) => v!.isEmpty ? 'This field is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _odometerController,
                decoration: const InputDecoration(labelText: 'Odometer (KM)'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'This field is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _jenisBBMController,
                decoration: const InputDecoration(labelText: 'Fuel Type'),
                validator: (v) => v!.isEmpty ? 'This field is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _jumlahLiterController,
                decoration: const InputDecoration(labelText: 'Liters'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) => v!.isEmpty ? 'This field is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _biayaController,
                decoration: const InputDecoration(labelText: 'Cost (Rp)'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'This field is required' : null,
              ),
              const SizedBox(height: 20),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )
                    : const Center(
                        child: Text(
                          'No photo selected',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
              ),
              const SizedBox(height: 8),

              ElevatedButton.icon(
                onPressed: _showImagePickerOptions,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take/Choose Photo'),
              ),

              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text('SUBMIT REPORT'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
