class Report {
  final String idKendaraan;
  final String namaDriver;
  final int odometer;
  final String jenisBbm;
  final double jumlahLiter;
  final int biaya;
  final String fotoUrl;
  final String timestamp;

  Report({
    required this.idKendaraan,
    required this.namaDriver,
    required this.odometer,
    required this.jenisBbm,
    required this.jumlahLiter,
    required this.biaya,
    required this.fotoUrl,
    required this.timestamp,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      idKendaraan: json['id_kendaraan'] ?? 'N/A',
      namaDriver: json['nama_driver'] ?? 'N/A',
      odometer: (json['odometer'] as num?)?.toInt() ?? 0,
      jenisBbm: json['jenis_bbm'] ?? 'N/A',
      jumlahLiter: (json['jumlah_liter'] as num?)?.toDouble() ?? 0.0,
      biaya: (json['biaya'] as num?)?.toInt() ?? 0,
      fotoUrl: json['foto_url'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}