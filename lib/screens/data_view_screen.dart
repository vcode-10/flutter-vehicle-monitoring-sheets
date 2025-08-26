import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/report_model.dart';
import '../providers/report_provider.dart';

class DataViewScreen extends StatefulWidget {
  const DataViewScreen({super.key});

  @override
  State<DataViewScreen> createState() => _DataViewScreenState();
}

class _DataViewScreenState extends State<DataViewScreen> {
  late Future<void> _fetchReportsFuture;

  @override
  void initState() {
    super.initState();
    _fetchReportsFuture = _fetchReports();
  }

  Future<void> _fetchReports() {
    return Provider.of<ReportProvider>(context, listen: false).fetchTodaysReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Hari Ini'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() { _fetchReportsFuture = _fetchReports(); }),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _fetchReportsFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          } else {
            return Consumer<ReportProvider>(
              builder: (ctx, reportProvider, child) {
                if (reportProvider.reports.isEmpty) {
                  return const Center(child: Text('Belum ada laporan untuk hari ini.'));
                }
                return ListView.builder(
                  itemCount: reportProvider.reports.length,
                  itemBuilder: (ctx, index) {
                    final Report report = reportProvider.reports[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  report.fotoUrl, 
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(report.namaDriver, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
                                  Text(report.idKendaraan, style: TextStyle(color: Colors.grey[700])), 
                                  const SizedBox(height: 8),
                                  Text('Odometer: ${report.odometer} KM'), 
                                  Text('${report.jenisBbm}: ${report.jumlahLiter} L'), 
                                  Text('Biaya: Rp ${report.biaya.toString()}'), 
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(report.timestamp, style: TextStyle(color: Colors.grey[600], fontSize: 12)), 
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}