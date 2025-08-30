import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/driver_model.dart';
import '../models/route_model.dart';
import '../models/vehicle_model.dart';

class DataProvider with ChangeNotifier {
  static const String _baseUrl = "https://script.google.com/macros/s/AKfycbzRiCLtVi1i_DcthKItr6OIs6phnvw5ogvV57lJDkXi18yOPlF-JOL0VMP2OAPcbTpJ/exec"; // <-- GANTI URL ANDA

  List<Vehicle> _vehicles = [];
  List<Driver> _drivers = [];
  List<RouteModel> _routes = [];
  bool _isLoading = false;

  List<Vehicle> get vehicles => _vehicles;
  List<Driver> get drivers => _drivers;
  List<RouteModel> get routes => _routes;
  bool get isLoading => _isLoading;

  Future<void> fetchInitialData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final url = Uri.parse('$_baseUrl?action=getInitialData');
      final response = await http.get(url);
      final responseData = json.decode(response.body)['data'];
      
      _vehicles = (responseData['vehicles'] as List).map((item) => Vehicle.fromJson(item)).toList();
      _drivers = (responseData['drivers'] as List).map((item) => Driver.fromJson(item)).toList();
      _routes = (responseData['routes'] as List).map((item) => RouteModel.fromJson(item)).toList();

    } catch (error) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}