class Driver {
  final String idSopir;
  final String namaSopir;

  Driver({required this.idSopir, required this.namaSopir});

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      idSopir: json['id_sopir'] ?? '',
      namaSopir: json['nama_sopir'] ?? '',
    );
  }
}