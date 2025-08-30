class FuelType {
  final String jenisBbm;
  final int hargaPerLiter;

  FuelType({required this.jenisBbm, required this.hargaPerLiter});

  factory FuelType.fromJson(Map<String, dynamic> json) {
    return FuelType(
      jenisBbm: json['jenis_bbm'] ?? '',
      hargaPerLiter: (json['harga_per_liter'] as num?)?.toInt() ?? 0,
    );
  }
}