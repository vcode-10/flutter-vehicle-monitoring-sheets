import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/trip_status_model.dart';

class TripProvider with ChangeNotifier {
  static const String _baseUrl = "https://script.google.com/macros/s/AKfycbzRiCLtVi1i_DcthKItr6OIs6phnvw5ogvV57lJDkXi18yOPlF-JOL0VMP2OAPcbTpJ/exec"; // <-- GANTI URL ANDA

  TripStatus? _currentTripStatus;
  bool _isLoading = false;

  TripStatus? get currentTripStatus => _currentTripStatus;
  bool get isLoading => _isLoading;

  Future<void> checkTripStatus(String vehicleId, String driverId) async {
  _isLoading = true;
  _currentTripStatus = null; 
  notifyListeners();
  
  try {
    final url = Uri.parse('$_baseUrl?action=getTripStatus&vehicleId=$vehicleId&driverId=$driverId');
    final response = await http.get(url);

    if (response.body.startsWith('<')) {
      throw Exception('Server returned an error page (HTML). Check Apps Script Execution Logs.');
    }

    final responseData = json.decode(response.body);

    if (responseData['status'] == 'success') {
      _currentTripStatus = TripStatus.fromJson(responseData['data']);
    } else {
      throw Exception(responseData['message'] ?? 'Failed to get trip status.');
    }

  } catch (e) {
    print("Error checking trip status: $e");
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<int> getLastOdometer(String vehicleId) async {
    final url = Uri.parse('$_baseUrl?action=getLastOdometer&vehicleId=$vehicleId');
    final response = await http.get(url);
    final responseData = json.decode(response.body)['data'];
    return (responseData['lastOdometer'] as num).toInt();
  }

  Future<void> startTrip(Map<String, dynamic> tripData) async {
    final url = Uri.parse('$_baseUrl?action=startTrip');
    await http.post(url, body: json.encode(tripData));
  }

  Future<void> addFuelLog(Map<String, dynamic> logData) async {
    final url = Uri.parse('$_baseUrl?action=addFuelLog');
    await http.post(url, body: json.encode(logData));
  }
  
  Future<void> endTrip(Map<String, dynamic> tripData) async {
    final url = Uri.parse('$_baseUrl?action=endTrip');
    await http.post(url, body: json.encode(tripData));
  }
}