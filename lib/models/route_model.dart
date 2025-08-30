class RouteModel {
  final String idRute;
  final String namaRute;

  RouteModel({required this.idRute, required this.namaRute});

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      idRute: json['id_rute'] ?? '',
      namaRute: json['nama_rute'] ?? '',
    );
  }
}