// lib/providers/selection_provider.dart

import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../models/vehicle_model.dart';

class SelectionProvider with ChangeNotifier {
  Vehicle? _selectedVehicle;
  Driver? _selectedDriver;

  Vehicle? get selectedVehicle => _selectedVehicle;
  Driver? get selectedDriver => _selectedDriver;

  void setSelection(Vehicle vehicle, Driver driver) {
    _selectedVehicle = vehicle;
    _selectedDriver = driver;
    notifyListeners();
  }
}