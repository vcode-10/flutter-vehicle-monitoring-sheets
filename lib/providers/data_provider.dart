// lib/providers/data_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/driver_model.dart';
import '../models/fuel_type_model.dart';
import '../models/vehicle_model.dart';

class DataProvider with ChangeNotifier {
  // GANTI DENGAN URL SCRIPT ANDA
  static const String _baseUrl = "https://script.google.com/macros/s/AKfycbz7XH28u-6GsOyuU54OUsBuDZGgQ4ETIx32BtOqoaFSOKc-im7Iu02sRVQfMxA6kGSa/exec";

  List<Vehicle> _vehicles = [];
  List<Driver> _drivers = [];
  List<FuelType> _fuelTypes = [];
  bool _isLoading = false;

  List<Vehicle> get vehicles => _vehicles;
  List<Driver> get drivers => _drivers;
  List<FuelType> get fuelTypes => _fuelTypes;
  bool get isLoading => _isLoading;

  Future<void> fetchInitialData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.wait([
        fetchVehicles(),
        fetchDrivers(),
        fetchFuelTypes(),
      ]);
    } catch (error) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> fetchVehicles() async {
     final url = Uri.parse('$_baseUrl?action=getVehicles');
     final response = await http.get(url);
     final List<dynamic> data = json.decode(response.body);
     _vehicles = data.map((item) => Vehicle.fromJson(item)).toList();
     notifyListeners();
  }

  Future<void> fetchDrivers() async {
     final url = Uri.parse('$_baseUrl?action=getDrivers');
     final response = await http.get(url);
     final List<dynamic> data = json.decode(response.body);
     _drivers = data.map((item) => Driver.fromJson(item)).toList();
     notifyListeners();
  }

  Future<void> fetchFuelTypes() async {
     final url = Uri.parse('$_baseUrl?action=getFuelTypes');
     final response = await http.get(url);
     final List<dynamic> data = json.decode(response.body);
     _fuelTypes = data.map((item) => FuelType.fromJson(item)).toList();
     notifyListeners();
  }

  Future<void> updateFuelPrices(List<Map<String, dynamic>> updatedPrices) async {
    final url = Uri.parse('$_baseUrl?action=updateFuelPrices');
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedPrices),
    );
    // Refresh data setelah update
    await fetchFuelTypes();
  }
}