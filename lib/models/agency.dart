// lib/models/agency.dart
class Agency {
  final int id;
  final String name;

  Agency({
    required this.id,
    required this.name,
  });

  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
      id: json['id'],
      name: json['agency'] ?? 'N/A', // 'agency' คือ key จาก API
    );
  }
}