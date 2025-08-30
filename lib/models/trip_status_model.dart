class TripStatus {
  final bool tripExists;
  final String? tripId;
  final bool isFinished;

  TripStatus({required this.tripExists, this.tripId, required this.isFinished});

  factory TripStatus.fromJson(Map<String, dynamic> json) {
    return TripStatus(
      tripExists: json['tripExists'] ?? false,
      tripId: json['tripId'],
      isFinished: json['isFinished'] ?? false,
    );
  }
}