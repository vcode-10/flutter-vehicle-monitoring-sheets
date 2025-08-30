class Vehicle {
  final String idKendaraan;
  final String tipeMobil;

  Vehicle({required this.idKendaraan, required this.tipeMobil});

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      idKendaraan: json['id_kendaraan'] ?? '',
      tipeMobil: json['tipe_mobil'] ?? '',
    );
  }
}