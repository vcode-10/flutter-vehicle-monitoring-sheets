// lib/screens/data_view_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';
import '../providers/selection_provider.dart';

class DataViewScreen extends StatefulWidget {
  const DataViewScreen({super.key});

  @override
  State<DataViewScreen> createState() => _DataViewScreenState();
}

class _DataViewScreenState extends State<DataViewScreen> {
  Future? _reportsFuture;
  String? _selectedVehicleType;

  @override
  void initState() {
    super.initState();
    final driverName = Provider.of<SelectionProvider>(context, listen: false).selectedDriver!.namaSopir;
    _reportsFuture = Provider.of<ReportProvider>(context, listen: false).fetchTodaysReports(driverName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Hari Ini'),
      ),
      body: FutureBuilder(
        future: _reportsFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }
          return Consumer<ReportProvider>(
            builder: (ctx, reportProvider, child) {
              if (reportProvider.reports.isEmpty) {
                return const Center(child: Text('Tidak ada laporan untuk sopir ini.'));
              }
              
              final allReports = reportProvider.reports;
              final vehicleTypes = allReports.map((r) => r.idKendaraan.split(' ')[0]).toSet().toList(); // Ambil tipe mobil unik
              final filteredReports = _selectedVehicleType == null
                  ? allReports
                  : allReports.where((r) => r.idKendaraan.startsWith(_selectedVehicleType!)).toList();

              return Column(
                children: [
                  // Widget Filter
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<String>(
                      value: _selectedVehicleType,
                      hint: const Text('Filter berdasarkan Tipe Mobil'),
                      items: vehicleTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedVehicleType = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        suffixIcon: _selectedVehicleType != null ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _selectedVehicleType = null;
                            });
                          },
                        ) : null
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredReports.length,
                      itemBuilder: (ctx, index) {
                        final report = filteredReports[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(report.idKendaraan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 8),
                                Text('Odometer: ${report.odometer} KM'),
                                Text('${report.jenisBbm}: ${report.jumlahLiter} L'),
                                Text('Biaya: Rp ${report.biaya.toString()}'),
                                const SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    report.timestamp,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}