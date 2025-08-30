import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/report_model.dart';

class ReportProvider with ChangeNotifier {
  // --- STATE ---
  // Variabel privat untuk menyimpan daftar laporan dan status loading.
  List<Report> _reports = [];
  bool _isLoading = false;

  // --- GETTERS ---
  // Cara aman bagi UI untuk mengakses state tanpa bisa mengubahnya langsung.
  List<Report> get reports => _reports;
  bool get isLoading => _isLoading;

  // --- KONFIGURASI ---
  // GANTI URL INI dengan URL Web App dari Google Apps Script Anda.
  // Ini adalah bagian paling penting untuk koneksi ke backend.
  static const String _baseUrl =
      'https://script.google.com/macros/s/AKfycby8x49wFg9uFBaK1FUv-ETA6SaB6fdZ0h0OoAjnKcFwJmUUVY78L77y1DzjgYf6bB6p/exec';

  // --- ACTIONS ---

  /// Mengambil semua laporan yang diinput pada hari ini dari Google Sheet.
  Future<void> fetchTodaysReports(String driverName) async {
    _isLoading = true;
    _reports = []; // Kosongkan list sebelum fetch data baru
    notifyListeners();

    // Tambahkan parameter driverName ke URL
    final url = Uri.parse('$_baseUrl?action=getTodaysReports&driverName=$driverName');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> extractedData = json.decode(response.body);
        _reports = extractedData.map((item) => Report.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat laporan.');
      }
    } catch (error) {
      print("Error fetching reports: $error");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mengirim satu laporan baru ke Google Sheet.
  /// Menerima [reportData] dalam bentuk Map yang berisi semua field dari form.
  Future<void> submitReport(Map<String, dynamic> reportData) async {
    final url = Uri.parse('$_baseUrl?action=addReport');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reportData),
      );

      print('Request to submit report has been sent.');
    } catch (error) {
      // Hanya akan menangkap error jika gagal mengirim (misal: tidak ada internet)
      print("Error attempting to send report: $error");
    }
  }
}
